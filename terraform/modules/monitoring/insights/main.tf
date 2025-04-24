resource "azurerm_log_analytics_workspace" "insights" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_days

  # Optional: Enable querying across multiple workspaces
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled

  # Optional: Linked services configuration
  local_authentication_disabled = var.local_authentication_disabled

  tags = var.tags
}
