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
    "datastream.googleapis.com"
  ]
}

module "buckets" {
  source = "./buckets"

  bucket_name = "test1dsa414234dsa1233231123"
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
  datastream_conn_bucket = "test1dsa414234dsa1233231123"
  depends_on = [ module.project-services ]
}

module "pubsub" {
  source = "./pubsub"
  ecom_topic_name = "ecom_topic"
  ecom_subscription_name = "ecom_subscription"
}