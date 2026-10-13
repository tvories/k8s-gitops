# BookBridge's admin UI is guarded with a proxy provider in forward-auth mode:
# BookBridge has no OIDC client (cporcellijr/bookbridge#363), but its Reverse
# Proxy Auto-Login trusts a username header, so authentik signs the user in and
# BookBridge picks the identity up from X-authentik-username.
#
# The first app to use authentik through Gateway API rather than nginx: Envoy
# Gateway calls the outpost's /outpost.goauthentik.io/auth/envoy endpoint via a
# SecurityPolicy (media/bookbridge/securitypolicy.yaml). The provider itself is
# identical either way — the proxy integration lives in the outpost, not here.
#
# Only bookbridge.<domain> is covered. bsync.<domain>, the KOSync endpoint, is
# deliberately NOT behind authentik: KOReader cannot complete a browser sign-in.
#
# Served by the "TVo Proxy" outpost declared in agentmemory.tf.

resource "authentik_provider_proxy" "bookbridge" {
  name = "bookbridge"
  # forward_single: one host, serving its own /outpost.goauthentik.io path
  # (the bookbridge-outpost HTTPRoute). See agentmemory.tf for why not
  # forward_domain.
  mode                  = "forward_single"
  external_host         = "https://bookbridge.${var.CLUSTER_DOMAIN}"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  invalidation_flow     = data.authentik_flow.invalidation_flow.id
  access_token_validity = "hours=24"
}

resource "authentik_application" "bookbridge" {
  name               = "BookBridge"
  slug               = "bookbridge"
  protocol_provider  = authentik_provider_proxy.bookbridge.id
  group              = authentik_group.default["infrastructure"].name
  open_in_new_tab    = true
  meta_launch_url    = "https://bookbridge.${var.CLUSTER_DOMAIN}"
  policy_engine_mode = "all"
}

# Restrict to the Infrastructure group, mirroring agentmemory and the OAuth2
# applications' bindings in directory.tf.
resource "authentik_policy_binding" "bookbridge" {
  target = authentik_application.bookbridge.uuid
  group  = authentik_group.default["infrastructure"].id
  order  = 0
}
