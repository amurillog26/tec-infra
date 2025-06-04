# # bastion.tf - Azure Bastion deployment

# # Public IP for Bastion
# resource "azurerm_public_ip" "bastion_pip" {
#   count               = var.bastion_enabled ? 1 : 0
#   name                = "pip-bastion-${var.environment}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   allocation_method   = "Static"
#   sku                 = "Standard"

#   tags = merge(var.tags, {
#     service = "bastion"
#     workload = "remote-access"
#   })
# }

# # Azure Bastion Module
# module "bastion" {
#   count  = var.bastion_enabled ? 1 : 0
#   source = "./terraform/modules/networking/bastion"

#   bastion_name         = "bastion-gpt-${var.environment}"
#   location             = var.location
#   resource_group_name  = var.resource_group_name
#   subnet_id           = module.networking.subnet_ids["AzureBastionSubnet"]
#   public_ip_address_id = azurerm_public_ip.bastion_pip[0].id

#   # Bastion configuration
#   sku_name              = var.bastion_config.sku_name
#   copy_paste_enabled    = var.bastion_config.copy_paste_enabled
#   file_copy_enabled     = var.bastion_config.file_copy_enabled
#   scale_units           = var.bastion_config.scale_units
#   shareable_link_enabled = var.bastion_config.shareable_link_enabled
#   tunneling_enabled     = var.bastion_config.tunneling_enabled
#   ip_connect_enabled    = var.bastion_config.ip_connect_enabled

#   # Diagnostics
#   enable_diagnostics         = true
#   log_analytics_workspace_id = module.log_analytics.workspace_id

#   tags = merge(var.tags, {
#     service     = "bastion"
#     environment = var.environment
#   })

#   depends_on = [
#     module.networking,
#     module.log_analytics
#   ]
# }

# # Key Vault secret for Bastion DNS name
# resource "azurerm_key_vault_secret" "bastion_dns" {
#   count        = var.bastion_enabled ? 1 : 0
#   name         = "bastion-dns-name"
#   value        = module.bastion[0].dns_name
#   key_vault_id = module.key_vault.kv_id

#   depends_on = [
#     module.bastion
#   ]
# }

# # Outputs
# output "bastion_id" {
#   description = "ID of the Azure Bastion host"
#   value       = var.bastion_enabled ? module.bastion[0].id : null
# }

# output "bastion_dns_name" {
#   description = "FQDN of the Azure Bastion host"
#   value       = var.bastion_enabled ? module.bastion[0].dns_name : null
# }

# output "bastion_public_ip" {
#   description = "Public IP address of the Bastion host"
#   value       = var.bastion_enabled ? azurerm_public_ip.bastion_pip[0].ip_address : null
# }
