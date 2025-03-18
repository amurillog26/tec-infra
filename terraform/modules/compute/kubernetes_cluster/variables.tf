variable "cluster_name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "location" {
  type        = string
  description = "Azure region where the cluster will be deployed"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for the cluster"
}

variable "disk_encryption_set_id" {
  type        = string
  description = "Disk Encryption Set ID"
  default     = null
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.31.5"
}

variable "default_node_pool" {
  type = object({
    name                = string
    node_count         = number
    vm_size            = string
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
  })
  description = "Default node pool configuration"
  default = {
    name                = "default"
    node_count         = 3
    vm_size            = "Standard_D8ds v5"
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 3
  }
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the AKS cluster"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["1"]
}

variable "attach_acr" {
  type        = bool
  description = "Attach Azure Container Registry"
  default     = false
}

variable "acr_id" {
  type        = string
  description = "Azure Container Registry ID"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}

# Añadir estas variables nuevas
variable "private_cluster_enabled" {
  type        = bool
  description = "Enable private cluster for AKS"
  default     = false
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS Zone ID for AKS API server"
  default     = null
}

# Variable para nodepools adicionales
variable "additional_node_pools" {
  type = map(object({
    name                = string
    node_count         = number
    vm_size            = string
    mode               = string
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
    node_labels        = optional(map(string), {})
    node_taints        = optional(list(string), [])
  }))
  description = "Map of additional node pool configurations"
  default     = {}
}

variable "user_assigned_identity_id" {
  type        = string
  description = "User assigned identity ID for AKS"
  default     = null  # Esto permite que sea opcional
}
