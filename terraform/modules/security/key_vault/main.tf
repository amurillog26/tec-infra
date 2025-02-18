locals {
  kv_retention    = 7
  kv_purge        = false
}

# --------------------------------------------------
# Kery Vault resource
# --------------------------------------------------
resource "azurerm_key_vault" "tec_kv" {
  name                        = var.kv_name
  location                    = var.main_vn_location
  resource_group_name         = var.main_rg_name
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = local.kv_retention
  purge_protection_enabled    = local.kv_purge
  public_network_access_enabled = var.kv_public_access
  sku_name = var.kv_sku_name
  
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
  enable_rbac_authorization = false

  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
    #  ip_rules = var.allow_subnets
    # virtual_network_subnet_ids = var.allow_subnets
  }

  tags = var.tags
}

