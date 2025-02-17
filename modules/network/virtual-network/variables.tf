variable "main_vn_name" {
  type          = string
  description   = "Nombre de Virtual Network principal para XPOX"
}

variable "main_vn_location" {
  type          = string
  description   = "Region donde sera creada la Virtual Network principal para XPOX"
}

variable "main_rg_name" {
  type          = string
  description   = "Nombre de Resouce Group principal para tec"
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags de recursos"
}

variable "main_vn_address_space" {
  type        = list(string)
  description = "Bloque CIDR para la Virtual Network principal"
}

variable "aro_master_subnet_name" {
  type        = string
  description = "Nombre para Subnet de nodos master de ARO"
}

variable "aro_master_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de nodos master de ARO"
}

variable "aro_worker_subnet_name" {
  type        = string
  description = "Nombre para Subnet de nodos worker de ARO"
}

variable "aro_worker_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de nodos worker de ARO"
}

variable "firewall_subnet_name" {
  type        = string
  description = "Nombre para Subnet de Firewall"
}

variable "firewall_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de Firewall"
}

variable "vm_subnet_name" {
  type        = string
  description = "Nombre para Subnet de vm"
}

variable "vm_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet del Host vm"
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Nombre para Subnet de Priate Endpoints"
}

variable "private_endpoint_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de Private Endpoints"
}


variable "sqlmi_subnet_name" {
  type        = string
  description = "The subnet name of Sql Managed Instance"
}

variable "sqlmi_subnet_addr" {
  type        = list(string)
  description = "The prefix CICR for Sql Managed Instance"
}

variable "nosql_subnet_name" {
  type        = string
  description = "Espacio de direcciones o CIDR para la Subnet de based de datos nosql"
}

variable "nosql_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de bases de datos nosql"
}

variable "apim_subnet_name" {
  type        = string
  description = "Espacio de direcciones o CIDR para la Subnet de API Managment"
}

variable "apim_subnet_addr" {
  type        = list(string)
  description = "Espacio de direcciones o CIDR para la Subnet de API Managment"
}

