module "container_registry" {
  source = "./terraform/modules/compute/container_registry"

  acr_name                = var.acr_name
  main_rg_name            = data.azurerm_resource_group.rg.name
  main_vn_location        = data.azurerm_resource_group.rg.location
  acr_admin_enabled       = var.acr_admin_enabled
  acr_public              = var.acr_public
  resource_tags           = var.tags
  zone_redundancy_enabled = var.acr_zone_redundancy_enabled

  # Add these lines
  enable_identity = var.acr_enable_identity
  identity_type   = var.acr_identity_type
  identity_ids    = var.acr_identity_ids
}
