# The token value is stored in Terraform state (GCS backend) as well as shown
# here; there is no way to mint a token in Terraform without that. Copy it into
# 1Password -> `cloudflare` item, field `external_dns_token`, which
# ../externalsecret.yaml reads. Print it with:
#   terraform output -raw external_dns_token
output "external_dns_token" {
  description = "Scoped Cloudflare API token for external-dns -> 1Password cloudflare/external_dns_token."
  value       = cloudflare_api_token.external_dns.value
  sensitive   = true
}
