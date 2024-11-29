terraform {

  required_providers {
    slack = {
      source  = "pablovarela/slack"
      version = "1.1.27"
    }

    sops = {
      version = "= 0.7.2"
      source  = "carlpett/sops"
    }

    http = {
      version = "= 2.1.0"
    }

    google = {
      version = "= 3.71.0"
    }

    github = {
      version = "= 4.17.0"
      source  = "integrations/github"
    }
  }
}
