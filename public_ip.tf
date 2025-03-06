module "public_ip" {
  source = "./terraform/modules/networking/public_ip"
  
  resource_group_name = var.resource_group_name
  location           = var.location
  public_ips         = var.public_ips
  tags               = var.tags
}
