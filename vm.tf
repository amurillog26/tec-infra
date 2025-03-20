module "windows_vm" {
  source = "./terraform/modules/compute/virtual_machine"

  main_rg_name     = var.resource_group_name
  main_vn_location = var.location

  vm_name     = var.windows_vm.name
  vm_nic_name = var.windows_vm.nic_name
  # Referencia correcta al módulo networking que ya tienes definido
  vm_subnet_id      = module.networking.subnet_ids["snet_gpt_vm_dev"]
  vm_size           = var.windows_vm.size
  vm_admin_username = var.windows_vm.admin_username
  vm_admin_password = var.windows_vm.admin_password
  vm_hostname       = var.windows_vm.hostname

  resource_tags = merge(var.tags, var.windows_vm.tags)
}

