# agentmemory speaks no OIDC — it authenticates with a single static bearer
# token — so it cannot join the OAuth2 applications in main.tf. Adding it to
# local.applications would wrongly generate an authentik_provider_oauth2 for
# it via that map's for_each. Its web viewer is protected with a proxy
# provider in forward-auth mode instead: nginx asks the outpost whether the
# caller is signed in before proxying the request through.
#
# The viewer stays bound to loopback inside the agentmemory pod, with a socat
# sidecar bridging it to the Service. That is deliberate: agentmemory's own
# inbound bearer check only engages on a non-loopback bind, and satisfying it
# would mean duplicating AGENTMEMORY_SECRET into cluster-secrets.sops.yaml and
# rendering it into an Ingress annotation. authentik is the access control
# here; the pod-internal hop needs no second secret.
#
# Flow data sources (default-provider-authorization-implicit-consent,
# invalidation_flow) and authentik_group.default are declared in main.tf,
# system.tf and directory.tf.

resource "authentik_provider_proxy" "agentmemory" {
  name = "agentmemory"
  # forward_single: this provider guards one host, and that host serves its
  # own /outpost.goauthentik.io path (see the agentmemory manifests). Switching
  # to forward_domain would instead route sign-in through ako.${CLUSTER_DOMAIN}
  # and require the embedded outpost to be imported into Terraform.
  mode                  = "forward_single"
  external_host         = "https://agentmemory-viewer.${var.CLUSTER_DOMAIN}"
  authorization_flow    = data.authentik_flow.default-provider-authorization-implicit-consent.id
  invalidation_flow     = data.authentik_flow.invalidation_flow.id
  access_token_validity = "hours=4"
}

resource "authentik_application" "agentmemory" {
  name               = "Agentmemory"
  slug               = "agentmemory"
  protocol_provider  = authentik_provider_proxy.agentmemory.id
  group              = authentik_group.default["infrastructure"].name
  open_in_new_tab    = true
  meta_launch_url    = "https://agentmemory-viewer.${var.CLUSTER_DOMAIN}"
  policy_engine_mode = "all"
}

# Restrict to the Infrastructure group, mirroring the binding the OAuth2
# applications get from directory.tf.
resource "authentik_policy_binding" "agentmemory" {
  target = authentik_application.agentmemory.uuid
  group  = authentik_group.default["infrastructure"].id
  order  = 0
}

# Dedicated proxy outpost. The embedded outpost is not managed by Terraform,
# and adding a provider to it would require importing it first — a separate
# outpost keeps this self-contained, at the cost of one more pod in `security`.
# authentik derives the Service name from this name: "TVo Proxy" becomes
# ak-outpost-tvo-proxy, which the Ingress annotations reference.
resource "authentik_outpost" "proxy" {
  name = "TVo Proxy"
  type = "proxy"

  service_connection = authentik_service_connection_kubernetes.local.id

  protocol_providers = [
    authentik_provider_proxy.agentmemory.id
  ]

  config = jsonencode({
    log_level                      = "info"
    docker_labels                  = null
    docker_network                 = null
    docker_map_ports               = true
    container_image                = null
    kubernetes_replicas            = 1
    kubernetes_namespace           = "security"
    kubernetes_ingress_annotations = {}
    kubernetes_ingress_secret_name = "authentik-outpost-tls"
    kubernetes_service_type        = "ClusterIP"
    kubernetes_disabled_components = []
    kubernetes_image_pull_secrets  = []
    authentik_host                 = "https://authentik.${var.CLUSTER_DOMAIN}"
    authentik_host_browser         = "https://authentik.${var.CLUSTER_DOMAIN}"
  })
}
