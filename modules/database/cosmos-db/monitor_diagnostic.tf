# -------------------------------------------------- 
# Enable Diagnostic Settings for the CosmosDB
# -------------------------------------------------- 
resource "azurerm_monitor_diagnostic_setting" "tec_cosmosdb_monitor" {
  name               = var.cosmos_account_name
  target_resource_id = azurerm_cosmosdb_account.tec_cosmos_ac.id
  log_analytics_destination_type = "AzureDiagnostics"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "DataPlaneRequests"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "QueryRuntimeStatistics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "CassandraRequests"
    enabled  = false
    retention_policy {
        enabled  = false
      }
  }

  log {
    category = "ControlPlaneRequests"
    enabled  = false
    retention_policy {
        enabled  = false
      }
  }

  log {
    category = "GremlinRequests"
    enabled  = false
    retention_policy {
        enabled  = false
      }
  }

  log {
    category = "MongoRequests"
    enabled  = false
    retention_policy {
        enabled  = false
      }
  }

  log {
    category = "PartitionKeyRUConsumption"
    enabled  = false
    retention_policy {
        enabled  = false
      }
  }

  log {
    category = "PartitionKeyStatistics"
    enabled  = false
    retention_policy {
        enabled  = false
      }
  }

  log {
    category = "TableApiRequests"
    enabled  = false
    retention_policy {
        enabled  = false
      }
  }

  metric {
    category = "Requests"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

}
