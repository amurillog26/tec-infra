resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = false  # Cambia esto a false si es una conexión automática
  }

  private_dns_zone_group {
    name                 = "${var.name}-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  lifecycle {
    ignore_changes = [
      private_service_connection[0].private_connection_resource_id
    ]
  }
}
