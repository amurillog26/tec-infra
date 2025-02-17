locals {
  ip_allocation_method = "Dynamic"
  enable_ip_forwarding = true

  vm_caching              = "ReadWrite"
  vm_storage_account_type = "Standard_LRS"
  
  vm_sim_publisher        = "Canonical"
  vm_sim_version          = "latest"
  nic_ip_cfg_name             = "${var.vm_nic_name}-cfg"
}

# --------------------------------------------------
# Create the Network Security Group for to allow SSH
# connection
# --------------------------------------------------
resource "azurerm_network_security_group" "vm_public_nsg" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }
  
  name                = "${var.vm_name}-pblc-nsg"
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name

  # Allow SSH traffic
  security_rule {
    name                       = "allow-ssh-all"
    description                = "SSH Connection"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow GRPC traffic
  security_rule {
    name                       = "allow-grpc-api"
    description                = "GRPC Connection for Microservices"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5001"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SQLMI traffic
  security_rule {
    name                       = "allow-sqlmi-api"
    description                = "SQLMI Connection for GitHub Actions"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags                = var.resource_tags
}

# -------------------------------------------------- 
# Create a Network Interface for the VM vm Host
# -------------------------------------------------- 
resource "azurerm_network_interface" "vm_nic" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                      = var.vm_nic_name
  location                  = var.main_vn_location
  resource_group_name       = var.main_rg_name
  enable_ip_forwarding      = local.enable_ip_forwarding

  ip_configuration {
      name                          = local.nic_ip_cfg_name
      subnet_id                     = var.vm_subnet_id
      private_ip_address_allocation = local.ip_allocation_method
  }

  tags                      = var.resource_tags
}

# -------------------------------------------------- 
# Add NSG SSH connection to the Bation NIC
# -------------------------------------------------- 
resource "azurerm_network_interface_security_group_association" "network_interface_nsg_assoc" {
  network_interface_id          = azurerm_network_interface.vm_nic.id
  network_security_group_id     = azurerm_network_security_group.vm_public_nsg.id
}

# -------------------------------------------------- 
# Crate a Virtual Machine, this VM will be used how
# vm Host, Jumper Server and Tool Box
# -------------------------------------------------- 
resource "azurerm_linux_virtual_machine" "vm_virtual_machine" {
  lifecycle {
    ignore_changes = [resource_group_name]
  }

  name                = var.vm_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  computer_name       = var.vm_hostname

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.vm_admin_ssh_pub
  }

  os_disk {
    caching              = local.vm_caching
    storage_account_type = local.vm_storage_account_type
  }

  source_image_reference {
    publisher = local.vm_sim_publisher
    offer     = var.vm_vm_offer
    sku       = var.vm_vm_sku
    version   = local.vm_sim_version
  }

  tags                      = var.resource_tags
}
