module "storage" {
  source = "./terraform/modules/data/storage_account"

  resource_group_name = data.azurerm_resource_group.rg.name
  location           = data.azurerm_resource_group.rg.location
  storage_accounts   = var.storage_accounts
  tags               = var.tags
}
