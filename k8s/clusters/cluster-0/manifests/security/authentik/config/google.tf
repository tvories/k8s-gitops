provider "google" {
  project = "taylor-cloud"
  region  = "us-west1"
}

resource "google_project_service" "apis" {
  for_each = toset([
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "identitytoolkit.googleapis.com",
  ])
  service            = each.key
  disable_on_destroy = false
}

resource "google_identity_platform_config" "authentik" {
  project = "taylor-cloud"
  multi_tenant {
    allow_tenants = false
  }
}
