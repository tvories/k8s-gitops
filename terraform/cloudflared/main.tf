locals {
  fqdn = "${var.tunnel_hostname}.${var.CLUSTER_DOMAIN}"
}

# ---------------------------------------------------------------------------
# Tunnel
# ---------------------------------------------------------------------------
# config_src = "local" keeps this a LOCALLY-managed tunnel, so the ingress
# rules in ../configmap.yaml stay authoritative. Setting it to "cloudflare"
# would move routing into the dashboard and make the ConfigMap dead weight --
# cloudflared refuses to mix the two.
resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id    = var.cloudflare_account_id
  name          = "k8s-cluster-0"
  tunnel_secret = var.cloudflared_tunnel_secret
  config_src    = "local"
}

# ---------------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------------
# Proxied CNAME to the tunnel's own hostname. This is what makes the record
# resolve to Cloudflare's anycast edge rather than to anything on the LAN, so
# a client on a corporate VPN reaches it without any private range being
# involved -- the whole reason this exists instead of WireGuard.
resource "cloudflare_dns_record" "tunnel" {
  zone_id = var.cloudflare_zone_id
  name    = var.tunnel_hostname
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1 # 1 == automatic; required field, and ignored while proxied
  comment = "Managed by Terraform - cloudflared tunnel to cluster-0"
}

# ---------------------------------------------------------------------------
# Access
# ---------------------------------------------------------------------------
# A service token rather than an identity policy: the consumer is the
# agentmemory MCP client, which is not a browser and cannot complete an OIDC
# redirect. Cloudflare returns the client secret exactly once, at creation.
resource "cloudflare_zero_trust_access_service_token" "agentmemory" {
  account_id = var.cloudflare_account_id
  name       = "agentmemory-mcp"
}

resource "cloudflare_zero_trust_access_policy" "agentmemory" {
  account_id = var.cloudflare_account_id
  name       = "agentmemory service token"

  # non_identity is the correct decision for service tokens: it admits a
  # caller presenting valid credentials without requiring a human identity.
  decision = "non_identity"

  include = [{
    service_token = {
      token_id = cloudflare_zero_trust_access_service_token.agentmemory.id
    }
  }]
}

resource "cloudflare_zero_trust_access_application" "agentmemory" {
  account_id = var.cloudflare_account_id
  name       = "agentmemory"
  domain     = local.fqdn
  type       = "self_hosted"

  # Return 401 to unauthenticated callers instead of redirecting them to the
  # Cloudflare login page. Without this an API client receives an HTML login
  # page with a 302 and reports a confusing parse error rather than an auth
  # failure.
  service_auth_401_redirect = true

  session_duration = "24h"

  policies = [{
    id         = cloudflare_zero_trust_access_policy.agentmemory.id
    precedence = 1
  }]
}
