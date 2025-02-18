output "service_plan_ids" {
  description = "Map of service plan names to their IDs"
  value       = { for k, v in azurerm_service_plan.asp : k => v.id }
}
