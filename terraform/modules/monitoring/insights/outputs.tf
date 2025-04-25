output "workspace_id" {
  description = "The workspace ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.insights.id
}

output "workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.insights.name
}

output "workspace_primary_key" {
  description = "The primary key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.insights.primary_shared_key
  sensitive   = true
}

output "workspace_secondary_key" {
  description = "The secondary key of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.insights.secondary_shared_key
  sensitive   = true
}
