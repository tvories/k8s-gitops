terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.12.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.2.1"
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
