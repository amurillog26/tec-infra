variable "main_rg_name" {
  type          = string
}

variable "main_vn_location" {
  type          = string
}

variable "resource_tags" {
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

variable "sp_object_id" {
  type        = string
  description = "The Object id of current subscription"
}

variable "sp_app_object_id" {
  type        = string
  description = "The Object id of current subscription"
}

variable "sp_app_application_id" {
  type        = string
  description = "The object ID of an Application in Azure Active Directory."
}

variable "kv_sp_frontdoor_object_id" {
  type        = string
  description = "The Object id of FrontDoor App"
}

variable "kv_sp_frontdoor_application_id" {
  type        = string
  description = "The object ID of FrontDoor App."
}

variable "kv_private_endpoint_name" {
  type        = string
  description = "Private Endpoint Name for Key Vault"
}

variable "kv_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet Id of Private endpoint for Key Vault"
}

variable "kv_private_link_name" {
  type        = string
  description = "Name of Private Link Service Connection for Private Endpoint and Key Vault"
}

variable "kv_private_dns_zone" {
  type        = string
  description = "Private DNS Zone name for Key Vault"
}

variable "kv_vnet_dns_link" {
  type        = string
  description = "Name of Virtual Network Link with Private Zone Key Vault"
}

variable "kv_public_access" {
  type        = bool
  description = "Set the public access for the Key Vault"
}

variable "main_vn_id" {
  type        = string
  description = "Virtual Network Main ID"
}

variable "allow_subnets" {
  type        = set(string)
  description = "Allow Subnets for access to KeyVault" 
}

variable "kv_certificate_ssl_name" {
  type        = string
  description = "The name of the SSL tec certificate"
}

variable "kv_certificate_ssl_password" {
  type        = string
  sensitive   = true
  description = "The password of the ssl file certificadte"
}

variable "kv_certificate_ssl_file" {
  type        = string
  sensitive   = true
  description = "The pfx file of the ssl file certificate"
}
