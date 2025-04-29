# ai_services.tf

# 1. Speech Services en tu región original (South Central US)
resource "azurerm_cognitive_account" "speech_services" {
  name                  = "tecgpt-speech-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = "SpeechServices"
  sku_name              = "S0"
  custom_subdomain_name = "cs-speech-${var.environment}"

  public_network_access_enabled = false
  
  network_acls {
    default_action = "Deny"
    ip_rules       = []
  }

  tags = merge(var.tags, {
    service = "speech-services"
  })
}

# Private Endpoint para Speech Services
resource "azurerm_private_endpoint" "speech_services_pe" {
  name                = "pe-speech-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "private-link-speech-services"
    private_connection_resource_id = azurerm_cognitive_account.speech_services.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-speech-services"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.cognitiveservices.azure.com"].id]
  }

  tags = var.tags
}

# 2. Azure OpenAI Service en East US
resource "azurerm_cognitive_account" "openai" {
  name                  = "tecgpt-account-${var.environment}"
  location              = "eastus"  # Región donde están disponibles los modelos
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "tecgpt-account-${var.environment}"

  # Para permitir la conexión privada entre regiones
  public_network_access_enabled = false
  
  network_acls {
    default_action = "Deny"
    ip_rules       = []
 }

  tags = merge(var.tags, {
    service = "openai"
  })
}

# Despliegue del modelo DALL-E 3
resource "azurerm_cognitive_deployment" "dalle" {
  name                 = "tecgpt-dalle-3-${var.environment}"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "dall-e-3"
    version = "3.0"
  }

  sku {
    name     = "Standard"
  }
}

# Despliegue del modelo GPT-4o Audio Preview
resource "azurerm_cognitive_deployment" "gpt4o_audio" {
  name                 = "tecgpt-gpt4o-audio-${var.environment}"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "gpt-4o-audio-preview"
    version = "1"  # La versión puede variar, usa la disponible
  }
  sku {
    name     = "Standard"
  }
}

# Private Endpoint para OpenAI
resource "azurerm_private_endpoint" "openai_pe" {
  name                = "pe-openai-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]

  private_service_connection {
    name                           = "private-link-openai"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group-openai"
    private_dns_zone_ids = [module.private_dns_zone["privatelink.openai.azure.com"].id]
  }

  tags = var.tags
}

# 3. Placeholder para Bing Search
resource "azurerm_key_vault_secret" "bing_search_key" {
  name         = "bing-search-key"
  value        = "PLACEHOLDER_REQUIRES_MANUAL_UPDATE"
  key_vault_id = module.key_vault.kv_id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "bing_search_endpoint" {
  name         = "bing-search-endpoint"
  value        = "https://api.bing.microsoft.com/v7.0/search"
  key_vault_id = module.key_vault.kv_id
}

# Secretos para Speech Services
resource "azurerm_key_vault_secret" "speech_key" {
  name         = "speech-services-key"
  value        = azurerm_cognitive_account.speech_services.primary_access_key
  key_vault_id = module.key_vault.kv_id
}

resource "azurerm_key_vault_secret" "speech_endpoint" {
  name         = "speech-services-endpoint"
  value        = azurerm_cognitive_account.speech_services.endpoint
  key_vault_id = module.key_vault.kv_id
}

# Secretos para OpenAI y sus modelos
resource "azurerm_key_vault_secret" "openai_key" {
  name         = "openai-key"
  value        = azurerm_cognitive_account.openai.primary_access_key
  key_vault_id = module.key_vault.kv_id
}

resource "azurerm_key_vault_secret" "openai_endpoint" {
  name         = "openai-endpoint"
  value        = azurerm_cognitive_account.openai.endpoint
  key_vault_id = module.key_vault.kv_id
}

resource "azurerm_key_vault_secret" "openai_dalle_endpoint" {
  name         = "openai-dalle-endpoint"
  value        = "${azurerm_cognitive_account.openai.endpoint}/openai/deployments/dalle-3/images/generations?api-version=2023-12-01-preview"
  key_vault_id = module.key_vault.kv_id
}

resource "azurerm_key_vault_secret" "openai_audio_endpoint" {
  name         = "openai-audio-endpoint"
  value        = "${azurerm_cognitive_account.openai.endpoint}/openai/deployments/gpt4o-audio/audio/speech?api-version=2023-12-01-preview"
  key_vault_id = module.key_vault.kv_id
}
