
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
  zone_redundancy_enabled = var.zone_redundancy_enabled
  data_endpoint_enabled = true
    retention_policy {
    days = 7
    enabled = true
  }

  tags                = var.resource_tags
}
