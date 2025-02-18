
locals {
  container_registry_sku    = "Premium"
}

# -------------------------------------------------- 
# Azure Container Registry configuration for 
# the storage of Docker images
# -------------------------------------------------- 
resource "azurerm_container_registry" "aro_acr" {
  name                = var.acr_name
  resource_group_name = var.main_rg_name
  location            = var.main_vn_location
  sku                 = local.container_registry_sku
  admin_enabled       = var.acr_admin_enabled
  public_network_access_enabled = var.acr_public

  tags                = var.resource_tags
}

# -------------------------------------------------- 
# Crate a Private Endpoint Connection for ACR
# -------------------------------------------------- 
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  lifecycle {
    ignore_changes = [resource_group_name, subnet_id]
  }

  name                = var.acr_private_endpoint_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  subnet_id           = var.acr_private_endpoint_subnet_id

  private_service_connection {
    name                           = var.acr_private_link_name
    private_connection_resource_id = azurerm_container_registry.aro_acr.id
    is_manual_connection           = false
    subresource_names = [ "registry" ]
  }
}

# -------------------------------------------------- 
# Crate the Private DNS Zone for ACR
# -------------------------------------------------- 
resource "azurerm_private_dns_zone" "acr_dns_zone" {
  name                = var.acr_private_dns_zone
  resource_group_name = var.main_rg_name
  depends_on = [azurerm_container_registry.aro_acr]
}

# -------------------------------------------------- 
# Add Private DNS Zone ACR to Main Virtual Network
# -------------------------------------------------- 
resource "azurerm_private_dns_zone_virtual_network_link" "acr_pdzvnl" {
  name                  = var.acr_vnet_dns_link
  resource_group_name   = var.main_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns_zone.name
  virtual_network_id    = var.main_vn_id
  registration_enabled  = false
}

# -------------------------------------------------- 
# Create a DNS Record en Private DNS Zone ACR
# -------------------------------------------------- 
resource "azurerm_private_dns_a_record" "acrdata" {
  name                = regex("(?P<dns>.*)\\.azurecr\\.io",azurerm_private_endpoint.acr_private_endpoint.custom_dns_configs[0].fqdn).dns
  zone_name           = var.acr_private_dns_zone
  resource_group_name = var.main_rg_name
  ttl                 = 300
  records             = azurerm_private_endpoint.acr_private_endpoint.custom_dns_configs[0].ip_addresses
}

# -------------------------------------------------- 
# Create a DNS Record en Private DNS Zone ACR
# -------------------------------------------------- 
resource "azurerm_private_dns_a_record" "acr" {
  name                = regex("(?P<dns>.*)\\.azurecr\\.io",azurerm_private_endpoint.acr_private_endpoint.custom_dns_configs[1].fqdn).dns
  zone_name           = var.acr_private_dns_zone
  resource_group_name = var.main_rg_name
  ttl                 = 300
  records             = azurerm_private_endpoint.acr_private_endpoint.custom_dns_configs[1].ip_addresses
}