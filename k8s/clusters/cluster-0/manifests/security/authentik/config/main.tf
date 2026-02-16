locals {
  applications = {
    # dashbrr = {
    #   client_id     = module.onepassword_application["dashbrr"].fields["DASHBRR_CLIENT_ID"]
    #   client_secret = module.onepassword_application["dashbrr"].fields["DASHBRR_CLIENT_SECRET"]
    #   group         = "downloads"
    #   icon_url      = "https://raw.githubusercontent.com/joryirving/home-ops/main/docs/src/assets/icons/dashbrr.png"
    #   redirect_uri  = "https://dashbrr.${var.CLUSTER_DOMAIN}/api/auth/callback"
    #   launch_url    = "https://dashbrr.${var.CLUSTER_DOMAIN}/api/auth/callback"
    # },
    audiobookshelf = {
      client_id     = var.audiobookshelf_client_id
      client_secret = var.audiobookshelf_client_secret
      group         = "media"
      icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/audiobookshelf.png"
      redirect_uris = [
        "https://ab.${var.CLUSTER_DOMAIN}/auth/openid/callback",
        "https://ab.${var.CLUSTER_DOMAIN}/auth/openid/mobile-redirect",
      ]
      launch_url = "https://ab.${var.CLUSTER_DOMAIN}"
    },
    grafana = {
      client_id     = var.grafana_client_id
      client_secret = var.grafana_client_secret
      group         = "monitoring"
      icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/grafana.png"
      redirect_uri  = "https://grafana.cluster-0.t-vo.us/login/generic_oauth"
      launch_url    = "https://grafana.cluster-0.t-vo.us/login/generic_oauth"
    },
    gitlab = {
      client_id     = var.gitlab_client_id
      client_secret = var.gitlab_client_secret
      group         = "users"
      icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/gitlab.png"
      redirect_uri  = "https://gitlab.${var.CLUSTER_DOMAIN}/users/auth/openid_connect/callback"
      launch_url    = "https://gitlab.${var.CLUSTER_DOMAIN}"
    },
    immich = {
      client_id     = var.immich_client_id
      client_secret = var.immich_client_secret
      group         = "users"
      icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/immich.png"
      redirect_uris = [
        "app.immich:///oauth-callback",
        "https://photos.${var.CLUSTER_DOMAIN}/auth/login",
        "https://photos.${var.CLUSTER_DOMAIN}/user-settings",
      ]
      launch_url = "https://photos.${var.CLUSTER_DOMAIN}/auth/login?autoLaunch=1"
    },
    nextcloud = {
      client_id     = var.nextcloud_client_id
      client_secret = var.nextcloud_client_secret
      group         = "users"
      icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/nextcloud.png"
      redirect_uri  = "https://nc.${var.CLUSTER_DOMAIN}/apps/user_oidc/code"
      launch_url    = "https://nc.${var.CLUSTER_DOMAIN}"
    },
    tandoor = {
      client_id     = var.tandoor_client_id
      client_secret = var.tandoor_client_secret
      group         = "home"
      icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/tandoor-recipes.png"
      redirect_uri  = "https://tandoor.${var.CLUSTER_DOMAIN}/accounts/oidc/authentik/login/callback/"
      launch_url    = "https://tandoor.${var.CLUSTER_DOMAIN}"
    },
    # headlamp = {
    #   client_id     = module.onepassword_application["headlamp"].fields["HEADLAMP_CLIENT_ID"]
    #   client_secret = module.onepassword_application["headlamp"].fields["HEADLAMP_CLIENT_SECRET"]
    #   group         = "infrastructure"
    #   icon_url      = "https://raw.githubusercontent.com/headlamp-k8s/headlamp/refs/heads/main/frontend/src/resources/icon-dark.svg"
    #   redirect_uri  = "https://headlamp.${var.CLUSTER_DOMAIN}/oidc-callback"
    #   launch_url    = "https://headlamp.${var.CLUSTER_DOMAIN}/"
    # },
    # kyoo = {
    #   client_id     = module.onepassword_application["kyoo"].fields["KYOO_CLIENT_ID"]
    #   client_secret = module.onepassword_application["kyoo"].fields["KYOO_CLIENT_SECRET"]
    #   group         = "media"
    #   icon_url      = "https://raw.githubusercontent.com/zoriya/Kyoo/master/icons/icon-256x256.png"
    #   redirect_uri  = "https://kyoo.${var.CLUSTER_DOMAIN}/api/auth/logged/authentik"
    #   launch_url    = "https://kyoo.${var.CLUSTER_DOMAIN}/api/auth/login/authentik?redirectUrl=https://kyoo.${var.CLUSTER_DOMAIN}/login/callback"
    # },
    # lubelogger = {
    #   client_id     = module.onepassword_application["lubelogger"].fields["LUBELOGGER_CLIENT_ID"]
    #   client_secret = module.onepassword_application["lubelogger"].fields["LUBELOGGER_CLIENT_SECRET"]
    #   group         = "home"
    #   icon_url      = "https://demo.lubelogger.com/defaults/lubelogger_icon_72.png"
    #   redirect_uri  = "https://lubelogger.${var.CLUSTER_DOMAIN}/Login/RemoteAuth"
    #   launch_url    = "https://lubelogger.${var.CLUSTER_DOMAIN}/Login/RemoteAuth"
    # },
    # paperless = {
    #   client_id     = module.onepassword_application["paperless"].fields["PAPERLESS_CLIENT_ID"]
    #   client_secret = module.onepassword_application["paperless"].fields["PAPERLESS_CLIENT_SECRET"]
    #   group         = "home"
    #   icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/paperless.png"
    #   redirect_uri  = "https://paperless.${var.CLUSTER_DOMAIN}/accounts/oidc/authentik/login/callback/"
    #   launch_url    = "https://paperless.${var.CLUSTER_DOMAIN}/"
    # },
    # portainer = {
    #   client_id     = module.onepassword_application["portainer"].fields["PORTAINER_CLIENT_ID"]
    #   client_secret = module.onepassword_application["portainer"].fields["PORTAINER_CLIENT_SECRET"]
    #   group         = "infrastructure"
    #   icon_url      = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/main/png/portainer.png"
    #   redirect_uri  = "https://portainer.${var.CLUSTER_DOMAIN}/"
    #   launch_url    = "https://portainer.${var.CLUSTER_DOMAIN}/"
    # }
  }
}

data "authentik_flow" "default-provider-authorization-implicit-consent" {
  slug = "default-provider-authorization-implicit-consent"
}

data "authentik_property_mapping_provider_scope" "scope-email" {
  name = "authentik default OAuth Mapping: OpenID 'email'"
}

data "authentik_property_mapping_provider_scope" "scope-profile" {
  name = "authentik default OAuth Mapping: OpenID 'profile'"
}

data "authentik_property_mapping_provider_scope" "scope-openid" {
  name = "authentik default OAuth Mapping: OpenID 'openid'"
}

data "authentik_flow" "invalidation_flow" {
  slug = "default-provider-invalidation-flow"
}

resource "authentik_provider_oauth2" "oauth2" {
  for_each           = local.applications
  name               = each.key
  client_id          = each.value.client_id
  client_secret      = each.value.client_secret
  authorization_flow = data.authentik_flow.default-provider-authorization-implicit-consent.id
  invalidation_flow  = data.authentik_flow.invalidation_flow.id
  signing_key        = data.authentik_certificate_key_pair.generated.id
  property_mappings = [
    data.authentik_property_mapping_provider_scope.scope-email.id,
    data.authentik_property_mapping_provider_scope.scope-profile.id,
    data.authentik_property_mapping_provider_scope.scope-openid.id,
  ]
  access_token_validity = "hours=4"
  allowed_redirect_uris = [
    for uri in try(each.value.redirect_uris, [each.value.redirect_uri]) : {
      matching_mode = "strict",
      url           = uri,
    }
  ]
}

resource "authentik_application" "application" {
  for_each           = local.applications
  name               = title(each.key)
  slug               = each.key
  protocol_provider  = authentik_provider_oauth2.oauth2[each.key].id
  group              = authentik_group.default[each.value.group].name
  open_in_new_tab    = true
  meta_icon          = each.value.icon_url
  meta_launch_url    = each.value.launch_url
  policy_engine_mode = "all"
}
