resource "azurerm_dashboard_grafana" "grafana" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  api_key_enabled                   = var.api_key_enabled
  deterministic_outbound_ip_enabled = var.deterministic_outbound_ip_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  zone_redundancy_enabled           = var.zone_redundancy_enabled
 
  # Especificar el SKU
  sku = var.sku_name
  
  # Especificar la versión de Grafana (10 o 11 para Standard SKU)
  grafana_major_version = "11"

  identity {
    type = var.identity_type
  }

  dynamic "azure_monitor_workspace_integrations" {
    for_each = var.azure_monitor_workspace_id != null ? [1] : []
    content {
      resource_id = var.azure_monitor_workspace_id
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      grafana_major_version
    ]
  }
}

# Asignación de roles para Grafana
resource "azurerm_role_assignment" "grafana_admin" {
  count                = length(var.admin_principal_ids)
  principal_id         = var.admin_principal_ids[count.index]
  role_definition_name = "Grafana Admin"
  scope                = azurerm_dashboard_grafana.grafana.id
}

resource "azurerm_role_assignment" "grafana_editor" {
  count                = length(var.editor_principal_ids)
  principal_id         = var.editor_principal_ids[count.index]
  role_definition_name = "Grafana Editor"
  scope                = azurerm_dashboard_grafana.grafana.id
}

resource "azurerm_role_assignment" "grafana_viewer" {
  count                = length(var.viewer_principal_ids)
  principal_id         = var.viewer_principal_ids[count.index]
  role_definition_name = "Grafana Viewer"
  scope                = azurerm_dashboard_grafana.grafana.id
}


resource "azurerm_private_endpoint" "grafana_pe" {
  count = var.private_endpoint_enabled ? 1 : 0

  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "private-link-grafana"
    private_connection_resource_id = azurerm_dashboard_grafana.grafana.id
    is_manual_connection           = false
    subresource_names              = ["grafana"]
  }

  # Solo crear el grupo de zona DNS si se proporcionan IDs de zonas DNS
  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "dns-zone-group-grafana"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}
