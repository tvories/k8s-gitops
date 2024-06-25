resource "vault_ldap_auth_backend" "ldap" {
  path              = "ldap"
  url               = data.sops_file.secrets.data["ldap_url"]
  userdn            = data.sops_file.secrets.data["ldap_auth_user_dn"]
  groupdn           = data.sops_file.secrets.data["ldap_auth_group_dn"]
  binddn            = data.sops_file.secrets.data["ldap_bind_user"]
  bindpass          = data.sops_file.secrets.data["ldap_bind_password"]
  userattr          = "sAMAccountName"
  groupfilter       = "(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))"
  groupattr         = "memberOf"
  starttls          = true
  insecure_tls      = true
  username_as_alias = true
  # TODO: Test using this config
  #   token_ttl = 86400
  #   token_max_ttl = 259200
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}
