output "id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.private_dns_zone.id
}

output "name" {
  description = "The name of the private DNS zone"
  value       = azurerm_private_dns_zone.private_dns_zone.name
}

output "vnet_links" {
  description = "Map of Virtual Network links created"
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.vnet_link : k => v.id }
}
