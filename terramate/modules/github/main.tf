#!!!!!!!!!!!!!
#! Organization: Membership
#!!!!!!!!!!!!!

locals {
  admin-array = concat(
    var.teams["Team Leads"]["roles"]["maintainer"],
    var.teams["DevOps"]["roles"]["maintainer"],
    var.teams["Executive"]["roles"]["maintainer"],
    var.teams["Executive"]["roles"]["member"],
  )

  organization-members = distinct(flatten([
    for team in keys(var.teams) : [
      for roletype in keys(var.teams[team]["roles"]) : [
        for username in var.teams[team]["roles"][roletype] : {
          username = username
          role     = (contains(local.admin-array, username) ? "admin" : "member")
        }
      ]
    ]
  ]))
}

output "local-organization-members" {
  value = var.debug ? local.organization-members : []
}

resource "github_membership" "membership" {
  for_each = {
    for membership in local.organization-members : "${var.organization}:${membership.username}" => membership
  }
  username = each.value.username
  role     = each.value.role
}

output "organization_members" {
  value       = var.debug ? local.organization-members : []
  description = "List of organization members"
}

output "github_memberships" {
  value       = var.debug ? github_membership.membership : {}
  description = "GitHub memberships"
}

#!!!!!!!!!!!!!
#! Repository: Create
#!!!!!!!!!!!!!

resource "github_repository" "repositories" {
  for_each               = toset(keys(var.repositories))
  name                   = each.value
  description            = try(var.repositories[each.value]["description"], "")
  has_downloads          = try(var.repositories[each.value]["has_downloads"], false)
  has_issues             = try(var.repositories[each.value]["has_issues"], false)
  has_projects           = try(var.repositories[each.value]["has_projects"], false)
  has_wiki               = try(var.repositories[each.value]["has_wiki"], false)
  archived               = try(var.repositories[each.value]["archived"], false)
  allow_merge_commit     = try(var.repositories[each.value]["allow_merge_commit"], true)
  allow_rebase_merge     = try(var.repositories[each.value]["allow_rebase_merge"], true)
  allow_squash_merge     = try(var.repositories[each.value]["allow_squash_merge"], true)
  visibility             = try(var.repositories[each.value]["visibility"], "private")
  delete_branch_on_merge = try(var.repositories[each.value]["delete_branch_on_merge"], false)
  homepage_url           = try(var.repositories[each.value]["homepage_url"], "")

  dynamic "pages" {
    for_each = [
      for exists in ["exists"] : exists
      if try(var.repositories[each.value]["pages"], null) != null
    ]

    content {
      source {
        branch = try(var.repositories[each.value]["pages"]["source"]["branch"], null)
        path   = try(var.repositories[each.value]["pages"]["source"]["path"], null)
      }
    }
  }

}

output "github_repositories" {
  value       = var.debug ? github_repository.repositories : {}
  description = "GitHub repositories"
}

#!!!!!!!!!!!!!
#! Repository: Team permissions
#!!!!!!!!!!!!!

locals {
  repository_permissions = flatten([
    for team in keys(var.teams) : [
      for permission in try(keys(var.teams[team]["repositories"]), []) : [
        for repository in var.teams[team]["repositories"][permission] : {
          team       = team
          repository = repository
          permission = permission
        }
      ]
    ]
  ])
}

resource "github_team_repository" "memberships" {
  for_each = {
    for memberships in local.repository_permissions : "${base64encode(memberships.team)}:${memberships.repository}" => memberships
  }

  team_id    = github_team.teams[base64encode(each.value.team)].id
  repository = each.value.repository
  permission = each.value.permission

  depends_on = [
    github_repository.repositories
  ]
}

output "github_team_repositories" {
  value       = var.debug ? github_team_repository.memberships : {}
  description = "GitHub team repository memberships"
}

#!!!!!!!!!!!!!
#! Repos: Branch Permissions
#!!!!!!!!!!!!!

locals {
  branch_protections = flatten([
    for repository in keys(var.repositories) : [
      for branch in try(keys(var.repositories[repository]["branches"]), []) : {
        repository         = repository
        branch             = branch
        push_restrictions  = try(var.repositories[repository]["branches"][branch]["push_restrictions"], [])
        merge_restrictions = try(var.repositories[repository]["branches"][branch]["merge_restrictions"], true)
      }
    ]
  ])
}

resource "github_branch_protection" "branch_protections" {
  for_each = {
    for protections in local.branch_protections : "${replace(lower(protections.repository), " ", "-")}:${protections.branch}" => protections
  }

  repository_id = replace(lower(each.value.repository), " ", "-")
  pattern       = each.value.branch

  dynamic "required_pull_request_reviews" {
    for_each = coalesce(each.value.merge_restrictions, true) ? [true] : []
    content {
      dismiss_stale_reviews           = true
      required_approving_review_count = 1
    }
  }

  dynamic "required_status_checks" {
    for_each = try(var.repositories[each.value.repository]["branches"][each.value.branch]["required_status_checks"], null) != null ? [true] : []
    content {
      strict   = try(var.repositories[each.value.repository]["branches"][each.value.branch]["required_status_checks"]["strict"], false)
      contexts = try(var.repositories[each.value.repository]["branches"][each.value.branch]["required_status_checks"]["contexts"], [])
    }
  }

  push_restrictions = each.value.push_restrictions != null ? [
    for node_id in each.value.push_restrictions :
    github_team.teams[base64encode(node_id)].node_id
  ] : null

  depends_on = [
    github_team_repository.memberships,
    github_repository.repositories
  ]
}

output "github_branch_protections" {
  value       = var.debug ? github_branch_protection.branch_protections : {}
  description = "GitHub branch protections"
}

#!!!!!!!!!!!!!
#! Repos: Repository Webhooks
#!!!!!!!!!!!!!

locals {
  repository_webhooks = flatten([
    for repo, repo_config in var.repositories :
    [
      for webhook in lookup(repo_config, "github_repository_webhooks", []) : {
        repository   = replace(lower(repo), " ", "-")
        name         = webhook.name
        url          = try(var.sops-secrets[webhook.configuration.url], local.http_secrets[webhook.configuration.url])
        content_type = webhook.configuration.content_type
        insecure_ssl = webhook.configuration.insecure_ssl
        secret       = try(var.sops-secrets[webhook.configuration.secret], null)
        active       = lookup(webhook, "active", null)
        events       = webhook.events
      }
    ]
    if lookup(repo_config, "github_repository_webhooks", null) != null
  ])
}

resource "github_repository_webhook" "repository_webhooks" {
  for_each = {
    for webhook in local.repository_webhooks : "${webhook.repository}:${webhook.name}" => webhook
  }

  repository = each.value.repository

  configuration {
    url          = each.value.url
    content_type = each.value.content_type
    insecure_ssl = each.value.insecure_ssl
    secret       = each.value.secret
  }

  active = each.value.active
  events = each.value.events
}

output "github_repository_webhooks" {
  value       = var.debug ? github_repository_webhook.repository_webhooks : {}
  description = "GitHub repository webhooks"
}

#!!!!!!!!!!!!!
#! Teams: Create
#!!!!!!!!!!!!!

locals {
  teams = flatten([
    for team in keys(var.teams) : {
      team        = team
      team_encode = base64encode(team)
    }
  ])
  parent_team_names = compact(distinct(flatten([
    for team in keys(var.teams) : try(var.teams[team].parent_team_name, "")
  ])))
}

output "test" {
  value = local.parent_team_names
}

data "github_team" "parent" {
  for_each = toset(local.parent_team_names)
  slug     = each.value
}

resource "github_team" "teams" {
  for_each = {
    for team in local.teams : team.team_encode => team
  }
  name           = each.value.team
  description    = try(var.teams[each.value.team]["description"], "")
  parent_team_id = try(data.github_team.parent[var.teams[each.value.team]["parent_team_name"]].id, null)
  privacy        = "closed"
}

output "github_teams" {
  value       = var.debug ? github_team.teams : {}
  description = "GitHub teams"
}

#!!!!!!!!!!!!!
#! Teams: Membership
#!!!!!!!!!!!!!

locals {
  team-membership = flatten([
    for team in keys(var.teams) : [
      for role in keys(var.teams[team]["roles"]) : [
        for username in var.teams[team]["roles"][role] : {
          team     = team
          username = username
          role     = role
        }
      ]
      if try(var.teams[team]["roles"], null) != null
    ]
  ])
}

resource "github_team_membership" "membership" {
  for_each = {
    for memberships in local.team-membership : "${base64encode(memberships.team)}:${memberships.username}" => memberships
  }

  team_id  = github_team.teams[base64encode(each.value.team)].id
  username = each.value.username
  role     = each.value.role
}

output "github_team_memberships" {
  value       = var.debug ? github_team_membership.membership : {}
  description = "GitHub team memberships"
}
