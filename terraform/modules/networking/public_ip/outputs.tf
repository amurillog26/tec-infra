
# outputs.tf
output "public_ip_ids" {
  description = "Map of public IP names to their IDs"
  value       = { for k, v in azurerm_public_ip.public_ip : k => v.id }
}

output "public_ip_addresses" {
  description = "Map of public IP names to their addresses"
  value       = { for k, v in azurerm_public_ip.public_ip : k => v.ip_address }
}
