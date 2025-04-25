# federated_identities.tf

locals {
  # Lista de todos los servicios con sus respectivos namespaces y service accounts
  service_accounts = [
    {
      name      = "ai-chat-service"
      namespace = "ai-chat-service"
      sa_name   = "ai-chat-service-sa"
    },
    {
      name      = "authentication-service"
      namespace = "authentication-service"
      sa_name   = "authentication-service-sa"
    },
    {
      name      = "data-extraction-service"
      namespace = "data-extraction-service"
      sa_name   = "data-extraction-service-sa"
    },
    {
      name      = "form-service"
      namespace = "form-service"
      sa_name   = "form-service-sa"
    },
    {
      name      = "front-service"
      namespace = "front-service"
      sa_name   = "front-service-sa"
    },
    {
      name      = "image-processing-service"
      namespace = "image-processing-service"
      sa_name   = "image-processing-service-sa"
    },
    {
      name      = "proxy-service"
      namespace = "proxy-service"
      sa_name   = "proxy-service-sa"
    },
    {
      name      = "search-service"
      namespace = "search-service"
      sa_name   = "search-service-sa"
    },
    {
      name      = "skill-service"
      namespace = "skill-service"
      sa_name   = "skill-service-sa"
    },
    {
      name      = "skrill-service"
      namespace = "skrill-service"
      sa_name   = "skrill-service-sa"
    },
    {
      name      = "skrill-search-service"
      namespace = "skrill-service"
      sa_name   = "search-service-sa"
    },
    {
      name      = "user-file-storage-service"
      namespace = "user-file-storage-service"
      sa_name   = "user-file-storage-service-sa"
    }
  ]

  # OIDC Issuer URL para el cluster de AKS
  oidc_issuer = module.aks.oidc_issuer_url != "" ? module.aks.oidc_issuer_url : "https://southcentralus.oic.prod-aks.azure.com/c65a3ea6-0f7c-400b-8934-5a6dc1705645/43c3af0b-0981-43ed-8de4-da61292e5318/"
}

# Crear todas las credenciales federadas de forma dinámica
resource "azurerm_federated_identity_credential" "service_credentials" {
  for_each = { for sa in local.service_accounts : sa.name => sa }

  name                = "${each.value.name}-federated-identity"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = local.oidc_issuer
  parent_id           = module.service_managed_identities["aks-services-wi"].id
  subject             = "system:serviceaccount:${each.value.namespace}:${each.value.sa_name}"
}
