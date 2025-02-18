# variables.tf
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location for resources"
}

variable "environment" {
  type        = string
  description = "Environment (dev, pre, prod)"
  validation {
    condition     = contains(["dev", "pre", "prod"], var.environment)
    error_message = "Environment must be one of: dev, pre, prod."
  }
}

variable "web_apps" {
  type = map(object({
    name              = string
    service_plan_id   = string
    subnet_id         = optional(string)
    app_settings      = map(string)
    ip_restrictions   = optional(map(object({
      name            = string
      ip_address      = optional(string)
      subnet_id       = optional(string)
      priority        = number
      action          = string
    })))
  }))
  description = "Map of web apps to create"
}

variable "acr_login_server" {
  type        = string
  description = "ACR login server URL"
}

variable "acr_admin_username" {
  type        = string
  description = "ACR admin username"
}

variable "acr_admin_password" {
  type        = string
  description = "ACR admin password"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {}
}
