#!/bin/bash
# run_secret_population.sh
# Script para ejecutar la población de secretos en diferentes ambientes

# Obtener el ambiente desde los argumentos o usar "dev" por defecto
ENVIRONMENT=${1:-dev}

echo "Ejecutando población de secretos para el ambiente: $ENVIRONMENT"

# Validar ambiente
if [[ ! "$ENVIRONMENT" =~ ^(dev|pprd|prod)$ ]]; then
  echo "Ambiente no válido. Debe ser uno de: dev, pprd, prod"
  exit 1
fi

# Ejecutar el script fish con el ambiente adecuado
fish -c "set -x ENVIRONMENT $ENVIRONMENT; ./populate_secrets_improved.fish"

echo "Proceso completado para ambiente $ENVIRONMENT"
