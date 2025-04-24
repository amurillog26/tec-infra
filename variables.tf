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
    name                             = string
    account_tier                     = optional(string)
    account_replication_type         = optional(string)
    account_kind                     = optional(string)
    min_tls_version                  = optional(string)
    access_tier                      = optional(string)
    is_hns_enabled                   = optional(bool)
    cross_tenant_replication_enabled = optional(bool)

    network_rules = optional(object({
      default_action = optional(string)
      ip_rules       = optional(list(string))
      bypass         = optional(list(string))
    }))

    containers = optional(list(object({
      name        = string
      access_type = optional(string)
    })))

    tables = optional(list(object({
      name = string
    })))

    tags = optional(map(string))
  }))
  description = "Mapa de cuentas de almacenamiento para crear"
}


variable "tags" {
  type        = map(string)
  description = "Tags comunes para todos los recursos"
  default     = {}
}
variable "main_rg_name" {
  type = string
}

variable "main_vn_location" {
  type = string
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
  default     = false

}

variable "kv_sku_name" {
  type        = string
  description = "The SKU for Key Vault"
}

variable "key_vault_secrets" {
  description = "Mapa de secretos para almacenar en Key Vault, agrupados por categoría"
  type        = map(list(string))
  default     = {}
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
    private_endpoint_network_policies             = optional(string)
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
      name          = string
      partition_key = string # Esto ahora es un solo string para partition_key_path
      throughput    = number
    }))
  }))
  description = "List of Cosmos DB databases and their containers"
}

variable "cosmos_capabilities" {
  type        = list(string)
  description = "List of Cosmos DB capabilities"
  default     = null

}

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Enable private endpoint for Cosmos DB"
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS Zone ID for Cosmos DB private endpoint"
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
  default     = false
}
variable "acr_zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy for the Container Registry"
  default     = true

}

variable "service_plans" {
  type = map(object({
    name         = string
    sku_name     = string
    os_type      = string
    worker_count = number
  }))
  description = "Map of service plans"

}
variable "sp_zone_balancing_enabled" {
  type        = bool
  description = "Enable zone balancing"
  default     = true

}

variable "web_apps" {
  type = map(object({
    name                   = string
    subnet_id              = optional(string)
    vnet_route_all_enabled = optional(bool, false)
    app_settings           = map(string)
    ip_restrictions = optional(map(object({
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
    name                 = string
    publisher_name       = string
    publisher_email      = string
    sku_name             = string
    capacity             = number
    subnet_id            = string
    virtual_network_type = string
    # Opcional: Puedes añadir explícitamente el ID de IP pública si es necesario
    public_ip_address_id = optional(string)
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
    policy = optional(object({
      xml_content = string
    }))
    products = map(object({
      product_id            = string
      display_name          = string
      description           = string
      subscription_required = bool
      approval_required     = bool
      published             = bool
      subscriptions_limit   = number
    }))
    apis = map(object({
      name         = string
      display_name = string
      path         = string
      protocols    = list(string)
      revision     = string
      version      = optional(string)
      version_set = optional(object({
        name              = string
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
    is_enterprise       = optional(bool, false) # New field to determine resource type
    family              = optional(string)      # Required for standard Redis, not for Enterprise
    sku_name            = string                # Will be different format for Enterprise
    minimum_tls_version = optional(string, "1.2")
    zones               = optional(list(string)) # For Enterprise zone redundancy

    # Standard Redis configurations - make optional
    redis_configuration = optional(object({
      maxmemory_policy                       = optional(string, "volatile-lru")
      maxfragmentationmemory_reserved        = optional(number)
      maxmemory_reserved                     = optional(number)
      data_persistence_authentication_method = optional(string)
    }))

    # Enterprise Redis configurations
    client_protocol   = optional(string, "Encrypted")
    clustering_policy = optional(string, "OSSCluster")
    eviction_policy   = optional(string, "NoEviction")
    modules           = optional(list(string), ["RediSearch"]) # List of modules to enable

    patch_schedule = optional(object({
      day_of_week    = string
      start_hour_utc = number
    }))

    private_endpoint = optional(object({
      enabled   = bool
      subnet_id = optional(string)
    }))

    alerts = optional(object({
      cpu_threshold        = number
      memory_threshold     = number
      connection_threshold = number
    }))

    firewall_rules = optional(map(object({
      start_ip = string
      end_ip   = string
    })), {})

    tags = optional(map(string), {})
  }))
  description = "Redis Cache and Redis Enterprise configurations"
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


variable "application_gateway" {
  type = object({
    name = string
    sku = object({
      name     = string
      tier     = string
      capacity = number
    })
    gateway_ip_configurations = map(object({
      subnet_id = string
    }))
    frontend_ip_configurations = map(object({
      name                 = string
      public_ip_address_id = string
    }))
    frontend_ports = map(object({
      name = string
      port = number
    }))
    ssl_certificates = map(object({
      name                = string
      key_vault_secret_id = string
    }))
    backend_address_pools = map(object({
      name  = string
      fqdns = list(string)
    }))
    backend_http_settings = map(object({
      name                  = string
      cookie_based_affinity = string
      path                  = string
      port                  = number
      protocol              = string
      request_timeout       = number
      probe_name            = string
    }))
    http_listeners = map(object({
      name                           = string
      frontend_ip_configuration_name = string
      frontend_port_name             = string
      protocol                       = string
      ssl_certificate_name           = optional(string)
      host_name                      = optional(string)
    }))
    probes = map(object({
      name                = string
      host                = string
      interval            = number
      path                = string
      timeout             = number
      unhealthy_threshold = number
      protocol            = string
      port                = number
      match = object({
        status_codes = list(string)
      })
    }))
    request_routing_rules = map(object({
      name                       = string
      rule_type                  = string
      http_listener_name         = string
      backend_address_pool_name  = string
      backend_http_settings_name = string
      priority                   = number
    }))
    waf_configuration = object({
      enabled                  = bool
      firewall_mode            = string
      rule_set_type            = string
      rule_set_version         = string
      file_upload_limit_mb     = number
      request_body_check       = bool
      max_request_body_size_kb = number
      disabled_rule_groups = list(object({
        rule_group_name = string
        rules           = list(string)
      }))
      exclusions = list(object({
        match_variable          = string
        selector                = string
        selector_match_operator = string
      }))
    })
    ssl_policy = object({
      policy_type = string
      policy_name = string
    })
    private_link_configuration = object({
      enabled = bool
    })
    tags = map(string)
  })
  description = "Application Gateway configuration"
}

variable "managed_identity" {
  type = object({
    name                  = string
    assign_key_vault_role = bool
    tags                  = map(string)
  })
  description = "Managed identity configuration"
}

variable "public_ips" {
  type = map(object({
    name              = string
    allocation_method = string
    sku               = string
    sku_tier          = optional(string)
    zones             = optional(list(string))
    tags              = map(string)
  }))
  description = "Configuración de las IPs públicas"
}

variable "private_endpoints" {
  type = map(object({
    name                 = string
    resource_id          = string
    subresource_names    = list(string)
    subnet_key           = optional(string, "snet_gpt_int_dev") # Default subnet for private endpoints
    is_manual_connection = optional(bool, false)
    private_dns_zone_ids = optional(list(string))
  }))
  description = "Map of private endpoints to create"
  default     = {}
}

variable "private_dns_zones" {
  type = map(object({
    name                 = string
    registration_enabled = optional(bool, false)
  }))
  description = "Map of private DNS zones to create"
  default     = {}
}

variable "windows_vm" {
  description = "Configuración de la máquina virtual Windows"
  type = object({
    name           = string
    nic_name       = string
    size           = string
    admin_username = string
    admin_password = string
    hostname       = string
    tags           = map(string)
  })
  default = {
    name           = "vm-gpt-win11-dev"
    nic_name       = "nic-gpt-win11-dev"
    size           = "Standard_B4ms"
    admin_username = "adminuser"
    admin_password = null # Debe configurarse en el archivo tfvars
    hostname       = "win11-workstation"
    tags = {
      type = "workstation"
    }
  }
}
variable "grafana" {
  description = "Configuración del recurso Azure Managed Grafana"
  type = object({
    name                              = string
    sku_name                          = string
    grafana_version                   = string
    api_key_enabled                   = bool
    deterministic_outbound_ip_enabled = bool
    public_network_access_enabled     = bool
    zone_redundancy_enabled           = bool
    identity_type                     = string
    azure_monitor_workspace_id        = optional(string)
    admin_principal_ids               = optional(list(string))
    editor_principal_ids              = optional(list(string))
    viewer_principal_ids              = optional(list(string))
    private_endpoint_enabled          = bool
    tags                              = optional(map(string))
  })
  default = {
    name                              = "grafana-gpt-dev"
    sku_name                          = "Standard"
    grafana_version                   = "11" # Usar versión 10 o 11 para SKU Standard
    api_key_enabled                   = true
    deterministic_outbound_ip_enabled = true
    public_network_access_enabled     = true
    zone_redundancy_enabled           = false
    identity_type                     = "SystemAssigned"
    private_endpoint_enabled          = false
  }
}

# Añadir al final del archivo variables.tf
variable "kubernetes" {
  type = object({
    cluster_name       = string
    dns_prefix         = string
    kubernetes_version = string
    availability_zones = list(string)
    # Nuevos campos para clúster privado
    private_cluster_enabled           = bool
    private_dns_zone_name             = string
    enable_key_vault_secrets_provider = optional(bool, false)
    sku_tier                          = optional(string, "Free") # Add this field
    default_node_pool = object({
      name                = string
      node_count          = number
      vm_size             = string
      enable_auto_scaling = bool
      min_count           = number
      max_count           = number
      node_labels         = optional(map(string), {})
      node_taints         = optional(list(string), [])
    })

    # Nuevo campo para nodepools adicionales
    additional_node_pools = map(object({
      name                = string
      node_count          = number
      vm_size             = string
      mode                = string
      enable_auto_scaling = bool
      min_count           = number
      max_count           = number
      node_labels         = optional(map(string), {})
      node_taints         = optional(list(string), [])
    }))

    attach_acr = bool
    tags       = map(string)
  })
  description = "Configuración del clúster de Kubernetes"
}

variable "admin_object_id" {
  description = "Object ID del administrador que necesita acceso completo al Key Vault"
  type        = string
  default     = "" # Completar con tu Object ID
}

variable "admin_app_id" {
  description = "Application ID para el administrador del Key Vault"
  type        = string
  default     = ""
}

variable "kv_accessor_ids" {
  description = "Mapa de IDs de objetos para políticas de acceso al Key Vault"
  type        = map(string)
  default     = {}
}

variable "subscription_id" {
  description = "ID de la suscripción de Azure"
  type        = string
}
variable "acr_enable_identity" {
  type        = bool
  description = "Enable identity for Azure Container Registry"
  default     = false
}

variable "acr_identity_type" {
  type        = string
  description = "Type of identity for ACR"
  default     = "UserAssigned"
}

variable "acr_identity_ids" {
  type        = list(string)
  description = "List of identity IDs for ACR"
  default     = []
}

variable "key_vault_access_policies" {
  description = "List of access policies for the Key Vault"
  type = list(object({
    tenant_id               = string
    object_id               = string
    application_id          = optional(string, null)
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = []
}

variable "security_contacts" {
  description = "Email addresses for security alerts"
  type = list(object({
    email               = string
    phone               = optional(string)
    alert_notifications = optional(bool)
    alerts_to_admins    = optional(bool)
  }))
  default = [
    {
      email               = "security@yourdomain.com"
      alert_notifications = true
      alerts_to_admins    = true
    }
  ]
}
