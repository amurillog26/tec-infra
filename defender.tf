# defender.tf

module "defender" {
  source = "./terraform/modules/security/defender"

  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name

  # Planes de Defender según tu diagrama
  defender_plans = {
    Containers = {
      tier = "Standard" # Para AKS y Container Registry
    }
    KubernetesService = {
      tier = "Standard" # Específico para AKS
    }
    KeyVaults = {
      tier = "Standard" # Para Key Vault
    }
    AppServices = {
      tier = "Standard" # Para App Services/Bastion
    }
    Dns = {
      tier = "Standard" # Para Azure DNS
    }
    CosmosDbs = {
      tier = "Standard" # Para Cosmos DB
    }
    Arm = {
      tier = "Standard" # Para Resource Manager
    }
    VirtualMachines = {
      tier = "Standard" # Para VMs
    }
    StorageAccounts = {
      tier = "Standard" # Para Table Storage
    }
  }

  # Configuración para Defender for APIs
  api_defender_subplan = "P1" # P1 para desarrollo

  # Configuración para Log Analytics - usando variables que se conocen en tiempo de planificación
  log_analytics_workspace_id = module.log_analytics.workspace_id
  enable_log_analytics_integration = true  # Nueva variable para control determinista

  # Configurar contactos para alertas
  security_contacts = var.security_contacts
}
