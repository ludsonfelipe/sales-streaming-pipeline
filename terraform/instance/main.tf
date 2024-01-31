resource "google_compute_instance" "ingest_data" {
  name         = "ingestdata"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }
  metadata_startup_script   = templatefile("instance/start.sh", {"repos" = var.repository, "address" = var.address, "project" = var.project}) 
  allow_stopping_for_update = true
  service_account {
    email = var.account
    scopes = ["cloud-platform"]
  }
}
