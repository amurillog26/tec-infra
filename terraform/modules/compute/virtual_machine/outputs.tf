output "vm_id" {
  description = "ID de la máquina virtual"
  value       = azurerm_windows_virtual_machine.vm_virtual_machine.id
}

output "vm_name" {
  description = "Nombre de la máquina virtual"
  value       = azurerm_windows_virtual_machine.vm_virtual_machine.name
}

output "private_ip_address" {
  description = "Dirección IP privada de la máquina virtual"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "public_ip_address" {
  description = "Dirección IP pública de la máquina virtual"
  value       = azurerm_public_ip.vm_public_ip.ip_address
}

output "public_ip_id" {
  description = "ID de la dirección IP pública"
  value       = azurerm_public_ip.vm_public_ip.id
}

output "network_interface_id" {
  description = "ID de la interfaz de red"
  value       = azurerm_network_interface.vm_nic.id
}
