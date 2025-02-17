# --------------------------------------------------
# Get the principal Resource Group of the tec
# --------------------------------------------------
data "azurerm_resource_group" "main_rg" {
  count = var.lookup_rg ? 1 : 0
  name =  var.main_rg_name
}
