generate_hcl "_terramate_generated_providers.tf" {
  content {
    provider "google" {
      project = global.project_id
      region  = global.region
    }

    provider "google-beta" {
      project = global.project_id
      region  = global.region
    }

    terraform {
      required_providers {

        aws = {
          version = "4.84.0"
        }

        null = {
          version = "4.84.0"
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

        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "2.13.1"
        }

        mongodbatlas = {
          source  = "mongodb/mongodbatlas"
          version = "1.4.3"
        }
      }

      required_version = global.terraform_version
    }
  }
}
