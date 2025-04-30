# Azure Managed Grafana
# module "grafana" {
#   source = "./terraform/modules/monitoring/grafana"

#   name                = var.grafana.name
#   resource_group_name = var.resource_group_name
#   location            = var.location

#   Configuración básica
#   sku_name                          = var.grafana.sku_name
#   grafana_version                   = var.grafana.grafana_version
#   api_key_enabled                   = var.grafana.api_key_enabled
#   deterministic_outbound_ip_enabled = var.grafana.deterministic_outbound_ip_enabled
#   public_network_access_enabled     = var.grafana.public_network_access_enabled
#   zone_redundancy_enabled           = var.grafana.zone_redundancy_enabled
#   private_endpoint_enabled          = var.grafana.private_endpoint_enabled

#   Identidad
#   identity_type = var.grafana.identity_type

#   Integración con Azure Monitor (opcional)
#   azure_monitor_workspace_id = lookup(var.grafana, "azure_monitor_workspace_id", null)

#   Asignación de roles
#   admin_principal_ids  = lookup(var.grafana, "admin_principal_ids", [])
#   editor_principal_ids = lookup(var.grafana, "editor_principal_ids", [])
#   viewer_principal_ids = lookup(var.grafana, "viewer_principal_ids", [])

#   tags = merge(var.tags, lookup(var.grafana, "tags", {}))
# }

# 6. Asignación de roles para Grafana
# resource "azurerm_role_assignment" "grafana_monitoring_reader" {
#   scope                = module.aks.cluster_id
#   role_definition_name = "Monitoring Reader"
#   principal_id         = module.grafana.identity[0].principal_id
# }

# resource "azurerm_role_assignment" "grafana_monitoring_data_reader" {
#   scope                = azurerm_monitor_workspace.prometheus.id
#   role_definition_name = "Monitoring Data Reader"
#   principal_id         = module.grafana.identity[0].principal_id
# }

# 7. Acceso a datos de Azure Monitor a nivel de suscripción
# resource "azurerm_role_assignment" "grafana_monitor_reader" {
#   scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   role_definition_name = "Monitoring Reader"
#   principal_id         = module.grafana.identity[0].principal_id
# }
