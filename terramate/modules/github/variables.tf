variable "organization" {
  description = "github organization to use"
  type        = string
}

variable "repositories" {
  description = "Map of repositories to manage"
  type = map(object({
    description            = optional(string)
    has_downloads          = optional(bool)
    has_issues             = optional(bool)
    has_projects           = optional(bool)
    has_wiki               = optional(bool)
    archived               = optional(bool)
    allow_merge_commit     = optional(bool)
    allow_rebase_merge     = optional(bool)
    allow_squash_merge     = optional(bool)
    visibility             = optional(string)
    vulnerability_alerts   = optional(bool)
    delete_branch_on_merge = optional(bool)
    archive_on_destroy     = optional(bool)
    homepage_url           = optional(string)
    branches = optional(map(object({
      push_restrictions  = optional(list(string))
      merge_restrictions = optional(bool)
      required_status_checks = optional(object({
        strict   = optional(bool)
        contexts = optional(list(string))
      }))
    })))
    pages = optional(object({
      source = object({
        branch = string
        path   = optional(string)
      })
    }))
    github_repository_webhooks = optional(list(object({
      name = string
      configuration = object({
        url          = string
        content_type = string
        insecure_ssl = bool
        secret       = optional(string)
      })
      active = optional(bool)
      events = list(string)
    })))
    secrets = optional(map(string))
  }))
}

variable "teams" {
  description = "Map of teams to manage"
  type = map(object({
    description      = optional(string)
    parent_team_name = optional(string)
    privacy          = optional(string)
    repositories     = optional(map(list(string)))
    roles = object({
      maintainer = list(string)
      member     = list(string)
    })
  }))
}

variable "debug" {
  description = "Enable debug output"
  type        = bool
  default     = false
}

variable "sops-secrets" {
  description = "Map of secrets from SOPS"
  type        = map(string)
  sensitive   = true
}
