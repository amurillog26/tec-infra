variable "name" {
  description = "The name of the private endpoint"
  type        = string
}

variable "location" {
  description = "The Azure region where the private endpoint should be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the private endpoint"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the private endpoint should be created"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The resource ID of the private link service or resource to connect to"
  type        = string
}

variable "subresource_names" {
  description = "A list of subresource names which the private endpoint is able to connect to"
  type        = list(string)
}

variable "is_manual_connection" {
  description = "Does the Private Endpoint require manual approval from the remote resource owner?"
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "The IDs of the private DNS zones to link to the private endpoint"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
