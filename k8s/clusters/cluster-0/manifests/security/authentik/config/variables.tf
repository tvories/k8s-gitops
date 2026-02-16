variable "authentik_token" {
  description = "The Authentik API token for managing resources."
  type        = string
  sensitive   = true
}

variable "authentik_url" {
  description = "The URL of the Authentik instance."
  type        = string
}

variable "audiobookshelf_client_id" {
  description = "The client ID for Audiobookshelf in Authentik."
  type        = string
}

variable "audiobookshelf_client_secret" {
  description = "The client secret for Audiobookshelf in Authentik."
  type        = string
  sensitive   = true
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

variable "google_oauth_client_id" {
  description = "The Google OAuth client ID for Authentik."
  type        = string
}

variable "google_oauth_client_secret" {
  description = "The Google OAuth client secret for Authentik."
  type        = string
  sensitive   = true
}

variable "CLUSTER_DOMAIN" {
  description = "The cluster domain name."
  type        = string
}

variable "gitlab_client_id" {
  description = "The client ID for GitLab in Authentik."
  type        = string
}

variable "gitlab_client_secret" {
  description = "The client secret for GitLab in Authentik."
  type        = string
  sensitive   = true
}

variable "gitlab_svc_password" {
  description = "Password for the Gitlab LDAP service account."
  type        = string
  sensitive   = true
}

variable "immich_client_id" {
  description = "The client ID for Immich in Authentik."
  type        = string
}

variable "immich_client_secret" {
  description = "The client secret for Immich in Authentik."
  type        = string
  sensitive   = true
}

variable "nextcloud_client_id" {
  description = "The client ID for Nextcloud in Authentik."
  type        = string
}

variable "nextcloud_client_secret" {
  description = "The client secret for Nextcloud in Authentik."
  type        = string
  sensitive   = true
}

variable "tandoor_client_id" {
  description = "The client ID for Tandoor in Authentik."
  type        = string
}

variable "tandoor_client_secret" {
  description = "The client secret for Tandoor in Authentik."
  type        = string
  sensitive   = true
}
