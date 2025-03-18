variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}
variable "environment" {
  type        = string
  description = "Environment for resources"
  default = "dev"
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
  }))
  description = "Map of service plans to create"
}
variable "zone_balancing_enabled" {
  type        = bool
  description = "Enable zone balancing"
  default     = true
  
}
variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {}
}
