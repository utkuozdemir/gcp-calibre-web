output "dns_information" {
  value = <<EOF
  DNS record required on the registrar:
  ${google_compute_address.calibre_server_public_ip.address} -> ${local.domain_name}
  EOF
}

output "information" {
  value = <<EOF
  Now you need to add an A type DNS record in your registrar:
  ${google_compute_address.calibre_server_public_ip.address} -> ${local.domain_name}
  Then you will be able to access Calibre Web over "https://${local.domain_name}"
  EOF
}
