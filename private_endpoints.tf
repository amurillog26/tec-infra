module "private_endpoint" {
  source   = "./terraform/modules/networking/private_endpoint"
  for_each = var.private_endpoints

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Use the subnet_id from the networking module if subnet_key is provided
  subnet_id = lookup(each.value, "subnet_id",
    lookup(module.networking.subnet_ids,
  lookup(each.value, "subnet_key", ""), null))

  private_connection_resource_id = each.value.resource_id
  subresource_names              = lookup(each.value, "subresource_names", [])
  is_manual_connection           = lookup(each.value, "is_manual_connection", false)

  # Use all the specific properties to preserve existing resources
  custom_network_interface_name = lookup(each.value, "custom_network_interface_name", null)
  private_service_connection_name = lookup(each.value, "private_service_connection_name",
  "${each.value.name}-connection")
  private_dns_zone_group_name = lookup(each.value, "private_dns_zone_group_name",
  "${each.value.name}-dns-zone-group")
  private_dns_zone_ids = lookup(each.value, "private_dns_zone_ids", null)
  ip_configurations    = lookup(each.value, "ip_configurations", null)

  tags = merge(var.tags, lookup(each.value, "tags", {}))

  depends_on = [
    module.networking,
    module.cosmos_db,
    module.key_vault,
    module.storage,
    module.container_registry
  ]
}
