terraform {
  required_providers {
    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.1"
    }
  }
}
