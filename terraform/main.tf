provider "google" {
  #credentials = file("../source/scripts/keys/key.json")
  project     = var.project
  region      = var.region
}

module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "17.0.0"
  disable_services_on_destroy = false

  project_id  = var.project
  enable_apis = var.enable_apis

  activate_apis = [
    "serviceusage.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudapis.googleapis.com",
    "sqladmin.googleapis.com",
    "datastream.googleapis.com",
    "iam.googleapis.com"
  ]
}

# Get the service account for pubsub
resource "google_project_service_identity" "pubsub_id" {
  provider = google-beta
  project = var.project
  service = "pubsub.googleapis.com"
}

# Grant the service account the necessary permissions to access the storage bucket
resource "google_storage_bucket_iam_member" "user_pubsub_storage" {
  bucket = module.buckets.bucket_name_pubsub
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_project_service_identity.pubsub_id.email}"
}

# Generate a random bucket id
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Create the buckets
module "buckets" {
  source = "./buckets"

  bucket_name_database = "raw-database-${random_id.bucket_id.hex}"
  bucket_name_pubsub = "raw-pubsub-${random_id.bucket_id.hex}"
  location = "US"
}

# Create the database
module "database" {

  source = "./database"
  project_region = var.region
  project_id = var.project

  user = "pipeline"
  password = "123456"
  database_name = "sales_db"
  instance_cloud_sql = "postgres"
  depends_on = [ module.project-services ]
}

# Create the pubsub topic and subscription
module "pubsub" {
  source = "./pubsub"
  ecom_topic_name = "ecom_topic"
  ecom_subscription_name = "ecom_subscription"
  bucket_name_pubsub = module.buckets.bucket_name_pubsub
  depends_on = [ 
    module.buckets.bucket_name_pubsub,
    google_storage_bucket_iam_member.user_pubsub_storage,
    ]
}

resource "google_service_account" "my_service_account" {
  account_id   = "pipeline"
  display_name = "Pipeline Service Account"
}

# Grant the service account the necessary permissions to publish to the pubsub topic
resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}

module "datastreams" {

  source = "./datastream"
  project_id = var.project
  project_region = var.region

  user = "pipeline"
  password = "123456"
  database_name = "sales_db"
  public_ip_address = module.database.database_ip

  datastream_name = "sales_stream"
  datastream_conn_db = "postgres"
  datastream_conn_bucket = module.buckets.bucket_name_database
  depends_on = [ module.project-services ]
}

# Create the instance that will generate the data
module "instances" {

  source = "./instance"
  address = module.database.database_ip
  repository = var.repo
  project = var.project
  account = google_service_account.my_service_account.email
  depends_on = [ google_project_iam_binding.pubsub_publisher ]
}