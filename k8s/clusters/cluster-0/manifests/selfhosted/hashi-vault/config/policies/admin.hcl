# Manage auth methods broadly across Vault
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*" {
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth" {
  capabilities = ["read"]
}

# List existing policies
path "sys/policies/acl" {
  capabilities = ["list"]
}

# Create and manage all policies
path "sys/policies/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
# Create and manage ACL policies
path "sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List, create, update, and delete key/value secrets
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage secrets engines
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage ad secrets engine
path "ad/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing secrets engines.
path "sys/mounts" {
  capabilities = ["read"]
}

# Read health checks
path "sys/health" {
  capabilities = ["read", "sudo"]
}

# Mount the AppRole auth method
path "sys/auth/approle" {
  capabilities = [ "create", "read", "update", "delete", "sudo" ]
}

# Configure the AppRole auth method
path "sys/auth/approle/*" {
  capabilities = [ "create", "read", "update", "delete" ]
}

# Create and manage roles
path "auth/approle/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Manage tokens for verification
path "auth/token/create" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Manage the leases
path "sys/leases/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

# Link existing policies
path "sys/policy" {
  capabilities = ["read"]
}

# Create and manage ACL policies broadly across Vault
path "sys/policy/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Backup raft snapshots
path "sys/storage/raft/snapshot" {
  capabilities = ["read"]
}