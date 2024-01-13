output "ssh_command" {
  value = "gcloud compute ssh ${google_compute_instance.ingest_data.name} --zone=${google_compute_instance.ingest_data.zone}"
}