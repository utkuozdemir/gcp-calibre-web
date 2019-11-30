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

variable "use_xip_io_for_domain_name" {
  type = bool
}

variable "custom_domain_name" {
  type = string
  default = "calibre.invalid"
}
