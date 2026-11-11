terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2026.8.2"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.4.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "8.11.0"
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
