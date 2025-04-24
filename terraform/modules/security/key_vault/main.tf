# --------------------------------------------------
# Archivo: main.tf del módulo key_vault
# --------------------------------------------------

locals {
  kv_retention    = 7
  kv_purge        = false
  
  # Filtrar cualquier política inválida aquí dentro del módulo
  valid_policies = [
    for policy in var.access_policies : policy
    if policy.object_id != null && policy.object_id != ""
  ]
}

# --------------------------------------------------
# Key Vault resource
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
  }

  # Añadir políticas de acceso dinámicas
  dynamic "access_policy" {
    for_each = local.valid_policies
    content {
      tenant_id               = access_policy.value.tenant_id
      object_id               = access_policy.value.object_id
      application_id          = lookup(access_policy.value, "application_id", null) == "" ? null : lookup(access_policy.value, "application_id", null)
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  tags = var.tags
}
