# CDN Profile 
resource "azurerm_cdn_profile" "cdn_profile" {
  name                = var.cdn_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"

  tags = var.tags
}

# CDN Endpoint para el contenido estático
resource "azurerm_cdn_endpoint" "cdn_endpoint_static" {
  name                = var.cdn_profile_name
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  location            = var.location
  resource_group_name = var.resource_group_name
  origin_host_header  = "${var.cdn_storage_account_name}.blob.core.windows.net"

  origin {
    name      = "static-origin"
    host_name = "${var.cdn_storage_account_name}.blob.core.windows.net"
  }

  is_compression_enabled = true
  content_types_to_compress = [
    "application/javascript", "application/json", "application/x-javascript", "application/xml", "text/css", "text/html", "text/javascript", "text/plain"
  ]

  optimization_type = "GeneralWebDelivery"

  # Configuración de caché para recursos estáticos
  delivery_rule {
    name  = "CacheImagesAndIcons"
    order = 1

    cache_expiration_action {
      behavior = "Override"
      duration = "7.00:00:00"
    }

    request_scheme_condition {
      match_values = [
        "HTTPS",
      ]
      negate_condition = false
      operator         = "Equal"
    }
  }

  tags = var.tags
}

# Salida con la URL del CDN
output "cdn_endpoint_url" {
  value       = "https://${azurerm_cdn_endpoint.cdn_endpoint_static.fqdn}"
  description = "URL del endpoint CDN para contenido estático"
}
