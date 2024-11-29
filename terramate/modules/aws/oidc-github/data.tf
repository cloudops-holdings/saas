data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test = "StringLike"
      values = [
        for org in distinct(var.github_organizations) :
        "repo:${org}/*:*"
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }

  version = "2012-10-17"
}

data "aws_iam_openid_connect_provider" "github" {
  count = var.enabled && !var.create_oidc_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

locals {
  github_cert_thumbprints = [for cert in data.tls_certificate.github.certificates : cert.sha1_fingerprint]
}
