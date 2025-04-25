variable "main_rg_name" {
  description = "Nombre del grupo de recursos principal"
  type        = string
}

variable "main_vn_location" {
  description = "Ubicación de la red virtual principal"
  type        = string
}

variable "vm_name" {
  description = "Nombre de la máquina virtual"
  type        = string
}

variable "vm_nic_name" {
  description = "Nombre de la interfaz de red de la VM"
  type        = string
}

variable "vm_subnet_id" {
  description = "ID de la subred donde se desplegará la VM"
  type        = string
}

variable "vm_size" {
  description = "Tamaño de la máquina virtual"
  type        = string
  default     = "Standard_B4ms"
}

variable "vm_admin_username" {
  description = "Nombre de usuario administrador"
  type        = string
}

variable "vm_admin_password" {
  description = "Contraseña del usuario administrador"
  type        = string
  sensitive   = true
}

variable "vm_hostname" {
  description = "Nombre de host de la máquina virtual"
  type        = string
}

variable "resource_tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}
