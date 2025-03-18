module "networking" {
  source = "./terraform/modules/networking/virtual_network"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  environment         = var.environment
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  subnets             = var.subnets
  dns_servers         = var.dns_servers
  tags                = var.tags

}
