variable "access_key" {}
variable "secret_key" {}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true # Critical for local S3-compat storage

  endpoints {
    s3 = "https://s3.nas.t-vo.us"
  }
}

locals {
  gitlab_buckets = [
    "gitlab-lfs",
    "gitlab-artifacts",
    "gitlab-uploads",
    "gitlab-packages",
    "gitlab-external-diffs",
    "gitlab-dependency-proxy",
    "gitlab-terraform-state",
    "gitlab-ci-secure-files",
    "gitlab-backups",
    "gitlab-tmp",
  ]
}

resource "aws_s3_bucket" "gitlab_storage" {
  for_each = toset(local.gitlab_buckets)
  bucket   = each.value
}

output "bucket_ids" {
  description = "The IDs (names) of the created GitLab buckets"
  value       = { for k, v in aws_s3_bucket.gitlab_storage : k => v.id }
}