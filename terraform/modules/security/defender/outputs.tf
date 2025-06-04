# terraform/modules/security/defender/outputs.tf

output "defender_plans" {
  description = "The Defender plans enabled"
  value       = [for plan in azurerm_security_center_subscription_pricing.defender_plans : plan.resource_type]
}

# output "security_contact" {
#   description = "Security contact information"
#   value       = length(azurerm_security_center_contact.security_contact) > 0 ? azurerm_security_center_contact.security_contact[0].email : null
# }
