# main.tf
resource "azurerm_public_ip" "fw_pip" {
  name                = var.fw_public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall_policy" "fw_policy" {
  name                = var.fw_policy_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.fw_sku_tier
  
  dns {
    proxy_enabled = var.dns_proxy_enabled
  }

  insights {
    enabled                            = var.enable_fw_insights
    default_log_analytics_workspace_id = var.log_analytics_workspace_id
    retention_in_days                  = var.log_retention_days
  }
  
  tags = var.tags
}

resource "azurerm_firewall" "fw" {
  name                = var.fw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.fw_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.fw_policy.id
  
  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = var.fw_subnet_id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
  
  tags = var.tags
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.fw_name}-diag"
  target_resource_id         = azurerm_firewall.fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}

# Optional route table for forced tunneling
resource "azurerm_route_table" "fw_route_table" {
  count               = var.create_route_table ? 1 : 0
  name                = "${var.fw_name}-routes"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  dynamic "route" {
    for_each = var.route_table_routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
  
  tags = var.tags
}