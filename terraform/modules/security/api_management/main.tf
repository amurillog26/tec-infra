locals {
  apim_vn_type    = "External"
}

# --------------------------------------------------
# API Management
# --------------------------------------------------
resource "azurerm_api_management" "tec_apim" {
  name                  = var.apim_name
  location              = var.main_vn_location
  resource_group_name   = var.main_rg_name
  publisher_name        = var.apim_company_name
  publisher_email       = var.apim_publisher_email
  virtual_network_type  = local.apim_vn_type
  
  virtual_network_configuration {
    subnet_id = var.apim_subnet_id
  }
  
  identity {
    type = "SystemAssigned"
  }

  sku_name = var.apim_sku_name

  tags = var.resource_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_to_apimsubnet" {
  subnet_id                 = var.apim_subnet_id
  network_security_group_id = azurerm_network_security_group.apim_nsg.id

  depends_on = [
    azurerm_network_security_group.apim_nsg
  ]
}

# -------------------------------------------------- 
# Enable Diagnostic Settings for the API Management
# --------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "tec_apim_monitor" {
  name               = var.apim_name
  target_resource_id = azurerm_api_management.tec_apim.id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  log_analytics_destination_type = "AzureDiagnostics"

  log {
    category = "GatewayLogs"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "WebSocketConnectionLogs"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
      enabled = false
    }
  }
}
