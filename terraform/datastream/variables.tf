variable "project_id" { 
  type = string
}
variable "project_region" {
  type = string
}
// datastream
variable "datastream_name" {
  type = string
}
variable "datastream_conn_db" {
  type = string
}
variable "datastream_conn_bucket" {
  type = string
}
variable "publication_name" {
  default = "publi"
}
variable "replication_name" {
  default = "repl"
}
variable "database_name" {
  type = string
}
variable "user" {
    type = string
}
variable "password" {
  type = string
}
variable "public_ip_address" {
  type = string
}