variable "lookup_rg" {
  type = bool
  description = "Condicion para consultar o no el grupo de recursos principal"
  default = true
}

variable "main_rg_name" {
  type          = string
}