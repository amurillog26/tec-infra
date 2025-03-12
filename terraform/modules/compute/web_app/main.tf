# main.tf
locals {
  is_production = var.environment != "dev"
}

resource "azurerm_linux_web_app" "web_app" {
  for_each = var.web_apps

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = each.value.service_plan_id
  https_only         = true
  
  # Integración con VNet
  virtual_network_subnet_id = each.value.subnet_id
  
  site_config {
    always_on               = true
    minimum_tls_version     = "1.2"
    vnet_route_all_enabled  = each.value.vnet_route_all_enabled
    use_32_bit_worker      = false
    
    # Configuración Docker
    container_registry_use_managed_identity = false
    
    # Restricciones IP
    dynamic "ip_restriction" {
      for_each = each.value.ip_restrictions != null ? each.value.ip_restrictions : {}
      content {
        name                      = ip_restriction.value.name
        ip_address               = lookup(ip_restriction.value, "ip_address", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "subnet_id", null)
        priority                 = ip_restriction.value.priority
        action                   = ip_restriction.value.action
      }
    }
  }

  app_settings = merge(
    each.value.app_settings,
    {
      DOCKER_REGISTRY_SERVER_URL          = var.acr_login_server
      DOCKER_REGISTRY_SERVER_USERNAME     = var.acr_admin_username
      DOCKER_REGISTRY_SERVER_PASSWORD     = var.acr_admin_password
      WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
    }
  )
  
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    WebApp = each.value.name
    Environment = var.environment
  })
}
