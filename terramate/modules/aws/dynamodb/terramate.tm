generate_hcl "_terramate_generated_main.tf" {
  content {
    module "dynamodb" {
      source      = "${terramate.stack.path.to_root}/terramate/modules/aws/dynamodb"
      name        = global.name
      region      = global.aws_region
      namespace   = global.namespace
      stage       = global.stage
      environment = global.environment

    }
  }
}
