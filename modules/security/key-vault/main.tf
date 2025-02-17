locals {
  kv_retention    = 7
  kv_purge        = false
}

# --------------------------------------------------
# Kery Vault resource
# --------------------------------------------------
resource "azurerm_key_vault" "tec_kv" {
  name                        = var.kv_name
  location                    = var.main_vn_location
  resource_group_name         = var.main_rg_name
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = local.kv_retention
  purge_protection_enabled    = local.kv_purge
  public_network_access_enabled = var.kv_public_access
  sku_name = var.kv_sku_name
  
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
  enable_rbac_authorization = false

  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
    #  ip_rules = var.allow_subnets
    # virtual_network_subnet_ids = var.allow_subnets
  }

  tags = var.resource_tags
}

resource "azurerm_key_vault_certificate" "example" {
  name         = var.kv_certificate_ssl_name
  key_vault_id = azurerm_key_vault.tec_kv.id

  certificate {
    contents = filebase64("${path.module}/${var.kv_certificate_ssl_file}")
    password = var.kv_certificate_ssl_password
  }
}

# -------------------------------------------------- 
# Crate a Private Endpoint Connection for Key Vault
# -------------------------------------------------- 
resource "azurerm_private_endpoint" "kv_private_endpoint" {
  lifecycle {
    ignore_changes = [resource_group_name, subnet_id]
  }

  name                = var.kv_private_endpoint_name
  location            = var.main_vn_location
  resource_group_name = var.main_rg_name
  subnet_id           = var.kv_private_endpoint_subnet_id

  private_service_connection {
    name                           = var.kv_private_link_name
    private_connection_resource_id = azurerm_key_vault.tec_kv.id
    is_manual_connection           = false
    subresource_names = [ "vault" ]
  }

  tags = var.resource_tags
}

# -------------------------------------------------- 
# Crate the Private DNS Zone for Key Vault
# -------------------------------------------------- 
resource "azurerm_private_dns_zone" "kv_dns_zone" {
  name                = var.kv_private_dns_zone
  resource_group_name = var.main_rg_name
  depends_on = [azurerm_key_vault.tec_kv]
}

# -------------------------------------------------- 
# Add Private DNS Zone Key Vault to Main Virtual Network
# -------------------------------------------------- 
resource "azurerm_private_dns_zone_virtual_network_link" "kv_pdzvnl" {
  name                  = var.kv_vnet_dns_link
  resource_group_name   = var.main_rg_name
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns_zone.name
  virtual_network_id    = var.main_vn_id
  registration_enabled  = false
}

# -------------------------------------------------- 
# Create a DNS Record en Private DNS Zone Key Vault
# -------------------------------------------------- 
resource "azurerm_private_dns_a_record" "acrdata" {
  name                = lower(azurerm_key_vault.tec_kv.name)
  zone_name           = azurerm_private_dns_zone.kv_dns_zone.name
  resource_group_name = var.main_rg_name
  ttl                 = 300
  records             = [ azurerm_private_endpoint.kv_private_endpoint.private_service_connection[0].private_ip_address ]
}
