locals {
  authentik_groups = {
    downloads      = { name = "Downloads" }
    home           = { name = "Home" }
    infrastructure = { name = "Infrastructure" }
    media          = { name = "Media" }
    monitoring     = { name = "Monitoring" }
    users          = { name = "Users" }
  }
}

data "authentik_group" "admins" {
  name = "authentik Admins"
}

resource "authentik_group" "grafana_admin" {
  name         = "Grafana Admins"
  is_superuser = false
}

resource "authentik_group" "gitlab_admin" {
  name         = "GitLab Admins"
  is_superuser = false
}

resource "authentik_group" "default" {
  for_each     = local.authentik_groups
  name         = each.value.name
  is_superuser = false
}

resource "authentik_policy_binding" "application_policy_binding" {
  for_each = local.applications

  target = authentik_application.application[each.key].uuid
  group  = authentik_group.default[each.value.group].id
  order  = 0
}

# Google OAuth Source
data "authentik_flow" "default-source-authentication" {
  slug = "default-source-authentication"
}

data "authentik_flow" "default-source-enrollment" {
  slug = "default-source-enrollment"
}

resource "authentik_source_oauth" "google" {
  name = "Google"
  slug = "google"
  # Note: Ensure these data source names match your actual data blocks
  authentication_flow = data.authentik_flow.default-source-authentication.id
  enrollment_flow     = data.authentik_flow.default-source-enrollment.id
  user_matching_mode  = "email_link"

  provider_type = "google"
  # Reference variables instead of the deprecated resource
  consumer_key    = var.google_oauth_client_id
  consumer_secret = var.google_oauth_client_secret

  # For Google, Authentik's 'google' provider_type usually handles
  # these automatically, but keeping them is fine for clarity:
  oidc_well_known_url = "https://accounts.google.com/.well-known/openid-configuration"
}

# module "onepassword_discord" {
#   source = "github.com/joryirving/terraform-1password-item"
#   vault  = "Kubernetes"
#   item   = "discord"
# }

# ##Oauth
# resource "authentik_source_oauth" "discord" {
#   name                = "Discord"
#   slug                = "discord"
#   authentication_flow = data.authentik_flow.default-source-authentication.id
#   enrollment_flow     = authentik_flow.enrollment-invitation.uuid
#   user_matching_mode  = "email_deny"

#   provider_type   = "discord"
#   consumer_key    = module.onepassword_discord.fields["DISCORD_CLIENT_ID"]
#   consumer_secret = module.onepassword_discord.fields["DISCORD_CLIENT_SECRET"]
# }
