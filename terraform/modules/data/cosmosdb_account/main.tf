# main.tf
locals {
  account_enable_automatic_failover = true  
  account_consistency_level        = "Session"

  cosmos_databases = flatten([
    for db in var.cosmos_sql_databases : [
      db.database_name
    ]
  ])

  cosmos_containers = flatten([
    for db in var.cosmos_sql_databases : [
      for container in db.containers : {
        database_name   = db.database_name
        container_name  = container.name
        partition_key   = container.partition_key
        throughput     = container.throughput
      }
    ]
  ])
}

resource "azurerm_cosmosdb_account" "tec_cosmos_ac" {
  name                = var.cosmos_account_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  offer_type          = var.cosmos_account_offer_type
  kind                = var.cosmos_account_kind

  automatic_failover_enabled     = false  # Cambiado a false para serverless
  public_network_access_enabled = var.enable_private_endpoint ? false : var.cosmos_public_access
  network_acl_bypass_for_azure_services = true

  dynamic "capabilities" {
    for_each = var.cosmos_capabilities != null ? var.cosmos_capabilities : []
    content {
      name = capabilities.value
    }
  }

  consistency_policy {
    consistency_level       = local.account_consistency_level
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = var.main_vn_location
    failover_priority = 0
  }

  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 8
  }

  tags = var.tags
}

# Private Endpoint Configuration
resource "azurerm_private_endpoint" "cosmos_private_endpoint" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.cosmos_account_name}-pe"
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.cosmos_account_name}-privatelink"
    private_connection_resource_id = azurerm_cosmosdb_account.tec_cosmos_ac.id
    is_manual_connection           = false
    subresource_names             = ["Sql"]
  }

  private_dns_zone_group {
    name                 = "privatelink-documents-azure-com"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
