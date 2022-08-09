terraform {
  backend "gcs" {
    bucket      = "tvo-homelab-tfstate"
    prefix      = "terraform/state/hashi-vault"
    credentials = "/home/tadmin/gits/homelab/terraform/keys/terraform.json"
  }
}

# This is used for the initial connection to bootstrap vault.  Uncomment for first use
# Use the approle once first use has been created
# provider "vault" {
#   address = "https://hashi-vault.t-vo.us"
#   token = data.sops_file.secrets.data["vault_token"]
# }

# This is block to be used after bootstrap.  Leverage the terraform approle
provider "vault" {
  address = "https://hashi-vault.${data.sops_file.secrets.data["external_domain"]}"
  auth_login {
    path = "auth/approle/login"

    parameters = {
      "role_id"   = data.sops_file.secrets.data["terraform_app_role"]
      "secret_id" = data.sops_file.secrets.data["terraform_secret_id"]
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secret.sops.yaml"
}

resource "vault_ldap_auth_backend_user" "taylor" {
  username = "taylor"
  policies = [
    "admin"
  ]
  backend = vault_ldap_auth_backend.ldap.path
}

resource "vault_approle_auth_backend_role" "terraform" {
  backend        = vault_auth_backend.approle.path
  role_name      = "terraform"
  token_policies = ["admin"]
}

resource "vault_approle_auth_backend_role_secret_id" "terraform" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.terraform.role_name
}

resource "vault_approle_auth_backend_login" "terraform" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.terraform.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.terraform.secret_id
}
