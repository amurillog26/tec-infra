# private_endpoints.tf

locals {
  # Determinar el nombre del storage account según el ambiente
  storage_account_name = var.environment == "dev" ? "stgptdev01" : "stgpt${var.environment}"
}

# 1. KeyVault Private Endpoint
resource "azurerm_private_endpoint" "keyvault_pe" {
  # Usar una condición basada en variables conocidas, no en outputs computados
  count = var.kv_name != "" ? 1 : 0

  name                = "pe-kv-gpt-oai-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-kv-gpt-oai-${var.environment}-connection"
    private_connection_resource_id = module.key_vault.kv_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "pe-kv-gpt-oai-${var.environment}-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.vaultcore.azure.net"].id]
  }

  tags = merge(var.tags, {
    workload = "oai"
  })

  depends_on = [module.key_vault, module.networking, module.private_dns_zone]
}

# 2. Cosmos DB Private Endpoint
resource "azurerm_private_endpoint" "cosmosdb_pe" {
  # Usar una condición basada en variables conocidas
  count = var.cosmos_account_name != "" ? 1 : 0

  name                = "pe-cosmos-gpt-db-${var.environment}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-cosmos-gpt-db-${var.environment}-01-connection"
    private_connection_resource_id = module.cosmos_db.cosmos_db_id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }

  private_dns_zone_group {
    name                 = "pe-cosmos-gpt-db-${var.environment}-01-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.documents.azure.com"].id]
  }

  tags = merge(var.tags, {
    workload = "oai"
  })

  depends_on = [module.cosmos_db, module.networking, module.private_dns_zone]
}

# 3. Storage Account Table Private Endpoint
resource "azurerm_private_endpoint" "storage_table_pe" {
  # Usar una condición basada en si existe la configuración de storage
  count = contains(keys(var.storage_accounts), local.storage_account_name) ? 1 : 0

  name                = "pe-${local.storage_account_name}-table"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-${local.storage_account_name}-table-connection"
    private_connection_resource_id = module.storage.storage_accounts[local.storage_account_name].id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "pe-${local.storage_account_name}-table-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.table.core.windows.net"].id]
  }

  tags = merge(var.tags, {
    workload = "oai"
  })

  depends_on = [module.storage, module.networking, module.private_dns_zone]
}

# 4. Storage Account Blob Private Endpoint
resource "azurerm_private_endpoint" "storage_blob_pe" {
  # Usar una condición basada en si existe la configuración de storage
  count = contains(keys(var.storage_accounts), local.storage_account_name) ? 1 : 0

  name                = "pe-${local.storage_account_name}-blob-cdn"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-${local.storage_account_name}-blob-cdn-connection"
    private_connection_resource_id = module.storage.storage_accounts[local.storage_account_name].id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "pe-${local.storage_account_name}-blob-cdn-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.blob.core.windows.net"].id]
  }

  tags = var.tags

  depends_on = [module.storage, module.networking, module.private_dns_zone]
}

# 5. Redis Cache Private Endpoint
# NOTA: Actualmente solo soporta Redis Standard, no Redis Enterprise
# Para prod con Redis Enterprise, el private endpoint debe crearse manualmente o actualizar el módulo
resource "azurerm_private_endpoint" "redis_pe" {
  # Solo crear si es Redis Standard (no Enterprise) y existe la configuración
  for_each = {
    for k, v in var.redis_cache : k => v
    if k == "redis_gpt_cache_${var.environment}" && !lookup(v, "is_enterprise", false)
  }

  name                = "pe-redis-gpt-cache-${var.environment}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-redis-gpt-cache-${var.environment}-01-connection"
    private_connection_resource_id = module.redis.redis_cache_ids[each.key]
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "pe-redis-gpt-cache-${var.environment}-01-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.redis.cache.windows.net"].id]
  }

  tags = merge(var.tags, {
    workload = "oai"
  })

  depends_on = [module.redis, module.networking, module.private_dns_zone]
}

# 6. Container Registry Private Endpoint
resource "azurerm_private_endpoint" "acr_pe" {
  # Usar una condición basada en variables conocidas
  count = var.acr_name != "" ? 1 : 0

  name                = "pe-${var.acr_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-${var.acr_name}-connection"
    private_connection_resource_id = module.container_registry.id_container_registry
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "pe-${var.acr_name}-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.azurecr.io"].id]
  }

  tags = merge(var.tags, {
    workload = "oai"
  })

  depends_on = [module.container_registry, module.networking, module.private_dns_zone]
}

# 7. Grafana Private Endpoint (comentado, pero corregido)
# resource "azurerm_private_endpoint" "grafana_pe" {
#   # Usar una condición basada en la existencia del módulo grafana
#   count = contains(["dev", "pprd"], var.environment) ? 1 : 0
#   
#   name                = "pe-grafana-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]
#
#   private_service_connection {
#     name                           = "pe-grafana-${var.environment}-connection"
#     private_connection_resource_id = module.grafana[0].id
#     is_manual_connection           = false
#     subresource_names              = ["grafana"]
#   }
#
#   private_dns_zone_group {
#     name                 = "pe-grafana-${var.environment}-dns-zone-group"
#     private_dns_zone_ids = [module.private_dns_zone["privatelink.grafana.azure.com"].id]
#   }
#
#   tags = merge(var.tags, {
#     workload = "oai"
#   })
#   
#   depends_on = [module.grafana, module.networking, module.private_dns_zone]
# }
