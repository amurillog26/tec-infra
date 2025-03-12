
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
