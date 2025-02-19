# outputs.tf
output "id" {
  value       = azurerm_api_management.apim.id
  description = "The ID of the API Management service"
}

output "gateway_url" {
  value       = azurerm_api_management.apim.gateway_url
  description = "The URL of the Gateway for the API Management service"
}

output "identity_principal_id" {
  value       = azurerm_api_management.apim.identity[0].principal_id
  description = "The Principal ID of the API Management service's Managed Identity"
}

output "public_ip_addresses" {
  value       = azurerm_api_management.apim.public_ip_addresses
  description = "The Public IP addresses of the API Management service"
}
