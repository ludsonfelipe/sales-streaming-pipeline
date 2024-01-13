resource "google_storage_bucket" "pipeline-bucket" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = true
  uniform_bucket_level_access = true
}
