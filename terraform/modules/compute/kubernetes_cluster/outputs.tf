output "cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "AKS cluster ID"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
  description = "Raw kube config"
}

output "cluster_fqdn" {
  value       = azurerm_kubernetes_cluster.aks.fqdn
  description = "FQDN of the AKS cluster"
}

# versions.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  required_version = ">=1.0.0"
}

output "additional_node_pools" {
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.additional_pools : k => v.name }
  description = "Names of additional node pools"
}
