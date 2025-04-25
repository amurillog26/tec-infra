# Obtener todos los NSGs en el grupo de recursos de AKS
data "azurerm_resources" "aks_nsgs" {
  resource_group_name = "MC_rg_gpt_oai_${var.environment}_aks-gpt-${var.environment}-001_southcentralus"
  type                = "Microsoft.Network/networkSecurityGroups"
}

# Filtrar el NSG específico usando locals
locals {
  aks_mc_resource_group = "MC_rg_gpt_oai_${var.environment}_aks-gpt-${var.environment}-001_southcentralus"
  
  # Filtrar manualmente el NSG que coincida con el patrón
  matching_nsgs = [
    for nsg in data.azurerm_resources.aks_nsgs.resources :
    nsg if length(regexall("^aks-agentpool-[0-9]+-nsg$", nsg.name)) > 0
  ]
  
  # Obtener el primer NSG que coincida
  aks_nsg_id   = length(local.matching_nsgs) > 0 ? local.matching_nsgs[0].id : ""
  aks_nsg_name = length(local.matching_nsgs) > 0 ? local.matching_nsgs[0].name : ""
}

# Obtener más detalles del NSG específico una vez identificado
data "azurerm_network_security_group" "aks_nsg" {
  count               = local.aks_nsg_name != "" ? 1 : 0
  name                = local.aks_nsg_name
  resource_group_name = local.aks_mc_resource_group
}

# Aplicar esta lógica solo si se encontró un NSG
resource "azurerm_network_security_rule" "allow_aks_to_apim" {
  count                       = local.aks_nsg_name != "" ? 1 : 0
  name                        = "Allow-AKS-To-APIM"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = module.networking.subnet_address_prefixes["snet_gpt_apim_${var.environment}"]
  resource_group_name         = local.aks_mc_resource_group
  network_security_group_name = local.aks_nsg_name
  
  depends_on = [
    module.aks,
    module.networking
  ]
}

# Regla para permitir el tráfico de entrada desde APIM a AKS
resource "azurerm_network_security_rule" "allow_apim_to_aks" {
  count                       = local.aks_nsg_name != "" ? 1 : 0
  name                        = "Allow-APIM-To-AKS"
  priority                    = 210
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = module.networking.subnet_address_prefixes["snet_gpt_apim_${var.environment}"]
  destination_address_prefix  = "*"
  resource_group_name         = local.aks_mc_resource_group
  network_security_group_name = local.aks_nsg_name
  
  depends_on = [
    module.aks,
    module.networking
  ]
}
