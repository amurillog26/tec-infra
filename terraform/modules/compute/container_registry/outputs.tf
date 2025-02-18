output "name_container_registry" {
  description = "Nombre Container Registry: "
  value = azurerm_container_registry.aro_acr.name
}

output "id_container_registry" {
  description = "ID Container Registry: "
  value = azurerm_container_registry.aro_acr.id
}