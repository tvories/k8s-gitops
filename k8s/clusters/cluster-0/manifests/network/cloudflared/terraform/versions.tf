terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.24.0"
    }
  }
  backend "gcs" {
    bucket = "tvo-homelab-tfstate"
    prefix = "terraform/state/cloudflared"
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
