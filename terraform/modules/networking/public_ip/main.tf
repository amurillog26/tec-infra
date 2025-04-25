resource "azurerm_public_ip" "public_ip" {
  for_each = var.public_ips

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = each.value.allocation_method
  sku                = each.value.sku
  sku_tier           = lookup(each.value, "sku_tier", "Regional")
  zones              = lookup(each.value, "zones", null)
  domain_name_label   = lookup(each.value, "domain_name_label", null)
  
  tags               = merge(var.tags, each.value.tags)
  
  # Añadir un bloque lifecycle para ignorar cambios en domain_name_label
  # Esto evitará que Terraform intente modificar este valor
  # lifecycle {
  #   ignore_changes = [
  #     domain_name_label
  #   ]
  # }
}
