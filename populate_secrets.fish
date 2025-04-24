#!/usr/bin/env fish
# populate_secrets.fish
# Script para poblar automáticamente los secretos del KeyVault desde los recursos de Azure
# Versión para Fish Shell

# Colores para mejor visualización
set GREEN '\033[0;32m'
set YELLOW '\033[1;33m'
set RED '\033[0;31m'
set BLUE '\033[0;34m'
set CYAN '\033[0;36m'
set NC '\033[0m' # No Color

# Configuración
set KV_NAME "kv-gpt-oai-dev-01"
set RG_NAME "rg_gpt_oai_dev"
set SUBSCRIPTION_ID "49b8793e-f25e-49ab-8fc2-1190c08f377e"  # Tomado de tus archivos

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
    az keyvault secret set --vault-name $KV_NAME --name "$name" --value "$value" --tags "category=$category" "environment=dev" "managed_by=script" >/dev/null
    
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

# === Cosmos DB ===
echo -e "\n$CYAN📁 Procesando secretos de Cosmos DB...$NC"
set COSMOS_ACCOUNT "cosmos-gpt-db-dev-01"

az cosmosdb show --name $COSMOS_ACCOUNT --resource-group $RG_NAME >/dev/null 2>&1
if test $status -eq 0
    echo -e "$BLUE➡️ Obteniendo claves y cadenas de conexión...$NC"
    set PRIMARY_KEY (az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG_NAME --query primaryMasterKey -o tsv)
    set SECONDARY_KEY (az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG_NAME --query secondaryMasterKey -o tsv)
    set CONNECTION_STRING (az cosmosdb keys list --name $COSMOS_ACCOUNT --resource-group $RG_NAME --type connection-strings --query 'connectionStrings[0].connectionString' -o tsv)

    set_secret "cosmos-gpt-db-dev-primary-key" "$PRIMARY_KEY" "database"
    set_secret "cosmos-gpt-db-dev-secondary-key" "$SECONDARY_KEY" "database"
    set_secret "cosmos-gpt-db-dev-connection-string" "$CONNECTION_STRING" "database"
    
    # También configuramos el secreto tecgpt-apiback-cosmos que se mencionó en la lista
    set_secret "tecgpt-apiback-cosmos" "$CONNECTION_STRING" "database"
else
    echo -e "$YELLOW⚠️ Cosmos DB $COSMOS_ACCOUNT no encontrado$NC"
end

# === Redis Cache ===
echo -e "\n$CYAN📁 Procesando secretos de Redis Cache...$NC"
set REDIS_NAME "redis-gpt-cache-dev-01"

az redis show --name $REDIS_NAME --resource-group $RG_NAME >/dev/null 2>&1
if test $status -eq 0
    echo -e "$BLUE➡️ Obteniendo claves y configuración...$NC"
    set PRIMARY_KEY (az redis list-keys --name $REDIS_NAME --resource-group $RG_NAME --query primaryKey -o tsv)
    set SECONDARY_KEY (az redis list-keys --name $REDIS_NAME --resource-group $RG_NAME --query secondaryKey -o tsv)
    set HOST (az redis show --name $REDIS_NAME --resource-group $RG_NAME --query hostName -o tsv)
    set PORT "6380"  # Puerto SSL estándar para Redis en Azure
    set SSL "True"
    set CONNECTION_STRING "$REDIS_NAME.redis.cache.windows.net:$PORT,password=$PRIMARY_KEY,ssl=$SSL,abortConnect=False"

    set_secret "redis-gpt-cache-dev-primary-key" "$PRIMARY_KEY" "redis"
    set_secret "redis-gpt-cache-dev-secondary-key" "$SECONDARY_KEY" "redis"
    set_secret "redis-gpt-cache-dev-connection-string" "$CONNECTION_STRING" "redis"
    
    # Configurar también los secretos específicos para BTC Redis
    set_secret "btc-redis-address" "$HOST" "redis"
    set_secret "btc-redis-port" "$PORT" "redis"
    set_secret "btc-redis-password" "$PRIMARY_KEY" "redis"
else
    echo -e "$YELLOW⚠️ Redis Cache $REDIS_NAME no encontrado$NC"
end

# === Storage Account ===
echo -e "\n$CYAN📁 Procesando secretos de Storage Account...$NC"
set STORAGE_ACCOUNT "stgptdev01"

az storage account show --name $STORAGE_ACCOUNT --resource-group $RG_NAME >/dev/null 2>&1
if test $status -eq 0
    echo -e "$BLUE➡️ Obteniendo claves de acceso...$NC"
    set STORAGE_KEY (az storage account keys list --account-name $STORAGE_ACCOUNT --resource-group $RG_NAME --query '[0].value' -o tsv)
    set CONN_STRING (az storage account show-connection-string --name $STORAGE_ACCOUNT --resource-group $RG_NAME --query connectionString -o tsv)

    set_secret "stgptdev01-key" "$STORAGE_KEY" "storage"
    set_secret "stgptdev01-connection-string" "$CONN_STRING" "storage"
    
    # Configurar secretos de blob storage para btc
    set_secret "btc-blob-conv-account-name" "$STORAGE_ACCOUNT" "storage"
    set_secret "btc-blob-conv-account-key" "$STORAGE_KEY" "storage"
    
    # Intentar configurar el secreto para Skrill blob storage (aunque probablemente necesite ajuste manual)
    set_secret "skrill-bs-dev-connection-string" "$CONN_STRING" "storage"
else
    echo -e "$YELLOW⚠️ Storage Account $STORAGE_ACCOUNT no encontrado$NC"
end

# === Container Registry ===
echo -e "\n$CYAN📁 Procesando secretos de Container Registry...$NC"
set ACR_NAME "crgptoaidev01"

az acr show --name $ACR_NAME --resource-group $RG_NAME >/dev/null 2>&1
if test $status -eq 0
    echo -e "$BLUE➡️ Obteniendo credenciales...$NC"
    set ACR_USERNAME (az acr credential show --name $ACR_NAME --query username -o tsv)
    set ACR_PASSWORD (az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)

    set_secret "crgptoaidev01-admin-username" "$ACR_USERNAME" "container_registry"
    set_secret "crgptoaidev01-admin-password" "$ACR_PASSWORD" "container_registry"
else
    echo -e "$YELLOW⚠️ Container Registry $ACR_NAME no encontrado$NC"
end

# === AKS ===
echo -e "\n$CYAN📁 Procesando secretos de AKS...$NC"
set AKS_NAME "aks-gpt-dev-001"

az aks show --name $AKS_NAME --resource-group $RG_NAME >/dev/null 2>&1
if test $status -eq 0
    echo -e "$BLUE➡️ Obteniendo configuración de Kubernetes...$NC"
    set KUBE_CONFIG (az aks get-credentials --name $AKS_NAME --resource-group $RG_NAME --file - -o json)
    set SP_ID (az aks show --name $AKS_NAME --resource-group $RG_NAME --query servicePrincipalProfile.clientId -o tsv)
    
    set_secret "aks-gpt-dev-001-kube-config" "$KUBE_CONFIG" "kubernetes"
    set_secret "aks-gpt-dev-001-sp-client-id" "$SP_ID" "kubernetes"
    
    # Nota: No podemos obtener el SP_SECRET automáticamente, debe ser proporcionado manualmente
    echo -e "$YELLOW⚠️ El secreto del service principal de AKS debe ser configurado manualmente$NC"
else
    echo -e "$YELLOW⚠️ AKS $AKS_NAME no encontrado$NC"
end

# === Web App ===
echo -e "\n$CYAN📁 Procesando secretos de Web App...$NC"
set WEBAPP_NAME "app-gpt-api-dev"

az webapp show --name $WEBAPP_NAME --resource-group $RG_NAME >/dev/null 2>&1
if test $status -eq 0
    echo -e "$BLUE➡️ Obteniendo perfil de publicación...$NC"
    # Obtener token de despliegue (requiere roles avanzados)
    set PUBLISH_PROFILE (az webapp deployment list-publishing-profiles --name $WEBAPP_NAME --resource-group $RG_NAME --xml)
    
    if test -n "$PUBLISH_PROFILE"
        set_secret "app-gpt-api-dev-publishing-profile" "$PUBLISH_PROFILE" "web_app"
    else
        echo -e "$YELLOW⚠️ No se pudo obtener el perfil de publicación para $WEBAPP_NAME$NC"
    end
else
    echo -e "$YELLOW⚠️ Web App $WEBAPP_NAME no encontrada$NC"
end

# === VM (No podemos obtener credenciales existentes) ===
echo -e "\n$CYAN📁 Secretos de VM...$NC"
echo -e "$YELLOW⚠️ Las credenciales de la máquina virtual deben ser configuradas manualmente$NC"

# === Secretos de seguridad personalizados ===
echo -e "\n$CYAN📁 Generando secretos de seguridad personalizados...$NC"
set JWT_KEY (openssl rand -base64 32)
set ENCRYPTION_KEY (openssl rand -base64 32)

set_secret "jwt-signing-key" "$JWT_KEY" "security"
set_secret "SSJWTtoken" "$JWT_KEY" "security"  # También configuramos este secreto que parece ser para el mismo propósito
set_secret "encryption-key" "$ENCRYPTION_KEY" "security"
set_secret "btc-pass-encrypt" "$ENCRYPTION_KEY" "security"  # También configuramos este secreto que parece ser para el mismo propósito

# === Crear el secreto para multimedia-reader-configuration ===
set MULTIMEDIA_CONFIG '{
  "providers": {
    "local": {
      "enabled": true,
      "basePath": "/data/media"
    },
    "azure": {
      "enabled": true,
      "connectionString": "'$CONN_STRING'",
      "containerName": "media"
    }
  },
  "cache": {
    "enabled": true,
    "ttl": 3600
  }
}'
set_secret "multimedia-reader-configuration" "$MULTIMEDIA_CONFIG" "config"

# === Secretos que requieren configuración manual ===
echo -e "\n$CYAN📁 Secretos que requieren configuración manual...$NC"
echo -e "$YELLOW Los siguientes secretos no pueden ser poblados automáticamente y requieren configuración manual:$NC"

echo -e "$YELLOW
1. Microsoft Graph API:
   - API-GRAPH-ten-cli-sec
   - api-graph-url

2. Skrill:
   - skrill-user
   - skrill-pass
   - skrill-url
   - skrill-gpt-folder-id
   - skrill-gpt-drive-id
   - skrill-container-dev-name

3. Test:
   - test-user
   - test-pass

4. API Personalizadas:
   - API-CUSTOM-SKILL-dom-tok
   - API-CUSTOM-CHATS-dom-tok

5. Skills y Conocimiento:
   - skill-studio-imagenes
   - conocimiento-blob-documento
   - cosmos-Skill-Studio-url-key
   - tecgpt-tblquerys
$NC"

# Opción para configurar manualmente algunos secretos críticos
echo -e "\n$CYAN📝 ¿Deseas configurar manualmente algunos secretos críticos ahora? (s/n)$NC"
read -l configure_now

if test "$configure_now" = "s" -o "$configure_now" = "S"
    echo -e "$BLUE➡️ Configurando secretos críticos manualmente...$NC"
    
    # Skrill
    echo -e "\n$CYAN Configurando secretos de Skrill:$NC"
    read -P "Usuario de Skrill (skrill-user): " skrill_user
    
    # Fish no tiene un equivalente directo para read -sp, usamos stty para ocultar la entrada
    echo -n "Contraseña de Skrill (skrill-pass): "
    stty -echo
    read -l skrill_pass
    stty echo
    echo
    
    read -P "URL de Skrill (skrill-url): " skrill_url
    
    if test -n "$skrill_user"
        set_secret "skrill-user" "$skrill_user" "skrill"
    end
    if test -n "$skrill_pass"
        set_secret "skrill-pass" "$skrill_pass" "skrill"
    end
    if test -n "$skrill_url"
        set_secret "skrill-url" "$skrill_url" "skrill"
    end
    
    # Test
    echo -e "\n$CYAN Configurando secretos de Test:$NC"
    read -P "Usuario de prueba (test-user): " test_user
    
    echo -n "Contraseña de prueba (test-pass): "
    stty -echo
    read -l test_pass
    stty echo
    echo
    
    if test -n "$test_user"
        set_secret "test-user" "$test_user" "test"
    end
    if test -n "$test_pass"
        set_secret "test-pass" "$test_pass" "test"
    end
    
    # Microsoft Graph
    echo -e "\n$CYAN Configurando secretos de Microsoft Graph:$NC"
    read -P "Valores separados por coma para API-GRAPH-ten-cli-sec: " graph_cli_sec
    read -P "URL de API Graph (api-graph-url): " graph_url
    
    if test -n "$graph_cli_sec"
        set_secret "API-GRAPH-ten-cli-sec" "$graph_cli_sec" "graph"
    end
    if test -n "$graph_url"
        set_secret "api-graph-url" "$graph_url" "graph"
    end
end

echo -e "\n$GREEN✅ Proceso de población de secretos completado$NC"
echo -e "$BLUE ℹ️ Para los secretos restantes, utiliza el Portal de Azure o la CLI de Azure para configurarlos manualmente$NC"
echo -e "$BLUE ℹ️ Ejemplo: az keyvault secret set --vault-name $KV_NAME --name \"NOMBRE_SECRETO\" --value \"VALOR_SECRETO\" --tags \"category=categoria\"$NC"
