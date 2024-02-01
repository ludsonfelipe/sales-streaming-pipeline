output "bucket_name_database" {
  value = google_storage_bucket.pipeline-bucket-database.name
}
output "bucket_name_pubsub" {
  value = google_storage_bucket.pipeline-bucket-pubsub.name
}