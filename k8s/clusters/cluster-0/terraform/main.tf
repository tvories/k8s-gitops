#TODO: Move all cluster-0 terraform to this dir?

terraform {
  backend "gcs" {
    bucket      = "tvo-homelab-tfstate"
    prefix      = "terraform/state/talos-cluster-0"
    credentials = "/mnt/c/Users/taylor/gits/homelab/terraform/keys/terraform.json"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.38.0"
    }
  }
}

provider "google" {
  project = "taylor-cloud"
  region  = "us-west1"
}

resource "google_service_account" "cluster_0_flux" {
  account_id   = "svc-cluster-0-flux"
  display_name = "svc-cluster-0-flux"
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
  filename = "${path.module}/cluster-0-flux-sa.json"
}
