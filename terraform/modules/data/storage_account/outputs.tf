# outputs.tf
output "storage_accounts" {
  description = "Mapa de storage accounts creados"
  value = {
    for key, sa in azurerm_storage_account.storage_accounts : key => {
      id                  = sa.id
      name                = sa.name
      primary_access_key = sa.primary_access_key
      primary_blob_endpoint = sa.primary_blob_endpoint
      containers = {
        for container_key, container in azurerm_storage_container.containers : 
        split(container_key, ".")[1] => container.id
        if split(container_key, ".")[0] == key
      }
    }
  }
  sensitive = true
}
