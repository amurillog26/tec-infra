# # Azure Cognitive Search Service
# resource "azurerm_search_service" "search_service" {
#   name                = "tecgpt-search-${var.environment}"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   sku                 = "standard"  # Opciones: free, basic, standard, standard2, standard3, storage_optimized_l1, storage_optimized_l2
#   replica_count       = 1
#   partition_count     = 1
#   hosting_mode        = "default"  # Default o HighDensity
  
#   # Configuración de red privada
#   public_network_access_enabled = false

#   # Identidad administrada
#   identity {
#     type = "SystemAssigned"
#   }

#   tags = merge(var.tags, {
#     service = "search-service"
#     environment = var.environment
#   })
# }

# # Private Endpoint para Azure Search
# resource "azurerm_private_endpoint" "search_pe" {
#   name                = "pe-search-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

#   private_service_connection {
#     name                           = "private-link-search"
#     private_connection_resource_id = azurerm_search_service.search_service.id
#     is_manual_connection           = false
#     subresource_names              = ["searchService"]
#   }
  
#   # Usamos el recurso de zona DNS directamente en vez del módulo
#   # Aplicaremos la configuración de DNS posteriormente
  
#   tags = var.tags
# }

# # Configuración de DNS para el endpoint después de que se cree
# resource "azurerm_private_dns_a_record" "search_dns_record" {
#   name                = azurerm_search_service.search_service.name
#   zone_name           = "privatelink.search.windows.net"
#   resource_group_name = var.resource_group_name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.search_pe.private_service_connection[0].private_ip_address]
  
#   # Necesitamos que exista la zona DNS privada
#   depends_on = [
#     module.private_dns_zone
#   ]
# }

# # Añadir las claves y endpoints al Key Vault
# resource "azurerm_key_vault_secret" "search_admin_key" {
#   name         = "search-admin-key"
#   value        = azurerm_search_service.search_service.primary_key
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "search_query_key" {
#   name         = "search-query-key"
#   value        = azurerm_search_service.search_service.query_keys[0].key
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "search_endpoint" {
#   name         = "search-endpoint"
#   value        = "https://${azurerm_search_service.search_service.name}.search.windows.net"
#   key_vault_id = module.key_vault.kv_id
# }

# # Secretos compatibles con nombres existentes
# # resource "azurerm_key_vault_secret" "search_service_key" {
# #   name         = "gpt-skrill-${var.environment}-search-admin-key"
# #   value        = azurerm_search_service.search_service.primary_key
# #   key_vault_id = module.key_vault.kv_id
# # }

# # resource "azurerm_key_vault_secret" "search_service_endpoint" {
# #   name         = "gpt-skrill-${var.environment}-search-endpoint"
# #   value        = "https://${azurerm_search_service.search_service.name}.search.windows.net"
# #   key_vault_id = module.key_vault.kv_id
# # }


# # Outputs
# output "search_service_id" {
#   description = "ID del servicio Azure Cognitive Search"
#   value       = azurerm_search_service.search_service.id
# }

# output "search_service_endpoint" {
#   description = "Endpoint del servicio Azure Cognitive Search"
#   value       = "https://${azurerm_search_service.search_service.name}.search.windows.net"
# }

# output "search_private_ip" {
#   description = "IP privada del Private Endpoint de Azure Search"
#   value       = azurerm_private_endpoint.search_pe.private_service_connection[0].private_ip_address
#   depends_on  = [azurerm_private_endpoint.search_pe]
# }
