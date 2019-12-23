output "info" {
  value = <<EOF

Setup complete. Try accessing:
https://${var.domain_name}/calibre-web
on your browser.

EOF
}
