provider "google" {
  credentials = file("serviceaccount.json")
  project = var.gcp_project_id
  region = var.gcp_region
  zone = var.gcp_zone
}

resource "google_compute_address" "calibre_server_public_ip" {
  name = "calibre-server-public-ip"
}

locals {
  domain_name = var.use_xip_io_for_domain_name ? "${google_compute_address.calibre_server_public_ip.address}.xip.io" : var.custom_domain_name
}

resource "google_compute_resource_policy" "calibre_server_disk_backup_schedule" {
  count = var.backups_enabled ? 1 : 0
  name = "calibre-server-disk-backup-schedule"
  region = var.gcp_region
  snapshot_schedule_policy {
    retention_policy {
      max_retention_days = 14
    }
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "04:00"
      }
    }
  }
}

resource "google_compute_disk" "calibre_server_disk" {
  image = "ubuntu-1804-bionic-v20191113"
  name = "calibre-server-disk"
  size = var.disk_size_in_gb
}

resource "google_compute_disk_resource_policy_attachment" "calibre_server_disk_backups" {
  count = var.backups_enabled ? 1 : 0
  name = google_compute_resource_policy.calibre_server_disk_backup_schedule[0].name
  disk = google_compute_disk.calibre_server_disk.name
  zone = var.gcp_zone
}

resource "google_compute_instance" "calibre_server" {
  name = "calibre-server"
  machine_type = var.machine_type
  zone = "europe-west3-b"

  allow_stopping_for_update = var.allow_stopping_for_update

  timeouts {
    create = "60m"
    update = "30m"
  }

  boot_disk {
    source = google_compute_disk.calibre_server_disk.name
  }

  tags = [
    "http-server",
    "https-server"
  ]

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.calibre_server_public_ip.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file("keys/id_rsa.pub")}"
  }

  connection {
    type = "ssh"
    host = google_compute_address.calibre_server_public_ip.address
    user = "ubuntu"
    timeout = "500s"
    private_key = file("keys/id_rsa")
  }

  provisioner "file" {
    source = "./files"
    destination = "/tmp"
  }

  provisioner "file" {
    content = templatefile("templates/docker-compose.yaml", {
      timezone = var.timezone
    })
    destination = "/tmp/files/docker-compose.yaml"
  }

  provisioner "file" {
    content = templatefile("templates/calibre-web-proxy-initial.conf", {
      domain_name = local.domain_name
    })
    destination = "/tmp/files/calibre-web-proxy-initial.conf"
  }

  provisioner "file" {
    content = templatefile("templates/calibre-web-proxy-final.conf", {
      domain_name = local.domain_name
    })
    destination = "/tmp/files/calibre-web-proxy-final.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/files/startup-script.sh",
      "sudo /tmp/files/startup-script.sh ${local.domain_name} ${var.admin_email} ${var.use_test_ssl_cert} ${var.dropbox_enabled} ${var.timezone}",
      "sudo rm -rf /tmp/files/"
    ]
  }
}