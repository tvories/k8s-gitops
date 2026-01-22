terraform {
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = "2025.12.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }
  }
}

provider "authentik" {
  # url   = var.authentik_url
  url = "https://authentik.t-vo.us"
  token = var.authentik_token
  # token = "irevokedmylasttokensorry"
}
