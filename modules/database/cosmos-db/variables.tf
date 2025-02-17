variable "main_rg_name" {
  type          = string
}

variable "main_vn_location" {
  type          = string
}

variable "resource_tags" {
  type        = map(string)
  description = "General Tags"
}

variable "cosmos_account_name" {
  type        = string
  description = "The name of Account for Cosmos DB, for Logger service"
}

variable "cosmos_account_offer_type" {
  type        = string
  description = "The type of Account"
}

variable "cosmos_account_kind" {
  type        = string
  description = "The kind of Account"
}

variable "cosmos_failover_az_region" {
  type        = string
  description = "The azure region for failover database"
}

variable "cosmos_sql_databases" {    
  type = list(object({        
    database_name = string
    containers = list(string)
  }))
}

variable "cosmos_throughput" {
  type        = string
}

variable "main_vn_id" {
  type        = string
  description = "Virtual Network Main ID"
}

variable "cosmos_private_endpoint_name" {
  type        = string
  description = "Private Endpoint Name for CosmosDB"
}

variable "cosmos_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet Id of Private endpoint for CosmosDB"
}

variable "cosmos_private_link_name" {
  type        = string
  description = "Name of Private Link Service Connection for Private Endpoint and CosmosDB"
}

variable "cosmos_private_dns_zone" {
  type        = string
  description = "Private DNS Zone name for CosmosDB"
}

variable "cosmos_vnet_dns_link" {
  type        = string
  description = "Name of Virtual Network Link with Private Zone CosmosDB"
}

variable "cosmos_public_access" {
  type        = string
  description = "Set the public access for the Cosmos DB"
}

variable "log_analytics_workspace_id" {
  type        = string
}