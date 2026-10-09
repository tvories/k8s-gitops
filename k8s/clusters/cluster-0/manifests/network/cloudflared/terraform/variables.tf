variable "cloudflare_api_token" {
  description = <<-EOT
    Cloudflare API token. Needs more scope than the DNS-only token cert-manager
    uses, so mint a separate one rather than widening that:
      Account | Cloudflare Tunnel              | Edit
      Account | Access: Apps and Policies      | Edit
      Account | Access: Service Tokens         | Edit
      Zone    | DNS                            | Edit  (on the cluster zone)
  EOT
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID that owns the tunnel and Access apps."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for CLUSTER_DOMAIN, where the tunnel's CNAME is created."
  type        = string
}

variable "cloudflared_tunnel_secret" {
  description = <<-EOT
    The tunnel's shared secret, base64, at least 32 bytes.

    This is an INPUT rather than a `random_bytes` resource on purpose: in this
    repo 1Password is the source of truth for credentials and Terraform pushes
    them outward, so the value must originate there. Generating it here would
    also mean the only copy lived in Terraform state.

    Create it once with `openssl rand -base64 32`, store it in 1Password, and
    reference it from .env_vars — never as a literal.
  EOT
  type        = string
  sensitive   = true
}

variable "CLUSTER_DOMAIN" {
  description = "The cluster domain name, matching the authentik config's variable of the same name."
  type        = string
}

variable "tunnel_hostname" {
  description = "Subdomain the tunnel serves. Must match the `ingress` hostname in ../configmap.yaml."
  type        = string
  default     = "am"
}
