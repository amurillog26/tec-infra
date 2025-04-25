# Análisis de Secretos de Key Vault: kv-gpt-oai-dev-01

Este análisis categoriza los secretos según su tipo y cómo deberían gestionarse en diferentes ambientes.

## 1. Secretos que pueden generarse con Terraform

| Nombre del Secreto | Patrón Detectado | Propuesta para Terraform |
|-------------------|-----------------|--------------------------|
| btc-blob-conv-account-key | Clave/Token | module.resource.primary_key |
| btc-pass-encrypt | Clave/Token | module.resource.primary_key |
| btc-redis-password | Clave/Token | module.resource.primary_key |
| cognitivespeech-endpointkey | Clave/Token | module.resource.primary_key |
| conocimiento-blob-documento | Cadena de conexión | module.storage_account[*].primary_connection_string |
| cosmos-gpt-db-dev-primary-key | Clave/Token | module.resource.primary_key |
| cosmos-gpt-db-dev-secondary-key | Clave/Token | module.resource.primary_key |
| cosmos-Skill-Studio-url-key | Endpoint/URL | module.resource.endpoint |
| crgptoaidev01-admin-password | Clave/Token | module.resource.primary_key |
| encryption-key | Clave/Token | module.resource.primary_key |
| gpt-skrill-dev-bing-sus-key | Clave/Token | module.resource.primary_key |
| jwt-signing-key | Clave/Token | module.resource.primary_key |
| redis-gpt-cache-dev-primary-key | Clave/Token | module.resource.primary_key |
| redis-gpt-cache-dev-secondary-key | Clave/Token | module.resource.primary_key |
| skill-studio-imagenes | Cadena de conexión | module.storage_account[*].primary_connection_string |
| skrill-bs-dev-connection-string | Cadena de conexión | module.storage_account[*].primary_connection_string |
| skrill-gpt-folder-id | Clave/Token | module.resource.primary_key |
| stgptdev01-connection-string | Cadena de conexión | module.storage_account[*].primary_connection_string |
| stgptdev01-key | Clave/Token | module.resource.primary_key |
| whisper-endpointkey | Clave/Token | module.resource.primary_key |
| whisper-endpointname | Endpoint/URL | module.resource.endpoint |

## 2. Secretos que deben mantenerse como variables específicas por ambiente

| Nombre del Secreto | Valor Actual (parcial) | Categoría |
|-------------------|----------------------|-----------|
| aks-gpt-dev-001-kube-config | apiV***** | kubernetes |
| aks-gpt-dev-001-sp-client-id | ***** | kubernetes |
| API-CUSTOM-CHATS-dom-tok | http***** | uncategorized |
| API-CUSTOM-SKILL-dom-tok | http***** | uncategorized |
| API-GRAPH-ten-cli-sec | c65a***** | uncategorized |
| api-graph-url | http***** | uncategorized |
| app-gpt-api-dev-publishing-profile | <pub***** | web_app |
| btc-blob-conv-account-name | stgp***** | storage |
| btc-redis-address | redi***** | uncategorized |
| btc-redis-port | ***** | uncategorized |
| client-secret | pN18***** | azure |
| cognitivespeech-endpointregion | sout***** | uncategorized |
| cosmos-gpt-db-dev-connection-string | Acco***** | database |
| crgptoaidev01-admin-username | crgp***** | container_registry |
| gpt-skrill-dev-bing-endpoint | http***** | uncategorized |
| grl-tecgpt-mail-pass | T3cG***** | uncategorized |
| multimedia-reader-configuration | {   ***** | uncategorized |
| openai-dalle-endpoint | http***** | uncategorized |
| openai-dalle-token | eyJh***** | uncategorized |
| openai-gpt-dev-endpoint-skrill | http***** | uncategorized |
| openai-gpt-endpoint | http***** | uncategorized |
| redis-gpt-cache-dev-connection-string | redi***** | redis |
| skrill-container-dev-name | skri***** | uncategorized |
| skrill-gpt-drive-id | b!2E***** | uncategorized |
| skrill-pass | dgMW***** | uncategorized |
| skrill-url | http***** | uncategorized |
| skrill-user | GX5k***** | uncategorized |
| SSJWTtoken | bK1r***** | uncategorized |
| tecgpt-apiback-cosmos | {   ***** | uncategorized |
| tecgpt-apiback-deepseek-r1 | {   ***** | uncategorized |
| tecgpt-apiback-openai-4o | {   ***** | uncategorized |
| tecgpt-apiback-openai-o1 | {   ***** | uncategorized |
| tecgpt-apiback-openai-test | {   ***** | uncategorized |
| tecgpt-tblquerys | TECG***** | uncategorized |
| tenant-id | c65a***** | azure |
| test-pass | ***** | test |
| test-user | ***** | test |
| user-file-storage-url | http***** | uncategorized |
| whisper-endpointmodelname | ***** | uncategorized |

## 3. Propuesta para gestionar con Terraform

```terraform
# En env/dev.tfvars, env/pprd.tfvars, env/prod.tfvars
key_vault_secret_values = {
  # Valores específicos para cada ambiente
  "nombre-secreto-1" = "valor-dev-o-pprd-o-prod"
  "nombre-secreto-2" = "valor-dev-o-pprd-o-prod"
  # (Otros valores específicos del ambiente)
}

# En main.tf o en un módulo específico para secretos
# Para secretos generados por otros recursos:
resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "storage-connection-string"
  value        = module.storage_account.primary_connection_string
  key_vault_id = module.key_vault.id
}

# Para secretos con valores específicos por ambiente:
resource "azurerm_key_vault_secret" "environment_secrets" {
  for_each = var.key_vault_secret_values

  name         = each.key
  value        = each.value
  key_vault_id = module.key_vault.id
}
```
