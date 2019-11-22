output "public_ip" {
  value = google_compute_address.calibre_server_public_ip.address
}

output "address" {
  value = "https://${local.domain_name}"
}
