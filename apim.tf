module "apim" {
  source = "./terraform/modules/networking/api_management"

  resource_group_name = var.resource_group_name
  location            = var.location
  apim                = var.apim
  tenant_id           = var.tenant_id
  tags                = var.tags
  depends_on = [
    module.networking
  ]
}
