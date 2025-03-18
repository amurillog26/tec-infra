output "id" {
  value       = azurerm_application_gateway.agw.id
  description = "The ID of the Application Gateway"
}

output "frontend_ip_configuration" {
  value       = azurerm_application_gateway.agw.frontend_ip_configuration
  description = "The Frontend IP Configuration of the Application Gateway"
}

output "backend_address_pool_ids" {
  value = {
    for pool in azurerm_application_gateway.agw.backend_address_pool : pool.name => pool.id
  }
  description = "Map of Backend Address Pool IDs"
}

output "ssl_certificate_ids" {
  value = {
    for cert in azurerm_application_gateway.agw.ssl_certificate : cert.name => cert.id
  }
  description = "Map of SSL Certificate IDs"
}

output "public_ip_addresses" {
  value = [
    for ip in azurerm_application_gateway.agw.frontend_ip_configuration : ip.private_ip_address if ip.private_ip_address != ""
  ]
  description = "List of public IP addresses assigned to the Application Gateway"
}
