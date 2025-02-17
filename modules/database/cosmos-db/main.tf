locals {
  account_enable_automatic_failover = true  
  account_consistency_level         = "Session"

  cosmos_databases = flatten([
    for db in var.cosmos_sql_databases : [
      db.database_name
    ]
  ])

  cosmos_containers = flatten([
    for db in var.cosmos_sql_databases : [
      for cn in db.containers : {
        database_name = db.database_name
        container_name = cn
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

  enable_automatic_failover = local.account_enable_automatic_failover
  public_network_access_enabled = var.cosmos_public_access

  consistency_policy {
    consistency_level       = local.account_consistency_level
  }

  geo_location {
    location          = var.cosmos_failover_az_region
    failover_priority = 1
  }

  geo_location {
    location          = var.main_vn_location
    failover_priority = 0
  }

  tags = var.resource_tags
}

resource "azurerm_cosmosdb_sql_database" "tec_databases" {
  for_each            = toset(local.cosmos_databases)
  name                = each.value
  resource_group_name = var.main_rg_name
  account_name        = azurerm_cosmosdb_account.tec_cosmos_ac.name
}


resource "azurerm_cosmosdb_sql_container" "tec_containers" {
  for_each = {
    for cn in local.cosmos_containers : "${cn.database_name}-${cn.container_name}" => cn
  }

  name                  = each.value.container_name
  resource_group_name   = var.main_rg_name
  account_name          = azurerm_cosmosdb_account.tec_cosmos_ac.name
  database_name         = each.value.database_name
  partition_key_path    = "/id"
  throughput            = var.cosmos_throughput

  depends_on = [
    azurerm_cosmosdb_sql_database.tec_databases
  ]
}

# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------

# # -------------------------------------------------- 
# # Crate a Private Endpoint Connection for CosmosDB
# # -------------------------------------------------- 
# resource "azurerm_private_endpoint" "cosmos_private_endpoint" {
#   name                = var.cosmos_private_endpoint_name
#   location            = var.main_vn_location
#   resource_group_name = var.main_rg_name
#   subnet_id           = var.cosmos_private_endpoint_subnet_id

#   private_service_connection {
#     name                           = var.cosmos_private_link_name
#     private_connection_resource_id = azurerm_cosmosdb_account.tec_cosmos_ac.id
#     is_manual_connection           = false
#     subresource_names = [ "Sql" ]
#   }
# }

# # -------------------------------------------------- 
# # Crate the Private DNS Zone for CosmosDB
# # -------------------------------------------------- 
# resource "azurerm_private_dns_zone" "cosmos_dns_zone" {
#   name                = var.cosmos_private_dns_zone
#   resource_group_name = var.main_rg_name
#   depends_on = [ azurerm_cosmosdb_account.tec_cosmos_ac ]
# }

# # -------------------------------------------------- 
# # Add Private DNS Zone CosmosDB to Main Virtual Network
# # -------------------------------------------------- 
# resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_pdzvnl" {
#   name                  = var.cosmos_vnet_dns_link
#   resource_group_name   = var.main_rg_name
#   private_dns_zone_name = azurerm_private_dns_zone.cosmos_dns_zone.name
#   virtual_network_id    = var.main_vn_id
#   registration_enabled  = false
# }

# # -------------------------------------------------- 
# # Create a DNS Record en Private DNS Zone CosmosDB
# # -------------------------------------------------- 
# resource "azurerm_private_dns_a_record" "cosmosdata" {
#   name                = azurerm_cosmosdb_account.tec_cosmos_ac.name
#   zone_name           = var.cosmos_private_dns_zone
#   resource_group_name = var.main_rg_name
#   ttl                 = 300
#   records             = [ azurerm_private_endpoint.cosmos_private_endpoint.private_service_connection[0].private_ip_address ]
# }

# ----------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------
