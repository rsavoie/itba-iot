terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name = "iot-platform-network"
}

resource "google_compute_firewall" "firewall" {
  name    = "iot-platform-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3000", "8000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "default" {
  name         = "iot-platform-instance"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.id
    access_config {
    }
  }

  metadata = {
    ssh-keys = "savoie:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfmxNQ5WSZTiQpdtsPO93jfbr8sSzIbpIkAtjFwWM+0 savoie"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io docker-compose git openssh-server
  EOT
}


