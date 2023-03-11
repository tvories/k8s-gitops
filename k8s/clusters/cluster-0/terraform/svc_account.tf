
provider "google" {
  project = "taylor-cloud"
  region  = "us-west1"
}

resource "google_service_account" "flux" {
  account_id   = "svc-${var.cluster_name}-flux"
  display_name = "svc-${var.cluster_name}-flux"
}

resource "google_kms_key_ring_iam_member" "flux" {
  key_ring_id = "projects/taylor-cloud/locations/global/keyRings/sops"
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member      = "serviceAccount:${google_service_account.flux.email}"
}

resource "google_service_account_key" "flux" {
  service_account_id = google_service_account.flux.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "flux" {
  content  = base64decode(google_service_account_key.flux.private_key)
  filename = "${path.module}/gcp-flux-sa-credential.json"
}
