generate_hcl "_terramate_generated_providers.tf" {
  content {
    provider "aws" {
      region = global.aws_region
    }

    terraform {
      required_providers {

        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
        null = {
          source  = "hashicorp/null"
          version = ">= 2.0"
        }
        random = {
          version = "= 3.4.2"
        }
        template = {
          version = "= 2.2.0"
        }

        http = {
          version = "= 3.1.0"
        }
        sops = {
          version = "= 0.7.1"
          source  = "carlpett/sops"
        }
        cloudflare = {
          source  = "cloudflare/cloudflare"
          version = "3.23.0"
        }
        time = {
          source  = "hashicorp/time"
          version = ">= 0.7"
        }
        awsutils = {
          source  = "cloudposse/awsutils"
          version = ">= 0.11.0"
        }

      }

      required_version = global.terraform_version
    }
  }
}
