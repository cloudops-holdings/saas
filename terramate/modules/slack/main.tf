locals {
  slack_api_token = data.sops_file.secrets.data["terraform_slack_token"]
  team_members    = { for team_name, team_data in var.teams : team_name => setsubtract(concat(team_data.roles.maintainer, team_data.roles.member), var.github_users_who_arent_in_slack) }

  slack_groups = flatten([
    for key, value in local.team_members : {
      name   = key
      handle = var.teams[key].slug
      users = compact([
        for i in value : data.slack_user.all[var.email_lookup[i]].id
      ])
    } if !try(var.teams[key]["exclude_from_slack"], false) && value != null && length(compact(value)) > 0
  ])

  all_github_accounts = distinct(flatten([for key, value in local.team_members : value]))
  all_emails          = [for i in local.all_github_accounts : var.email_lookup[i]]
}

data "slack_user" "all" {
  for_each = toset(local.all_emails)
  email    = each.value
}

resource "slack_usergroup" "groups" {
  for_each = {
    for group in local.slack_groups : "${group.name}" => group
  }
  name        = each.key
  handle      = each.value.handle
  description = try(each.value.description, "")
  users       = each.value.users
}

output "slack_groups" {
  value = var.debug ? local.slack_groups : null
}

output "team_members" {
  value = var.debug ? local.team_members : null
}
