terraform {
  backend "azurerm" {
    resource_group_name  = "rg_gpt_oai_dev" # El resource group donde está tu storage account
    storage_account_name = "stgpttfstates01"
    container_name       = "tfstate"
    # La key se pasa dinámicamente en el workflow
  }
}

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg_gpt_oai_pprd" # El resource group donde está tu storage account
#     storage_account_name = "tfstatepprdgptoai"
#     container_name       = "tfstate"
#     key                  = "release.tfstate"
#   }
# }
