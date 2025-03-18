output "name_container_registry" {
  description = "Nombre Container Registry: "
  value = azurerm_container_registry.aro_acr.name
}

output "id_container_registry" {
  description = "ID Container Registry: "
  value = azurerm_container_registry.aro_acr.id
}

output "acr_id" {
  description = "The ID of the Container Registry"
  value       = azurerm_container_registry.aro_acr.id
}

output "acr_login_server" {
  description = "The URL that can be used to log into the container registry"
  value       = azurerm_container_registry.aro_acr.login_server
}

output "acr_admin_username" {
  description = "The Admin Username for the Container Registry"
  value       = azurerm_container_registry.aro_acr.admin_username
  sensitive   = false
}

output "acr_admin_password" {
  description = "The Admin Password for the Container Registry"
  value       = azurerm_container_registry.aro_acr.admin_password
  sensitive   = true
}
