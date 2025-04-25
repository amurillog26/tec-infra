resource "azurerm_linux_web_app" "web_app" {
  for_each = var.web_apps

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = each.value.service_plan_id
  https_only          = true
  
  virtual_network_subnet_id = each.value.subnet_id
  public_network_access_enabled = false

  site_config {
    always_on               = true
    minimum_tls_version     = "1.2"
    vnet_route_all_enabled  = each.value.subnet_id != null ? true : false
    use_32_bit_worker       = false
    ftps_state = "Disabled"
    health_check_path = "/health"
    health_check_eviction_time_in_min = 3  # Agregado este parámetro obligatorio
    http2_enabled = true
  
    dynamic "ip_restriction" {
      for_each = each.value.ip_restrictions != null ? each.value.ip_restrictions : {}
      content {
        name                      = ip_restriction.value.name
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "subnet_id", null)
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
      }
    }
    
    # Aplicar las mismas restricciones al sitio SCM
    dynamic "scm_ip_restriction" {
      for_each = each.value.ip_restrictions != null ? each.value.ip_restrictions : {}
      content {
        name                      = "${scm_ip_restriction.value.name}-scm"
        ip_address                = lookup(scm_ip_restriction.value, "ip_address", null)
        service_tag               = lookup(scm_ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(scm_ip_restriction.value, "subnet_id", null)
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action
      }
    }
  }
  logs {
    http_logs {
      file_system {
        retention_in_days = 30
        retention_in_mb = 100
      }
    }
    detailed_error_messages = true
    failed_request_tracing = true
  }

  app_settings = merge(
    each.value.app_settings,
    {
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false",
      "FTPS_STATE" = "Disabled"
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
