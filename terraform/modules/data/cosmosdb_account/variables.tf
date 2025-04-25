# variables.tf
variable "cosmos_account_name" {
  type        = string
  description = "Name of the Cosmos DB account"
}

variable "main_vn_location" {
  type        = string
  description = "Location for the Cosmos DB account"
}

variable "main_rg_name" {
  type        = string
  description = "Resource group name"
}

variable "cosmos_account_offer_type" {
  type        = string
  default     = "Standard"
  description = "Offer type for Cosmos DB account"
}

variable "cosmos_account_kind" {
  type        = string
  default     = "GlobalDocumentDB"
  description = "Kind of Cosmos DB account"
}

variable "cosmos_public_access" {
  type        = bool
  default     = false
  description = "Enable public network access"
}

variable "cosmos_failover_az_region" {
  type        = string
  description = "Azure region for failover"
}

variable "cosmos_sql_databases" {
  type = list(object({
    database_name = string
    containers = list(object({
      name           = string
      partition_key  = string  # Esto ahora es un solo string para partition_key_path
      throughput     = number
    }))
  }))
  description = "List of Cosmos DB databases and their containers"
}

variable "enable_private_endpoint" {
  type        = bool
  default     = true
  description = "Enable private endpoint"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for private endpoint"
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS Zone ID"
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {}
}

variable "cosmos_capabilities" {
  type        = list(string)
  description = "List of capabilities to enable on the Cosmos DB account"
  default     = null
}
