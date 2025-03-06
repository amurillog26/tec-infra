variable "name" {
  description = "Nombre del recurso Managed Grafana"
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos donde se creará el recurso Grafana"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure donde se creará el recurso Grafana"
  type        = string
}

variable "sku_name" {
  description = "SKU para el recurso de Grafana"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Essential"], var.sku_name)
    error_message = "El SKU debe ser Standard o Essential."
  }
}

variable "api_key_enabled" {
  description = "Indica si se permite la creación de API keys"
  type        = bool
  default     = true
}

variable "deterministic_outbound_ip_enabled" {
  description = "Indica si se habilitan las IPs salientes determinísticas"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Indica si se permite el acceso desde redes públicas"
  type        = bool
  default     = true
}

variable "zone_redundancy_enabled" {
  description = "Indica si se habilita la redundancia de zona"
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "Tipo de identidad asignada"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "El tipo de identidad debe ser SystemAssigned, UserAssigned o ambos."
  }
}

variable "azure_monitor_workspace_id" {
  description = "ID del espacio de trabajo de Azure Monitor para integración"
  type        = string
  default     = null
}

variable "private_endpoint_resource_id" {
  description = "ID del recurso para el private endpoint de Grafana"
  type        = string
  default     = null
}

variable "private_endpoint_subresource_name" {
  description = "Nombre del subrecurso para el private endpoint"
  type        = string
  default     = "grafana"
}

variable "admin_principal_ids" {
  description = "Lista de IDs de principal a los que se asignará el rol de Grafana Admin"
  type        = list(string)
  default     = []
}

variable "editor_principal_ids" {
  description = "Lista de IDs de principal a los que se asignará el rol de Grafana Editor"
  type        = list(string)
  default     = []
}

variable "viewer_principal_ids" {
  description = "Lista de IDs de principal a los que se asignará el rol de Grafana Viewer"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Etiquetas a asignar al recurso Grafana"
  type        = map(string)
  default     = {}
}
