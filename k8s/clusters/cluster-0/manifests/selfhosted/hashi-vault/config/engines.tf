# AD/LDAP secret backend - commented out, no longer using AD
# resource "vault_ldap_secret_backend" "config" {
#   path            = "ad"
#   binddn          = var.ldap_bind_user
#   bindpass        = var.ldap_bind_password
#   url             = var.ldap_url
#   userdn          = var.ldap_auth_user_dn
#   insecure_tls    = true
#   starttls        = true
#   password_policy = vault_password_policy.ad.id
# }

# resource "vault_ldap_secret_backend_static_role" "packer" {
#   mount           = vault_ldap_secret_backend.config.path
#   username        = "packer"
#   role_name       = "packer"
#   dn              = "CN=packer,${var.ad_backend_userdn}"
#   rotation_period = 60
# }

# resource "vault_ldap_secret_backend_static_role" "terraform" {
#   mount           = vault_ldap_secret_backend.config.path
#   username        = "terraform"
#   role_name       = "terraform"
#   dn              = "CN=terraform,${var.ad_backend_userdn}"
#   rotation_period = 60
# }
