terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.12.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.1.2"
    }
    google = {
      source  = "hashicorp/google"
      version = "7.18.0"
    }
  }
  backend "gcs" {
    bucket = "tvo-homelab-tfstate"
    prefix = "terraform/state/authentik"
  }
}

provider "authentik" {
  url   = var.authentik_url
  token = var.authentik_token
}
