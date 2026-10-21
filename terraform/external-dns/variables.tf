variable "cloudflare_api_token" {
  description = <<-EOT
    Cloudflare API token used to MINT the external-dns token. It needs:
      User | API Tokens | Edit
    The cloudflared token does not have this, and widening it would let that
    token create other tokens, so use a separate bootstrap token.
  EOT
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Zone ID for t-vo.us. The external-dns token is scoped to this one zone."
  type        = string
}
