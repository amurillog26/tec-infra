# terraform/modules/networking/private_endpoint/variables.tf

variable "name" {
  description = "The name of the private endpoint"
  type        = string
}

variable "location" {
  description = "The location of the private endpoint"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name of the private endpoint"
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the private endpoint"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The resource ID to connect to"
  type        = string
}

variable "subresource_names" {
  description = "A list of subresource names to connect to"
  type        = list(string)
}

variable "is_manual_connection" {
  description = "Whether the connection is manual"
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "A list of private DNS zone IDs"
  type        = list(string)
  default     = null
}

variable "custom_network_interface_name" {
  description = "Custom name for the network interface"
  type        = string
  default     = null
}

variable "private_service_connection_name" {
  description = "Name of the private service connection"
  type        = string
  default     = null
}

variable "private_dns_zone_group_name" {
  description = "Name of the private DNS zone group"
  type        = string
  default     = null
}

variable "ip_configurations" {
  description = "List of IP configurations for the private endpoint"
  type        = list(map(string))
  default     = null
}

variable "tags" {
  description = "Tags for the private endpoint"
  type        = map(string)
  default     = {}
}
