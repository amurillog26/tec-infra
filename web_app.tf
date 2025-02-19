module "service_plans" {
  source = "./terraform/modules/compute/app_service_plan"

  resource_group_name = data.azurerm_resource_group.rg.name
  location           = data.azurerm_resource_group.rg.location
  service_plans      = var.service_plans
  tags               = var.tags
}

# Web Apps
module "web_apps" {
  source = "./terraform/modules/compute/web_app"

  resource_group_name = "rg_gpt_oai_dev"
  location           = "southcentralus"
  environment        = "dev"

  web_apps = {
    "api" = {
      name            = "app-gpt-api-dev"
      service_plan_id = module.service_plans.service_plan_ids["plan1"]  # Referencia al plan existente
      subnet_id       = null  # Opcional para dev
      app_settings = {
        "WEBSITES_PORT" = "8080"
        "API_VERSION"   = "v1"
        "ENVIRONMENT"   = "development"
      }
      ip_restrictions = {}  # Vacío para dev
    }
  }

  acr_login_server   = module.container_registry.acr_login_server
  acr_admin_username = module.container_registry.acr_admin_username
  acr_admin_password = module.container_registry.acr_admin_password

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    owner       = "dev-team"
    workload    = "oai"
  }
}
