#!/bin/bash

# Variables - Ajusta estos valores
KV_NAME="kv-gpt-oai-dev-01"
RG_NAME="rg_gpt_oai_dev"
OUTPUT_FILE="kv_secrets_values_analysis.md"

# Comprobación inicial de permisos
echo "Verificando permisos de acceso a secretos..."
if ! az keyvault secret list --vault-name $KV_NAME &>/dev/null; then
  echo "Error: No tienes permisos para acceder a los secretos del Key Vault $KV_NAME"
  exit 1
fi

# Creación del archivo de análisis
echo "# Análisis de Secretos de Key Vault: $KV_NAME" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Este análisis categoriza los secretos según su tipo y cómo deberían gestionarse en diferentes ambientes." >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "## 1. Secretos que pueden generarse con Terraform" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "| Nombre del Secreto | Patrón Detectado | Propuesta para Terraform |" >> $OUTPUT_FILE
echo "|-------------------|-----------------|--------------------------|" >> $OUTPUT_FILE

# Obtener todos los secretos
secrets=$(az keyvault secret list --vault-name $KV_NAME --query "[].name" -o tsv)

# Analizar cada secreto
for secret_name in $secrets; do
  # Obtener el valor del secreto
  secret_value=$(az keyvault secret show --vault-name $KV_NAME --name "$secret_name" --query "value" -o tsv)
  
  # Verificar patrones comunes para identificar si es un valor generado por Azure
  is_connection_string=false
  is_endpoint=false
  is_key=false
  terraform_proposal=""
  
  # Verificar si parece ser una cadena de conexión
  if [[ "$secret_value" == *"AccountName="* && "$secret_value" == *"AccountKey="* ]]; then
    is_connection_string=true
    terraform_proposal="module.storage_account[*].primary_connection_string"
  fi
  
  # Verificar si parece ser un endpoint
  if [[ "$secret_value" == https://* && "$secret_value" == *.azure.* ]]; then
    is_endpoint=true
    terraform_proposal="module.resource.endpoint"
  fi
  
  # Verificar si parece ser una clave o token
  if [[ ${#secret_value} -gt 30 && "$secret_value" =~ ^[A-Za-z0-9+/=]+$ ]]; then
    is_key=true
    terraform_proposal="module.resource.primary_key"
  fi
  
  # Agregar al análisis si se detectó un patrón
  if $is_connection_string || $is_endpoint || $is_key; then
    pattern=""
    [[ $is_connection_string == true ]] && pattern="Cadena de conexión"
    [[ $is_endpoint == true ]] && pattern="Endpoint/URL"
    [[ $is_key == true ]] && pattern="Clave/Token"
    
    echo "| $secret_name | $pattern | $terraform_proposal |" >> $OUTPUT_FILE
  fi
done

echo "" >> $OUTPUT_FILE
echo "## 2. Secretos que deben mantenerse como variables específicas por ambiente" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "| Nombre del Secreto | Valor Actual (parcial) | Categoría |" >> $OUTPUT_FILE
echo "|-------------------|----------------------|-----------|" >> $OUTPUT_FILE

# Listar secretos que parecen configuración manual
for secret_name in $secrets; do
  secret_value=$(az keyvault secret show --vault-name $KV_NAME --name "$secret_name" --query "value" -o tsv)
  category=$(az keyvault secret show --vault-name $KV_NAME --name "$secret_name" --query "tags.category" -o tsv)
  
  # Mostrar valor parcial (primeros 4 caracteres + *****)
  if [[ ${#secret_value} -gt 8 ]]; then
    masked_value="${secret_value:0:4}*****"
  else
    masked_value="*****"
  fi
  
  # No mostrar el valor parcial de los secretos ya categorizados como generados
  if ! grep -q "$secret_name" $OUTPUT_FILE; then
    echo "| $secret_name | $masked_value | ${category:-uncategorized} |" >> $OUTPUT_FILE
  fi
done

echo "" >> $OUTPUT_FILE
echo "## 3. Propuesta para gestionar con Terraform" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo '```terraform' >> $OUTPUT_FILE
echo '# En env/dev.tfvars, env/pprd.tfvars, env/prod.tfvars' >> $OUTPUT_FILE
echo 'key_vault_secret_values = {' >> $OUTPUT_FILE
echo '  # Valores específicos para cada ambiente' >> $OUTPUT_FILE
echo '  "nombre-secreto-1" = "valor-dev-o-pprd-o-prod"' >> $OUTPUT_FILE
echo '  "nombre-secreto-2" = "valor-dev-o-pprd-o-prod"' >> $OUTPUT_FILE
echo '  # (Otros valores específicos del ambiente)' >> $OUTPUT_FILE
echo '}' >> $OUTPUT_FILE
echo '' >> $OUTPUT_FILE
echo '# En main.tf o en un módulo específico para secretos' >> $OUTPUT_FILE
echo '# Para secretos generados por otros recursos:' >> $OUTPUT_FILE
echo 'resource "azurerm_key_vault_secret" "storage_connection_string" {' >> $OUTPUT_FILE
echo '  name         = "storage-connection-string"' >> $OUTPUT_FILE
echo '  value        = module.storage_account.primary_connection_string' >> $OUTPUT_FILE
echo '  key_vault_id = module.key_vault.id' >> $OUTPUT_FILE
echo '}' >> $OUTPUT_FILE
echo '' >> $OUTPUT_FILE
echo '# Para secretos con valores específicos por ambiente:' >> $OUTPUT_FILE
echo 'resource "azurerm_key_vault_secret" "environment_secrets" {' >> $OUTPUT_FILE
echo '  for_each = var.key_vault_secret_values' >> $OUTPUT_FILE
echo '' >> $OUTPUT_FILE
echo '  name         = each.key' >> $OUTPUT_FILE
echo '  value        = each.value' >> $OUTPUT_FILE
echo '  key_vault_id = module.key_vault.id' >> $OUTPUT_FILE
echo '}' >> $OUTPUT_FILE
echo '```' >> $OUTPUT_FILE

echo ""
echo "Análisis completado y guardado en $OUTPUT_FILE"
echo "ADVERTENCIA: Este archivo contiene información parcial sobre valores secretos."
echo "Asegúrate de mantenerlo confidencial y bórralo después de su uso."
