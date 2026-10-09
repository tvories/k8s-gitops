# credentials.json is assembled by ../externalsecret.yaml from three fields on
# the 1Password `cloudflared` item, rather than being emitted here as a single
# blob. That keeps `tunnel_secret` inside 1Password instead of round-tripping
# it through Terraform state, the terminal and shell history -- and it is why
# neither output below is sensitive, so `op run` has nothing to mask.
#
# Copy both into the 1Password `cloudflared` item alongside `tunnel_secret`.

# Also goes into ../configmap.yaml in place of REPLACE_WITH_TUNNEL_ID.
output "tunnel_id" {
  description = "Tunnel UUID -> 1Password cloudflared/tunnel_id, and ../configmap.yaml."
  value       = cloudflare_zero_trust_tunnel_cloudflared.this.id
}

output "account_tag" {
  description = "Cloudflare account tag -> 1Password cloudflared/account_tag."
  value       = cloudflare_zero_trust_tunnel_cloudflared.this.account_tag
}

output "access_client_id" {
  description = "CF-Access-Client-Id for the MCP client's local cloudflared proxy."
  value       = cloudflare_zero_trust_access_service_token.agentmemory.client_id
}

# Cloudflare returns this once. If it is lost the token must be rotated.
output "access_client_secret" {
  description = "CF-Access-Client-Secret. Store in 1Password; shown only at creation."
  value       = cloudflare_zero_trust_access_service_token.agentmemory.client_secret
  sensitive   = true
}

output "hostname" {
  description = "Public hostname the tunnel serves."
  value       = local.fqdn
}
