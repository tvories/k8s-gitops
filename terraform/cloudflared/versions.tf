terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.28.1"
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
