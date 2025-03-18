# Asegúrate de añadir este output al archivo outputs.tf de tu módulo APIM si no existe
output "id" {
  description = "The ID of the API Management service"
  value       = azurerm_api_management.apim.id
}
