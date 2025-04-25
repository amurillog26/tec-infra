# terraform/modules/security/defender/main.tf

# Habilitar planes de Microsoft Defender
resource "azurerm_security_center_subscription_pricing" "defender_plans" {
  for_each = var.defender_plans

  tier          = each.value.tier
  resource_type = each.key
  lifecycle {
    ignore_changes = [
      subplan
    ]
  }
}

# Para API Management, que requiere un subplan, usamos un recurso separado
resource "azurerm_resource_group_template_deployment" "api_defender" {
  count               = contains(keys(var.defender_plans), "Api") ? 1 : 0
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
}

# Configuración de contactos de seguridad
resource "azurerm_security_center_contact" "security_contact" {
  count = length(var.security_contacts) > 0 ? 1 : 0
  
  name  = "security-contact"
  email = var.security_contacts[0].email
  phone = lookup(var.security_contacts[0], "phone", null)
  
  alert_notifications = lookup(var.security_contacts[0], "alert_notifications", true)
  alerts_to_admins    = lookup(var.security_contacts[0], "alerts_to_admins", true)
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
