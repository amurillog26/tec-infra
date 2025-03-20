variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos donde se crearán las cuentas de almacenamiento"
}

variable "location" {
  type        = string
  description = "Ubicación de Azure donde se crearán los recursos"
}

variable "tags" {
  type        = map(string)
  description = "Tags comunes para todos los recursos"
  default     = {}
}

variable "storage_accounts" {
  type = map(object({
    name                      = string
    account_tier             = optional(string)
    account_replication_type = optional(string)
    account_kind            = optional(string)
    min_tls_version         = optional(string)
    access_tier             = optional(string)
    is_hns_enabled         = optional(bool)
    cross_tenant_replication_enabled = optional(bool)
    
    network_rules = optional(object({
      default_action = optional(string)
      ip_rules       = optional(list(string))
      bypass         = optional(list(string))
    }))
    
    containers = optional(list(object({
      name        = string
      access_type = optional(string)
    })))
    
    tables = optional(list(object({
      name = string
    })))
    
    tags = optional(map(string))
  }))
  description = "Mapa de cuentas de almacenamiento para crear"
}
