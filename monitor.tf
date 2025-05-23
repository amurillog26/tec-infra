# Log Analytics Workspace Module
module "log_analytics" {
  source = "./terraform/modules/monitoring/insights"

  workspace_name      = "log-analytics-${var.environment}-workspace"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_days      = 30

  tags = merge(var.tags, {
    component = "monitoring"
    type      = "log-analytics"
  })
}

# 2. Azure Monitor Workspace para Prometheus
resource "azurerm_monitor_workspace" "prometheus" {
  name                = "amw-${var.kubernetes.cluster_name}-prometheus"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# 3. Data Collection Endpoint
resource "azurerm_monitor_data_collection_endpoint" "prometheus_dce" {
  name                          = "dce-${var.kubernetes.cluster_name}-prometheus"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  kind                          = "Linux"
  public_network_access_enabled = true
  description                   = "Data Collection Endpoint para métricas de Prometheus"

  tags = var.tags
}

# 4. Data Collection Rule para Prometheus
resource "azurerm_monitor_data_collection_rule" "prometheus_dcr" {
  name                        = "dcr-${var.kubernetes.cluster_name}-prometheus"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.prometheus_dce.id

  description = "Data Collection Rule para Prometheus en AKS"

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.prometheus.id
      name               = "prometheus-workspace"
    }
  }

  data_flow {
    destinations = ["prometheus-workspace"]
    streams      = ["Microsoft-PrometheusMetrics"]
  }

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }

  tags = var.tags
}

# 5. Asociación entre DCR y AKS
resource "azurerm_monitor_data_collection_rule_association" "prometheus_dcra" {
  name                    = "dcra-${var.kubernetes.cluster_name}-prometheus"
  target_resource_id      = module.aks.cluster_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus_dcr.id
  description             = "Asociación de Prometheus con AKS"
}
