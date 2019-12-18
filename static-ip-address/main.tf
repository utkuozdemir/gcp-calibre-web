provider "google" {
  credentials = file("../serviceaccount.json")
  project = var.gcp_project_id
  region = var.gcp_region
  zone = var.gcp_zone
}

resource "google_compute_address" "calibre_server_public_ip" {
  name = "calibre-server-public-ip"
}