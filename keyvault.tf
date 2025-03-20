# --------------------------------------------------
# Archivo: main.tf en la raíz del proyecto
# --------------------------------------------------

module "key_vault" {
  source = "./terraform/modules/security/key_vault"

  kv_name          = var.kv_name
  main_rg_name     = data.azurerm_resource_group.rg.name
  main_vn_location = data.azurerm_resource_group.rg.location
  tenant_id        = var.tenant_id
  kv_public_access = var.kv_public_access
  kv_sku_name      = var.kv_sku_name
  
  # Agregar políticas de acceso para el Service Principal que ejecuta Terraform
  access_policies = [
    {
      tenant_id = var.tenant_id
      object_id = "693831f7-28b7-4429-bb0c-f0892c718230"  # El Object ID del error
      application_id = "ff864b72-fd0c-4ad9-8e38-ea5407e2c0c7"  # El Application ID del error
      secret_permissions = [
        "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
      ]
    },
    # También puedes agregar una política para tu usuario
    {
      tenant_id = var.tenant_id
      object_id = var.admin_object_id  # Variable para tu Object ID
      secret_permissions = [
        "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
      ]
    }
  ]
  
  tags             = var.tags
}
