#!/bin/bash

# Definir variables comunes
SUBSCRIPTION="49b8793e-f25e-49ab-8fc2-1190c08f377e"
RG="rg_gpt_oai_dev"
IDENTITY="id-aks-services-wi"
VAR_FILE="env/dev.tfvars"

# Array de servicios
SERVICES=(
  "proxy-service"
  "data-extraction-service"
  "authentication-service"
  "search-service"
  "form-service"
  "image-processing-service"
  "skrill-search-service"
  "skrill-service"
  "skill-service"
  "user-file-storage-service"
  "ai-chat-service"
  "front-service"
)

# Importar cada credencial
for SERVICE in "${SERVICES[@]}"; do
  echo "Importando $SERVICE..."
  
  terraform import -var-file="$VAR_FILE" \
    "azurerm_federated_identity_credential.service_credentials[\"$SERVICE\"]" \
    "/subscriptions/$SUBSCRIPTION/resourceGroups/$RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$IDENTITY/federatedIdentityCredentials/${SERVICE}-federated-identity"
  
  echo "------------------------------"
done

echo "Importación completada"
