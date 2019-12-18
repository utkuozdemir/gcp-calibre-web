output "information" {
  value = <<EOF
  Now, you need to add an A type DNS record in your registrar, if you haven't already:
  ${var.domain_name} -> ${google_compute_address.calibre_server_public_ip.address}
  Make sure that DNS record is propagated before proceeding to the next step.
  Check it by the following command:
  nslookup ${var.domain_name} 8.8.8.8
  EOF
}
