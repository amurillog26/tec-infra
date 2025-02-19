output "firewall_id" {
  description = "ID del Azure Firewall"
  value       = azurerm_firewall.fw.id
}

output "firewall_name" {
  description = "Nombre del Azure Firewall"
  value       = azurerm_firewall.fw.name
}

output "firewall_private_ip" {
  description = "IP privada del Azure Firewall"
  value       = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "IP pública del Azure Firewall"
  value       = azurerm_public_ip.fw_pip.ip_address
}

output "firewall_public_ip_id" {
  description = "ID de la IP pública del Azure Firewall"
  value       = azurerm_public_ip.fw_pip.id
}

output "firewall_policy_id" {
  description = "ID de la política del Azure Firewall"
  value       = azurerm_firewall_policy.fw_policy.id
}

output "firewall_policy_name" {
  description = "Nombre de la política del Azure Firewall"
  value       = azurerm_firewall_policy.fw_policy.name
}

output "route_table_id" {
  description = "ID de la tabla de rutas (si se creó)"
  value       = var.create_route_table ? azurerm_route_table.fw_route_table[0].id : null
}