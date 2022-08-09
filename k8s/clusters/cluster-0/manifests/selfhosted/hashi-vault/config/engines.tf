resource "vault_ad_secret_backend" "config" {
  backend         = "ad"
  binddn          = data.sops_file.secrets.data["ldap_bind_user"]
  bindpass        = data.sops_file.secrets.data["ldap_bind_password"]
  url             = data.sops_file.secrets.data["ldap_url"]
  userdn          = data.sops_file.secrets.data["ldap_auth_user_dn"]
  insecure_tls    = true
  starttls        = true
  password_policy = vault_password_policy.ad.id
}

resource "vault_ad_secret_role" "packer" {
  backend              = vault_ad_secret_backend.config.backend
  role                 = "packer"
  service_account_name = "packer@${data.sops_file.secrets.data["local_domain"]}"
  ttl                  = 60
}

resource "vault_ad_secret_role" "terraform" {
  backend              = vault_ad_secret_backend.config.backend
  role                 = "terraform"
  service_account_name = "terraform@${data.sops_file.secrets.data["local_domain"]}"
  ttl                  = 60
}
