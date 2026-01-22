variable "authentik_token" {
  description = "The Authentik API token for managing resources."
  type        = string
  sensitive   = true
}

variable "authentik_url" {
  description = "The URL of the Authentik instance."
  type        = string
}

variable "grafana_client_id" {
  description = "The client ID for Grafana in Authentik."
  type        = string
}

variable "grafana_client_secret" {
  description = "The client secret for Grafana in Authentik."
  type        = string
  sensitive   = true
}

# variable "OP_CONNECT_HOST" {
#   type        = string
#   description = "OnePassword Connect URL"
# }

# variable "OP_CONNECT_TOKEN" {
#   type        = string
#   description = "The path to the service account JSON for OnePassword."
#   sensitive   = true
#   default     = null
# }
