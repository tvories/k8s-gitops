variable "external_domain" {
  description = "The external domain for Vault."
  type        = string
}

variable "vault_oidc_client_id" {
  description = "The OIDC client ID for Vault in Authentik."
  type        = string
}

variable "vault_oidc_client_secret" {
  description = "The OIDC client secret for Vault in Authentik."
  type        = string
  sensitive   = true
}

variable "terraform_app_role" {
  description = "The Terraform AppRole role ID."
  type        = string
}

variable "terraform_secret_id" {
  description = "The Terraform AppRole secret ID."
  type        = string
  sensitive   = true
}

# AD/LDAP secret engine variables - commented out, no longer using AD
# variable "ldap_bind_user" {
#   description = "The LDAP bind user DN for the AD secret engine."
#   type        = string
# }

# variable "ldap_bind_password" {
#   description = "The LDAP bind password for the AD secret engine."
#   type        = string
#   sensitive   = true
# }

# variable "ldap_url" {
#   description = "The LDAP URL for the AD secret engine."
#   type        = string
# }

# variable "ldap_auth_user_dn" {
#   description = "The LDAP user DN for the AD secret engine."
#   type        = string
# }

# variable "ad_backend_userdn" {
#   description = "The AD backend user DN for static roles."
#   type        = string
# }
