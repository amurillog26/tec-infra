# keyvault_policies.tf - Segunda etapa para políticas de acceso
resource "azurerm_key_vault_access_policy" "managed_identity_policy" {
  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  object_id    = module.managed_identity.principal_id
  
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "service_identities_policies" {
  for_each = module.service_managed_identities

  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  object_id    = each.value.principal_id
  
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "aks_kubelet_policy" {
  count = module.aks.kubelet_identity_principal_id != null ? 1 : 0
  
  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  object_id    = module.aks.kubelet_identity_principal_id
  
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "aks_agentpool_policy" {
  count = module.aks.agent_pool_identity_principal_id != null ? 1 : 0
  
  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  object_id    = module.aks.agent_pool_identity_principal_id
  
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]
}

resource "azurerm_key_vault_access_policy" "apim_policy" {
  count = module.apim.identity_principal_id != null ? 1 : 0
  
  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  object_id    = module.apim.identity_principal_id
  
  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]
}

# Aplica las políticas estáticas originales
resource "azurerm_key_vault_access_policy" "static_policies" {
  for_each = { 
    for idx, policy in var.key_vault_access_policies : 
    idx => policy 
    if policy.object_id != null && policy.object_id != ""
  }
  
  key_vault_id = module.key_vault.kv_id
  tenant_id    = each.value.tenant_id
  object_id    = each.value.object_id
  
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
  
  application_id = lookup(each.value, "application_id", "") == "" ? null : lookup(each.value, "application_id", null)
}
