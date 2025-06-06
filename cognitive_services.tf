# # cognitive_services.tf

# # Recurso para Bing Search
# resource "azurerm_cognitive_account" "bing_search" {
#   name                  = "cs-bing-search-${var.environment}"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   kind                  = "Bing.Search.v7"
#   sku_name              = "S1"
#   custom_subdomain_name = "cs-bing-search-${var.environment}"

#   public_network_access_enabled = false

#   # Configuración de red para permitir acceso desde la vnet
#   network_acls {
#     default_action = "Deny"
#     ip_rules       = []
#   }

#   tags = merge(var.tags, {
#     service = "bing-search"
#   })
# }

# # Private Endpoint para Bing Search
# resource "azurerm_private_endpoint" "bing_search_pe" {
#   name                = "pe-bing-search-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

#   private_service_connection {
#     name                           = "private-link-bing-search"
#     private_connection_resource_id = azurerm_cognitive_account.bing_search.id
#     is_manual_connection           = false
#     subresource_names              = ["account"]
#   }

#   private_dns_zone_group {
#     name                 = "dns-zone-group-bing-search"
#     private_dns_zone_ids = [module.private_dns_zone["privatelink.cognitiveservices.azure.com"].id]
#   }

#   tags = var.tags
# }

# # Recurso para Speech Services
# resource "azurerm_cognitive_account" "speech_services" {
#   name                  = "cs-speech-${var.environment}"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   kind                  = "SpeechServices"
#   sku_name              = "S0"
#   custom_subdomain_name = "cs-speech-${var.environment}"

#   public_network_access_enabled = false

#   # Configuración de red para permitir acceso desde la vnet
#   network_acls {
#     default_action = "Deny"
#     ip_rules       = []
#   }

#   tags = merge(var.tags, {
#     service = "speech-services"
#   })
# }

# # Private Endpoint para Speech Services
# resource "azurerm_private_endpoint" "speech_services_pe" {
#   name                = "pe-speech-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

#   private_service_connection {
#     name                           = "private-link-speech-services"
#     private_connection_resource_id = azurerm_cognitive_account.speech_services.id
#     is_manual_connection           = false
#     subresource_names              = ["account"]
#   }

#   private_dns_zone_group {
#     name                 = "dns-zone-group-speech-services"
#     private_dns_zone_ids = [module.private_dns_zone["privatelink.cognitiveservices.azure.com"].id]
#   }

#   tags = var.tags
# }

# # Añadir las claves y endpoints al Key Vault
# resource "azurerm_key_vault_secret" "bing_search_key" {
#   name         = "bing-search-key"
#   value        = azurerm_cognitive_account.bing_search.primary_access_key
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "bing_search_endpoint" {
#   name         = "bing-search-endpoint"
#   value        = azurerm_cognitive_account.bing_search.endpoint
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "speech_key" {
#   name         = "speech-services-key"
#   value        = azurerm_cognitive_account.speech_services.primary_access_key
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "speech_endpoint" {
#   name         = "speech-services-endpoint"
#   value        = azurerm_cognitive_account.speech_services.endpoint
#   key_vault_id = module.key_vault.kv_id
# }
