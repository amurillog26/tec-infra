locals {
  afw_allocation_method = "Static"
  afw_sku               = "Standard"
  afw_ipconfig_name     = "tecafwconfig"

  afw_natrule_col       = "natrulecollection"
  afw_apprule_col       = "internetrulecollection"

  afw_nrc               = "oxzafwnrctec"
  afw_rule_alltraffic   = "oxzafwrtec-all_traffic"
  afw_vm_nat       = "oxzafwrtec-vm_nat_rule"
  rt_to_firewall        = "oxzrttec-to_firewall"
  rt_route_gateway      = "oxzrtrtec-route_gateway_firewall"
}

# --------------------------------------------------
# Public IP for the Firewall configuration
# --------------------------------------------------
resource "azurerm_public_ip" "tec_pip_afw" {
  name                = var.afw_public_ip_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  allocation_method   = local.afw_allocation_method
  sku                 = local.afw_sku
}

# --------------------------------------------------
# Azure Firewall configuration
# --------------------------------------------------
resource "azurerm_firewall" "tec_afw" {
  lifecycle {
    ignore_changes = [resource_group_name, ip_configuration[0].subnet_id]
  }

  name                = var.afw_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  sku_name            = var.afw_sku_name
  sku_tier            = var.afw_sku_tier

  ip_configuration {
    name                 = local.afw_ipconfig_name
    subnet_id            = var.afw_subnet_id
    public_ip_address_id = azurerm_public_ip.tec_pip_afw.id
  }
}

resource "azurerm_firewall_network_rule_collection" "tec_afw_internet" {
  name                = local.afw_nrc
  azure_firewall_name = azurerm_firewall.tec_afw.name
  resource_group_name = var.main_rg_name
  priority            = 400
  action              = "Allow"

  rule {
    name = local.afw_rule_alltraffic

    source_addresses = concat(
      var.vm_subnet_addr, var.aro_master_subnet_addr,var.aro_worker_subnet_addr
    )
    destination_ports = ["*"]
    destination_addresses = ["*"]

    protocols = [
      "Any"
    ]
  }
}


# --------------------------------------------------
# Firewall Policy Rules for the inbound traffic by DNAT
# --------------------------------------------------
resource "azurerm_firewall_nat_rule_collection" "tec_afw_natrules" {
  name                = local.afw_natrule_col
  azure_firewall_name = azurerm_firewall.tec_afw.name
  resource_group_name = var.main_rg_name
  priority            = 500
  action              = "Dnat"

  rule {
    name = local.afw_vm_nat
    description = "SSH Connection"

    source_addresses = ["*"]
    destination_addresses = [
      azurerm_public_ip.tec_pip_afw.ip_address
    ]
    destination_ports   = ["5022"]

    translated_address  = var.vm_private_ip
    translated_port     = "22"

    protocols = [
      "TCP"
    ]
  }

  rule {
    name = "grpc-connection"
    description = "GRPC Connection"

    source_addresses = ["*"]
    destination_addresses = [
      azurerm_public_ip.tec_pip_afw.ip_address
    ]
    destination_ports   = ["5001"]

    translated_address  = var.vm_private_ip
    translated_port     = "5001"

    protocols = [
      "TCP"
    ]
  }

  rule {
    name = "sqlmi-connection"
    description = "SQLMI Connection Databases"

    source_addresses = ["*"]
    destination_addresses = [
      azurerm_public_ip.tec_pip_afw.ip_address
    ]
    destination_ports   = ["1433"]

    translated_address  = var.vm_private_ip
    translated_port     = "1433"

    protocols = [
      "TCP"
    ]
  }
}

resource "azurerm_route_table" "tec_rt_firewall" {
  name                = local.rt_to_firewall
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  disable_bgp_route_propagation = true

  route {
    name           = local.rt_route_gateway
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.tec_afw.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "vm_to_firewall" {
  subnet_id      = var.vm_subnet_id
  route_table_id = azurerm_route_table.tec_rt_firewall.id
}

# -------------------------------------------------- 
# Enable Diagnostic Settings for the Firewall
# -------------------------------------------------- 
resource "azurerm_monitor_diagnostic_setting" "tec_firewall_monitor" {
  name               = var.afw_name
  target_resource_id = azurerm_firewall.tec_afw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_analytics_destination_type = "AzureDiagnostics"

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AzureFirewallDnsProxy"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }



  log {
    category = "AZFWApplicationRule"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWApplicationRuleAggregation"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWDnsQuery"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWFatFlow"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWFlowTrace"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWFqdnResolveFailure"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWIdpsSignature"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "AZFWNatRule"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "AZFWNatRuleAggregation"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "AZFWNetworkRule"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "AZFWNetworkRuleAggregation"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AZFWThreatIntel"
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
