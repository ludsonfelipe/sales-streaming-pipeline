variable "region" { 
  default = "us-central1"
  type = string
}
variable "project" {
  default = "playground-s-11-acfa5e34"
  type = string
}
variable "repo" {
  default = "https://github.com/ludsonfelipe/sales-streaming-pipeline"
}
variable "enable_apis" {
  default = "true"
}