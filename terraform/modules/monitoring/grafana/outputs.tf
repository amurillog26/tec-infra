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
