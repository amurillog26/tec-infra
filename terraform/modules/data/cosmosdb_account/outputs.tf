# outputs.tf
output "cosmos_db_id" {
  value       = azurerm_cosmosdb_account.tec_cosmos_ac.id
  description = "The ID of the Cosmos DB account"
}

output "cosmos_db_endpoint" {
  value       = azurerm_cosmosdb_account.tec_cosmos_ac.endpoint
  description = "The endpoint of the Cosmos DB account"
}

output "cosmos_db_primary_key" {
  value       = azurerm_cosmosdb_account.tec_cosmos_ac.primary_key
  sensitive   = true
  description = "The primary key of the Cosmos DB account"
}

output "private_endpoint_ip" {
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.cosmos_private_endpoint[0].private_service_connection[0].private_ip_address : null
  description = "Private endpoint IP address"
}
