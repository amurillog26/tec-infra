# Azure Kubernetes Service
module "aks" {
  source = "./terraform/modules/compute/kubernetes_cluster"

  cluster_name        = var.kubernetes.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.kubernetes.dns_prefix
  kubernetes_version  = var.kubernetes.kubernetes_version

  subnet_id          = lookup(module.networking.subnet_ids, "snet_gpt_aks_dev", null)
  availability_zones = var.kubernetes.availability_zones

  # Configuración para clúster privado
  private_cluster_enabled   = var.kubernetes.private_cluster_enabled
  private_dns_zone_id       = var.kubernetes.private_dns_zone_name
  user_assigned_identity_id = module.managed_identity.id

  default_node_pool = var.kubernetes.default_node_pool

  # Añadir nodepool adicional
  additional_node_pools = var.kubernetes.additional_node_pools

  # attach_acr         = var.kubernetes.attach_acr
  # acr_id             = module.container_registry.acr_id

  tags = merge(var.tags, var.kubernetes.tags)
}
