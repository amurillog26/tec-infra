module "cosmos_db" {
  source = "./terraform/modules/data/cosmosdb_account"

  cosmos_account_name       = var.cosmos_account_name
  main_rg_name              = data.azurerm_resource_group.rg.name
  main_vn_location          = data.azurerm_resource_group.rg.location
  cosmos_account_offer_type = var.cosmos_account_offer_type
  cosmos_account_kind       = var.cosmos_account_kind
  cosmos_public_access      = var.cosmos_public_access
  cosmos_failover_az_region = var.cosmos_failover_az_region
  cosmos_sql_databases      = var.cosmos_sql_databases
  enable_private_endpoint   = var.enable_private_endpoint
  subnet_id                 = var.enable_private_endpoint ? module.networking.subnet_ids["snet_gpt_pe_${var.environment}"] : null
  private_dns_zone_id       = var.private_dns_zone_id
  cosmos_capabilities       = var.cosmos_capabilities
  tags                      = var.tags
}
