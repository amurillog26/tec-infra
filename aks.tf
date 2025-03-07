# Azure Kubernetes Service
module "aks" {
  source = "./terraform/modules/compute/kubernetes_cluster"

  cluster_name       = var.kubernetes.cluster_name
  location           = var.location
  resource_group_name = var.resource_group_name
  dns_prefix         = var.kubernetes.dns_prefix
  kubernetes_version = var.kubernetes.kubernetes_version

  subnet_id          = lookup(module.networking.subnet_ids, "snet_gpt_aks_dev", null)
  availability_zones = var.kubernetes.availability_zones

  default_node_pool  = {
    name                = var.kubernetes.default_node_pool.name
    node_count          = var.kubernetes.default_node_pool.node_count
    vm_size             = var.kubernetes.default_node_pool.vm_size
    enable_auto_scaling = var.kubernetes.default_node_pool.enable_auto_scaling
    min_count           = var.kubernetes.default_node_pool.min_count
    max_count           = var.kubernetes.default_node_pool.max_count
  }

  attach_acr         = var.kubernetes.attach_acr
  acr_id             = module.container_registry.acr_id

  tags               = merge(var.tags, var.kubernetes.tags)
}
