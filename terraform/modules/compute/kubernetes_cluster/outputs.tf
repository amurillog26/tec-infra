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

output "additional_node_pools" {
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.additional_pools : k => v.name }
  description = "Names of additional node pools"
}

# Nuevas políticas de acceso al KeyVault
output "key_vault_access_policy" {
  description = "Política de acceso al KeyVault requerida por AKS kubelet"
  value = {
    object_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
    tenant_id = var.tenant_id
    secret_permissions = ["Get", "List"]
    key_permissions = ["Get", "List"]
    certificate_permissions = []
    storage_permissions = []
    application_id = null
  }
}

output "agentpool_key_vault_access_policy" {
  description = "Política de acceso al KeyVault para el agentpool de AKS"
  value = {
    object_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    tenant_id = var.tenant_id
    secret_permissions = ["Get", "List"]
    key_permissions = ["Get", "List"]
    certificate_permissions = []
    storage_permissions = []
    application_id = null
  }
}

# Terraform provider requirements (esto debería estar en versions.tf, no en outputs.tf)
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  required_version = ">=1.0.0"
}
