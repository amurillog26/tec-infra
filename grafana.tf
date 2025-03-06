# Azure Managed Grafana
module "grafana" {
  source = "./terraform/modules/monitoring/grafana"

  name                = var.grafana.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Configuración básica
  sku_name                        = var.grafana.sku_name
  api_key_enabled                 = var.grafana.api_key_enabled
  deterministic_outbound_ip_enabled = var.grafana.deterministic_outbound_ip_enabled
  public_network_access_enabled   = var.grafana.public_network_access_enabled
  zone_redundancy_enabled         = var.grafana.zone_redundancy_enabled
  
  # Identidad
  identity_type                   = var.grafana.identity_type
  
  # Integración con Azure Monitor (opcional)
  azure_monitor_workspace_id      = lookup(var.grafana, "azure_monitor_workspace_id", null)
  
  # Private Endpoint (opcional)
  private_endpoint_resource_id    = lookup(var.grafana, "private_endpoint_resource_id", null)
  private_endpoint_subresource_name = lookup(var.grafana, "private_endpoint_subresource_name", "grafana")
  
  # Asignación de roles
  admin_principal_ids             = lookup(var.grafana, "admin_principal_ids", [])
  editor_principal_ids            = lookup(var.grafana, "editor_principal_ids", [])
  viewer_principal_ids            = lookup(var.grafana, "viewer_principal_ids", [])
  
  tags                            = merge(var.tags, lookup(var.grafana, "tags", {}))
}
