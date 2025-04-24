# terraform/modules/networking/private_endpoint/outputs.tf

output "id" {
  description = "The ID of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.id
}

output "name" {
  description = "The name of the private endpoint"
  value       = azurerm_private_endpoint.private_endpoint.name
}

output "private_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = length(azurerm_private_endpoint.private_endpoint.private_service_connection) > 0 ? azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address : null
}
