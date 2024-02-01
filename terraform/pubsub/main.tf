resource "google_pubsub_topic" "ecom_topic" {
  name = var.ecom_topic_name
}

resource "google_pubsub_subscription" "ecom_sub" {
  topic = google_pubsub_topic.ecom_topic.name
  name = var.ecom_subscription_name
}
resource "random_id" "random_number" {
  byte_length = 4
}
resource "google_pubsub_subscription" "gcs_subscription" {
  name  = "ecom-subscription-gcs"
  topic = google_pubsub_topic.ecom_topic.name

  cloud_storage_config {
    bucket = var.bucket_name_pubsub

    filename_prefix = "ecom-"
    filename_suffix = "-${random_id.random_number.hex}"

    max_bytes = 1000
    max_duration = "60s"
  }
}