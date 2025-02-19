variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos"
}

variable "location" {
  type        = string
  description = "Ubicación de Azure"
}

variable "storage_accounts" {
  type = map(object({
    name                     = string
    account_tier             = optional(string)
    account_replication_type = optional(string)
    account_kind            = optional(string)
    network_rules = optional(object({
      default_action = optional(string)
      ip_rules       = optional(list(string))
      bypass         = optional(list(string))
    }))
    containers = optional(list(object({
      name        = string
      access_type = optional(string)
    })))
    tags = optional(map(string))
  }))
  description = "Configuración de storage accounts"
}

variable "tags" {
  type        = map(string)
  description = "Tags comunes para todos los recursos"
  default     = {}
}
variable "main_rg_name" {
  type          = string
}

variable "main_vn_location" {
  type          = string
}

variable "resource_tags" {
  type        = map(string)
  description = "General Tags"
}

variable "kv_name" {
  type        = string
  description = "The name of Key Vault"
}

variable "kv_public_access" {
  type        = bool
  description = "Enable or disable public access to the key vault"
  default     = true
  
}

variable "kv_sku_name" {
  type        = string
  description = "The SKU for Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID"
  
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
}

variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    service_endpoints                             = optional(list(string), [])
    delegation = optional(list(object({
      name    = string
      actions = list(string)
    })), [])
  }))
  description = "Map of subnet configurations"
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers"
  default     = []
}

# Cosmos DB Variables
variable "cosmos_account_name" {
  type        = string
  description = "Name of the Cosmos DB account"
}

variable "cosmos_account_offer_type" {
  type        = string
  default     = "Standard"
  description = "Offer type for Cosmos DB account"
}

variable "cosmos_account_kind" {
  type        = string
  default     = "GlobalDocumentDB"
  description = "Kind of Cosmos DB account"
}

variable "cosmos_public_access" {
  type        = bool
  description = "Enable public network access for Cosmos DB"
}

variable "cosmos_failover_az_region" {
  type        = string
  description = "Azure region for Cosmos DB failover"
}

variable "cosmos_sql_databases" {
  type = list(object({
    database_name = string
    containers = list(object({
      name           = string
      partition_key  = string  # Esto ahora es un solo string para partition_key_path
      throughput     = number
    }))
  }))
  description = "List of Cosmos DB databases and their containers"
}

variable "enable_private_endpoint" {
  type        = bool
  default     = false
  description = "Enable private endpoint for Cosmos DB"
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS Zone ID for Cosmos DB private endpoint"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for diagnostics"
}

# Container Registry Variables
variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry"
}

variable "acr_admin_enabled" {
  type        = bool
  description = "Enable admin user for the Container Registry"
  default     = false
}

variable "acr_public" {
  type        = bool
  description = "Enable public access to Container Registry"
  default     = true
}

variable "service_plans" {
  type = map(object({
    name                    = string
    sku_name                = string
    os_type                 = string
    worker_count            = number
    zone_balancing_enabled  = bool
  }))
  description = "Map of service plans"
  
}

variable "web_apps" {
  type = map(object({
    name                   = string
    subnet_id             = optional(string)
    vnet_route_all_enabled = optional(bool, false)
    app_settings          = map(string)
    ip_restrictions       = optional(map(object({
      name       = string
      ip_address = optional(string)
      subnet_id  = optional(string)
      priority   = number
      action     = string
    })))
  }))
  description = "Map of web apps to create"
}


variable "apim" {
  type = object({
    name                = string
    publisher_name      = string
    publisher_email     = string
    sku_name           = string
    capacity           = number
    subnet_id          = string
    virtual_network_type = string
    protocols = object({
      enable_http2 = bool
    })
    security = object({
      enable_backend_ssl30  = bool
      enable_backend_tls10  = bool
      enable_backend_tls11  = bool
      enable_frontend_ssl30 = bool
      enable_frontend_tls10 = bool
      enable_frontend_tls11 = bool
    })
    identity_type = string
    policy = object({
      xml_content = string
    })
    products = map(object({
      product_id            = string
      display_name         = string
      description         = string
      subscription_required = bool
      approval_required    = bool
      published           = bool
      subscriptions_limit = number
    }))
    apis = map(object({
      name         = string
      display_name = string
      path         = string
      protocols    = list(string)
      revision     = string
      version      = optional(string)
      version_set  = optional(object({
        name = string
        versioning_scheme = string
      }))
    }))
    named_values = map(object({
      display_name = string
      value        = string
    }))
    additional_settings = object({
      enable_sign_in = bool
      enable_sign_up = bool
    })
    tags = map(string)
  })
  description = "API Management configuration"
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
