globals {
  repo_name = "saas"

  terraform_version  = ">= 1.2.0"
  terraform_bucket   = "${global.namespace}-${global.environment}-${global.stage}-terraform-state"
  terraform_key      = "terraform-saas/terraform.tfstate"
  domain             = "cloudops.holdings"
  company            = "cloudops"
  state_name         = "terraform"
  environment_domain = "${global.aws_region}-${global.environment}.${global.cloud}.${global.domain}"

}
