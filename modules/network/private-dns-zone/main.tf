# -------------------------------------------------- 
# Configuracion para  Private DNS subnet
# -------------------------------------------------- 
resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.domain_name
  resource_group_name = var.main_rg_name
}

resource "azurerm_private_dns_a_record" "a_records_private" {
  depends_on = [
    azurerm_private_dns_zone.private_dns_zone
  ]
  for_each = { for rs in var.a_records : rs.name => rs }

  resource_group_name = var.main_rg_name
  zone_name           = var.domain_name

  name    = each.value.name
  ttl     = each.value.ttl
  records = each.value.value
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_link" {
  name                  = var.virt_net_link_name
  resource_group_name   = var.main_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.main_vn_id
  registration_enabled  = var.registration_enabled
}
