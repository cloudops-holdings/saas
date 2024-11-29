generate_hcl "_terramate_generated_backend.tf" {
  content {
    terraform {
      backend "gcs" {
        bucket = global.terraform_bucket
        prefix = global.terraform_key
      }
    }
  }
}
