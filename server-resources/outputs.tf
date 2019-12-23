output "info" {
  value = <<EOF

Setup complete. Try accessing:
https://${var.domain_name}/calibre-web
on your browser.
It might take couple of minutes to start working.

EOF
}
