# variables.tf
variable "name" {
  type        = string
  description = "Name of the managed identity"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region where the identity will be created"
}

variable "assign_key_vault_role" {
  type        = bool
  description = "Whether to assign Key Vault Secrets User role to the identity"
  default     = true
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault where certificates are stored"
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "Azure AD tenant ID"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to the identity"
  default     = {}
}
