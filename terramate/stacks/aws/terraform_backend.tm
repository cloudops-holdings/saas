generate_hcl "_terramate_generated_backend.tf" {
  content {
    terraform {
      backend "s3" {
        bucket         = global.terraform_bucket
        key            = global.terraform_key
        region         = global.aws_region
        dynamodb_table = ""
      }
    }
  }
}
