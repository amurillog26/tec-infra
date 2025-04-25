# Azure Kubernetes Service
module "aks" {
  source = "./terraform/modules/compute/kubernetes_cluster"

  cluster_name        = var.kubernetes.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.kubernetes.dns_prefix
  kubernetes_version  = var.kubernetes.kubernetes_version

  subnet_id          = lookup(module.networking.subnet_ids, "snet_gpt_aks_${var.environment}", null)
  availability_zones = var.kubernetes.availability_zones

  # Configuración para clúster privado
  private_cluster_enabled           = var.kubernetes.private_cluster_enabled
  private_dns_zone_id               = var.kubernetes.private_dns_zone_name
  user_assigned_identity_id         = module.service_managed_identities["aks-services-wi"].id
  enable_key_vault_secrets_provider = var.kubernetes.enable_key_vault_secrets_provider
  default_node_pool                 = var.kubernetes.default_node_pool
  sku_tier                          = var.kubernetes.sku_tier # Add this line

  # Añadir nodepool adicional
  additional_node_pools      = var.kubernetes.additional_node_pools
  log_analytics_workspace_id = module.log_analytics.workspace_id
  # attach_acr         = var.kubernetes.attach_acr
  # acr_id             = module.container_registry.acr_id
  tenant_id = var.tenant_id

  tags = merge(var.tags, var.kubernetes.tags)
}

# 1. Monitor Diagnostic Setting para AKS - Sintaxis actualizada
resource "azurerm_monitor_diagnostic_setting" "aks_diagnostic" {
  name                       = "aks-${var.environment}-diagnostics"
  target_resource_id         = module.aks.cluster_id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
