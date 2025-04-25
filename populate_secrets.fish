#!/usr/bin/env fish
# populate_secrets_improved.fish
# Script mejorado para poblar automáticamente los secretos del KeyVault desde los recursos de Azure y los outputs de Terraform

# Colores para mejor visualización
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set RED '\033[0;31m'
set BLUE '\033[0;34m'
set CYAN '\033[0;36m'
set NC '\033[0m' # No Color

# Configuración
set ENVIRONMENT "dev"  # Este valor podría pasarse como argumento
set KV_NAME "kv-gpt-oai-$ENVIRONMENT-01"
set RG_NAME "rg_gpt_oai_$ENVIRONMENT"
set SUBSCRIPTION_ID "49b8793e-f25e-49ab-8fc2-1190c08f377e"

# Asegurarse de que estamos en la suscripción correcta
echo -e "$BLUE➡️ Configurando suscripción Azure...$NC"
az account set --subscription $SUBSCRIPTION_ID
if test $status -ne 0
    echo -e "$RED❌ Error al establecer la suscripción. Verifica que estés autenticado en Azure CLI y que el ID de suscripción sea correcto.$NC"
    exit 1
end

echo -e "$GREEN✅ Iniciando población de secretos para el KeyVault: $CYAN$KV_NAME$NC"

# Function para establecer secretos con manejo de errores
function set_secret
    set name $argv[1]
    set value $argv[2]
    set category $argv[3]

    if test -z "$value"
        echo -e "$YELLOW⚠️ El valor para $name está vacío. No se actualizará.$NC"
        return
    end

    echo -e "$BLUE🔑 Configurando secreto: $CYAN$name$BLUE (categoría: $CYAN$category$BLUE)$NC"
    az keyvault secret set --vault-name $KV_NAME --name "$name" --value "$value" --tags "category=$category" "environment=$ENVIRONMENT" "managed_by=script" >/dev/null
    
    if test $status -eq 0
        echo -e "$GREEN  ✅ Secreto configurado correctamente$NC"
    else
        echo -e "$RED  ❌ Error al configurar el secreto. Verifica los permisos y la conectividad.$NC"
    end
end

# Comprobar si el KeyVault existe
echo -e "$BLUE➡️ Verificando existencia del KeyVault...$NC"
az keyvault show --name $KV_NAME --resource-group $RG_NAME >/dev/null 2>&1
if test $status -ne 0
    echo -e "$RED❌ El KeyVault $KV_NAME no existe en el grupo de recursos $RG_NAME$NC"
    exit 1
end
echo -e "$GREEN✅ KeyVault encontrado$NC"

# Intentar primero usar terraform output
echo -e "$BLUE➡️ Buscando outputs de Terraform...$NC"
set TERRAFORM_OUTPUT_FILE "terraform_outputs.json"

# Verificar si estamos en un directorio de Terraform y hay un state
if test -f "./terraform.tfstate"
    echo -e "$BLUE➡️ Encontrado estado local de Terraform, extrayendo outputs...$NC"
    terraform output -json > $TERRAFORM_OUTPUT_FILE
    if test $status -eq 0
        echo -e "$GREEN✅ Outputs de Terraform extraídos correctamente$NC"
    else
        echo -e "$YELLOW⚠️ No se pudieron extraer outputs de Terraform, usando método alternativo$NC"
        rm -f $TERRAFORM_OUTPUT_FILE
    end
else
    echo -e "$YELLOW⚠️ No se encontró estado local de Terraform, usando método alternativo$NC"
end

# === Cosmos DB ===
echo -e "\n$CYAN📁 Procesando secretos de Cosmos DB...$NC"
set COSMOS_ACCOUNT "cosmos-gpt-db-$ENVIRONMENT-01"

# Intentar obtener de Terraform primero
if test -f $TERRAFORM_OUTPUT_FILE
    set PRIMARY_KEY (jq -r '.cosmos_db_outputs.value.primary_key // empty' $TERRAFORM_OUTPUT_FILE)
    set ENDPOINT (jq -r '.cosmos_db_outputs.value.endpoint // empty' $TERRAFORM_OUTPUT_FILE)
    
    if test -n "$PRIMARY_KEY" -a -n "$ENDPOINT"
        set CONNECTION_STRING "AccountEndpoint=$ENDPOINT;AccountKey=$PRIMARY_KEY;"
        set_secret "$COSMOS_ACCOUNT-primary-key" "$PRIMARY_KEY" "database"
        set_secret "$COSMOS_ACCOUNT-secondary-key" "$PRIMARY_KEY" "database" # Mismo valor para dev
        set_secret "$COSMOS_ACCOUNT-connection-string" "$CONNECTION_STRING" "database"
        set_secret "tecgpt-apiback-cosmos" "$CONNECTION_STRING" "database"
    else
        echo -e "$YELLOW⚠️ No se encontraron outputs de Terraform para Cosmos DB, consultando Azure CLI$NC"
    end
end

# Si no se pudo obtener de Terraform, usar Azure CLI
if not set -q PRIMARY_KEY; or test -z "$PRIMARY_KEY"
    az cosmosdb show --name $COSMOS_ACCOUNT --resource-group $RG_NAME >/dev/null 2>&1
    if test $status -eq 0
        echo -e "$BLUE➡️ Obteniendo claves y cadenas de conexión...$NC"
        set PRIMARY_KEY (az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG_NAME --query primaryMasterKey -o tsv)
        set SECONDARY_KEY (az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG_NAME --query secondaryMasterKey -o tsv)
        set ENDPOINT (az cosmosdb show --name $COSMOS_ACCOUNT --resource-group $RG_NAME --query documentEndpoint -o tsv)
        set CONNECTION_STRING "AccountEndpoint=$ENDPOINT;AccountKey=$PRIMARY_KEY;"

        set_secret "$COSMOS_ACCOUNT-primary-key" "$PRIMARY_KEY" "database"
        set_secret "$COSMOS_ACCOUNT-secondary-key" "$SECONDARY_KEY" "database"
        set_secret "$COSMOS_ACCOUNT-connection-string" "$CONNECTION_STRING" "database"
        set_secret "tecgpt-apiback-cosmos" "$CONNECTION_STRING" "database"
    else
        echo -e "$YELLOW⚠️ Cosmos DB $COSMOS_ACCOUNT no encontrado$NC"
    end
end

# === Redis Cache ===
echo -e "\n$CYAN📁 Procesando secretos de Redis Cache...$NC"
set REDIS_NAME "redis-gpt-cache-$ENVIRONMENT-01"

# Intentar obtener de Terraform primero
if test -f $TERRAFORM_OUTPUT_FILE
    set REDIS_KEY (jq -r '.redis_outputs.value.primary_key // empty' $TERRAFORM_OUTPUT_FILE)
    set REDIS_HOST (jq -r '.redis_outputs.value.hostname // empty' $TERRAFORM_OUTPUT_FILE)
    
    if test -n "$REDIS_KEY" -a -n "$REDIS_HOST"
        set PORT "6380"  # Puerto SSL estándar para Redis en Azure
        set SSL "True"
        set CONNECTION_STRING "$REDIS_HOST:$PORT,password=$REDIS_KEY,ssl=$SSL,abortConnect=False"

        set_secret "redis-gpt-cache-$ENVIRONMENT-primary-key" "$REDIS_KEY" "redis"
        set_secret "redis-gpt-cache-$ENVIRONMENT-secondary-key" "$REDIS_KEY" "redis" # Mismo valor para dev
        set_secret "redis-gpt-cache-$ENVIRONMENT-connection-string" "$CONNECTION_STRING" "redis"
        set_secret "btc-redis-address" "$REDIS_HOST" "redis"
        set_secret "btc-redis-port" "$PORT" "redis"
        set_secret "btc-redis-password" "$REDIS_KEY" "redis"
    else
        echo -e "$YELLOW⚠️ No se encontraron outputs de Terraform para Redis, consultando Azure CLI$NC"
    end
end

# Si no se pudo obtener de Terraform, usar Azure CLI
if not set -q REDIS_KEY; or test -z "$REDIS_KEY"
    az redis show --name $REDIS_NAME --resource-group $RG_NAME >/dev/null 2>&1
    if test $status -eq 0
        echo -e "$BLUE➡️ Obteniendo claves y configuración...$NC"
        set PRIMARY_KEY (az redis list-keys --name $REDIS_NAME --resource-group $RG_NAME --query primaryKey -o tsv)
        set SECONDARY_KEY (az redis list-keys --name $REDIS_NAME --resource-group $RG_NAME --query secondaryKey -o tsv)
        set HOST (az redis show --name $REDIS_NAME --resource-group $RG_NAME --query hostName -o tsv)
        set PORT "6380"  # Puerto SSL estándar para Redis en Azure
        set SSL "True"
        set CONNECTION_STRING "$HOST:$PORT,password=$PRIMARY_KEY,ssl=$SSL,abortConnect=False"

        set_secret "redis-gpt-cache-$ENVIRONMENT-primary-key" "$PRIMARY_KEY" "redis"
        set_secret "redis-gpt-cache-$ENVIRONMENT-secondary-key" "$SECONDARY_KEY" "redis"
        set_secret "redis-gpt-cache-$ENVIRONMENT-connection-string" "$CONNECTION_STRING" "redis"
        set_secret "btc-redis-address" "$HOST" "redis"
        set_secret "btc-redis-port" "$PORT" "redis"
        set_secret "btc-redis-password" "$PRIMARY_KEY" "redis"
    else
        echo -e "$YELLOW⚠️ Redis Cache $REDIS_NAME no encontrado$NC"
    end
end

# === Storage Account ===
echo -e "\n$CYAN📁 Procesando secretos de Storage Account...$NC"
set STORAGE_ACCOUNT "stgpt${ENVIRONMENT}01"

# Intentar obtener de Terraform primero
if test -f $TERRAFORM_OUTPUT_FILE
    set JQ_PATH ".storage_outputs.value.${STORAGE_ACCOUNT}.primary_access_key // empty"
    set STORAGE_KEY (jq -r $JQ_PATH $TERRAFORM_OUTPUT_FILE)
    
    set JQ_PATH ".storage_outputs.value.${STORAGE_ACCOUNT}.connection_string // empty"
    set CONN_STRING (jq -r $JQ_PATH $TERRAFORM_OUTPUT_FILE)
    
    if test -n "$STORAGE_KEY"
        set_secret "${STORAGE_ACCOUNT}-key" "$STORAGE_KEY" "storage"
        set_secret "btc-blob-conv-account-key" "$STORAGE_KEY" "storage"
        set_secret "btc-blob-conv-account-name" "$STORAGE_ACCOUNT" "storage"
        
        if test -n "$CONN_STRING"
            set_secret "${STORAGE_ACCOUNT}-connection-string" "$CONN_STRING" "storage"
            set_secret "skrill-bs-${ENVIRONMENT}-connection-string" "$CONN_STRING" "storage"
        end
    else
        echo -e "$YELLOW⚠️ No se encontraron outputs de Terraform para Storage, consultando Azure CLI$NC"
    end
end

# Si no se pudo obtener de Terraform, usar Azure CLI
if not set -q STORAGE_KEY; or test -z "$STORAGE_KEY"
    az storage account show --name $STORAGE_ACCOUNT --resource-group $RG_NAME >/dev/null 2>&1
    if test $status -eq 0
        echo -e "$BLUE➡️ Obteniendo claves de acceso...$NC"
        set STORAGE_KEY (az storage account keys list --account-name $STORAGE_ACCOUNT --resource-group $RG_NAME --query '[0].value' -o tsv)
        set CONN_STRING (az storage account show-connection-string --name $STORAGE_ACCOUNT --resource-group $RG_NAME --query connectionString -o tsv)

        set_secret "${STORAGE_ACCOUNT}-key" "$STORAGE_KEY" "storage"
        set_secret "${STORAGE_ACCOUNT}-connection-string" "$CONN_STRING" "storage"
        set_secret "btc-blob-conv-account-name" "$STORAGE_ACCOUNT" "storage"
        set_secret "btc-blob-conv-account-key" "$STORAGE_KEY" "storage"
        set_secret "skrill-bs-${ENVIRONMENT}-connection-string" "$CONN_STRING" "storage"
    else
        echo -e "$YELLOW⚠️ Storage Account $STORAGE_ACCOUNT no encontrado$NC"
    end
end

# === Container Registry ===
echo -e "\n$CYAN📁 Procesando secretos de Container Registry...$NC"
set ACR_NAME "crgptoai${ENVIRONMENT}01"

# Intentar obtener de Terraform primero
if test -f $TERRAFORM_OUTPUT_FILE
    set ACR_USERNAME (jq -r '.acr_outputs.value.admin_username // empty' $TERRAFORM_OUTPUT_FILE)
    set ACR_PASSWORD (jq -r '.acr_outputs.value.admin_password // empty' $TERRAFORM_OUTPUT_FILE)
    
    if test -n "$ACR_USERNAME" -a -n "$ACR_PASSWORD"
        set_secret "${ACR_NAME}-admin-username" "$ACR_USERNAME" "container_registry"
        set_secret "${ACR_NAME}-admin-password" "$ACR_PASSWORD" "container_registry"
    else
        echo -e "$YELLOW⚠️ No se encontraron outputs de Terraform para ACR, consultando Azure CLI$NC"
    end
end

# Si no se pudo obtener de Terraform, usar Azure CLI
if not set -q ACR_PASSWORD; or test -z "$ACR_PASSWORD"
    az acr show --name $ACR_NAME --resource-group $RG_NAME >/dev/null 2>&1
    if test $status -eq 0
        echo -e "$BLUE➡️ Obteniendo credenciales...$NC"
        set ACR_USERNAME (az acr credential show --name $ACR_NAME --query username -o tsv)
        set ACR_PASSWORD (az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

        set_secret "${ACR_NAME}-admin-username" "$ACR_USERNAME" "container_registry"
        set_secret "${ACR_NAME}-admin-password" "$ACR_PASSWORD" "container_registry"
    else
        echo -e "$YELLOW⚠️ Container Registry $ACR_NAME no encontrado$NC"
    end
end

# === AKS ===
echo -e "\n$CYAN📁 Procesando secretos de AKS...$NC"
set AKS_NAME "aks-gpt-dev-001"

# Intentar obtener de Terraform primero
if test -f $TERRAFORM_OUTPUT_FILE
    set KUBE_CONFIG (jq -r '.aks_outputs.value.kube_config // empty' $TERRAFORM_OUTPUT_FILE)
    set SP_ID (jq -r '.aks_outputs.value.principal_id // empty' $TERRAFORM_OUTPUT_FILE)
    
    if test -n "$KUBE_CONFIG"
        set_secret "aks-gpt-dev-001-kube-config" "$KUBE_CONFIG" "kubernetes"
        if test -n "$SP_ID"
            set_secret "aks-gpt-dev-001-sp-client-id" "$SP_ID" "kubernetes"
        end
    else
        echo -e "$YELLOW⚠️ No se encontraron outputs de Terraform para AKS, consultando Azure CLI$NC"
    end
end

# Si no se pudo obtener de Terraform, usar Azure CLI
if not set -q KUBE_CONFIG; or test -z "$KUBE_CONFIG"
    az aks show --name $AKS_NAME --resource-group $RG_NAME >/dev/null 2>&1
    if test $status -eq 0
        echo -e "$BLUE➡️ Obteniendo configuración de Kubernetes...$NC"
        set KUBE_CONFIG (az aks get-credentials --name $AKS_NAME --resource-group $RG_NAME --file - -o json)
        set SP_ID (az aks show --name $AKS_NAME --resource-group $RG_NAME --query identity.principalId -o tsv)
        
        set_secret "aks-gpt-dev-001-kube-config" "$KUBE_CONFIG" "kubernetes"
        set_secret "aks-gpt-dev-001-sp-client-id" "$SP_ID" "kubernetes"
    else
        echo -e "$YELLOW⚠️ AKS $AKS_NAME no encontrado$NC"
    end
end

# === Secretos de seguridad personalizados ===
echo -e "\n$CYAN📁 Generando secretos de seguridad personalizados...$NC"
set JWT_KEY (openssl rand -base64 32)
set ENCRYPTION_KEY (openssl rand -base64 32)

set_secret "jwt-signing-key" "$JWT_KEY" "security"
set_secret "SSJWTtoken" "$JWT_KEY" "security"  # También configuramos este secreto que parece ser para el mismo propósito
set_secret "encryption-key" "$ENCRYPTION_KEY" "security"
set_secret "btc-pass-encrypt" "$ENCRYPTION_KEY" "security"  # También configuramos este secreto que parece ser para el mismo propósito

# Limpiar archivo temporal
if test -f $TERRAFORM_OUTPUT_FILE
    rm -f $TERRAFORM_OUTPUT_FILE
end

echo -e "\n$GREEN✅ Proceso de población de secretos completado$NC"
echo -e "$BLUE ℹ️ Para los secretos restantes, utiliza el Portal de Azure o la CLI de Azure para configurarlos manualmente$NC"
