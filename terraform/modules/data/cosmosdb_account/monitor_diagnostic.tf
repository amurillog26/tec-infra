# # monitor_diagnostic.tf
# resource "azurerm_monitor_diagnostic_setting" "tec_cosmosdb_monitor" {
#   name                           = "${var.cosmos_account_name}-diag"
#   target_resource_id            = azurerm_cosmosdb_account.tec_cosmos_ac.id
#   log_analytics_workspace_id    = var.log_analytics_workspace_id
#   log_analytics_destination_type = "AzureDiagnostics"

#   enabled_log {
#     category = "DataPlaneRequests"
#   }

#   enabled_log {
#     category = "QueryRuntimeStatistics"

#   }

#   enabled_log {
#     category = "PartitionKeyStatistics"

#   }

#   metric {
#     category = "Requests"
#     enabled  = true

#   }
# }
