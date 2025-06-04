# terraform/modules/security/defender/main.tf

# Habilitar planes de Microsoft Defender
resource "azurerm_security_center_subscription_pricing" "defender_plans" {
  for_each = var.defender_plans

  tier          = each.value.tier
  resource_type = each.key

  # Agregar extensiones dinámicamente si existen
  dynamic "extension" {
    for_each = lookup(each.value, "extensions", [])
    content {
      name = extension.value.name
      additional_extension_properties = lookup(extension.value, "additional_extension_properties", {})
    }
  }

  lifecycle {
    ignore_changes = [
      subplan,
      extension  # Ignorar cambios en extensiones para evitar eliminación
    ]
  }
}

# Para API Management, que requiere un subplan, usamos un recurso separado
resource "azurerm_resource_group_template_deployment" "api_defender" {
  count               = var.api_defender_enabled ? 1 : 0
  name                = "api-defender-deployment"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  
  template_content = <<TEMPLATE
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "resources": [
    {
      "type": "Microsoft.Security/pricings",
      "apiVersion": "2023-01-01",
      "name": "Api",
      "properties": {
        "pricingTier": "Standard",
        "subPlan": "${var.api_defender_subplan}"
      }
    }
  ]
}
TEMPLATE

  lifecycle {
    # Ignorar cambios en subPlan para evitar reconstrucción
    ignore_changes = [template_content]
  }
}

# Conexión con Log Analytics usando un recurso nulo y CLI de Azure
resource "null_resource" "log_analytics_connection" {
  # Solo ejecutar si enable_log_analytics_integration es true
  count = var.enable_log_analytics_integration ? 1 : 0
  
  # Cualquier cambio en el ID del workspace triggereará esto
  triggers = {
    log_analytics_id = var.log_analytics_workspace_id
    subscription_id  = var.subscription_id
  }
  
  # Usamos local-exec para configurar la integración después de que los recursos están creados
  provisioner "local-exec" {
    command = <<-EOT
      az security workspace-setting create \
        --name default \
        --target-workspace "${var.log_analytics_workspace_id}" \
        --subscription "${var.subscription_id}"
    EOT
  }
}
