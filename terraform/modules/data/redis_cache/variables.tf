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
    is_enterprise       = optional(bool, false)  # Flag to determine resource type
    family              = optional(string)       # Required for standard Redis, not for Enterprise
    sku_name            = string                 # Different format for Enterprise vs Standard
    minimum_tls_version = optional(string, "1.2")
    zones               = optional(list(string)) # For Enterprise zone redundancy
    
    # Standard Redis configurations
    redis_configuration = optional(object({
      maxmemory_policy     = optional(string, "volatile-lru")
      maxfragmentationmemory_reserved = optional(number)
      maxmemory_reserved              = optional(number)
      data_persistence_authentication_method = optional(string)
    }))

    # Enterprise Redis configurations
    client_protocol     = optional(string, "Encrypted")
    clustering_policy   = optional(string, "OSSCluster")
    eviction_policy     = optional(string, "NoEviction")

    patch_schedule = optional(object({
      day_of_week    = string
      start_hour_utc = number
    }))

    private_endpoint = optional(object({
      enabled   = bool
      subnet_id = optional(string)
    }))

    alerts = optional(object({
      cpu_threshold = number
      memory_threshold = number
      connection_threshold = number
    }))

    firewall_rules = optional(map(object({
      start_ip = string
      end_ip   = string
    })))

    tags = optional(map(string), {})
  }))
  description = "Redis Cache configurations"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}
