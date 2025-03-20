
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
  
  # Add this dynamic block
  dynamic "identity" {
    for_each = var.enable_identity ? [1] : []
    content {
      type = var.identity_type
      identity_ids = var.identity_ids
    }
  }
  
  retention_policy_in_days = 7

  tags = var.resource_tags
}
