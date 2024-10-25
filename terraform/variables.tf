variable "region" { 
  default = "us-central1"
  type = string
}
variable "project" {
  default = "sales-pipeline-419523"
  type = string
}
variable "repo" {
  default = "https://github.com/ludsonfelipe/sales-streaming-pipeline"
}
variable "enable_apis" {
  default = "true"
}
