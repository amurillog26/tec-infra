# main.tf
resource "azurerm_api_management" "apim" {
  name                = var.apim.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.apim.publisher_name
  publisher_email     = var.apim.publisher_email
  sku_name           = var.apim.sku_name
  
  public_ip_address_id = "/subscriptions/49b8793e-f25e-49ab-8fc2-1190c08f377e/resourceGroups/rg_gpt_oai_dev/providers/Microsoft.Network/publicIPAddresses/apim-mgmnt-pip"
  
  virtual_network_type = var.apim.virtual_network_type

  zones = ["1"]
  
  dynamic "virtual_network_configuration" {
    for_each = var.apim.virtual_network_type != "None" ? [1] : []
    content {
      subnet_id = var.apim.subnet_id
    }
  }
  public_network_access_enabled = true
  identity {
    type = var.apim.identity_type
  }

  protocols {
    enable_http2 = var.apim.protocols.enable_http2
  }

  security {
    enable_backend_ssl30  = var.apim.security.enable_backend_ssl30
    enable_backend_tls10  = var.apim.security.enable_backend_tls10
    enable_backend_tls11  = var.apim.security.enable_backend_tls11
    enable_frontend_ssl30 = var.apim.security.enable_frontend_ssl30
    enable_frontend_tls10 = var.apim.security.enable_frontend_tls10
    enable_frontend_tls11 = var.apim.security.enable_frontend_tls11
  }

  sign_in {
    enabled = var.apim.additional_settings.enable_sign_in
  }

  sign_up {
    enabled = var.apim.additional_settings.enable_sign_up
    terms_of_service {
      enabled          = false
      consent_required = false
    }
  }

  tags = merge(var.tags, var.apim.tags)
}

# Políticas globales
resource "azurerm_api_management_policy" "global" {
  count               = var.apim.policy != null ? 1 : 0  # Hacemos la política opcional
  api_management_id   = azurerm_api_management.apim.id
  xml_content        = try(var.apim.policy.xml_content, null)

  depends_on = [
    azurerm_api_management.apim
  ]
}

# Productos
resource "azurerm_api_management_product" "products" {
  for_each = var.apim.products

  product_id            = each.value.product_id
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = var.resource_group_name
  display_name          = each.value.display_name
  description          = each.value.description
  subscription_required = each.value.subscription_required
  approval_required     = each.value.approval_required
  published            = each.value.published
  subscriptions_limit  = each.value.subscriptions_limit
}

# API Version Sets
resource "azurerm_api_management_api_version_set" "version_sets" {
  for_each = {
    for k, v in var.apim.apis : k => v
    if lookup(v, "version_set", null) != null
  }

  name                = each.value.version_set.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  display_name        = each.value.version_set.name
  versioning_scheme   = each.value.version_set.versioning_scheme
}

# APIs
resource "azurerm_api_management_api" "apis" {
  for_each = var.apim.apis

  name                = each.value.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  display_name        = each.value.display_name
  path                = each.value.path
  protocols           = each.value.protocols
  revision            = each.value.revision
  version             = lookup(each.value, "version", null)
  version_set_id      = lookup(each.value, "version_set", null) != null ? azurerm_api_management_api_version_set.version_sets[each.key].id : null
}

# Named Values
resource "azurerm_api_management_named_value" "named_values" {
  for_each = var.apim.named_values

  name                = each.key
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  display_name        = each.value.display_name
  value               = each.value.value
}
