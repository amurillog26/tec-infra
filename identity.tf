module "managed_identity" {
  source = "./terraform/modules/security/managed_identity" # Ajusta la ruta según tu estructura

  name                  = var.managed_identity.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  assign_key_vault_role = var.managed_identity.assign_key_vault_role
  key_vault_id          = module.key_vault.kv_id
  tags                  = var.managed_identity.tags
}
