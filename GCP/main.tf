provider "google" {
  credentials = "${file(var.account_file_path)}"
  project     = "${var.project_name}"
  region      = "${var.region}"
}

# Creates a custom network, similar to VPC on AWS
resource "google_compute_network" "abacao-network" {
  name                    = "abacao-network"
  auto_create_subnetworks = "false"
}

# Creates a custom subnetwork, similar to VPC on AWS
resource "google_compute_subnetwork" "abacao-sub" {
  name          = "abacao-sub"
  ip_cidr_range = "10.15.0.0/16"
  network       = "${google_compute_network.abacao-network.self_link}"
  region        = "${var.region}"
}

# Security Grups to alow ssh
resource "google_compute_firewall" "abacao-rule-ssh" {
  name    = "abacao-rule-ssh"
  network = "abacao-network"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Security Grups to alow ping
resource "google_compute_firewall" "abacao-rule-ping" {
  name    = "abacao-rule-ping"
  network = "abacao-network"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Creates the instance
resource "google_compute_instance" "abacao-instance" {
  count        = 1
  name         = "abacao-server-${count.index + 1}"
  machine_type = "f1-micro"
  zone         = "${var.region_zone}"
  tags         = ["abacao", "terraform", "instance"]

  disk {
    image = "centos-7-v20170327"
  }

  # The network or subnetwork in witch this instance will be running
  network_interface {
    #network = "abacao-network"
    subnetwork = "${google_compute_subnetwork.abacao-sub.name}"

    access_config {
      // Ephemeral IP - leaving this block empty will generate a new external IP and assign it to the machine
    }
  }
}


# # LATER define default connection for remote provisioners
# connection {
# type = "ssh"
# user = "${var.gce_ssh_user}"
# private_key = "${file(var.gce_ssh_private_key_file)}"
# }
