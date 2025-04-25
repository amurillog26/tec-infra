# Función local para generar los endpoints dinámicamente (con outputs de módulos)
locals {
  # Generar private endpoints basados en los outputs de módulos
  dynamic_private_endpoints = {
    # Key Vault Private Endpoint
    "pe-kv-gpt-oai-${var.environment}" = {
      name              = "pe-kv-gpt-oai-${var.environment}"
      subnet_key        = "snet_gpt_pe_${var.environment}"
      resource_id       = module.key_vault.kv_id
      subresource_names = ["vault"]
      private_dns_zone_ids = [
        try(module.private_dns_zone["privatelink.vaultcore.azure.net"].id, "")
      ]
    },
    
    # Cosmos DB Private Endpoint
    "pe-cosmos-gpt-db-${var.environment}-01" = {
      name              = "pe-cosmos-gpt-db-${var.environment}-01"
      subnet_key        = "snet_gpt_pe_${var.environment}"
      resource_id       = module.cosmos_db.cosmos_db_id
      subresource_names = ["Sql"]
      private_dns_zone_ids = [
        try(module.private_dns_zone["privatelink.documents.azure.com"].id, "")
      ]
    },
    
    # Storage Account Table Private Endpoint
    "pe-stgpt${var.environment}001-table" = {
      name              = "pe-stgpt${var.environment}01-table"
      subnet_key        = "snet_gpt_pe_${var.environment}"
      resource_id       = lookup(module.storage.storage_accounts, "stgpt${var.environment}01", {id = ""}).id
      subresource_names = ["table"]
      private_dns_zone_ids = [
        try(module.private_dns_zone["privatelink.table.core.windows.net"].id, "")
      ]
    },
    
    # Storage Account Blob Private Endpoint
    "pe-stgpt${var.environment}01-blob-cdn" = {
      name              = "pe-stgpt${var.environment}01-blob-cdn"
      subnet_key        = "snet_gpt_pe_${var.environment}"
      resource_id       = lookup(module.storage.storage_accounts, "stgpt${var.environment}01", {id = ""}).id
      subresource_names = ["blob"]
      private_dns_zone_ids = [
        try(module.private_dns_zone["privatelink.blob.core.windows.net"].id, "")
      ]
    },
    
    # Redis Cache Private Endpoint
    "pe-redis-gpt-cache-${var.environment}-01" = {
      name              = "pe-redis-gpt-cache-${var.environment}-01"
      subnet_key        = "snet_gpt_pe_${var.environment}"
      resource_id       = lookup(module.redis.redis_cache_ids, "redis_gpt_cache_${var.environment}", "")
      subresource_names = ["redisCache"]
      private_dns_zone_ids = [
        try(module.private_dns_zone["privatelink.redis.cache.windows.net"].id, "")
      ]
    },
    
    # Container Registry Private Endpoint
    "pe-crgptoai${var.environment}01" = {
      name              = "pe-crgptoai${var.environment}01"
      subnet_key        = "snet_gpt_pe_${var.environment}"
      resource_id       = module.container_registry.id_container_registry
      subresource_names = ["registry"]
      private_dns_zone_ids = [
        try(module.private_dns_zone["privatelink.azurecr.io"].id, "")
      ]
    },
    
    # ACR Private Endpoint (parece redundante con el anterior, pero manteniendo por compatibilidad)
    "pe-acr-gpt-${var.environment}" = {
      name              = "pe-acr-gpt-${var.environment}"
      subnet_key        = "snet_gpt_pe_${var.environment}"
      resource_id       = module.container_registry.id_container_registry
      subresource_names = ["registry"]
      private_dns_zone_ids = [
        try(module.private_dns_zone["privatelink.azurecr.io"].id, "")
      ]
    }
  }
  
  # Combinar endpoints dinámicos y cualquier otro adicional definido en la variable
  all_private_endpoints = merge(
    local.dynamic_private_endpoints,
    var.additional_private_endpoints
  )
}
