resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# # Asignación de roles para Key Vault
resource "azurerm_role_assignment" "key_vault_secrets" {
  count                = var.assign_key_vault_role && var.key_vault_id != null ? 1 : 0
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

# # En terraform/modules/security/managed_identity/main.tf
# resource "azurerm_role_assignment" "dns_zone_contributor" {
#   count                = 1
#   scope                = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/privateDnsZones/privatelink.southcentralus.azmk8s.io"
#   role_definition_name = "Private DNS Zone Contributor"
#   principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
# }
