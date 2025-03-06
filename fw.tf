# # Añadir una subnet AzureFirewallSubnet a tu vnet existente
# resource "azurerm_subnet" "fw_subnet" {
#   name                 = "AzureFirewallSubnet"
#   resource_group_name  = var.main_rg_name
#   virtual_network_name = var.vnet_name
#   address_prefixes     = ["10.97.174.224/27"]  # Usar un rango disponible en tu VNET
# }

# # Implementar el firewall
# module "azure_firewall" {
#   source = "./terraform/modules/firewall"  # Ruta al módulo que acabamos de crear

#   resource_group_name      = var.main_rg_name
#   location                 = var.main_vn_location
#   fw_name                  = "fw-gpt-oai-${var.environment}"
#   fw_public_ip_name        = "pip-fw-gpt-oai-${var.environment}"
#   fw_policy_name           = "pol-fw-gpt-oai-${var.environment}"
#   fw_subnet_id             = azurerm_subnet.fw_subnet.id
#   fw_sku_tier              = "Standard"
#   dns_proxy_enabled        = true
#   enable_fw_insights       = true
#   enable_diagnostics       = true
#   log_analytics_workspace_id = var.log_analytics_workspace_id
#   log_retention_days       = 30
  
#   # Opcional: crear tabla de rutas con ruta por defecto al firewall
#   create_route_table      = true
#   route_table_routes      = [
#     {
#       name                   = "default-route"
#       address_prefix         = "0.0.0.0/0"
#       next_hop_type          = "VirtualAppliance"
#       next_hop_in_ip_address = module.azure_firewall.firewall_private_ip
#     }
#   ]
  
#   tags                     = merge(var.tags, var.resource_tags, {
#     component = "security"
#   })
# }

# # Ejemplo: Crear reglas de red para permitir comunicación entre subnets
# resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
#   name               = "rcg-network-rules"
#   firewall_policy_id = module.azure_firewall.firewall_policy_id
#   priority           = 100

#   network_rule_collection {
#     name     = "internal-communication"
#     priority = 100
#     action   = "Allow"
    
#     rule {
#       name                  = "allow-apim-to-aks"
#       protocols             = ["TCP"]
#       source_addresses      = var.subnets["snet_gpt_apim_dev"].address_prefixes
#       destination_addresses = var.subnets["snet_gpt_aks_dev"].address_prefixes
#       destination_ports     = ["443", "8080"]
#     }
    
#     rule {
#       name                  = "allow-agw-to-apim"
#       protocols             = ["TCP"]
#       source_addresses      = var.subnets["snet_gpt_agw_dev"].address_prefixes
#       destination_addresses = var.subnets["snet_gpt_apim_dev"].address_prefixes
#       destination_ports     = ["443"]
#     }
#   }
# }

# # Ejemplo: Crear reglas de aplicación para permitir acceso a servicios externos
# resource "azurerm_firewall_policy_rule_collection_group" "app_rules" {
#   name               = "rcg-app-rules"
#   firewall_policy_id = module.azure_firewall.firewall_policy_id
#   priority           = 200

#   application_rule_collection {
#     name     = "allowed-services"
#     priority = 100
#     action   = "Allow"
    
#     rule {
#       name = "allow-microsoft-services"
#       source_addresses = [
#         var.subnets["snet_gpt_aks_dev"].address_prefixes[0],
#         var.subnets["snet_gpt_apim_dev"].address_prefixes[0]
#       ]
      
#       protocols {
#         port = "443"
#         type = "Https"
#       }
      
#       destination_fqdns = [
#         "*.microsoft.com",
#         "*.windows.net",
#         "*.visualstudio.com",
#         "*.azure-api.net"
#       ]
#     }
    
#     rule {
#       name = "allow-updates"
#       source_addresses = concat(
#         var.subnets["snet_gpt_aks_dev"].address_prefixes,
#         var.subnets["snet_gpt_vm_dev"].address_prefixes
#       )
      
#       protocols {
#         port = "443"
#         type = "Https"
#       }
      
#       destination_fqdns = [
#         "*.windowsupdate.microsoft.com",
#         "*.update.microsoft.com",
#         "*.ubuntu.com",
#         "*.docker.com",
#         "*.mcr.microsoft.com"
#       ]
#     }
#   }
# }
