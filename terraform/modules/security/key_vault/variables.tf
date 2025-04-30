variable "main_rg_name" {
  type          = string
}

variable "main_vn_location" {
  type          = string
}

variable "tags" {
  type        = map(string)
  description = "General Tags"
}

variable "kv_name" {
  type        = string
  description = "The name of Key Vault"
}

variable "kv_sku_name" {
  type        = string
  description = "The SKU for Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "The tenant id of current subscription"
}

variable "kv_public_access" {
  type        = bool
  description = "Enable or disable public access to the key vault"
  default     = false
}

variable "access_policies" {
  description = "Lista de políticas de acceso para el Key Vault"
  type = list(object({
    tenant_id               = string
    object_id               = string
    application_id          = optional(string, null)
    certificate_permissions = optional(list(string), [])
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    storage_permissions     = optional(list(string), [])
  }))
  default = []
}

