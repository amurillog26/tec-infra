variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos"
}

variable "location" {
  type        = string
  description = "Ubicación de Azure"
}

variable "storage_accounts" {
  type = map(object({
    name                     = string
    account_tier             = optional(string)
    account_replication_type = optional(string)
    account_kind            = optional(string)
    network_rules = optional(object({
      default_action = optional(string)
      ip_rules       = optional(list(string))
      bypass         = optional(list(string))
    }))
    containers = optional(list(object({
      name        = string
      access_type = optional(string)
    })))
    tags = optional(map(string))
  }))
  description = "Configuración de storage accounts"
}

variable "tags" {
  type        = map(string)
  description = "Tags comunes para todos los recursos"
  default     = {}
}
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

variable "kv_name" {
  type        = string
  description = "The name of Key Vault"
}

variable "kv_public_access" {
  type        = bool
  description = "Enable or disable public access to the key vault"
  default     = true
  
}

variable "kv_sku_name" {
  type        = string
  description = "The SKU for Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID"
  
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "address_space" {
  type        = list(string)
  description = "Address space for the virtual network"
}

variable "subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    service_endpoints                             = optional(list(string), [])
    delegation = optional(list(object({
      name    = string
      actions = list(string)
    })), [])
  }))
  description = "Map of subnet configurations"
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers"
  default     = []
}

# Cosmos DB Variables
variable "cosmos_account_name" {
  type        = string
  description = "Name of the Cosmos DB account"
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
  description = "Enable public network access for Cosmos DB"
}

variable "cosmos_failover_az_region" {
  type        = string
  description = "Azure region for Cosmos DB failover"
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
  default     = false
  description = "Enable private endpoint for Cosmos DB"
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private DNS Zone ID for Cosmos DB private endpoint"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for diagnostics"
}
