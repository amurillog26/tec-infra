from azure.data.tables import TableServiceClient, TableClient
import os
from datetime import datetime
from dotenv import load_dotenv
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

# Cargar variables de entorno
load_dotenv()

# Configuración
SOURCE_CONNECTION_STRING = os.getenv("SOURCE_CONNECTION_STRING")  # stgptdev01
DEST_CONNECTION_STRING = os.getenv("DEST_CONNECTION_STRING")      # stgptpprd

# Tablas a migrar
TABLES_TO_MIGRATE = [
    "TECGPT1MODELS"
]

def migrate_entities(source_table_name, batch_size=100):
    """Migra entidades de una tabla desde la cuenta origen a la destino"""
    print(f"\nIniciando migración de la tabla: {source_table_name}")
    
    # Conectar a tabla origen
    source_service = TableServiceClient.from_connection_string(SOURCE_CONNECTION_STRING)
    source_table = source_service.get_table_client(table_name=source_table_name)
    
    # Conectar a tabla destino
    dest_service = TableServiceClient.from_connection_string(DEST_CONNECTION_STRING)
    dest_table = dest_service.get_table_client(table_name=source_table_name)
    
    # Asegurar que la tabla destino existe
    try:
        dest_service.create_table_if_not_exists(table_name=source_table_name)
    except Exception as e:
        print(f"Nota: La tabla '{source_table_name}' ya existe en destino o hubo un error: {str(e)}")
    
    # Consultar todas las entidades de la tabla origen
    try:
        entities = list(source_table.list_entities())
        total_entities = len(entities)
        print(f"Total de entidades a migrar: {total_entities}")
        
        if total_entities == 0:
            print(f"La tabla {source_table_name} está vacía. Continuando con la siguiente.")
            return 0, 0
            
    except Exception as e:
        print(f"Error al leer entidades de la tabla {source_table_name}: {str(e)}")
        return 0, 0
    
    # Función para migrar un lote de entidades
    def migrate_batch(batch):
        success_count = 0
        fail_count = 0
        
        for entity in batch:
            try:
                # Crear nueva entidad en destino (upsert sobrescribirá si ya existe)
                dest_table.upsert_entity(entity)
                success_count += 1
            except Exception as e:
                print(f"Error al migrar entidad {entity.get('PartitionKey', 'Unknown')}/{entity.get('RowKey', 'Unknown')}: {str(e)}")
                fail_count += 1
                
        return success_count, fail_count
    
    # Dividir entidades en lotes para procesamiento paralelo
    batches = [entities[i:i + batch_size] for i in range(0, len(entities), batch_size)]
    
    # Migrar lotes en paralelo
    total_success = 0
    total_fail = 0
    
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = [executor.submit(migrate_batch, batch) for batch in batches]
        
        # Mostrar progreso
        with tqdm(total=total_entities) as pbar:
            for future in as_completed(futures):
                try:
                    success, fail = future.result()
                    total_success += success
                    total_fail += fail
                    pbar.update(success + fail)
                except Exception as e:
                    print(f"Error en lote: {str(e)}")
    
    print(f"Migración completa para {source_table_name}. Entidades migradas: {total_success}/{total_entities}, Fallidas: {total_fail}")
    return total_success, total_fail

def main():
    print(f"Iniciando migración de {len(TABLES_TO_MIGRATE)} tablas")
    start_time = datetime.now()
    
    total_migrated = 0
    total_failed = 0
    
    for table in TABLES_TO_MIGRATE:
        success, fail = migrate_entities(table)
        total_migrated += success
        total_failed += fail
    
    end_time = datetime.now()
    duration = end_time - start_time
    
    print(f"\n===== RESUMEN DE MIGRACIÓN =====")
    print(f"Total tablas: {len(TABLES_TO_MIGRATE)}")
    print(f"Total entidades migradas: {total_migrated}")
    print(f"Total entidades fallidas: {total_failed}")
    print(f"Tiempo total: {duration}")
    print("===============================")

if __name__ == "__main__":
    main()

