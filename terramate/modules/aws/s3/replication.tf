locals {
  s3_replication_enabled = var.s3_replication_enabled
  s3_replication_rules = local.s3_replication_enabled ? [
    {
      id                 = "replication-test-explicit-bucket"
      status             = "Enabled"
      prefix             = "/extra"
      priority           = 5
      destination_bucket = module.s3_bucket_replication_target_extra[0].bucket_arn
      destination = {
        account_id = local.account_id
        metrics = {
          status = null
        }
      }
    },
    {
      id                 = "replication-test-metrics"
      status             = "Enabled"
      prefix             = "/with-metrics"
      priority           = 10
      destination_bucket = null
      destination = {
        account_id = local.account_id
        metrics = {
          status = "Enabled"
        }
      }
    }
  ] : []
}

module "s3_bucket_replication_target" {
  count = local.s3_replication_enabled ? 1 : 0

  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=f78000572fcb827456e20c4d110f133f2baef31a"

  user_enabled                = true
  acl                         = "private"
  force_destroy               = true
  versioning_enabled          = true
  s3_replication_source_roles = [module.s3.replication_role_arn]

  attributes = ["target"]
  context    = module.this.context
}

module "s3_bucket_replication_target_extra" {
  count = local.s3_replication_enabled ? 1 : 0

  source = "git::https://github.com/cloudposse/terraform-aws-s3-bucket.git?ref=f78000572fcb827456e20c4d110f133f2baef31a"

  user_enabled                = true
  acl                         = "private"
  force_destroy               = true
  versioning_enabled          = true
  s3_replication_source_roles = [module.s3.replication_role_arn]

  attributes = ["target", "extra"]
  context    = module.this.context
}
