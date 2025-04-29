# aks_nsg_rules.tf

# Obtener los NSGs en el grupo de recursos de AKS
data "azurerm_resources" "aks_nsgs" {
  resource_group_name = "MC_rg_gpt_oai_${var.environment}_aks-gpt-${var.environment}-001_southcentralus"
  type                = "Microsoft.Network/networkSecurityGroups"
  
  # Evitar errores por dependencia circular
  depends_on = [
    module.aks
  ]
}

locals {
  aks_mc_resource_group = "MC_rg_gpt_oai_${var.environment}_aks-gpt-${var.environment}-001_southcentralus"
  
  # Filtrar el NSG solo si hay resultados
  matching_nsgs = length(data.azurerm_resources.aks_nsgs.resources) > 0 ? [
    for nsg in data.azurerm_resources.aks_nsgs.resources :
    nsg if length(regexall("^aks-agentpool-[0-9]+-nsg$", nsg.name)) > 0
  ] : []
  
  # Obtener el primer NSG que coincida
  aks_nsg_id   = length(local.matching_nsgs) > 0 ? local.matching_nsgs[0].id : ""
  aks_nsg_name = length(local.matching_nsgs) > 0 ? local.matching_nsgs[0].name : ""
}

# Obtener más detalles del NSG específico una vez identificado
data "azurerm_network_security_group" "aks_nsg" {
  count               = local.aks_nsg_name != "" ? 1 : 0
  name                = local.aks_nsg_name
  resource_group_name = local.aks_mc_resource_group

  depends_on = [
    module.aks,
    data.azurerm_resources.aks_nsgs
  ]
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
    module.networking,
    data.azurerm_network_security_group.aks_nsg
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
    module.networking,
    data.azurerm_network_security_group.aks_nsg
  ]
}

# Agregamos un check condicional para verificar si el clúster AKS existe
# y sólo entonces aplicamos las reglas NSG
resource "null_resource" "check_aks_exists" {
  # Trigger cuando cambie el ID del clúster AKS
  triggers = {
    aks_id = module.aks.cluster_id
  }

  # No hacemos nada con este recurso, sólo lo usamos como dependencia
  provisioner "local-exec" {
    command = "echo El clúster AKS existe, ID: ${module.aks.cluster_id}"
  }
}
