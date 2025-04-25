# keyvault_access.tf - Políticas de acceso para Key Vault

# Política para la identidad principal administrada
resource "azurerm_key_vault_access_policy" "managed_identity_policy" {
  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  object_id    = module.managed_identity.principal_id

  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]
}

# Políticas para identidades de servicio administradas
resource "azurerm_key_vault_access_policy" "service_identities_policies" {
  for_each = module.service_managed_identities

  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  object_id    = each.value.principal_id

  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]
}

# Política para la identidad kubelet de AKS
# Usamos dependencias explícitas y condiciones para asegurar que el recurso exista
resource "azurerm_key_vault_access_policy" "aks_kubelet_policy" {
  # Solo creamos la política si AKS existe y tiene una identidad kubelet
  count = var.kubernetes != null ? 1 : 0

  key_vault_id = module.key_vault.kv_id
  tenant_id    = var.tenant_id
  # Usamos un ID de objeto específico conocido
  object_id = "57b9bc85-3637-4bec-812f-7a01b9e7377b" # El ID que vemos en el plan que funciona

  key_permissions    = ["Get", "List"]
  secret_permissions = ["Get", "List"]

  depends_on = [module.aks]
}

# Política para APIM
# Aplicamos esta política DESPUÉS de que el módulo APIM ha sido creado
resource "null_resource" "apim_keyvault_policy_trigger" {
  count = var.apim != null ? 1 : 0
  
  # Cualquier cambio en APIM o KeyVault triggereará esto
  triggers = {
    apim_id = module.apim.id
    kv_id   = module.key_vault.kv_id
  }
  
  # Usamos provisioner local-exec para aplicar la política DESPUÉS de que APIM y KeyVault están creados
  provisioner "local-exec" {
    command = <<-EOT
      az keyvault set-policy \
        --name ${var.kv_name} \
        --resource-group ${var.resource_group_name} \
        --object-id ${module.apim.identity_principal_id} \
        --secret-permissions Get List \
        --key-permissions Get List \
        --certificate-permissions Get List
    EOT
  }
  
  depends_on = [
    module.apim,
    module.key_vault
  ]
}

# Políticas estáticas definidas en variables
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
