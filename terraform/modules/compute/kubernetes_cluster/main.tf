resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix         = var.dns_prefix
  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name                = var.default_node_pool.name
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    vnet_subnet_id      = var.subnet_id
    zones               = var.availability_zones
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count          = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count          = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.max_count : null
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
  }

  role_based_access_control_enabled = true

  tags = var.tags
}

# resource "azurerm_role_assignment" "aks_acr" {
#   count                = var.attach_acr ? 1 : 0
#   scope                = var.acr_id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
# }
