# Scoped token for external-dns: edit DNS records in ONE zone and nothing else.
#
# Permission group IDs are Cloudflare's published, account-independent IDs.
# Verify them before the first apply:
#   curl -s -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
#     https://api.cloudflare.com/client/v4/user/tokens/permission_groups
locals {
  perm_dns_write = "4755a26eedb94da69e1066d98aa820be" # "DNS Write"
  perm_zone_read = "c8fed203ed3043cba015a93ad1616f1f" # "Zone Read"
}

resource "cloudflare_api_token" "external_dns" {
  name = "external-dns"

  policies = [{
    effect = "allow"
    permission_groups = [
      { id = local.perm_dns_write },
      { id = local.perm_zone_read },
    ]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${var.cloudflare_zone_id}" = "*"
    })
  }]
}
