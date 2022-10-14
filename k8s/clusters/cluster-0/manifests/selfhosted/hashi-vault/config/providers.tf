terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.7"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.9.1"
    }
  }
}
