# terraform/modules/networking/bastion/outputs.tf

output "id" {
  description = "The ID of the Bastion Host"
  value       = azurerm_bastion_host.bastion.id
}

output "name" {
  description = "The name of the Bastion Host"
  value       = azurerm_bastion_host.bastion.name
}

output "dns_name" {
  description = "The FQDN for the Bastion Host"
  value       = azurerm_bastion_host.bastion.dns_name
}
