
# variables.tf
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location for resources"
}

variable "redis_cache" {
  type = map(object({
    name                = string
    capacity            = number
    family             = string
    sku_name           = string
    minimum_tls_version = string
    
    redis_configuration = object({
      maxmemory_policy     = string
      maxfragmentationmemory_reserved = number
      maxmemory_reserved              = number
      data_persistence_authentication_method = string
    })

    patch_schedule = object({
      day_of_week    = string
      start_hour_utc = number
    })

    private_endpoint = object({
      enabled   = bool
      subnet_id = optional(string)
    })

    alerts = object({
      cpu_threshold = number
      memory_threshold = number
      connection_threshold = number
    })

    firewall_rules = map(object({
      start_ip = string
      end_ip   = string
    }))

    tags = map(string)
  }))
  description = "Redis Cache configurations"
}

# variable "diagnostics" {
#   type = object({
#     log_analytics_workspace_id = string
#     metrics = list(string)
#     logs    = list(string)
#     retention_policy = object({
#       enabled = bool
#       days    = number
#     })
#   })
#   description = "Diagnostics settings for Redis Cache"
# }

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}
