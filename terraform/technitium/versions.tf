terraform {
  required_providers {
    technitium = {
      # darkhonor's provider: actively maintained, full DHCP scope coverage.
      # Replaced kenske/technitium (stalled since 2025; DHCP options needed an
      # unmerged PR). Its STIG validation is opt-in and not enabled here.
      source  = "darkhonor/technitium"
      version = "1.3.0"
    }
  }
  backend "gcs" {
    bucket = "tvo-homelab-tfstate"
    prefix = "terraform/state/technitium"
  }
}

variable "technitium_token" {
  type      = string
  sensitive = true
}

provider "technitium" {
  server_url = var.technitium_url
  api_token  = var.technitium_token
}
