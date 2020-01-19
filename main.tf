provider "google" {
  credentials = file("serviceaccount.json")
  project = var.gcp_project_id
  region = var.gcp_region
  zone = var.gcp_zone
}

data "google_compute_address" "calibre_server_public_ip_address" {
  name = var.public_ip_address_resource_name
}

resource "google_compute_resource_policy" "calibre_server_disk_backup_schedule" {
  count = var.backups_enabled ? 1 : 0
  name = "calibre-server-disk-backup-schedule"
  region = var.gcp_region

  snapshot_schedule_policy {
    retention_policy {
      max_retention_days = var.backups_max_retention_days
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
  image = var.disk_image
  name = "calibre-server-disk"
  size = var.disk_size_in_gb
}

resource "google_compute_disk_resource_policy_attachment" "calibre_server_disk_backups" {
  count = var.backups_enabled ? 1 : 0
  name = google_compute_resource_policy.calibre_server_disk_backup_schedule[0].name
  disk = google_compute_disk.calibre_server_disk.name
  zone = var.gcp_zone
}

data "template_file" "startup_script" {
  template = file("startup-script-template.sh")
  vars = {
    timezone = var.timezone
    domain_name = var.domain_name
    admin_email = var.admin_email
    use_test_cert = var.use_test_ssl_cert
  }
}

data "null_data_source" "faik" {

}

resource "google_compute_instance" "calibre_server" {
  name = "calibre-server"
  machine_type = var.machine_type
  zone = var.gcp_zone

  allow_stopping_for_update = var.allow_stopping_for_update

  timeouts {
    create = "60m"
    update = "30m"
  }

  depends_on = [
    google_compute_disk.calibre_server_disk
  ]

  boot_disk {
    auto_delete = false
    source = google_compute_disk.calibre_server_disk.name
  }

  tags = [
    "http-server",
    "https-server"
  ]

  network_interface {
    network = "default"

    access_config {
      nat_ip = data.google_compute_address.calibre_server_public_ip_address.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_file_location)}"
  }

  metadata_startup_script = replace(data.template_file.startup_script.rendered,"\r\n" ,"\n" )
}
