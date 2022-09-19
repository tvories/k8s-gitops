
provider "google" {
  project = "taylor-cloud"
  region  = "us-west1"
}

resource "google_service_account" "cluster_0_flux" {
  account_id   = "svc-${var.svc_account_name}-flux"
  display_name = "svc-${var.svc_account_name}-flux"
}

resource "google_kms_key_ring_iam_member" "cluster_0_flux" {
  key_ring_id = "projects/taylor-cloud/locations/global/keyRings/sops"
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member      = "serviceAccount:${google_service_account.cluster_0_flux.email}"
}

resource "google_service_account_key" "cluster_0_flux" {
  service_account_id = google_service_account.cluster_0_flux.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "cluster_0_flux" {
  content  = base64decode(google_service_account_key.cluster_0_flux.private_key)
  filename = "${path.module}/${var.svc_account_name}-flux-sa.json"
}
