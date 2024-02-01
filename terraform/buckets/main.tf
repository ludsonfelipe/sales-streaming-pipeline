resource "google_storage_bucket" "pipeline-bucket-database" {
  name          = var.bucket_name_database
  location      = var.location
  force_destroy = true
  uniform_bucket_level_access = true
}
resource "google_storage_bucket" "pipeline-bucket-pubsub" {
  name          = var.bucket_name_pubsub
  location      = var.location
  force_destroy = true
  uniform_bucket_level_access = true
}