variable "resource_group_name" {
  type        = string
  description = "Nombre del grupo de recursos donde se desplegará Azure Firewall"
}

variable "location" {
  type        = string
  description = "Ubicación de Azure donde se desplegará el firewall"
}

variable "fw_name" {
  type        = string
  description = "Nombre del Azure Firewall"
}

variable "fw_public_ip_name" {
  type        = string
  description = "Nombre de la IP pública para el firewall"
  default     = "fw-pip"
}

variable "fw_policy_name" {
  type        = string
  description = "Nombre de la política de firewall"
  default     = "fw-policy"
}

variable "fw_subnet_id" {
  type        = string
  description = "ID de la subnet AzureFirewallSubnet existente"
}

variable "fw_sku_tier" {
  type        = string
  description = "SKU del Azure Firewall (Standard o Premium)"
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.fw_sku_tier)
    error_message = "El valor de fw_sku_tier debe ser 'Standard' o 'Premium'."
  }
}

variable "dns_proxy_enabled" {
  type        = bool
  description = "Habilitar proxy DNS en el firewall"
  default     = true
}

variable "enable_fw_insights" {
  type        = bool
  description = "Habilitar Azure Firewall Insights"
  default     = true
}

variable "enable_diagnostics" {
  type        = bool
  description = "Habilitar configuración de diagnóstico para el firewall"
  default     = true
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID del workspace de Log Analytics para diagnósticos"
  default     = null
}

variable "log_retention_days" {
  type        = number
  description = "Días de retención para logs"
  default     = 30
}

variable "create_route_table" {
  type        = bool
  description = "Crear tabla de rutas para el firewall"
  default     = false
}

variable "route_table_routes" {
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  description = "Rutas para la tabla de rutas del firewall"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Etiquetas para asignar a los recursos"
  default     = {}
}