locals {
  apim_vn_type    = "External"

  apim_users = flatten([
    for pr in var.apim_tec_products : [
      for us in pr.users : {
        pr_name = pr.pr_name
        name = us
      }
    ]
  ])

  apim_apis = flatten([
    for pr in var.apim_tec_products : [
      for ap in pr.apis : {
        pr_name = pr.pr_name
        pr_subs  = pr.pr_subs_req
        name = ap.name
        vers = ap.vers
        path = ap.path
        service_url = ap.service_url
        swagger_file = ap.swagger_file
      }
    ]
  ])

}

resource "azurerm_api_management_product" "tec_products" {
  for_each = {
    for pr in var.apim_tec_products : "${pr.pr_name}" => pr
  }

  product_id            = each.value.pr_name
  api_management_name   = var.apim_name
  resource_group_name   = var.main_rg_name
  display_name          = each.value.pr_dis
  subscription_required = each.value.pr_subs_req
  published             = each.value.pr_pub
}

resource "azurerm_api_management_user" "tec_users" {
  for_each = {
    for us in local.apim_users : "${us.name}-${us.pr_name}" => us
  }

  user_id             = "${each.value.name}-${each.value.pr_name}"
  api_management_name   = var.apim_name
  resource_group_name   = var.main_rg_name
  first_name            = "Application"
  last_name             = "User"
  email                 = "${each.value.name}-${each.value.pr_name}@oxxo.com"

  depends_on = [ azurerm_api_management_product.tec_products ]
}

resource "azurerm_api_management_subscription" "tec_subscriptions" {
  for_each = {
    for us in local.apim_users : "${us.name}-${us.pr_name}" => us
  }

  api_management_name = var.apim_name
  resource_group_name = var.main_rg_name
  user_id             = azurerm_api_management_user.tec_users["${each.value.name}-${each.value.pr_name}"].id
  product_id          = azurerm_api_management_product.tec_products[each.value.pr_name].id
  display_name        = "${each.value.name}-${each.value.pr_name} API"
  state               = "active"

  depends_on = [ azurerm_api_management_product.tec_products, azurerm_api_management_user.tec_users ]
}

# --------------------------------------------------
# API Management
# --------------------------------------------------
resource "azurerm_api_management_api" "tec_apis" {
  for_each = {
    for ap in local.apim_apis : "${ap.name}-${ap.pr_name}" => ap
  }

  name                = each.value.name
  resource_group_name = var.main_rg_name
  api_management_name = var.apim_name
  revision            = each.value.vers
  display_name        = each.value.name
  path                = each.value.path
  protocols           = ["https"]
  subscription_required = each.value.pr_subs
  service_url         = each.value.service_url
  
  import {
    content_format = "openapi"
    content_value  = file("${path.module}/swagger-files/${each.value.swagger_file}")
  }

  subscription_key_parameter_names {
    header  = "Ocp-Apim-Subscription-Key"
    query   = "subscription-key"
  }

  depends_on = [ azurerm_api_management_subscription.tec_subscriptions ]
}

resource "azurerm_api_management_product_api" "tec_products_apis" {
  for_each = {
    for ap in local.apim_apis : "${ap.name}-${ap.pr_name}" => ap
  }

  api_name            = each.value.name
  product_id          = azurerm_api_management_product.tec_products[each.value.pr_name].product_id
  resource_group_name = var.main_rg_name
  api_management_name = var.apim_name

  depends_on = [ azurerm_api_management_api.tec_apis ]
}
