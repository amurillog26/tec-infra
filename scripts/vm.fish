#!/usr/bin/env fish

# Variables - Usando los valores de su infraestructura existente
set RESOURCE_GROUP "rg_gpt_oai_dev"  # Grupo de recursos existente
set LOCATION "southcentralus"
set VNET_NAME "vnet_gpt_net_dev"
set SUBNET_NAME "snet_gpt_pe_dev"    # Subnet para VMs que ya existe
set VM_NAME "vm-gpt-aks-diag-3"
set VM_SIZE "Standard_B2s"
set ADMIN_USERNAME "admindiag"
set ADMIN_PASSWORD "Melco154.,Melco154.,"  # Cambiar a una contraseña más segura

# 1. Crear IP pública
echo "Creando IP pública..."
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name "$VM_NAME-ip" \
  --allocation-method Static

# 2. Crear NSG con reglas para SSH
echo "Creando grupo de seguridad de red..."
az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name "$VM_NAME-nsg"

az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name "$VM_NAME-nsg" \
  --name "AllowSSH" \
  --priority 1000 \
  --protocol Tcp \
  --destination-port-range 22 \
  --access Allow

# 3. Crear interfaz de red
echo "Creando interfaz de red..."
az network nic create \
  --resource-group $RESOURCE_GROUP \
  --name "$VM_NAME-nic" \
  --vnet-name $VNET_NAME \
  --subnet $SUBNET_NAME \
  --network-security-group "$VM_NAME-nsg" \
  --public-ip-address "$VM_NAME-ip"

# 4. Crear VM Linux
echo "Creando máquina virtual..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --nics "$VM_NAME-nic" \
  --image Ubuntu2204 \
  --size $VM_SIZE \
  --admin-username $ADMIN_USERNAME \
  --admin-password $ADMIN_PASSWORD \
  --authentication-type password

# 5. Instalar herramientas de diagnóstico
echo "Instalando herramientas de diagnóstico..."
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "apt-get update && apt-get install -y dnsutils net-tools iputils-ping curl tcpdump nmap netcat-openbsd apt-transport-https ca-certificates gnupg jq"

# 6. Instalar kubectl, Azure CLI y otras herramientas
echo "Instalando kubectl y Azure CLI..."
az vm run-command invoke \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --command-id RunShellScript \
  --scripts "curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/ && curl -sL https://aka.ms/InstallAzureCLIDeb | bash"

# 7. Obtener la IP pública
echo "Obteniendo IP pública..."
set PUBLIC_IP (az network public-ip show --resource-group $RESOURCE_GROUP --name "$VM_NAME-ip" --query ipAddress -o tsv)
echo "VM de diagnóstico creada con éxito!"
echo "IP pública: $PUBLIC_IP"
echo "Usuario: $ADMIN_USERNAME"
echo "Contraseña: $ADMIN_PASSWORD"
echo "Conéctate con: ssh $ADMIN_USERNAME@$PUBLIC_IP"

# 8. Verificar configuración de DNS privada
echo "La VM está en la misma VNET que tiene peering con la VNET del AKS."
echo "Asegúrate de que la zona DNS privada 'privatelink.southcentralus.azmk8s.io' esté vinculada a la VNET 'vnet_gpt_net_dev'."
