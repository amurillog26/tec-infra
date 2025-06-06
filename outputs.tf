# outputs.tf - Outputs para usar en el Key Vault

# Storage Account outputs
output "storage_outputs" {
  description = "Valores de cuentas de storage para poblar el Key Vault"
  value = {
    for k, v in module.storage.storage_accounts : k => {
      primary_access_key = v.primary_access_key
      connection_string  = "${v.primary_blob_endpoint};AccountKey=${v.primary_access_key}"
    }
  }
  sensitive = true
}

# Nombre de storage dinámico para referencias
output "storage_account_name" {
  description = "Nombre del Storage Account principal según el ambiente"
  value       = "stgpt${var.environment}01"
}

# Cosmos DB outputs
output "cosmos_db_outputs" {
  description = "Valores de Cosmos DB para poblar el Key Vault"
  value = {
    primary_key = module.cosmos_db.cosmos_db_primary_key
    endpoint    = module.cosmos_db.cosmos_db_endpoint
  }
  sensitive = true
}

# Redis Cache outputs
output "redis_outputs" {
  description = "Valores de Redis para poblar el Key Vault"
  value = {
    hostname          = lookup(module.redis.redis_cache_hostnames, "redis_gpt_cache_${var.environment}", null)
    primary_key       = lookup(module.redis.redis_cache_connection_strings, "redis_gpt_cache_${var.environment}", null)
    connection_string = lookup(module.redis.redis_cache_connection_strings, "redis_gpt_cache_${var.environment}", null)
  }
  sensitive = true
}

# ACR outputs
output "acr_outputs" {
  description = "Valores de ACR para poblar el Key Vault"
  value = {
    admin_username = module.container_registry.acr_admin_username
    admin_password = module.container_registry.acr_admin_password
  }
  sensitive = true
}

# AKS outputs
output "aks_outputs" {
  description = "Valores de AKS para poblar el Key Vault"
  value = {
    kube_config  = module.aks.kube_config
    principal_id = module.aks.key_vault_access_policy.object_id
  }
  sensitive = true
}

# Para generar un token JWT deterministico (solo para desarrollo)
output "jwt_signing_key" {
  description = "Clave para firmar tokens JWT (solo para desarrollo)"
  value       = sha256("${var.environment}-jwt-key-${formatdate("YYYY-MM-DD", timestamp())}")
  sensitive   = true
}

# Para generar una clave de cifrado determinística (solo para desarrollo)
output "encryption_key" {
  description = "Clave para cifrado (solo para desarrollo)"
  value       = sha256("${var.environment}-encryption-${formatdate("YYYY-MM-DD", timestamp())}")
  sensitive   = true
}
