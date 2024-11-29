variable "github_users_who_arent_in_slack" {
  description = "List of GitHub users who are not in Slack"
  type        = list(string)
}

variable "email_lookup" {
  description = "Map of GitHub usernames to email addresses"
  type        = map(string)
}

variable "organization" {
  description = "GitHub organization to use"
  type        = string
}

variable "teams" {
  description = "Map of teams to manage"
  type = map(object({
    slug        = string
    description = optional(string)
    roles = object({
      maintainer = list(string)
      member     = list(string)
    })
    exclude_from_slack = optional(bool)
  }))
}

variable "debug" {
  description = "Enable debug output"
  type        = bool
  default     = false
}

variable "sops_secrets_file" {
  description = "Path to the SOPS encrypted secrets file"
  type        = string
}
