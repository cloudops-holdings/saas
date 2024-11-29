locals {

  secrets-map = flatten([
    for repository in keys(var.repositories) : [
      for secret_name in keys(var.repositories[repository]["secrets"]) : {
        secret_name     = secret_name
        plaintext_value = var.repositories[repository]["secrets"][secret_name]
        repository      = repository
      }
      if lookup(var.repositories[repository], "secrets", null) != null
    ]
  ])

  secret_configs = {
    changeme = "something"
  }

  http_secrets = {
    for key, value in local.secret_configs :
    "${key}_gke_sa_key" => jsondecode(data.http.secrets[key].body)["terraform"]
  }

  bucket_name = "gcp-bucket"
}

data "google_client_config" "current" {}

data "google_storage_bucket_object" "secrets" {
  for_each = local.secret_configs
  name     = "outputs/project/${each.value}/secrets"
  bucket   = local.bucket_name
}

data "http" "secrets" {
  for_each = local.secret_configs
  url      = data.google_storage_bucket_object.secrets[each.key].media_link
  request_headers = {
    Authorization = "Bearer ${data.google_client_config.current.access_token}"
  }
}

resource "github_actions_secret" "secrets" {
  for_each = {
    for secrets in local.secrets-map : "${secrets.repository}:${secrets.secret_name}" => secrets
  }

  repository      = each.value.repository
  secret_name     = each.value.secret_name
  plaintext_value = try(var.sops-secrets[each.value.plaintext_value], local.http_secrets[each.value.plaintext_value])

  depends_on = [
    github_repository.repositories
  ]
}
