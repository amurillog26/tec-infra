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

variable "afw_name" {
  type        = string
  description = "The name of Azure Firewall"
}

variable "afw_public_ip_name" {
  type        = string
  description = "The name of the public IP for the Azure Firewall" 
}

variable "afw_subnet_id" {
  type        = string
}

variable "afw_sku_name" {
  type        = string
  description = "The SKU name of the Firewall"
}

variable "afw_sku_tier" {
  type        = string
  description = "The SKU tier of the Firewall"
}

variable "vm_private_ip" {
  type        = string
  description = "The private ip of vm host vm"
}

variable "vm_subnet_id" {
  type        = string
}

variable "vm_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet del Host vm"
}

variable "aro_master_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de nodos master de ARO"
}

variable "aro_worker_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de nodos worker de ARO"
}

variable "log_analytics_workspace_id" {
  type        = string
}
