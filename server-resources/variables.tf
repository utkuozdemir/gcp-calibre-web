variable "admin_email" {
  type = string
}

variable "timezone" {
  type = string
}

variable "use_test_ssl_cert" {
  type = bool
}

variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_zone" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "allow_stopping_for_update" {
  type = bool
  default = true
}

variable "backups_enabled" {
  type = bool
}

variable "disk_size_in_gb" {
  type = number
}

variable "domain_name" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "ssh_private_key_file_location" {
  type = string
  default = "~/.ssh/id_rsa"
}

variable "ssh_public_key_file_location" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}
