output "information" {
  value = <<EOF
  Now you need to add an A type DNS record in your registrar:
  ${google_compute_address.calibre_server_public_ip.address} -> ${var.domain_name}
  EOF
}
