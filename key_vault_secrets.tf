# --------------------------------------------------
# Archivo: keyvault_secrets.tf
# --------------------------------------------------

locals {
  # Crear una lista plana de todos los secretos desde la estructura anidada
  flat_secrets = flatten([
    for category, secrets in var.key_vault_secrets : [
      for secret in secrets : {
        name     = secret
        category = category
      }
    ]
  ])
}

# Para uso de data source, no es necesario permisos de creación,
# solo necesitamos permisos para obtener los valores de los secretos
data "azurerm_key_vault" "kv" {
  name                = var.kv_name
  resource_group_name = var.main_rg_name

  depends_on = [
    module.key_vault
  ]
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = { for item in local.flat_secrets : item.name => item }

  name         = each.value.name
  value        = ""  # Valor vacío inicial
  key_vault_id = data.azurerm_key_vault.kv.id

  lifecycle {
    ignore_changes = [
      value,
      key_vault_id,
      tags
    ]
  }

  tags = merge(var.tags, {
    category = each.value.category
  })

  depends_on = [
    module.key_vault
  ]
}
