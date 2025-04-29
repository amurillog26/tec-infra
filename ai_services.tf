# # ai_services.tf

# # 1. Speech Services en tu región original (South Central US)
# resource "azurerm_cognitive_account" "speech_services" {
#   name                  = "tecgpt-speech-${var.environment}"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   kind                  = "SpeechServices"
#   sku_name              = "S0"
#   custom_subdomain_name = "cs-speech-${var.environment}"

#   public_network_access_enabled = false
  
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

# # 2. Azure OpenAI Service en East US
# resource "azurerm_cognitive_account" "openai" {
#   name                  = "tecgpt-account-${var.environment}"
#   location              = "eastus"  # Región donde están disponibles los modelos
#   resource_group_name   = var.resource_group_name
#   kind                  = "OpenAI"
#   sku_name              = "S0"
#   custom_subdomain_name = "tecgpt-account-${var.environment}"

#   # Para permitir la conexión privada entre regiones
#   public_network_access_enabled = false
  
#   network_acls {
#     default_action = "Deny"
#     ip_rules       = []
#  }

#   tags = merge(var.tags, {
#     service = "openai"
#   })
# }

# # Despliegue del modelo DALL-E 3
# resource "azurerm_cognitive_deployment" "dalle" {
#   name                 = "tecgpt-dalle-3-${var.environment}"
#   cognitive_account_id = azurerm_cognitive_account.openai.id
#   model {
#     format  = "OpenAI"
#     name    = "dall-e-3"
#     version = "3.0"
#   }

#   sku {
#     name     = "Standard"
#   }
# }

# # Private Endpoint para OpenAI
# resource "azurerm_private_endpoint" "openai_pe" {
#   name                = "pe-openai-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

#   private_service_connection {
#     name                           = "private-link-openai"
#     private_connection_resource_id = azurerm_cognitive_account.openai.id
#     is_manual_connection           = false
#     subresource_names              = ["account"]
#   }

#   private_dns_zone_group {
#     name                 = "dns-zone-group-openai"
#     private_dns_zone_ids = [module.private_dns_zone["privatelink.openai.azure.com"].id]
#   }

#   tags = var.tags
# }

# # Secretos para Speech Services
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

# # Secretos para OpenAI y sus modelos
# resource "azurerm_key_vault_secret" "openai_key" {
#   name         = "openai-key"
#   value        = azurerm_cognitive_account.openai.primary_access_key
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "openai_endpoint" {
#   name         = "openai-endpoint"
#   value        = azurerm_cognitive_account.openai.endpoint
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "openai_dalle_endpoint" {
#   name         = "openai-dalle-endpoint"
#   value        = "${azurerm_cognitive_account.openai.endpoint}/openai/deployments/dalle-3/images/generations?api-version=2023-12-01-preview"
#   key_vault_id = module.key_vault.kv_id
# }
# # Recurso para el servicio OpenAI de Whisper
# resource "azurerm_cognitive_account" "whisper_openai" {
#   name                  = "tecgpt-whisper-${var.environment}"
#   location              = "eastus2"  # Región específica para Whisper
#   resource_group_name   = var.resource_group_name
#   kind                  = "OpenAI"
#   sku_name              = "S0"
#   custom_subdomain_name = "tecgpt-whisper-${var.environment}"

#   # Configuración de acceso de red privado
#   public_network_access_enabled = false
  
#   network_acls {
#     default_action = "Deny"
#     ip_rules       = []
#   }

#   tags = merge(var.tags, {
#     service = "whisper-openai"
#     environment = var.environment
#   })
# }

# # Despliegue del modelo Whisper
# resource "azurerm_cognitive_deployment" "whisper" {
#   name                 = "tecgpt-whisper-${var.environment}"
#   cognitive_account_id = azurerm_cognitive_account.whisper_openai.id
#   model {
#     format  = "OpenAI"
#     name    = "whisper"
#     version = "001"  # Versión del modelo Whisper
#   }
#   sku {
#     name = "Standard"
#   }
# }

# # Private Endpoint para Whisper OpenAI
# resource "azurerm_private_endpoint" "whisper_pe" {
#   name                = "pe-whisper-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

#   private_service_connection {
#     name                           = "private-link-whisper"
#     private_connection_resource_id = azurerm_cognitive_account.whisper_openai.id
#     is_manual_connection           = false
#     subresource_names              = ["account"]
#   }

#   private_dns_zone_group {
#     name                 = "dns-zone-group-whisper"
#     private_dns_zone_ids = [module.private_dns_zone["privatelink.openai.azure.com"].id]
#   }

#   tags = var.tags
# }

# # Secretos para Whisper OpenAI
# resource "azurerm_key_vault_secret" "whisper_key" {
#   name         = "whisper-key"
#   value        = azurerm_cognitive_account.whisper_openai.primary_access_key
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "whisper_endpoint" {
#   name         = "whisper-endpoint"
#   value        = azurerm_cognitive_account.whisper_openai.endpoint
#   key_vault_id = module.key_vault.kv_id
# }

# resource "azurerm_key_vault_secret" "whisper_deployment_endpoint" {
#   name         = "whisper-deployment-endpoint"
#   value        = "${azurerm_cognitive_account.whisper_openai.endpoint}/openai/deployments/tecgpt-whisper-${var.environment}/audio/transcriptions?api-version=2023-09-01-preview"
#   key_vault_id = module.key_vault.kv_id
# }

# # Secretos con nombres compatibles con la estructura existente
# # resource "azurerm_key_vault_secret" "whisper_endpointkey" {
# #   name         = "whisper-endpointkey"
# #   value        = azurerm_cognitive_account.whisper_openai.primary_access_key
# #   key_vault_id = module.key_vault.kv_id
# # }

# # resource "azurerm_key_vault_secret" "whisper_endpointname" {
# #   name         = "whisper-endpointname"
# #   value        = azurerm_cognitive_account.whisper_openai.endpoint
# #   key_vault_id = module.key_vault.kv_id
# # }

# # resource "azurerm_key_vault_secret" "whisper_endpointmodelname" {
# #   name         = "whisper-endpointmodelname"
# #   value        = "tecgpt-whisper-${var.environment}"
# #   key_vault_id = module.key_vault.kv_id
# # }

# # resource "azurerm_key_vault_secret" "whisper_endpointregion" {
# #   name         = "whisper-endpointregion"
# #   value        = "eastus2"
# #   key_vault_id = module.key_vault.kv_id
# # }
