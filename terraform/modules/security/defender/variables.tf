# terraform/modules/security/defender/variables.tf

variable "defender_plans" {
  description = "Map of Microsoft Defender plans to enable"
  type = map(object({
    tier = string
  }))
  default = {
    Containers = {
      tier = "Standard"
    }
    KeyVaults = {
      tier = "Standard"
    }
    AppServices = {
      tier = "Standard"
    }
    Dns = {
      tier = "Standard"
    }
    OpenSourceRelationalDatabases = {
      tier = "Standard"
    }
    CosmosDbs = {
      tier = "Standard"
    }
    Arm = {
      tier = "Standard"
    }
    VirtualMachines = {
      tier = "Standard"
    }
  }
}

variable "api_defender_subplan" {
  description = "Subplan for Defender for APIs (P1, P2, P3, P4, P5)"
  type        = string
  default     = "P1"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "security_contacts" {
  description = "List of security contacts"
  type = list(object({
    email               = string
    phone               = optional(string)
    alert_notifications = optional(bool)
    alerts_to_admins    = optional(bool)
  }))
  default = []
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace to use for Microsoft Defender"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Subscription ID where Defender will be enabled"
  type        = string
}

# Nueva variable para controlar la integración con Log Analytics
variable "enable_log_analytics_integration" {
  description = "Enable integration with Log Analytics workspace"
  type        = bool
  default     = false
}
