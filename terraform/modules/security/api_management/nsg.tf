locals {
  dp_access_whitelist = flatten([
    for ipslist in var.apim_developer_portal_whitelist : [
      for ip in ipslist : [ip]
    ]
  ])
}

resource "azurerm_network_security_group" "apim_nsg" {
  name                = var.apim_nsg_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
}

resource "azurerm_network_security_rule" "restrict_incoming_traffic_frontdoor" {
  name                        = "restrict_incoming_traffic_frontdoor"
  priority                    = 2000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "AzureFrontDoor.Backend"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.main_rg_name
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
}

resource "azurerm_network_security_rule" "access_developer_portal" {
  name                        = "restrict_incoming_traffic_developerportal"
  priority                    = 2500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  source_address_prefixes     = local.dp_access_whitelist

  destination_port_ranges     = ["443"]

  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.main_rg_name
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
}

resource "azurerm_network_security_rule" "management_endpoint__powershell" {
  name                        = "management_endpoint__powershell"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3443"
  source_address_prefix       = "ApiManagement"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.main_rg_name
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
}

resource "azurerm_network_security_rule" "azure_infrastructure_load_balancer" {
  name                        = "azure_infrastructure_load_balancer"
  priority                    = 700
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6390"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.main_rg_name
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
}

resource "azurerm_network_security_rule" "dependency_azure_storage" {
  name                        = "dependency_azure_storage"
  priority                    = 800
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "433"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Storage"
  resource_group_name         = var.main_rg_name
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
}

resource "azurerm_network_security_rule" "access_sql_endpoints" {
  name                        = "access_sql_endpoints"
  priority                    = 900
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "Sql"
  resource_group_name         = var.main_rg_name
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
}

resource "azurerm_network_security_rule" "access_key_vault" {
  name                        = "access_key_vault"
  priority                    = 1000
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureKeyVault"
  resource_group_name         = var.main_rg_name
  network_security_group_name = azurerm_network_security_group.apim_nsg.name
}
