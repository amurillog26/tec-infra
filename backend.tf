terraform {
  backend "azurerm" {
    resource_group_name  = "rg_gpt_oai_pprd" # El resource group donde está tu storage account para release
    storage_account_name = "tfstatepprdgptoai"
    container_name       = "tfstate"
  }
}
