# variables.tf
variable "resource_group_name" {
  description = "Nombre del grupo de recursos donde se creará el cluster"
  type        = string
}

variable "location" {
  description = "Ubicación de Azure donde se creará el cluster (si es null, usará la ubicación del grupo de recursos)"
  type        = string
  default     = null
}

variable "cluster_name" {
  description = "Nombre del cluster AKS"
  type        = string
}

variable "dns_prefix" {
  description = "Prefijo DNS para el cluster AKS"
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes a usar"
  type        = string
}

variable "default_node_pool_name" {
  description = "Nombre del node pool por defecto"
  type        = string
  default     = "default"
}

variable "node_vm_size" {
  description = "Tamaño de las VMs para los nodos"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "subnet_id" {
  description = "ID de la subnet donde se desplegarán los nodos"
  type        = string
}

variable "node_count" {
  description = "Número de nodos (cuando auto-scaling está deshabilitado)"
  type        = number
  default     = 1
}

variable "enable_auto_scaling" {
  description = "Habilitar auto-scaling para el node pool"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Número mínimo de nodos cuando auto-scaling está habilitado"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Número máximo de nodos cuando auto-scaling está habilitado"
  type        = number
  default     = 3
}

variable "max_pods" {
  description = "Número máximo de pods por nodo"
  type        = number
  default     = 30
}

variable "os_disk_size_gb" {
  description = "Tamaño del disco OS en GB"
  type        = number
  default     = 128
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para los nodos"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "network_plugin" {
  description = "Plugin de red a usar (azure o kubenet)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Plugin de política de red (azure o calico)"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "CIDR para servicios de Kubernetes"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "IP para el servicio DNS de Kubernetes"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "CIDR para el puente de docker"
  type        = string
  default     = "172.17.0.1/16"
}

variable "admin_group_object_ids" {
  description = "IDs de los grupos de AAD con acceso admin"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "ID del workspace de Log Analytics para monitoreo"
  type        = string
}

variable "node_labels" {
  description = "Labels para los nodos del pool por defecto"
  type        = map(string)
  default     = {}
}

variable "additional_node_pools" {
  description = "Configuración de node pools adicionales"
  type = map(object({
    name                = string
    vm_size             = string
    node_count          = number
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    os_disk_size_gb     = number
    node_labels         = map(string)
    node_taints         = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags para los recursos"
  type        = map(string)
  default     = {}
}
