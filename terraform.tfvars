resource_group_name = "rg_gpt_oai_dev"
location           = "southcentralus"
environment = "dev"

storage_accounts = {
  "stgptdev001" = {
    name = "stgptdev00demo"
    account_tier = "Standard"
    account_replication_type = "LRS"
    
    network_rules = {
      default_action = "Allow"
      bypass = ["AzureServices"]
      ip_rules = []
    }

    containers = [
      {
        name = "data"
        access_type = "private"
      }
    ]

    tags = {
      environment = "dev"
      workload = "oai"
    }
  }
}

tags = {
  environment = "dev"
  managed_by  = "terraform"
  owner       = "dev-team"
}

main_rg_name        = "rg_gpt_oai_dev"
main_vn_location    = "southcentralus"
kv_name             = "kv-gpt-oai-dev-001-demo"
kv_sku_name         = "standard"

resource_tags = {
    environment = "dev"
    workload = "oai"
}

tenant_id = "ff463ea8-92b7-4e5a-a417-cf03db333692"

########## vnet ##########


vnet_name           = "vnet_gpt_net_dev"
address_space       = ["10.97.174.0/23"]  # Mantiene el rango 10.97.174.0 - 10.97.175.255

subnets = {
  "snet_gpt_agw_dev" = {
    address_prefixes = ["10.97.174.0/27"]     # 32 IPs: 10.97.174.0 - 10.97.174.31
    service_endpoints = ["Microsoft.Web"]
  },
  "snet_gpt_apim_dev" = {
    address_prefixes = ["10.97.174.32/27"]    # 32 IPs: 10.97.174.32 - 10.97.174.63
    service_endpoints = ["Microsoft.Web", "Microsoft.ContainerRegistry"]
  },
  "snet_gpt_aks_dev" = {
    address_prefixes = ["10.97.175.0/24"]     # 256 IPs: 10.97.175.0 - 10.97.175.255 (subnet más grande en otro segmento)
    service_endpoints = ["Microsoft.ContainerRegistry"]
  },
  "snet_gpt_int_dev" = {
    address_prefixes = ["10.97.174.128/27"]   # 32 IPs: 10.97.174.128 - 10.97.174.159
    service_endpoints = ["Microsoft.Web"]
  },
  "snet_gpt_vm_dev" = {
    address_prefixes = ["10.97.174.160/27"]   # 32 IPs: 10.97.174.160 - 10.97.174.191
    service_endpoints = ["Microsoft.Web"]
  },
  "snet_gpt_pe_dev" = {
    address_prefixes = ["10.97.174.192/27"]   # 32 IPs: 10.97.174.192 - 10.97.174.223
    service_endpoints = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry", "Microsoft.AzureCosmosDB"]
    private_endpoint_network_policies_enabled = false
  }
}

########## cosmosdb ##########

cosmos_account_name        = "cosmos-gpt-db-dev-demo"
cosmos_account_offer_type  = "Standard"
cosmos_account_kind       = "GlobalDocumentDB"
cosmos_public_access      = false  # true for dev, false for prod
cosmos_failover_az_region = "eastus"  # región secundaria para failover

cosmos_sql_databases = [
  {
    database_name = "chatdb"
    containers = [
      {
        name          = "conversations"
        partition_key = "/userId"
        throughput    = 400
      },
      {
        name          = "messages"
        partition_key = "/conversationId"
        throughput    = 400
      }
    ]
  },
  {
    database_name = "userdb"
    containers = [
      {
        name          = "profiles"
        partition_key = "/id"
        throughput    = 400
      }
    ]
  }
]

enable_private_endpoint     = false  # true for prod
private_dns_zone_id        = null   # Required for prod
log_analytics_workspace_id = "/subscriptions/xxxx/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/log-analytics-workspace"

# Container Registry
acr_name           = "crgptoaidevdemo"  # Debe ser globalmente único
acr_admin_enabled  = true           # Habilitado para desarrollo
acr_public         = true           # Público para desarrollo

service_plans = {
  "plan1" = {
    name                    = "asp-gpt-api-dev"
    sku_name               = "S1"
    os_type                = "Linux"
    worker_count           = 1
    zone_balancing_enabled = false
  }
}

# Web Apps
web_apps = {
  "api" = {
    name            = "app-gpt-api-dev-demo"
    subnet_id       = null  # Opcional para ambiente dev
    docker_image    = "mcr.microsoft.com/appsvc/staticsite"  # Ajusta según tu imagen
    docker_image_tag = "latest"
    app_settings = {
      "WEBSITES_PORT" = "8080"
      "API_VERSION"   = "v1"
      "ENVIRONMENT"   = "development"
      "DOCKER_ENABLE_CI" = "true"
    }
    ip_restrictions = {}  # Vacío para dev, pero requerido
  }
}


apim = {
  name                = "apim-gpt-api-dev-demo"
  publisher_name      = "GPT Dev Team"
  publisher_email     = "admin@yourdomain.com"
  sku_name           = "Developer_1"
  capacity           = 1
  subnet_id          = null  # Para dev, en prod sería el ID de la subnet

  virtual_network_type = "None"  # None, External, Internal
  protocols = {
    enable_http2 = true
  }

  security = {
    enable_backend_ssl30  = false
    enable_backend_tls10  = false
    enable_backend_tls11  = false
    enable_frontend_ssl30 = false
    enable_frontend_tls10 = false
    enable_frontend_tls11 = false
  }

  identity_type = "SystemAssigned"

  policy = {
    xml_content = <<XML
<policies>
    <inbound>
        <cors>
            <allowed-origins>
                <origin>https://api-dev.yourdomain.com</origin>
            </allowed-origins>
            <allowed-methods>
                <method>GET</method>
                <method>POST</method>
            </allowed-methods>
            <allowed-headers>
                <header>content-type</header>
                <header>authorization</header>
            </allowed-headers>
        </cors>
        <base />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
XML
  }

  # Productos predefinidos
  products = {
    "basic" = {
      product_id            = "basic"
      display_name         = "Basic"
      description         = "Basic tier with limited calls"
      subscription_required = true
      approval_required    = false
      published           = true
      subscriptions_limit = 1
    },
    "standard" = {
      product_id            = "standard"
      display_name         = "Standard"
      description         = "Standard tier with higher limits"
      subscription_required = true
      approval_required    = true
      published           = true
      subscriptions_limit = 1
    }
  }

  # APIs predefinidas
  apis = {
    "gpt-api" = {
      name         = "gpt-api"
      display_name = "GPT API"
      path         = "gpt"
      protocols    = ["https"]
      revision     = "1"
      version      = "v1"
      version_set = {
        name = "gpt-api"
        versioning_scheme = "Segment"
      }
    }
  }

  named_values = {
    "ApiBaseUrl" = {
      display_name = "ApiBaseUrl"
      value        = "https://app-gpt-api-dev-demo.azurewebsites.net"
    },
    "Environment" = {
      display_name = "Environment"
      value        = "development"
    }
  }

  # Configuraciones adicionales
  additional_settings = {
    enable_sign_in = false
    enable_sign_up = false
  }

  tags = {
    environment = "dev"
    workload    = "oai"
  }
}


redis_cache = {
  "redis_gpt_cache_dev" = {
    name                = "redis-gpt-cache-dev-demo"
    capacity            = 1
    family             = "C"
    sku_name           = "Basic"
    minimum_tls_version = "1.2"
    
    redis_configuration = {
      maxmemory_policy     = "allkeys-lru"
      maxfragmentationmemory_reserved = 50
      maxmemory_reserved              = 50
    }

    patch_schedule = {
      day_of_week    = "Sunday"
      start_hour_utc = 2
    }

    private_endpoint = {
      enabled = false  # Para dev lo dejamos en false
      # subnet_id = module.networking.subnet_ids["snet_gpt_redis_dev"]  # Se usaría en prod
    }

    alerts = {
      cpu_threshold = 80
      memory_threshold = 80
      connection_threshold = 1000
    }

    # ACLs para desarrollo
    firewall_rules = {
      "AllowAll" = {
        start_ip = "0.0.0.0"
        end_ip   = "255.255.255.255"
      }
    }

    tags = {
      environment = "dev"
      workload    = "oai"
    }
  }
}

application_gateway = {
  name = "agw-gpt-web-dev"
  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  # Dejaremos estas configuraciones pendientes para ser establecidas en el módulo
  gateway_ip_configurations = {
    main = {
      subnet_id = null  # Se establecerá en el módulo
    }
  }

  frontend_ip_configurations = {
    public = {
      name                 = "frontend-public"
      public_ip_address_id = null  # Se establecerá en el módulo
    }
  }

  frontend_ports = {
    "443" = {
      name = "frontend-443"
      port = 443
    }
    "80" = {
      name = "frontend-80"
      port = 80
    }
  }

  ssl_certificates = {}  # Vacío para desarrollo inicial

  backend_address_pools = {
    "web-backend" = {
      name  = "web-backend"
      fqdns = ["app-gpt-api-dev-demo.azurewebsites.net"]
    }
  }

  backend_http_settings = {
    "http-settings" = {
      name                  = "http-settings"
      cookie_based_affinity = "Disabled"
      path                 = "/"
      port                 = 80
      protocol            = "Http"
      request_timeout     = 60
      probe_name         = "health-probe"
    }
  }

  http_listeners = {
    "http-listener" = {
      name                           = "http-listener"
      frontend_ip_configuration_name = "frontend-public"
      frontend_port_name            = "frontend-80"
      protocol                      = "Http"
    }
  }

  probes = {
    "health-probe" = {
      name                = "health-probe"
      host               = "app-gpt-api-dev-demo.azurewebsites.net"
      path               = "/health"
      interval           = 30
      timeout            = 30
      unhealthy_threshold = 3
      protocol           = "Http"
      port               = 80
      match = {
        status_codes = ["200-399"]
      }
    }
  }

  request_routing_rules = {
    "main-rule" = {
      name                       = "main-rule"
      rule_type                 = "Basic"
      http_listener_name        = "http-listener"
      backend_address_pool_name = "web-backend"
      backend_http_settings_name = "http-settings"
      priority                  = 100
    }
  }

  waf_configuration = {
    enabled                  = true
    firewall_mode           = "Prevention"
    rule_set_type          = "OWASP"
    rule_set_version       = "3.2"
    file_upload_limit_mb   = 100
    request_body_check     = true
    max_request_body_size_kb = 128
    disabled_rule_groups = []
    exclusions = []
  }

  ssl_policy = {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  private_link_configuration = {
    enabled = false
  }

  tags = {
    environment = "dev"
    workload    = "oai"
  }
}

# Managed Identity configuration
managed_identity = {
  name                = "id-agw-gpt-dev-001"
  assign_key_vault_role = true  
  tags = {
    environment = "dev"
    workload    = "oai"
  }
}


# Public IPs
public_ips = {
  "pip_agw_gpt_dev" = {
    name              = "pip-agw-gpt-dev"
    allocation_method = "Static"
    sku              = "Standard"
    sku_tier         = "Regional"
    zones            = ["1", "2", "3"]
    tags = {
      environment = "dev"
      workload    = "oai"
    }
  }
}

# Configuración de Private Endpoints
private_endpoints = {
  # Key Vault Private Endpoint
  "pe-kv-gpt-oai-dev" = {
    name              = "pe-kv-gpt-oai-dev"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.KeyVault/vaults/kv-gpt-oai-dev-001-demo"
    subresource_names = ["vault"]
    private_dns_zone_ids = [
      "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
    ]
  },
  
  # Cosmos DB Private Endpoint
  "pe-cosmos-gpt-db-dev" = {
    name              = "pe-cosmos-gpt-db-dev"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-gpt-db-dev-demo"
    subresource_names = ["Sql"]
    private_dns_zone_ids = [
      "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com"
    ]
  },
  
  # Storage Account Blob Private Endpoint
  "pe-stgptdev001-blob" = {
    name              = "pe-stgptdev001-blob"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Storage/storageAccounts/stgptdev001demo"
    subresource_names = ["blob"]
    private_dns_zone_ids = [
      "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    ]
  },
  
  # Redis Cache Private Endpoint
  "pe-redis-gpt-cache-dev" = {
    name              = "pe-redis-gpt-cache-dev"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Cache/Redis/redis-gpt-cache-dev-demo"
    subresource_names = ["redisCache"]
    private_dns_zone_ids = [
      "/subscriptions/8ceae346-107e-495e-81a7-bc733dcf308c/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"
    ]
  },
  
  # Container Registry Private Endpoint
  "pe-crgptoaidev" = {
    name              = "pe-crgptoaidev"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/{subscription_id}/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.ContainerRegistry/registries/crgptoaidevdemo"
    subresource_names = ["registry"]
    private_dns_zone_ids = [
      "/subscriptions/{subscription_id}/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
    ]
  },
  
  # API Management Private Endpoint
  # "pe-apim-gpt-api-dev" = {
  #   name              = "pe-apim-gpt-api-dev"
  #   subnet_key        = "snet_gpt_int_dev"
  #   resource_id       = "/subscriptions/{subscription_id}/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.ApiManagement/service/apim-gpt-api-dev-demo"
  #   subresource_names = ["gateway"]
  #   private_dns_zone_ids = [
  #     "/subscriptions/{subscription_id}/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
  #   ]
  # }
}
# Configuración de Private DNS Zones
private_dns_zones = {
  "privatelink.vaultcore.azure.net" = {
    name = "privatelink.vaultcore.azure.net"
  },
  "privatelink.documents.azure.com" = {
    name = "privatelink.documents.azure.com"
  },
  "privatelink.blob.core.windows.net" = {
    name = "privatelink.blob.core.windows.net"
  },
  "privatelink.file.core.windows.net" = {
    name = "privatelink.file.core.windows.net"
  },
  "privatelink.table.core.windows.net" = {
    name = "privatelink.table.core.windows.net"
  },
  "privatelink.redis.cache.windows.net" = {
    name = "privatelink.redis.cache.windows.net"
  },
  "privatelink.azurecr.io" = {
    name = "privatelink.azurecr.io"
  },
  "privatelink.azure-api.net" = {
    name = "privatelink.azure-api.net"
  },
  "privatelink.azurewebsites.net" = {
    name = "privatelink.azurewebsites.net"
  }
}
