variable "main_rg_name" {
  type          = string
  description   = "Nombre de Resouce Group principal para tec"
}

variable "domain_name" {
  type          = string
  description   = "Nombre de deominio privado para tec"
}

variable "a_records" {
    type = list(object({
        name = string
        ttl = number
        value = list(string)
    }))
    description = "List of A records."
}

variable "virt_net_link_name" {
    type = string
    description = "The name of the virtual network link."
}

variable "main_vn_id" {
  type          = string
  description   = "Virtual Network ID"
}

variable "registration_enabled" {
  type          = bool
  description   = "Indicates whether the registration is enabled or disabled."  
}
