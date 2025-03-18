# variables.tf
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Location of the resources"
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

variable "tags" {
  type        = map(string)
  description = "Tags for all resources"
  default     = {}
}
