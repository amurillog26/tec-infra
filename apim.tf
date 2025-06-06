module "apim" {
  source = "./terraform/modules/networking/api_management"

  resource_group_name = var.resource_group_name
  location            = var.location

  # Modificar la variable del módulo para pasar la referencia correcta a la IP
  apim = merge(var.apim, {
    # public_ip_address_id = module.public_ip.public_ip_ids["pip_apim_mgmt_${var.environment}"]
    public_ip_address_id = module.public_ip.public_ip_ids["apim-mgmnt-pip"]

  })
  environment = var.environment
  tenant_id   = var.tenant_id
  tags        = var.tags

  depends_on = [
    module.networking,
    module.public_ip
  ]
}
