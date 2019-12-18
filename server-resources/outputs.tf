output "information" {
  value = <<EOF
  Setup complete. Try accessing:
  https://${var.domain_name}
  EOF
}
