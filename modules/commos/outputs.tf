output "main_rg_name" {
  value = length(data.azurerm_resource_group.main_rg) > 0 ? data.azurerm_resource_group.main_rg[0].name : "Null"
}

output "main_rg_id" {
  value = length(data.azurerm_resource_group.main_rg) > 0 ? data.azurerm_resource_group.main_rg[0].id : "Null"
}

# output "az_region" {
#   value = local.az_region
# }

# output "resource_tags" {
#   value = local.resource_tags
# }