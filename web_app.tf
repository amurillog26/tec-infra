module "service_plans" {
  source = "./terraform/modules/compute/app_service_plan"

  resource_group_name = data.azurerm_resource_group.rg.name
  location           = data.azurerm_resource_group.rg.location
  service_plans      = var.service_plans
  tags               = var.tags
}

# # Web Apps
# module "web_apps" {
#   source = "./terraform/modules/compute/web_app"

#   resource_group_name  = data.azurerm_resource_group.rg.name
#   location            = data.azurerm_resource_group.rg.location
#   web_apps            = var.web_apps
#   acr_login_server    = module.container_registry.acr_login_server
#   acr_admin_username  = module.container_registry.acr_admin_username
#   acr_admin_password  = module.container_registry.acr_admin_password
#   environment = var.environment
#   tags                = var.tags

#   depends_on = [
#     module.service_plans,
#     module.container_registry
#   ]
# }
