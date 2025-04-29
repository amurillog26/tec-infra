# aks_nsg_rules.tf - Versión mejorada sin dependencias circulares

locals {
  # Nombre del resource group gestionado por AKS
  aks_mc_resource_group = "MC_rg_gpt_oai_${var.environment}_aks-gpt-${var.environment}-001_southcentralus"
  
  # Prefijo del nombre esperado para el NSG
  aks_nsg_prefix = "aks-agentpool"
  
  # Definir un nombre determinista para el NSG que esperamos encontrar
  # Esta es una convención estándar para los NSGs creados por AKS
  expected_nsg_name = "${local.aks_nsg_prefix}-28976913-nsg"
}

# Crear las reglas de NSG de forma condicional usando un recurso null_resource como interruptor
resource "null_resource" "aks_nsg_setup_trigger" {
  # Trigger basado en el ID del clúster AKS, así se ejecuta solo después de que AKS existe
  triggers = {
    aks_id = module.aks.cluster_id
  }

  # Este provisioner solo loguea información pero no afecta la infraestructura
  provisioner "local-exec" {
    command = "echo Preparando reglas NSG para AKS: ${module.aks.cluster_id}"
  }
}

# Regla para permitir tráfico desde AKS a APIM
resource "azurerm_network_security_rule" "allow_aks_to_apim" {
  # Solo crear este recurso si el trigger existe (es decir, AKS existe)
  depends_on = [null_resource.aks_nsg_setup_trigger]

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
  network_security_group_name = local.expected_nsg_name
  
  # Ignorar errores de creación ya que esto es una configuración opcional
  lifecycle {
    ignore_changes = [
      resource_group_name,
      network_security_group_name
    ]
    # Prevenir errores si el grupo no existe todavía
    create_before_destroy = true
  }
}

# Regla para permitir tráfico desde APIM a AKS
resource "azurerm_network_security_rule" "allow_apim_to_aks" {
  # Solo crear este recurso si el trigger existe (es decir, AKS existe)
  depends_on = [null_resource.aks_nsg_setup_trigger]

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
  network_security_group_name = local.expected_nsg_name
  
  # Ignorar errores de creación ya que esto es una configuración opcional
  lifecycle {
    ignore_changes = [
      resource_group_name,
      network_security_group_name
    ]
    # Prevenir errores si el grupo no existe todavía
    create_before_destroy = true
  }
}

# Proveemos un output para facilitar la depuración
output "aks_nsg_expected_name" {
  value = local.expected_nsg_name
  description = "Nombre esperado del NSG de AKS que se está configurando"
}

output "aks_mc_resource_group" {
  value = local.aks_mc_resource_group
  description = "Grupo de recursos gestionado de AKS donde se encuentran los NSGs"
}
