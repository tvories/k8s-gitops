# Fetch Technitium API token from 1Password
# Reference: op://k8s/technitium/password
# data "onepassword_item" "technitium" {
#   vault = "k8s"
#   title = "technitium"
# }

# provider "technitium" {
#   url   = var.technitium_url
#   token = data.onepassword_item.technitium.password
# }

# Variables
variable "technitium_url" {
  description = "Technitium DNS Server URL — https://, darkhonor refuses http->https redirects. Set via TF_VAR_technitium_url in .env_vars (1Password)."
  type        = string
}

locals {
  dns_servers = ["192.168.1.243"]
}
