# aks_nsg_rules.tf - Versión elegante que busca todos los NSGs

locals {
  # Nombre del resource group gestionado por AKS
  aks_mc_resource_group = "MC_rg_gpt_oai_${var.environment}_aks-gpt-${var.environment}-001_southcentralus"
}

data "azurerm_resources" "aks_nsgs" {
  depends_on = [module.aks]
  
  resource_group_name = local.aks_mc_resource_group
  type                = "Microsoft.Network/networkSecurityGroups"
}

# Data source para obtener detalles del primer NSG que empiece con "aks-agentpool"
data "azurerm_network_security_group" "aks_nsg" {
  depends_on = [data.azurerm_resources.aks_nsgs]
  
  # Buscar el primer NSG que coincida con el patrón
  name = [
    for nsg in data.azurerm_resources.aks_nsgs.resources : 
    nsg.name 
    if can(regex("^aks-agentpool-.*-nsg$", nsg.name))
  ][0]
  
  resource_group_name = local.aks_mc_resource_group
}

# Crear las reglas de NSG
resource "azurerm_network_security_rule" "allow_aks_to_apim" {
  name                        = "Allow-AKS-To-APIM"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = module.networking.subnet_address_prefixes["snet_gpt_apim_${var.environment}"]
  resource_group_name         = data.azurerm_network_security_group.aks_nsg.resource_group_name
  network_security_group_name = data.azurerm_network_security_group.aks_nsg.name
}

resource "azurerm_network_security_rule" "allow_apim_to_aks" {
  name                        = "Allow-APIM-To-AKS"
  priority                    = 210
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = module.networking.subnet_address_prefixes["snet_gpt_apim_${var.environment}"]
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_network_security_group.aks_nsg.resource_group_name
  network_security_group_name = data.azurerm_network_security_group.aks_nsg.name
}

# Outputs para debugging
output "aks_nsg_discovered_name" {
  value = data.azurerm_network_security_group.aks_nsg.name
  description = "Nombre del NSG de AKS descubierto dinámicamente"
}

output "aks_nsg_list" {
  value = [for nsg in data.azurerm_resources.aks_nsgs.resources : nsg.name]
  description = "Lista de todos los NSGs en el resource group de AKS"
}
