module "key_vault" {
  source = "./terraform/modules/security/key_vault"

  kv_name          = var.kv_name
  main_rg_name     = data.azurerm_resource_group.rg.name
  main_vn_location = data.azurerm_resource_group.rg.location
  tenant_id        = var.tenant_id
  kv_public_access = var.kv_public_access
  kv_sku_name      = var.kv_sku_name
  tags             = var.tags
}
