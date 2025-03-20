variable "main_rg_name" {
  type          = string
  description   = "Nombre de Resouce Group principal para tec"
}

variable "main_vn_location" {
  type          = string
  description   = "Region donde sera creada la Virtual Network principal para XPOX"
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags de recursos"
}

variable "acr_name" {
  type        = string
  description = "Nombre de Azure Container Registry"
}

# variable "acr_private_endpoint_name" {
#   type        = string
#   description = "Private Endpoint Name for ACR"
# }

# variable "acr_private_endpoint_subnet_id" {
#   type        = string
#   description = "Subnet Id of Private endpoint for ACR"
# }

# variable "acr_private_link_name" {
#   type        = string
#   description = "Name of Private Link Service Connection for Private Endpoint and ACR"
# }

# variable "acr_private_dns_zone" {
#   type        = string
#   description = "Private DNS Zone name"
# }

# variable "acr_vnet_dns_link" {
#   type        = string
#   description = "Name of Virtual Network Link with Private Zone ACR"
# }

# variable "main_vn_id" {
#   type        = string
#   description = "Virtual Network Main ID"
# }

variable "acr_admin_enabled" {
  type        = bool
  description = "Specifies whether the admin user is enabled."
}

variable "acr_public" {
  type       = bool
  description = "Whether public network access is allowed"
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Whether or not the container registry is zone redundant"
  default = true
}

variable "enable_identity" {
  type        = bool
  description = "Enable user assigned identity for container registry"
  default     = false
}

variable "identity_type" {
  type        = string
  description = "Type of identity to use"
  default     = "UserAssigned"
}

variable "identity_ids" {
  type        = list(string)
  description = "List of user assigned identity IDs"
  default     = []
}
