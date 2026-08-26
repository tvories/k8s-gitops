terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.5.1"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "8.0.0"
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
