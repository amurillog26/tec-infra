output "id" {
  description = "ID del recurso de Grafana Managed"
  value       = azurerm_dashboard_grafana.grafana.id
}

output "name" {
  description = "Nombre del recurso de Grafana Managed"
  value       = azurerm_dashboard_grafana.grafana.name
}

output "endpoint" {
  description = "URL del endpoint de Grafana"
  value       = azurerm_dashboard_grafana.grafana.endpoint
}

output "grafana_version" {
  description = "Versión de Grafana"
  value       = azurerm_dashboard_grafana.grafana.grafana_version
}

output "identity" {
  description = "Identidad asignada al recurso de Grafana"
  value       = azurerm_dashboard_grafana.grafana.identity
}

output "outbound_ip" {
  description = "IPs salientes utilizadas por el recurso de Grafana"
  value       = azurerm_dashboard_grafana.grafana.outbound_ip
}

# Añadir este output al archivo outputs.tf existente

output "private_endpoint_id" {
  description = "ID del private endpoint de Grafana"
  value       = var.private_endpoint_enabled ? azurerm_private_endpoint.grafana_pe[0].id : null
}

output "private_endpoint_ip" {
  description = "IP privada del private endpoint de Grafana"
  value       = var.private_endpoint_enabled ? azurerm_private_endpoint.grafana_pe[0].private_service_connection[0].private_ip_address : null
}
