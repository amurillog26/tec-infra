module "aks" {
  source = "./terraform/modules/compute/kubernetes_cluster"

  cluster_name        = "aks-gpt-dev-001"
  location           = var.location
  resource_group_name = "rg_gpt_oai_dev"
  dns_prefix         = "aks-gpt-dev"

  subnet_id = lookup(module.networking.subnet_ids, "snet_gpt_aks_dev", null)

  default_node_pool = {
    name                = "default01"
    node_count         = 1
    vm_size            = "standard_d8ds_v6"
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 3
  }

  attach_acr = true
  acr_id     = module.container_registry.acr_id

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    owner       = "dev-team"
    workload    = "oai"
  }
}
