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


variable "backups_enabled" {
  type = bool
}


variable "disk_size_in_gb" {
  type = number
}

variable "domain_name" {
  type = string
}

variable "disk_image" {
  type = string
  default = "ubuntu-1804-bionic-v20191113"
}

variable "allow_stopping_for_update" {
  type = bool
  default = true
}

variable "backups_schedule" {
  type = string
  default = "daily"
}

variable "backups_max_retention_days" {
  type = number
  default = 14
}

variable "ssh_private_key_file_location" {
  type = string
  default = "~/.ssh/id_rsa"
}

variable "ssh_public_key_file_location" {
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "public_ip_address_resource_name" {
  type = string
  default = "calibre-server-public-ip"
}
