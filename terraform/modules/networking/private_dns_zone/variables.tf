variable "name" {
  description = "The name of the private DNS zone"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the private DNS zone"
  type        = string
}

variable "linked_vnets" {
  description = "Map of virtual network IDs to link to the private DNS zone"
  type        = map(string)
  default     = {}
}

variable "registration_enabled" {
  description = "Is auto-registration of virtual machine records in the virtual network in the Private DNS zone enabled?"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
