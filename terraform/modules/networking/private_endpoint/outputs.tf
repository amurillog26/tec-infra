output "id" {
  description = "The ID of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.id
}

output "name" {
  description = "The name of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.name
}

output "private_ip_address" {
  description = "The private IP address associated with the private endpoint"
  value       = try(azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address, null)
}
