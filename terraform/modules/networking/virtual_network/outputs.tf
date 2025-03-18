# outputs.tf
output "vnet_id" {
  description = "The id of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}
