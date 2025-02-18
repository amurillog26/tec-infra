# outputs.tf
output "cluster_id" {
  description = "ID del cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "Nombre del cluster AKS"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  description = "Kubeconfig del cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kube_admin_config" {
  description = "Kubeconfig de admin del cluster"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
}

output "cluster_identity" {
  description = "Identidad asignada por el sistema del cluster"
  value = {
    principal_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
  }
}

output "node_resource_group" {
  description = "Nombre del grupo de recursos autogenerado que contiene los recursos del cluster"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}
