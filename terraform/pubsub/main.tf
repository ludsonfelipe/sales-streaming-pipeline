resource "google_pubsub_topic" "ecom_topic" {
  name = var.ecom_topic_name
}

resource "google_pubsub_subscription" "ecom_sub" {
    topic = google_pubsub_topic.ecom_topic.name
  name = var.ecom_subscription_name
}