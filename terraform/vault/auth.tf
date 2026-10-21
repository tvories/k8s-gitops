resource "vault_jwt_auth_backend" "oidc" {
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = "https://authentik.${var.external_domain}/application/o/vault/"
  oidc_client_id     = var.vault_oidc_client_id
  oidc_client_secret = var.vault_oidc_client_secret
  default_role       = "admin"

  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_jwt_auth_backend_role" "admin" {
  backend   = vault_jwt_auth_backend.oidc.path
  role_name = "admin"
  role_type = "oidc"

  allowed_redirect_uris = [
    "https://vault.${var.external_domain}/ui/vault/auth/oidc/oidc/callback",
    "http://localhost:8250/oidc/callback",
  ]

  user_claim      = "sub"
  token_policies  = ["admin"]
  oidc_scopes     = ["openid", "profile", "email"]
  bound_audiences = [var.vault_oidc_client_id]
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}
