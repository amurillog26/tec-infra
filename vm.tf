module "windows_vm" {
  source = "./terraform/modules/compute/virtual_machine"

  main_rg_name     = var.resource_group_name
  main_vn_location = var.location
  
  vm_name          = var.windows_vm.name
  vm_nic_name      = var.windows_vm.nic_name
  # Referencia correcta al módulo networking que ya tienes definido
  vm_subnet_id     = module.networking.subnet_ids["snet_gpt_vm_dev"]
  vm_size          = var.windows_vm.size
  vm_admin_username = var.windows_vm.admin_username
  vm_admin_password = var.windows_vm.admin_password
  vm_hostname      = var.windows_vm.hostname

  resource_tags    = merge(var.tags, var.windows_vm.tags)
}


# Network Interface (NIC) sin IP pública
resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-linux-vm-dev"
  location            = "southcentralus"
  resource_group_name = "rg_gpt_oai_dev"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.networking.subnet_ids["snet_gpt_vm_dev"]
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    workload    = "oai"
  }
}

# Network Security Group para la VM Linux
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-linux-vm-dev"
  location            = "southcentralus"
  resource_group_name = "rg_gpt_oai_dev"

  # Regla SSH - desde redes confiables únicamente
  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.97.174.0/23" # Solo desde dentro de la VNET
    destination_address_prefix = "*"
  }

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    workload    = "oai"
  }
}

# Asociar NSG a la NIC
resource "azurerm_network_interface_security_group_association" "nsg_nic_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# VM Linux Ubuntu con autenticación por contraseña
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-linux-dev"
  location            = "southcentralus"
  resource_group_name = "rg_gpt_oai_dev"
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!" # Asegúrate de cambiar esto a una contraseña segura
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"  # Ubuntu 22.04 LTS
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  tags = {
    environment = "dev"
    managed_by  = "terraform"
    workload    = "oai"
    type        = "jumpbox"
  }
}
