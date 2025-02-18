output "web_app_ids" {
  description = "Map of web app names to their IDs"
  value       = { for k, v in azurerm_linux_web_app.web_app : k => v.id }
}

output "web_app_urls" {
  description = "Map of web app names to their default URLs"
  value       = { for k, v in azurerm_linux_web_app.web_app : k => v.default_hostname }
}

output "web_app_identities" {
  description = "Map of web app names to their managed identities"
  value       = { for k, v in azurerm_linux_web_app.web_app : k => v.identity[0].principal_id }
}
