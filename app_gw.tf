module "application_gateway" {
  source = "./terraform/modules/security/application_gateway"

  resource_group_name  = var.resource_group_name
  location            = var.location
  application_gateway = var.application_gateway
  
  # Pasamos las referencias como variables separadas
  subnet_id    = module.networking.subnet_ids["snet_gpt_agw_dev"]
  public_ip_id = module.public_ip.public_ip_ids["pip_agw_gpt_dev"]
  managed_identity_id = module.managed_identity.id

  tags = var.tags
}
