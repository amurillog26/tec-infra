# resource "azurerm_resource_group" "prod" {
#   name     = "rg_gpt_oai_prod"
#   location = "East US"  # You can change this to your preferred Azure region
  
#   tags = {
#     environment = "production"
#     managed_by  = "terraform"
#   }
# }

# # Pre-Production Resource Group
# resource "azurerm_resource_group" "pprod" {
#   name     = "rg_gpt_oai_pprod"
#   location = "East US"  # You can change this to your preferred Azure region
  
#   tags = {
#     environment = "pre-production"
#     managed_by  = "terraform"
#   }
# }
