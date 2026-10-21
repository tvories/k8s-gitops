# The Admin Policy is used to grant an ldap user or group sudo permissions for vault

# Sudo access to path *
path "*" {
  policy = "sudo"
}

# Managed Vault leases
path "sys/leases/lookup" {
  policy = "sudo"
}

# Manage approle auth provider
path "auth/approle/*" {
  policy = "sudo"
}

path "auth/token/*" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}

path "auth/token/create" {
  capabilities = [ "create", "read", "update", "delete", "list", "sudo" ]
}
