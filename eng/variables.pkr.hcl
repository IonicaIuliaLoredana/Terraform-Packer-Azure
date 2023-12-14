variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "resource_group_name" {
  type = string
}

variable "image_name" {
  type = string
}

variable "app_path" {
  type = string
}

variable "service_name" {
  type = string
}

variable "executable_name" {
  type = string
}
