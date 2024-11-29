locals {
  oidc_provider_arn = var.enabled ? (var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : data.aws_iam_openid_connect_provider.github[0].arn) : ""
  partition         = data.aws_partition.current.partition
}

resource "aws_iam_role" "github" {
  count = var.enabled ? 1 : 0

  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json
  description           = "Role assumed by the GitHub runners"
  force_detach_policies = var.force_detach_policies
  max_session_duration  = var.max_session_duration
  name                  = var.iam_role_name
  path                  = var.iam_role_path
  permissions_boundary  = var.iam_role_permissions_boundary
  tags                  = var.tags

  dynamic "inline_policy" {
    for_each = var.iam_role_inline_policies

    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }
}

resource "aws_iam_role_policy_attachment" "custom" {
  count = var.enabled ? length(var.iam_role_policy_arns) : 0

  policy_arn = var.iam_role_policy_arns[count.index]
  role       = aws_iam_role.github[0].id
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enabled && var.create_oidc_provider ? 1 : 0

  client_id_list = concat(
    distinct([for org in var.github_organizations : "https://github.com/${org}"]),
    ["sts.amazonaws.com"]
  )

  tags            = var.tags
  thumbprint_list = local.github_cert_thumbprints
  url             = "https://token.actions.githubusercontent.com"
}
