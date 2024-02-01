provider "google" {
  #credentials = file("../source/scripts/keys/key.json")
  project     = var.project
  region      = var.region
}

module "project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "14.4.0"
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


resource "google_service_account" "my_service_account" {
  account_id   = "pipeline"
  display_name = "Pipeline Service Account"
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project
  role    = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.my_service_account.email}"
  ]
}

resource "google_project_service_identity" "pubsub_id" {
  provider = google-beta
  project = var.project
  service = "pubsub.googleapis.com"
}

resource "google_storage_bucket_iam_member" "user_pubsub_storage" {
  bucket = module.buckets.bucket_name_pubsub
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_project_service_identity.pubsub_id.email}"
}


resource "random_id" "bucket_id" {
  byte_length = 4
}

module "buckets" {
  source = "./buckets"

  bucket_name_database = "raw-database-${random_id.bucket_id.hex}"
  bucket_name_pubsub = "raw-pubsub-${random_id.bucket_id.hex}"
  location = "US"
}

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

module "instances" {

  source = "./instance"
  address = module.database.database_ip
  repository = var.repo
  project = var.project
  account = google_service_account.my_service_account.email
  depends_on = [ google_project_iam_binding.pubsub_publisher ]
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

module "pubsub" {
  source = "./pubsub"
  ecom_topic_name = "ecom_topic"
  ecom_subscription_name = "ecom_subscription"
  bucket_name_pubsub = module.buckets.bucket_name_pubsub
}