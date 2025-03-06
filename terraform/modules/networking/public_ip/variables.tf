
# variables.tf
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Location for the public IPs"
}

variable "public_ips" {
  type = map(object({
    name              = string
    allocation_method = string
    sku              = string
    sku_tier         = optional(string)
    zones            = optional(list(string))
    tags             = map(string)
  }))
  description = "Map of public IPs to create"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
