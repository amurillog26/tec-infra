locals {
  ip_allocation_method = "Dynamic"
  enable_ip_forwarding = true

  vm_caching              = "ReadWrite"
  vm_storage_account_type = "StandardSSD_LRS"
  
  vm_publisher            = "MicrosoftWindowsDesktop"
  vm_offer                = "Windows-11"
  vm_sku                  = "win11-22h2-pro"
  vm_version              = "latest"
  nic_ip_cfg_name         = "${var.vm_nic_name}-cfg"
}

# Public IP para la VM
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${var.vm_name}-pip"
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags                = var.resource_tags
  
  lifecycle {
    ignore_changes = [resource_group_name]
  }
}

# --------------------------------------------------
# Create the Network Security Group for the Windows VM
# --------------------------------------------------
resource "azurerm_network_security_group" "vm_nsg" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }
  
  name                = "${var.vm_name}-nsg"
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name

  # Allow RDP traffic
  security_rule {
    name                       = "allow-rdp-all"
    description                = "RDP Connection"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "0.0.0.0"
    destination_address_prefix = "*"
  }

  # Allow HTTP/HTTPS traffic
  security_rule {
    name                       = "allow-http"
    description                = "HTTP Connection"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "allow-https"
    description                = "HTTPS Connection"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags                = var.resource_tags
}

# -------------------------------------------------- 
# Create a Network Interface for the VM
# -------------------------------------------------- 
resource "azurerm_network_interface" "vm_nic" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                      = var.vm_nic_name
  location                  = var.main_vn_location
  resource_group_name       = var.main_rg_name

  ip_configuration {
      name                          = local.nic_ip_cfg_name
      subnet_id                     = var.vm_subnet_id
      private_ip_address_allocation = local.ip_allocation_method
      public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }

  tags                      = var.resource_tags
}

# -------------------------------------------------- 
# Associate NSG to Network Interface
# -------------------------------------------------- 
resource "azurerm_network_interface_security_group_association" "network_interface_nsg_assoc" {
  network_interface_id          = azurerm_network_interface.vm_nic.id
  network_security_group_id     = azurerm_network_security_group.vm_nsg.id
}

# -------------------------------------------------- 
# Create Windows 11 Virtual Machine
# -------------------------------------------------- 
resource "azurerm_windows_virtual_machine" "vm_virtual_machine" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                = var.vm_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password
  computer_name       = var.vm_hostname

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  os_disk {
    caching              = local.vm_caching
    storage_account_type = local.vm_storage_account_type
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = local.vm_publisher
    offer     = local.vm_offer
    sku       = local.vm_sku
    version   = local.vm_version
  }

  tags                      = var.resource_tags
}
