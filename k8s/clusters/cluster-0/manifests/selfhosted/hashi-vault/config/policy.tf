resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("${path.module}/policies/admin.hcl")
}

resource "vault_policy" "auth-admin" {
  name   = "auth-admin"
  policy = file("${path.module}/policies/auth-admin.hcl")
}

resource "vault_password_policy" "ad" {
  name   = "ad"
  policy = file("${path.module}/policies/ad-password-policy.hcl")
}
