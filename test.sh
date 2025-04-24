#!/bin/bash
# Script para crear una nueva subnet específica para GitHub Actions
# en una VNET existente

# stop on failure
set -e

# Configuración - AJUSTAR ESTOS VALORES
export AZURE_LOCATION="southcentralus"
export SUBSCRIPTION_ID="49b8793e-f25e-49ab-8fc2-1190c08f377e"
export RESOURCE_GROUP_NAME="rg_gpt_oai_dev"
export DATABASE_ID="73250510"

# Valores de infraestructura existente - NO MODIFICAR
export VNET_NAME="vnet_gpt_net_dev"

# Nueva subnet para GitHub Actions
export SUBNET_NAME="snet_gpt_github_actions"
export SUBNET_PREFIX="10.97.174.96/27"  # Rango libre identificado en tu VNET

# Valores para la configuración GitHub Actions
export NSG_NAME="github-actions-nsg"
export NETWORK_SETTINGS_RESOURCE_NAME="github-actions-network-settings"
export API_VERSION="2024-04-02"

echo
echo "Iniciando sesión en Azure..."
az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID" 

echo
echo "Estableciendo contexto de cuenta $SUBSCRIPTION_ID"
az account set --subscription $SUBSCRIPTION_ID

echo
echo "Registrando proveedor de recursos GitHub.Network"
az provider register --namespace GitHub.Network

echo

az deployment group create --resource-group $RESOURCE_GROUP_NAME \
  --template-file ./azure.bicep \
  --parameters location=$AZURE_LOCATION nsgName=$NSG_NAME

echo
echo "Creando nueva subnet para GitHub Actions"
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP_NAME \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --address-prefix $SUBNET_PREFIX \
  --delegations GitHub.Network/networkSettings \
  --network-security-group $NSG_NAME

echo
echo "Creando recurso de configuración de red para GitHub Actions"
az resource create \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $NETWORK_SETTINGS_RESOURCE_NAME \
  --resource-type GitHub.Network/networkSettings \
  --properties "{ \"location\": \"$AZURE_LOCATION\", \"properties\" : { \"subnetId\": \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME\", \"businessId\": \"$DATABASE_ID\" }}" \
  --is-full-object \
  --output table \
  --query "{GitHubId:tags.GitHubId, name:name}" \
  --api-version $API_VERSION

echo
echo "Verificando zona DNS privada para AKS"
az network private-dns link vnet show \
  --name "${SUBNET_NAME}-link" \
  --resource-group $RESOURCE_GROUP_NAME \
  --zone-name privatelink.southcentralus.azmk8s.io > /dev/null 2>&1 || \
  az network private-dns link vnet create \
    --name "${SUBNET_NAME}-link" \
    --resource-group $RESOURCE_GROUP_NAME \
    --zone-name privatelink.southcentralus.azmk8s.io \
    --virtual-network $VNET_NAME \
    --registration-enabled true

echo
echo "Configuración completada. GitHub Actions ahora puede usar la subnet $SUBNET_NAME en $VNET_NAME."
echo "El peering está configurado automáticamente ya que es la misma VNET donde está el AKS."
echo "La zona DNS privada 'privatelink.southcentralus.azmk8s.io' ha sido verificada/vinculada."
