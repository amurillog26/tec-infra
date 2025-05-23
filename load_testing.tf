# load_testing.tf
# Recurso para implementar Azure Load Testing sólo en el entorno pprd

# Crear Azure Load Test solo en ambiente pprd
resource "azurerm_load_test" "tecgpt_load_test" {
  count = var.environment == "pprd" ? 1 : 0

  name                = "lt-tecgpt-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Asignar una identidad administrada al servicio
  identity {
    type = "SystemAssigned"
  }

  tags = merge(var.tags, {
    service     = "load-testing"
    environment = var.environment
    workload    = "api-performance"
  })
  
  lifecycle {
    ignore_changes = [
      tags["created_date"],
      tags["created_by"]
    ]
  }
}

# Secret para guardar el Load Test Endpoint en Key Vault (solo en pprd)
resource "azurerm_key_vault_secret" "load_test_endpoint" {
  count = var.environment == "pprd" ? 1 : 0
  
  name         = "load-test-endpoint"
  value        = azurerm_load_test.tecgpt_load_test[0].data_plane_uri
  key_vault_id = module.key_vault.kv_id
  
  depends_on = [
    azurerm_load_test.tecgpt_load_test
  ]
}

# Output del ID y endpoint del Load Test
output "load_test_id" {
  description = "ID del servicio Azure Load Testing (solo en pprd)"
  value       = var.environment == "pprd" ? azurerm_load_test.tecgpt_load_test[0].id : null
}

output "load_test_endpoint" {
  description = "Endpoint del servicio Azure Load Testing (solo en pprd)"
  value       = var.environment == "pprd" ? azurerm_load_test.tecgpt_load_test[0].data_plane_uri : null
}
