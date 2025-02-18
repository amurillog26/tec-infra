module "container_registry" {
  source = "./terraform/modules/compute/container_registry"

  acr_name           = var.acr_name
  main_rg_name       = data.azurerm_resource_group.rg.name
  main_vn_location   = data.azurerm_resource_group.rg.location
  acr_admin_enabled  = var.acr_admin_enabled
  acr_public         = var.acr_public
  resource_tags      = var.tags
}
