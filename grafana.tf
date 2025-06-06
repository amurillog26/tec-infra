# grafana.tf - Actualizado para usar private endpoint
module "grafana" {
  source = "./terraform/modules/monitoring/grafana"

  count = contains(["dev", "pprd", "prod"], var.environment) ? 1 : 0

  name                = var.grafana.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Basic configuration
  sku_name                          = var.grafana.sku_name
  grafana_version                   = var.grafana.grafana_version
  api_key_enabled                   = var.grafana.api_key_enabled
  deterministic_outbound_ip_enabled = var.grafana.deterministic_outbound_ip_enabled
  public_network_access_enabled     = false
  zone_redundancy_enabled           = var.grafana.zone_redundancy_enabled

  # Private Endpoint configuration
  private_endpoint_enabled = true
  subnet_id                = module.networking.subnet_ids["snet_gpt_pe_${var.environment}"]
  private_dns_zone_ids     = [module.private_dns_zone["privatelink.grafana.azure.com"].id]

  # Identity - system assigned doesn't require permissions
  identity_type = var.grafana.identity_type

  # Don't provide any principal IDs to avoid role assignments
  admin_principal_ids  = []
  editor_principal_ids = []
  viewer_principal_ids = []

  tags = merge(var.tags, lookup(var.grafana, "tags", {}))
}

# Secret para guardar el endpoint de Grafana en Key Vault
resource "azurerm_key_vault_secret" "grafana_endpoint" {
  count = contains(["dev", "pprd"], var.environment) ? 1 : 0

  name         = "grafana-endpoint"
  value        = module.grafana[0].endpoint
  key_vault_id = module.key_vault.kv_id

  depends_on = [
    module.grafana
  ]
}
