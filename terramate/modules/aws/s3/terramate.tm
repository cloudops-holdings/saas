generate_hcl "_terramate_generated_main.tf" {
  content {
    module "s3" {
      source      = "${terramate.stack.path.to_root}/terramate/modules/aws/s3"
      name        = global.name
      region      = global.aws_region
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

      acl                    = global.acl
      force_destroy          = global.force_destroy
      user_enabled           = global.user_enabled
      versioning_enabled     = global.versioning_enabled
      allowed_bucket_actions = global.allowed_bucket_actions
      bucket_key_enabled     = global.bucket_key_enabled
      minimum_tls_version    = global.minimum_tls_version
    }
  }
}
