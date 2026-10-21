# Service account for LDAP binding
resource "authentik_user" "ldap_gitlab" {
  username  = "svc_gitlab"
  name      = "GitLab LDAP Service Account"
  email     = "svc_gitlab@t-vo.us"
  is_active = true
  type      = "service_account"
  path      = "users"
  password  = var.gitlab_svc_password
}

# Generic LDAP Provider for all applications
resource "authentik_provider_ldap" "default" {
  name    = "tvo-ldap"
  base_dn = "dc=ldap,dc=t-vo,dc=us"

  # TLS settings - disable for internal use
  tls_server_name = ""

  # Bind settings
  bind_mode = "cached"

  # Flows - using the flows defined in system.tf and main.tf
  bind_flow   = data.authentik_flow.default-brand-authentication.id
  unbind_flow = data.authentik_flow.invalidation_flow.id
}

resource "authentik_application" "ldap" {
  name              = "LDAP"
  slug              = "ldap"
  protocol_provider = authentik_provider_ldap.default.id
}

# Outpost for LDAP
resource "authentik_outpost" "ldap" {
  name = "TVo LDAP"
  type = "ldap"

  service_connection = authentik_service_connection_kubernetes.local.id

  protocol_providers = [
    authentik_provider_ldap.default.id
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
