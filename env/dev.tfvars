resource_group_name = "rg_gpt_oai_dev"
location           = "southcentralus"
environment = "dev"

storage_accounts = {
  "stgptdev01" = {
    name = "stgptdev01"
    account_tier = "Standard"
    account_replication_type = "LRS"
    
    network_rules = {
      default_action = "Allow"
      bypass = ["AzureServices"]
      ip_rules = []
    }
    tables = [
      {
        name = "gpt"
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
kv_name             = "kv-gpt-oai-dev-01"
kv_sku_name         = "standard"

resource_tags = {
    environment = "dev"
    workload = "oai"
}

tenant_id = "c65a3ea6-0f7c-400b-8934-5a6dc1705645"

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

cosmos_account_name        = "cosmos-gpt-db-dev-01"
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
acr_name           = "crgptoaidev01"  # Debe ser globalmente único
acr_admin_enabled  = true           # Habilitado para desarrollo
acr_public         = true           # Público para desarrollo

service_plans = {
  "plan1" = {
    name                    = "asp-gpt-api-dev"
    sku_name               = "B1"
    os_type                = "Linux"
    worker_count           = 1
    zone_balancing_enabled = false
  }
}

# Web Apps
web_apps = {
  "api" = {
    name            = "app-gpt-api-dev"
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
  name                = "apim-gpt-api-dev-01"  # Nuevo nombre
  publisher_name      = "GPT Dev Team"
  publisher_email     = "admin@yourdomain.com"
  sku_name           = "Developer_1"
  capacity           = 1
  
  # Para habilitar Private Endpoints, necesitamos:
  # 1. Una configuración de red virtual
  virtual_network_type = "External"  # o "Internal" dependiendo de tus requisitos
  subnet_id = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/virtualNetworks/vnet_gpt_net_dev/subnets/snet_gpt_int_dev"  
  # 2. Otras configuraciones necesarias
  identity_type       = "SystemAssigned"
  
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
  
  additional_settings = {
    enable_sign_in = true
    enable_sign_up = true
  }
  
  # Resto de tus configuraciones (products, apis, etc.)
  products = {}
  apis = {}
  named_values = {}
  
  tags = {
    environment = "dev"
    workload = "gpt-api"
  }
}


redis_cache = {
  "redis_gpt_cache_dev" = {
    name                = "redis-gpt-cache-dev-01"
    capacity            = 1
    family             = "P"
    sku_name           = "Premium"
    minimum_tls_version = "1.2"
    
    redis_configuration = {
      maxmemory_policy     = "allkeys-lru"
      maxfragmentationmemory_reserved = 642
      maxmemory_reserved              = 642
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
      fqdns = ["app-gpt-api-dev.azurewebsites.net"]
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
      host               = "app-gpt-api-dev.azurewebsites.net"
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
    resource_id       = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.KeyVault/vaults/kv-gpt-oai-dev-01"
    subresource_names = ["vault"]
    private_dns_zone_ids = [
      "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
    ]
  },
  
  # Cosmos DB Private Endpoint
  "pe-cosmos-gpt-db-dev-01" = {
    name              = "pe-cosmos-gpt-db-dev-01"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.DocumentDB/databaseAccounts/cosmos-gpt-db-dev-01"
    subresource_names = ["Sql"]
    private_dns_zone_ids = [
      "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.documents.azure.com"
    ]
  },
  
  # Storage Account Blob Private Endpoint
  "pe-stgptdev001-table" = {
    name              = "pe-stgptdev01-table"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Storage/storageAccounts/stgptdev01"
    subresource_names = ["table"]
    private_dns_zone_ids = [
      "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
    ]
  },
  
  # Redis Cache Private Endpoint
  "pe-redis-gpt-cache-dev-01" = {
    name              = "pe-redis-gpt-cache-dev-01"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Cache/Redis/redis-gpt-cache-dev-01"
    subresource_names = ["redisCache"]
    private_dns_zone_ids = [
      "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"
    ]
  },
  
  # Container Registry Private Endpoint
  "pe-crgptoaidev01" = {
    name              = "pe-crgptoaidev01"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.ContainerRegistry/registries/crgptoaidev01"
    subresource_names = ["registry"]
    private_dns_zone_ids = [
      "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
    ]
  },
  
  # API Management Private Endpoint
  "pe-apim-gpt-api-dev-01" = {
    name              = "pe-apim-gpt-api-dev-01"
    subnet_key        = "snet_gpt_int_dev"
    resource_id       = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.ApiManagement/service/apim-gpt-api-dev-01"
    subresource_names = ["gateway"]
    private_dns_zone_ids = [
      "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
    ]
  }
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

# Windows VM Configuration
windows_vm = {
  name           = "vm-gpt-win-dev"
  nic_name       = "nic-gpt-win11-dev"
  size           = "Standard_B4ms"
  admin_username = "adminuser"
  admin_password = "P@ssw0rd1234!" # ¡Considera usar Azure Key Vault en producción!
  hostname       = "win-workstation"
  tags = {
    environment = "dev"
    workload    = "oai"
    type        = "workstation"
  }
}

# Azure Managed Grafana Configuration
grafana = {
  name                            = "grafana-gpt-dev"
  sku_name                        = "Standard"
  api_key_enabled                 = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled   = true
  zone_redundancy_enabled         = false
  identity_type                   = "SystemAssigned"
  
  # Opcional: Integración con Azure Monitor
  # azure_monitor_workspace_id    = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Monitor/accounts/monitorws-gpt-dev"
  
  # Opcional: Private Endpoint
  # private_endpoint_resource_id  = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/virtualNetworks/vnet_gpt_net_dev/subnets/snet_gpt_pe_dev"
  # private_endpoint_subresource_name = "grafana"
  
  # Asignación de roles (opcional)
  admin_principal_ids           = [
    # IDs de los usuarios/grupos que serán administradores
  ]
  editor_principal_ids          = [
    # IDs de los usuarios/grupos que serán editores
  ]
  viewer_principal_ids          = [
    # IDs de los usuarios/grupos que serán visualizadores
  ]
  
  tags = {
    environment = "dev"
    workload    = "monitoring"
  }
}
