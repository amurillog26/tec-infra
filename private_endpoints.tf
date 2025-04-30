# private_endpoints.tf

# 1. KeyVault Private Endpoint
resource "azurerm_private_endpoint" "keyvault_pe" {
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

  count = module.key_vault.kv_id != "" ? 1 : 0
  depends_on = [module.key_vault, module.networking, module.private_dns_zone]
}

# 2. Cosmos DB Private Endpoint
resource "azurerm_private_endpoint" "cosmosdb_pe" {
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
  
  count = module.cosmos_db.cosmos_db_id != "" ? 1 : 0
  depends_on = [module.cosmos_db, module.networking, module.private_dns_zone]
}

# 3. Storage Account Table Private Endpoint
resource "azurerm_private_endpoint" "storage_table_pe" {
  name                = "pe-stgpt${var.environment}01-table"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-stgpt${var.environment}01-table-connection"
    private_connection_resource_id = lookup(module.storage.storage_accounts, "stgpt${var.environment}01", {id = ""}).id
    is_manual_connection           = false
    subresource_names              = ["table"]
  }

  private_dns_zone_group {
    name                 = "pe-stgpt${var.environment}01-table-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.table.core.windows.net"].id]
  }

  tags = merge(var.tags, {
    workload = "oai"
  })
  
  count = contains(keys(module.storage.storage_accounts), "stgpt${var.environment}01") ? 1 : 0
  depends_on = [module.storage, module.networking, module.private_dns_zone]
}

# 4. Storage Account Blob Private Endpoint
resource "azurerm_private_endpoint" "storage_blob_pe" {
  name                = "pe-stgpt${var.environment}01-blob-cdn"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-stgpt${var.environment}01-blob-cdn-connection"
    private_connection_resource_id = lookup(module.storage.storage_accounts, "stgpt${var.environment}01", {id = ""}).id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "pe-stgpt${var.environment}01-blob-cdn-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.blob.core.windows.net"].id]
  }

  # Nota: Este PE parece NO tener el tag workload
  tags = var.tags
  
  count = contains(keys(module.storage.storage_accounts), "stgpt${var.environment}01") ? 1 : 0
  depends_on = [module.storage, module.networking, module.private_dns_zone]
}

# 5. Redis Cache Private Endpoint
resource "azurerm_private_endpoint" "redis_pe" {
  name                = "pe-redis-gpt-cache-${var.environment}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-redis-gpt-cache-${var.environment}-01-connection"
    private_connection_resource_id = lookup(module.redis.redis_cache_ids, "redis_gpt_cache_${var.environment}", "")
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
  
  count = contains(keys(module.redis.redis_cache_ids), "redis_gpt_cache_${var.environment}") ? 1 : 0
  depends_on = [module.redis, module.networking, module.private_dns_zone]
}

# 6. Container Registry Private Endpoint
resource "azurerm_private_endpoint" "acr_pe" {
  name                = "pe-crgptoai${var.environment}01"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "pe-crgptoai${var.environment}01-connection"
    private_connection_resource_id = module.container_registry.id_container_registry
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "pe-crgptoai${var.environment}01-dns-zone-group"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.azurecr.io"].id]
  }

  tags = merge(var.tags, {
    workload = "oai"
  })
  
  count = module.container_registry.id_container_registry != "" ? 1 : 0
  depends_on = [module.container_registry, module.networking, module.private_dns_zone]
}

# # 7. Grafana Private Endpoint
# resource "azurerm_private_endpoint" "grafana_pe" {
#   name                = "pe-grafana-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

#   private_service_connection {
#     name                           = "pe-grafana-${var.environment}-connection"
#     private_connection_resource_id = try(module.grafana.id, "")
#     is_manual_connection           = false
#     subresource_names              = ["grafana"]
#   }

#   private_dns_zone_group {
#     name                 = "pe-grafana-${var.environment}-dns-zone-group"
#     private_dns_zone_ids = [module.private_dns_zone["privatelink.grafana.azure.com"].id]
#   }

#   tags = merge(var.tags, {
#     workload = "oai"
#   })
  
#   count = try(module.grafana.id != "", false) ? 1 : 0
#   depends_on = [module.grafana, module.networking, module.private_dns_zone]
# }
