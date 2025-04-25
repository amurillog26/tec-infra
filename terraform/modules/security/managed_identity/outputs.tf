# outputs.tf
output "id" {
  value       = azurerm_user_assigned_identity.managed_identity.id
  description = "The ID of the managed identity"
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.managed_identity.principal_id
  description = "The Principal ID of the managed identity"
}

output "client_id" {
  value       = azurerm_user_assigned_identity.managed_identity.client_id
  description = "The Client ID of the managed identity"
}

output "key_vault_access_policy" {
  description = "KeyVault access policy for this managed identity"
  value = {
    object_id               = azurerm_user_assigned_identity.managed_identity.principal_id
    tenant_id               = var.tenant_id
    secret_permissions      = ["Get", "List"]
    key_permissions         = ["Get", "List"]
    certificate_permissions = []
    storage_permissions     = []
    application_id          = null
  }
}
