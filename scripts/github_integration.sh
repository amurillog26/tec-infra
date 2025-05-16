#!/bin/bash

# This script creates the following resources in the specified subscription:
# - Resource group
# - Network Security Group rules
# - Virtual network (vnet) and subnet
# - Network Settings with specified subnet and GitHub Enterprisedatabase ID
#
# It also registers the `GitHub.Network` resource provider with the subscription,
# delegates the created subnet to the Actions service via the `GitHub.Network/NetworkSettings`
# resource type, and applies the NSG rules to the created subnet.

# stop on failure
set -e

#set environment
export AZURE_LOCATION=southcentralus
export SUBSCRIPTION_ID=49b8793e-f25e-49ab-8fc2-1190c08f377e
export RESOURCE_GROUP_NAME=rg_gpt_oai_pprd
export VNET_NAME=vnet_gpt_net_pprd
export SUBNET_NAME=snet_gpt_github_actions
export NSG_NAME=github-actions-nsg
export NETWORK_SETTINGS_RESOURCE_NAME=github-actions-settings
export DATABASE_ID=73250510
export API_VERSION=2024-04-02
export ARM_CLIENT_ID=c55934ac-fef7-4e1c-9260-1cf5798dc36a
export ARM_CLIENT_SECRET=
export ARM_TENANT_ID=c65a3ea6-0f7c-400b-8934-5a6dc1705645

# These are the default values. You can adjust your address and subnet prefixes.
export ADDRESS_PREFIX=10.0.0.0/16
export SUBNET_PREFIX=10.0.0.0/24

echo
echo login to Azure
. az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"

echo
echo set account context $SUBSCRIPTION_ID
. az account set --subscription $SUBSCRIPTION_ID

echo
echo Register resource provider GitHub.Network
. az provider register --namespace GitHub.Network

echo
echo Create NSG rules deployed with 'github.bicep' file
. az deployment group create --resource-group $RESOURCE_GROUP_NAME --template-file ./github.bicep --parameters location=$AZURE_LOCATION nsgName=$NSG_NAME

echo
echo Delegate subnet to GitHub.Network/networkSettings and apply NSG rules
. az network vnet subnet update --resource-group $RESOURCE_GROUP_NAME --name $SUBNET_NAME --vnet-name $VNET_NAME --delegations GitHub.Network/networkSettings --network-security-group $NSG_NAME

echo
echo Create network settings resource $NETWORK_SETTINGS_RESOURCE_NAME
. az resource create --resource-group $RESOURCE_GROUP_NAME --name $NETWORK_SETTINGS_RESOURCE_NAME --resource-type GitHub.Network/networkSettings --properties "{ \"location\": \"$AZURE_LOCATION\", \"properties\" : { \"subnetId\": \"/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Network/virtualNetworks/$VNET_NAME/subnets/$SUBNET_NAME\", \"businessId\": \"$DATABASE_ID\" }}" --is-full-object --output table --query "{GitHubId:tags.GitHubId, name:name}" --api-version $API_VERSION

echo
echo To clean up and delete resources run the following command:
echo az group delete --resource-group $RESOURCE_GROUP_NAME

