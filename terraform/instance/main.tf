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
  metadata_startup_script = <<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get upgrade
  git clone https://github.com/ludsonfelipe/sales-streaming-pipeline
  sudo snap install docker
  sudo snap refresh docker --channel=latest/edge
  export POSTGRES_PASSWORD=${var.public_ip_address}
  sudo apt install make
  sudo docker-compose up -d
  EOF

  allow_stopping_for_update = true
}