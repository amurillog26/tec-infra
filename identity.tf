# identity.tf - Elimina la dependencia circular
module "managed_identity" {
  source = "./terraform/modules/security/managed_identity"

  name                  = var.managed_identity.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  assign_key_vault_role = var.managed_identity.assign_key_vault_role
  # Ya no pasamos key_vault_id aquí
  key_vault_id          = null  # Elimina la dependencia circular
  tenant_id             = var.tenant_id
  tags                  = var.managed_identity.tags
}

module "service_managed_identities" {
  source   = "./terraform/modules/security/managed_identity"
  for_each = {
    "aks-keyvault-wi" = {
      name = "id-aks-keyvault-wi"
      assign_key_vault_role = true
      tags = merge(var.tags, { purpose = "aks-keyvault-access" })
    },
    "aks-services-wi" = {
      name = "id-aks-services-wi"
      assign_key_vault_role = true
      tags = merge(var.tags, { purpose = "aks-services" })
    }
  }

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  assign_key_vault_role = lookup(each.value, "assign_key_vault_role", false)
  # Ya no pasamos key_vault_id aquí
  key_vault_id          = null  # Elimina la dependencia circular
  tenant_id             = var.tenant_id
  tags                  = lookup(each.value, "tags", var.tags)
}
