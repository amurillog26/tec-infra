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

variable "vm_nic_name" {
  type          = string
  description   = "Nombre de NIC de vm Host"
}

variable "vm_subnet_id" {
  type          = string
  description   = "ID de Subnet publica de vm Host"
}

variable "vm_name" {
  type          = string
  description   = "Nombre de vm Host" 
}

variable "vm_size"{
  type          = string
  description   = "The size of the Virtual Machine"
}

variable "vm_hostname"{
  type          = string
  description   = "The hostname of the Virtual Machine"
}

variable "vm_admin_username"{
  type          = string
  description   = "The admin username of the Virtual Machine"
  sensitive     = true
}

variable "vm_admin_ssh_pub"{
  type          = string
  description   = "The SSH public key of the admin user"
  sensitive     = true
}

variable "vm_vm_sku" {
  type          = string
  description = "The version of UbuntuServer"
}

variable "vm_vm_offer" {
  type          = string
  description = "The Offer of UbuntuServer"
}
