# -------------------------------------------------- 
# Configuracion para  Virtual Network principal
# -------------------------------------------------- 
resource "azurerm_virtual_network" "main_vn" {
  name                = var.main_vn_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  address_space       = var.main_vn_address_space
  tags                = var.resource_tags
}

# --------------------------------------------------
# Cracion de Subnet para nodos Master de AKS
# --------------------------------------------------
resource "azurerm_subnet" "aro_master_subnet" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                 = var.aro_master_subnet_name
  virtual_network_name = azurerm_virtual_network.main_vn.name
  resource_group_name  = var.main_rg_name
  address_prefixes     = var.aro_master_subnet_addr
  enforce_private_link_service_network_policies = true
  enforce_private_link_endpoint_network_policies = true
  service_endpoints = [ "Microsoft.ContainerRegistry", "Microsoft.Storage" ]
}

# --------------------------------------------------
# Cracion de Subnet para node pool de AKS
# --------------------------------------------------
resource "azurerm_subnet" "aro_worker_subnet" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                 = var.aro_worker_subnet_name
  virtual_network_name = azurerm_virtual_network.main_vn.name
  resource_group_name  = var.main_rg_name
  address_prefixes     = var.aro_worker_subnet_addr
  enforce_private_link_service_network_policies = true
  service_endpoints = [ "Microsoft.ContainerRegistry", "Microsoft.Storage" ]
}

# --------------------------------------------------
# The Subnet for the NoSql databases, Cosmos DB and
# Redis Cache
# --------------------------------------------------
resource "azurerm_subnet" "nosql_subnet" {
  lifecycle {
    ignore_changes = [resource_group_name, delegation]
  }

  name                 = var.nosql_subnet_name
  virtual_network_name = azurerm_virtual_network.main_vn.name
  resource_group_name  = var.main_rg_name
  address_prefixes     = var.nosql_subnet_addr
  # delegation {
  #   name = "delegation"
  #   service_delegation {
  #     actions = [
  #       "Microsoft.Network/virtualNetworks/subnets/action",
  #     ]
  #     name    = "Microsoft.Web/serverfarms"
  #   }
  # }
}


# --------------------------------------------------
# Cracion de Subnet para Azure Firewall
# --------------------------------------------------
resource "azurerm_subnet" "firewall_subnet" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                 = var.firewall_subnet_name
  virtual_network_name = azurerm_virtual_network.main_vn.name
  resource_group_name  = var.main_rg_name
  address_prefixes     = var.firewall_subnet_addr
}

# --------------------------------------------------
# Cracion de Subnet para VM Host
# --------------------------------------------------
resource "azurerm_subnet" "vm_subnet" {
  name                 = var.vm_subnet_name
  virtual_network_name = azurerm_virtual_network.main_vn.name
  resource_group_name  = var.main_rg_name
  address_prefixes     = var.vm_subnet_addr
}

# --------------------------------------------------
# Cracion de Subnet para Private EndPoints
# --------------------------------------------------
resource "azurerm_subnet" "private_endpoint_subnet" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                 = var.private_endpoint_subnet_name
  virtual_network_name = azurerm_virtual_network.main_vn.name
  resource_group_name  = var.main_rg_name
  address_prefixes     = var.private_endpoint_subnet_addr
  enforce_private_link_service_network_policies = true
}

# --------------------------------------------------
# The Subnet for API Managment
# --------------------------------------------------
resource "azurerm_subnet" "apimng_endpoint_subnet" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                 = var.apim_subnet_name
  virtual_network_name = azurerm_virtual_network.main_vn.name
  resource_group_name  = var.main_rg_name
  address_prefixes     = var.apim_subnet_addr
}
