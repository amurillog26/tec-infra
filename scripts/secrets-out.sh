#!/bin/bash

# Nombre del archivo de salida
output_file="key_vault_secrets.txt"

# Crear o sobrescribir el archivo de salida
echo "LISTADO DE SECRETS DE AZURE KEY VAULT" > $output_file
echo "======================================" >> $output_file
echo "" >> $output_file
echo "Fecha de generación: $(date)" >> $output_file
echo "" >> $output_file

# Array con los nombres de los Key Vaults
key_vaults=("kv-gpt-oai-dev-01" "kv-gpt-oai-pprd")

# Procesar cada Key Vault
for kv in "${key_vaults[@]}"; do
    echo "===== Key Vault: $kv =====" >> $output_file
    echo "" >> $output_file
    
    # Obtener lista de nombres de secretos
    echo "Obteniendo lista de secretos para $kv..."
    secret_names=$(az keyvault secret list --vault-name "$kv" --query "[].name" -o tsv)
    
    # Verificar si se obtuvieron secretos
    if [ -z "$secret_names" ]; then
        echo "  No se encontraron secretos en $kv o no tienes permisos suficientes." >> $output_file
        continue
    fi
    
    # Ordenar los nombres de los secretos alfabéticamente
    sorted_secret_names=$(echo "$secret_names" | sort)
    
    # Procesar cada secreto
    for secret_name in $sorted_secret_names; do
        echo "Secret: $secret_name" >> $output_file
        # Obtener el valor del secreto
        secret_value=$(az keyvault secret show --vault-name "$kv" --name "$secret_name" --query "value" -o tsv)
        echo "Valor: $secret_value" >> $output_file
        echo "--------------------------" >> $output_file
    done
    
    echo "" >> $output_file # Línea vacía para mejor legibilidad entre Key Vaults
done

echo "Proceso completado. Los secretos se han guardado en el archivo '$output_file'"

