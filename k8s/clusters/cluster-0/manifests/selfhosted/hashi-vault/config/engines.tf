resource "vault_ldap_secret_backend" "config" {
  path            = "ad"
  binddn          = data.sops_file.secrets.data["ldap_bind_user"]
  bindpass        = data.sops_file.secrets.data["ldap_bind_password"]
  url             = data.sops_file.secrets.data["ldap_url"]
  userdn          = data.sops_file.secrets.data["ldap_auth_user_dn"]
  insecure_tls    = true
  starttls        = true
  password_policy = vault_password_policy.ad.id
}

resource "vault_ldap_secret_backend_static_role" "packer" {
  mount           = vault_ldap_secret_backend.config.path
  username        = "packer"
  role_name       = "packer"
  dn              = "CN=packer,${data.sops_file.secrets.data["ad_backend_userdn"]}"
  rotation_period = 60
}

resource "vault_ldap_secret_backend_static_role" "terraform" {
  mount           = vault_ldap_secret_backend.config.path
  username        = "terraform"
  role_name       = "terraform"
  dn              = "CN=terraform,${data.sops_file.secrets.data["ad_backend_userdn"]}"
  rotation_period = 60
}
