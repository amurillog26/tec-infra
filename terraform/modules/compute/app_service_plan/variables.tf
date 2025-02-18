variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location for resources"
}

variable "service_plans" {
  type = map(object({
    name                   = string
    sku_name              = string
    os_type               = string
    worker_count          = optional(number, 1)
    zone_balancing_enabled = optional(bool, false)
  }))
  description = "Map of service plans to create"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {}
}
