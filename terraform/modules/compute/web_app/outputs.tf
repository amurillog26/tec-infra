# outputs.tf
output "web_app_ids" {
  value = {
    for k, v in azurerm_linux_web_app.web_app : k => v.id
  }
  description = "Map of created Web App IDs"
}

output "web_app_default_hostnames" {
  value = {
    for k, v in azurerm_linux_web_app.web_app : k => v.default_hostname
  }
  description = "Map of created Web App default hostnames"
}

output "web_app_identities" {
  value = {
    for k, v in azurerm_linux_web_app.web_app : k => v.identity[0].principal_id
  }
  description = "Map of created Web App managed identities"
}
