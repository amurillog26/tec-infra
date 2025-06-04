# terraform/modules/networking/bastion/main.tf

locals {
  bastion_sku = var.sku_name
}

# Azure Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = local.bastion_sku

  # Configuration options
  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.file_copy_enabled && local.bastion_sku == "Standard"
  scale_units           = var.scale_units
  shareable_link_enabled = var.shareable_link_enabled && local.bastion_sku == "Standard"
  tunneling_enabled      = var.tunneling_enabled && local.bastion_sku == "Standard"
  ip_connect_enabled     = var.ip_connect_enabled && local.bastion_sku == "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id           = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
  }

  tags = var.tags
}

# Monitor Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "bastion_diagnostics" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.bastion_name}-diagnostics"
  target_resource_id         = azurerm_bastion_host.bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "BastionAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
