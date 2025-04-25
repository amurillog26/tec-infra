locals {
  asp_kind     = "Linux"
  asp_reserved = true  # Required for Linux plans
}
#checkov:skip=CKV_AZURE_225: No es necesario tener zone redundancy en este SKU
resource "azurerm_service_plan" "asp" {
  for_each = var.service_plans

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type            = each.value.os_type
  sku_name           = each.value.sku_name

  worker_count       = each.value.worker_count
  zone_balancing_enabled = var.zone_balancing_enabled

  tags = merge(var.tags, {
    ServicePlan = each.value.name
  })
}
