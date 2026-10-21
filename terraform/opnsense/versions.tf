terraform {
  required_providers {
    opnsense = {
      source  = "browningluke/opnsense"
      version = "0.26.0"
    }
  }
  backend "gcs" {
    bucket = "tvo-homelab-tfstate"
    prefix = "terraform/state/opnsense"
  }
}

# URI and credentials come from the environment (OPNSENSE_URI /
# OPNSENSE_API_KEY / OPNSENSE_API_SECRET), which `just tf` loads from
# .env_vars via `op run`.
provider "opnsense" {}
