# variables.tf
variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure donde se crearán los recursos"
  type        = string
}

variable "storage_accounts" {
  description = "Mapa de storage accounts a crear"
  type = map(object({
    name                     = string
    account_tier             = optional(string)
    account_replication_type = optional(string)
    account_kind            = optional(string)
    enable_https_traffic    = optional(bool)
    min_tls_version        = optional(string)
    access_tier            = optional(string)
    is_hns_enabled        = optional(bool)
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
}

variable "tags" {
  description = "Tags base para todos los recursos"
  type        = map(string)
  default     = {}
}
