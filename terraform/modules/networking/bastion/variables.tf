# terraform/modules/networking/bastion/variables.tf

variable "bastion_name" {
  description = "Name of the Azure Bastion host"
  type        = string
}

variable "location" {
  description = "Azure region where the Bastion will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the AzureBastionSubnet"
  type        = string
}

variable "public_ip_address_id" {
  description = "ID of the public IP address for Bastion"
  type        = string
}

variable "sku_name" {
  description = "SKU for Azure Bastion (Basic or Standard)"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard"], var.sku_name)
    error_message = "SKU must be either Basic or Standard."
  }
}

variable "copy_paste_enabled" {
  description = "Enable copy/paste functionality"
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Enable file copy functionality (Standard SKU only)"
  type        = bool
  default     = false
}

variable "scale_units" {
  description = "Number of scale units (2-50)"
  type        = number
  default     = 2
  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "Scale units must be between 2 and 50."
  }
}

variable "shareable_link_enabled" {
  description = "Enable shareable link functionality (Standard SKU only)"
  type        = bool
  default     = false
}

variable "tunneling_enabled" {
  description = "Enable tunneling functionality (Standard SKU only)"
  type        = bool
  default     = false
}

variable "ip_connect_enabled" {
  description = "Enable IP connect functionality (Standard SKU only)"
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the Bastion resources"
  type        = map(string)
  default     = {}
}
