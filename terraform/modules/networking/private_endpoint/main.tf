# terraform/modules/networking/private_endpoint/main.tf

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  # Only set custom_network_interface_name if provided
  custom_network_interface_name = var.custom_network_interface_name
  
  # Dynamic block for IP configuration - only used if provided
  dynamic "ip_configuration" {
    for_each = var.ip_configurations != null ? var.ip_configurations : []
    content {
      name               = lookup(ip_configuration.value, "name", null)
      private_ip_address = lookup(ip_configuration.value, "private_ip_address", null)
      subresource_name   = lookup(ip_configuration.value, "subresource_name", null)
      member_name        = lookup(ip_configuration.value, "member_name", null)
    }
  }
  
  private_service_connection {
    name                           = var.private_service_connection_name
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = var.subresource_names
  }
  
  # Only create DNS zone group if IDs are provided
  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
  
  tags = var.tags
  
  # This will prevent recreation when these attributes change
  lifecycle {
    ignore_changes = [
      tags,
      subnet_id,
      custom_network_interface_name,
      ip_configuration,
      private_service_connection.0.name,
      private_service_connection.0.subresource_names,
      private_dns_zone_group.0.name
    ]
  }
}
