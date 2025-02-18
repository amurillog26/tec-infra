resource_group_name = "rg_gpt_oai_dev"
location           = "southcentralus"
environment = "dev"

storage_accounts = {
  "stgptdev001" = {
    name = "stgptdev001"
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
      },
      {
        name = "logs"
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
kv_name             = "kv-gpt-oai-dev-001"
kv_sku_name         = "standard"

resource_tags = {
    environment = "dev"
    workload = "oai"
}

tenant_id = "c65a3ea6-0f7c-400b-8934-5a6dc1705645"

########## vnet ##########


vnet_name           = "vnet_gpt_net_dev"
address_space       = ["10.97.174.0/23"]

subnets = {
  "snet_gpt_agw_dev" = {
    address_prefixes = ["10.97.174.0/27"]  # 32 IPs: 10.97.174.0 - 10.97.174.31
    service_endpoints = ["Microsoft.Web"]
  },
  "snet_gpt_apim_dev" = {
    address_prefixes = ["10.97.174.32/27"]  # 32 IPs: 10.97.174.32 - 10.97.174.63
    service_endpoints = ["Microsoft.Web", "Microsoft.ContainerRegistry"]
  },
  "snet_gpt_aks_dev" = {
    address_prefixes = ["10.97.174.64/27"]  # 128 IPs: 10.97.174.0 - 10.97.174.127
    service_endpoints = ["Microsoft.ContainerRegistry"]
  },
  "snet_gpt_int_dev" = {
    address_prefixes = ["10.97.174.128/27"]  # 32 IPs: 10.97.174.128 - 10.97.174.159
    service_endpoints = ["Microsoft.Web"]
  },
  "snet_gpt_vm_dev" = {
    address_prefixes = ["10.97.174.160/27"]  # 32 IPs: 10.97.174.160 - 10.97.174.191
    service_endpoints = ["Microsoft.Web"]
  }
}


########## cosmosdb ##########

cosmos_account_name        = "cosmos-gpt-db-dev"
cosmos_account_offer_type  = "Standard"
cosmos_account_kind       = "GlobalDocumentDB"
cosmos_public_access      = true  # true for dev, false for prod
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
acr_name           = "crgptoaidev"  # Debe ser globalmente único
acr_admin_enabled  = true           # Habilitado para desarrollo
acr_public         = true           # Público para desarrollo

service_plans = {
  "plan1" = {
    name                    = "asp-gpt-api-dev"
    sku_name               = "P1v2"
    os_type                = "Linux"
    worker_count           = 3
    zone_balancing_enabled = true
  }
}

# # Web Apps
# web_apps = {
#   "api" = {
#     name            = "app-gpt-api-dev"
#     subnet_id       = null  # Opcional
#     app_settings = {
#       "WEBSITES_PORT" = "8080"
#       "API_VERSION"   = "v1"
#     }
#     ip_restrictions = {}  # Opcional, pero necesitamos incluirlo vacío si no lo usamos
#   }
# }
