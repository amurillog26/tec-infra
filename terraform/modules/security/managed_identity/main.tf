# main.tf
resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Si necesitamos acceso a Key Vault para los certificados del AppGW
resource "azurerm_role_assignment" "key_vault_secrets" {
  count                = var.assign_key_vault_role ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}
