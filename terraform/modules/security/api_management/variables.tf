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

variable "apim_name" {
  type        = string
  description = "The name of apim"
}

variable "apim_company_name" {
  type        = string
  description = "The company name"
}

variable "apim_publisher_email" {
  type        = string
  description = "The email of publisher in apim"
}

variable "apim_sku_name" {
  type        = string
  description = "The sku of apim"
}

variable "apim_subnet_id" {
  type        = string
  description = "The Subnet Id for the APIM"
}

variable "apim_nsg_name" {
  type        = string
  description = "Network Security Group name for the APIM"
}

variable "apim_developer_portal_whitelist" {
  type        = list(list(string))
  description = "White list with the ip list of developers"
}
