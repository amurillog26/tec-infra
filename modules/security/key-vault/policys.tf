resource "azurerm_key_vault_access_policy" "tec_kv_access_sp" {
  key_vault_id = azurerm_key_vault.tec_kv.id
  tenant_id    = var.tenant_id
  object_id    = var.sp_object_id

    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "SetIssuers",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey",
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set",
    ]

    storage_permissions = [
      "Get","List","Delete","Update"
    ]
}

resource "azurerm_key_vault_access_policy" "tec_kv_access_sp_applications" {
  key_vault_id = azurerm_key_vault.tec_kv.id
  tenant_id    = var.tenant_id
  object_id    = var.sp_app_object_id
  application_id = var.sp_app_application_id

    key_permissions = [
      "Get","List"
    ]

    secret_permissions = [
      "Get","List"
    ]

    storage_permissions = [
      "Get","List"
    ]
}

resource "azurerm_key_vault_access_policy" "tec_kv_access_sp_frontdoor" {
  key_vault_id = azurerm_key_vault.tec_kv.id
  tenant_id    = var.tenant_id
  object_id    = var.kv_sp_frontdoor_object_id
  application_id = var.kv_sp_frontdoor_application_id

    key_permissions = [
      "Get","List"
    ]

    secret_permissions = [
      "Get","List"
    ]

    storage_permissions = [
      "Get","List"
    ]

    certificate_permissions = [
      "Get","List"
    ]
}
