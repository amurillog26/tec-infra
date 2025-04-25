# Private DNS Zones for Azure Private Endpoints

module "private_dns_zone" {
  source   = "./terraform/modules/networking/private_dns_zone"
  for_each = var.private_dns_zones

  name                = each.value.name
  resource_group_name = var.resource_group_name
  linked_vnets = {
    "vnet_gpt_net_${var.environment}" = module.networking.vnet_id
  }
  registration_enabled = lookup(each.value, "registration_enabled", false)

  tags = merge(var.tags, {
    environment = var.environment
    workload    = "oai"
  })

  depends_on = [
    module.networking
  ]
}
