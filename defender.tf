# defender.tf
module "defender" {
  # Usa count para crear o no el módulo según el entorno
  count = var.environment == "dev" ? 1 : 0

  source = "./terraform/modules/security/defender"

  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name

  defender_plans = {
    Containers = {
      tier = "Standard" # Para AKS y Container Registry
    }
    ContainerRegistry = {
      tier = "Free" # Se encontró en el plan existente
    }
    KubernetesService = {
      tier = "Free" # Específico para AKS
    }
    KeyVaults = {
      tier = "Standard" # Para Key Vault
    }
    AppServices = {
      tier = "Standard" # Para App Services/Bastion
    }
    Dns = {
      tier = "Free" # Para Azure DNS
    }
    CosmosDbs = {
      tier = "Standard" # Para Cosmos DB
    }
    Arm = {
      tier = "Standard" # Para Resource Manager
    }
    VirtualMachines = {
      tier = "Standard" # Para VMs
      extension = {
        additional_extension_properties = {
          "ExclusionTags" = jsonencode([])
        }
        name = "AgentlessVmScanning"
      }
      extension = {
        additional_extension_properties = {}
        name                            = "AgentlessVmScanning"
      }
    }
    StorageAccounts = {
      tier = "Standard" # Para Table Storage
      extension = {
        additional_extension_properties = {}
        name                            = "SensitiveDataDiscovery"
      }
    }
    CloudPosture = {
      tier = "Standard" # Se encontró en el plan existente
      extension = {
        additional_extension_properties = {
          "ExclusionTags" = jsonencode([])
        }
        name = "AgentlessVmScanning"
      }
      extension = {
        additional_extension_properties = {}
        name                            = "AgentlessDiscoveryForKubernetes"
      }
      extension = {
        additional_extension_properties = {}
        name                            = "ApiPosture"
      }
      extension = {
        additional_extension_properties = {}
        name                            = "ContainerRegistriesVulnerabilityAssessments"
      }
      extension = {
        additional_extension_properties = {}
        name                            = "EntraPermissionsManagement"
      }
      extension = {
        additional_extension_properties = {}
        name                            = "SensitiveDataDiscovery"
      }
    }
    OpenSourceRelationalDatabases = {
      tier = "Standard" # Se encontró en el plan existente
    }
    SqlServerVirtualMachines = {
      tier = "Standard" # Se encontró en el plan existente
    }
    SqlServers = {
      tier = "Standard" # Se encontró en el plan existente
    }
  }

  # Configuración para Defender for APIs
  api_defender_subplan = "P1" # P1 para desarrollo

  # Asegurar que el API defender esté habilitado para mantener el template deployment
  api_defender_enabled = true # Añade esta línea si tu módulo lo soporta

  # Configuración para Log Analytics
  log_analytics_workspace_id       = module.log_analytics.workspace_id
  enable_log_analytics_integration = true

  # Configurar contactos para alertas
  security_contacts = var.security_contacts
}
