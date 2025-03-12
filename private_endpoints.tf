# Private Endpoints for Azure resources

module "private_endpoint" {
  source   = "./terraform/modules/networking/private_endpoint"
  for_each = var.private_endpoints

  name                           = each.value.name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = lookup(module.networking.subnet_ids, each.value.subnet_key, null)
  private_connection_resource_id = each.value.resource_id
  subresource_names              = each.value.subresource_names
  is_manual_connection           = lookup(each.value, "is_manual_connection", false)
  private_dns_zone_ids           = lookup(each.value, "private_dns_zone_ids", null)
  
  tags = merge(var.tags, {
    environment = var.environment
    workload    = "oai"
  })

  depends_on = [
    module.networking,
    module.cosmos_db,
    module.key_vault,
    # module.redis,
    module.storage,
    # module.apim,
    # module.web_apps
    module.container_registry  # Añade esta dependencia
  ]
}
