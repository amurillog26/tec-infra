from azure.cosmos import CosmosClient, PartitionKey
import json
import os
from datetime import datetime
from dotenv import load_dotenv
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

# Cargar variables de entorno
load_dotenv()

# Configuración de origen
SOURCE_URI = os.getenv("SOURCE_URI")  # Ej: https://cosmos-gpt-db-pprd-01.documents.azure.com:443/
SOURCE_KEY = os.getenv("SOURCE_KEY")

# Configuración de destino
DEST_URI = os.getenv("DEST_URI")  # Ej: https://cosmos-gpt-db-dev-01.documents.azure.com:443/
DEST_KEY = os.getenv("DEST_KEY")

# Definición de bases de datos a migrar y sus contenedores
# Formato: {"db_origen": "db_destino", "contenedores": [...]}
DATABASES_TO_MIGRATE = [
    {
        "source_db": "db_conversation_history",
        "dest_db": "db_conversation_history",
        "containers": {
            "configurations": "configurations",
            "conversations": "conversations",
            "model_configurations": "model_configurations"
        }
    },
    {
        "source_db": "Skill_Studio",
        "dest_db": "Skill_Studio",
        "containers": {
            "API_Users": "API_Users",
            "Asistente_Virtual": "Asistente_Virtual",
            "Audiencias_Custom": "Audiencias_Custom",
            "Chat_Model_Config_Data": "Chat_Model_Config_Data",
            "Configuracion": "Configuracion",
            "Containers_Tables_To_Clean": "Containers_Tables_To_Clean",
            "Contenidos": "Contenidos",
            "Conversaciones": "Conversaciones",
            "Conversaciones_Labs": "Conversaciones_Labs",
            "Semantica": "Semantica",
            "Skill": "Skill",
            "Tables_To_Update": "Tables_To_Update",
            "User": "User"
        }
    }
]

# Configuración de la partición por defecto si no se puede determinar
DEFAULT_PARTITION_KEY = "/id"

def get_container_info(db_client, container_name):
    """Obtiene información detallada de un contenedor"""
    try:
        container_client = db_client.get_container_client(container_name)
        properties = container_client.read()
        return {
            "exists": True,
            "properties": properties
        }
    except Exception as e:
        if "ResourceNotFound" in str(e):
            return {"exists": False}
        else:
            raise e

def create_destination_container(dest_db, source_container_info, dest_container_name):
    """Crea un contenedor en el destino basado en las propiedades del origen"""
    try:
        # Obtener la clave de partición del origen
        partition_key = source_container_info['properties'].get('partitionKey', {'paths': [DEFAULT_PARTITION_KEY]})
        
        # Crear el contenedor en destino
        container_props = dest_db.create_container(
            id=dest_container_name,
            partition_key=partition_key,
            default_ttl=source_container_info['properties'].get('defaultTtl', None)
        )
        
        print(f"Contenedor {dest_container_name} creado en destino")
        return container_props
    except Exception as e:
        print(f"Error al crear contenedor {dest_container_name}: {str(e)}")
        raise e

def migrate_container(source_db_name, dest_db_name, source_container_name, dest_container_name):
    print(f"Iniciando migración: {source_db_name}.{source_container_name} -> {dest_db_name}.{dest_container_name}")
    
    # Conectar a origen
    source_client = CosmosClient(SOURCE_URI, credential=SOURCE_KEY)
    source_db = source_client.get_database_client(source_db_name)
    
    # Verificar si el contenedor de origen existe
    source_container_info = get_container_info(source_db, source_container_name)
    if not source_container_info["exists"]:
        print(f"Error: Contenedor origen {source_db_name}.{source_container_name} no existe. Saltando.")
        return 0
    
    source_container = source_db.get_container_client(source_container_name)
    
    # Conectar a destino
    dest_client = CosmosClient(DEST_URI, credential=DEST_KEY)
    dest_db = dest_client.get_database_client(dest_db_name)
    
    # Verificar si el contenedor destino existe, si no, crearlo
    dest_container_info = get_container_info(dest_db, dest_container_name)
    if not dest_container_info["exists"]:
        print(f"Creando contenedor {dest_container_name} en destino...")
        create_destination_container(dest_db, source_container_info, dest_container_name)
    else:
        print(f"Contenedor {dest_container_name} ya existe en destino")
    
    dest_container = dest_db.get_container_client(dest_container_name)
    
    # Consultar todos los items del contenedor origen
    items = list(source_container.read_all_items())
    total_items = len(items)
    print(f"Total de documentos a migrar: {total_items}")
    
    if total_items == 0:
        print(f"No hay documentos para migrar en {source_container_name}")
        return 0
    
    # Función para migrar un lote de items
    def migrate_batch(batch):
        migrated = 0
        for item in batch:
            # Eliminar campos específicos de sistema
            system_fields = ['_etag', '_rid', '_self', '_ts', '_lsn', '_metadata']
            for field in system_fields:
                if field in item:
                    del item[field]
            
            # Intentar insertar el item en destino
            try:
                dest_container.upsert_item(body=item)
                migrated += 1
            except Exception as e:
                print(f"Error al migrar documento {item.get('id')}: {str(e)}")
        
        return migrated
    
    # Dividir items en lotes para procesamiento paralelo
    batch_size = 100
    batches = [items[i:i + batch_size] for i in range(0, len(items), batch_size)]
    
    # Migrar lotes en paralelo
    migrated_count = 0
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(migrate_batch, batch) for batch in batches]
        
        # Mostrar progreso
        with tqdm(total=total_items) as pbar:
            for future in as_completed(futures):
                try:
                    count = future.result()
                    migrated_count += count
                    pbar.update(count)
                except Exception as e:
                    print(f"Error en lote: {str(e)}")
    
    print(f"Migración completa: {source_container_name} -> {dest_container_name}")
    print(f"Documentos migrados: {migrated_count}/{total_items}")
    return migrated_count

def verify_database_exists(uri, key, db_name):
    """Verifica si la base de datos existe y la crea si no existe"""
    client = CosmosClient(uri, credential=key)
    try:
        # Intenta leer la base de datos para verificar si existe
        client.get_database_client(db_name).read()
        print(f"Base de datos {db_name} existe")
        return True
    except Exception as e:
        if "ResourceNotFound" in str(e):
            # La base de datos no existe, intentar crearla
            try:
                print(f"Base de datos {db_name} no existe. Creándola...")
                client.create_database(id=db_name)
                print(f"Base de datos {db_name} creada exitosamente")
                return True
            except Exception as create_err:
                print(f"Error al crear base de datos {db_name}: {str(create_err)}")
                return False
        else:
            # Otro error
            print(f"Error al verificar base de datos {db_name}: {str(e)}")
            return False

def main():
    print("=== Iniciando proceso de migración entre Cosmos DB ===")
    print(f"Origen: {SOURCE_URI}")
    print(f"Destino: {DEST_URI}")
    
    start_time = datetime.now()
    print(f"Iniciando migración: {start_time}")
    
    total_dbs = len(DATABASES_TO_MIGRATE)
    total_containers_count = sum(len(db["containers"]) for db in DATABASES_TO_MIGRATE)
    total_migrated = 0
    containers_processed = 0
    
    # Iterar por cada base de datos a migrar
    for db_config in DATABASES_TO_MIGRATE:
        source_db_name = db_config["source_db"]
        dest_db_name = db_config["dest_db"]
        containers = db_config["containers"]
        
        print(f"\n=== Procesando base de datos: {source_db_name} -> {dest_db_name} ===")
        
        # Verificar que las bases de datos existan
        if not verify_database_exists(SOURCE_URI, SOURCE_KEY, source_db_name):
            print(f"Error: Base de datos origen {source_db_name} no existe o no se puede acceder. Saltando.")
            continue
        
        if not verify_database_exists(DEST_URI, DEST_KEY, dest_db_name):
            print(f"Error: No se pudo crear/acceder a la base de datos destino {dest_db_name}. Saltando.")
            continue
        
        # Procesar cada contenedor
        for source_container, dest_container in containers.items():
            try:
                migrated = migrate_container(source_db_name, dest_db_name, source_container, dest_container)
                total_migrated += migrated
                containers_processed += 1
            except Exception as e:
                print(f"Error en migración de {source_db_name}.{source_container} -> {dest_db_name}.{dest_container}: {str(e)}")
    
    end_time = datetime.now()
    duration = end_time - start_time
    
    print("\n=== Resumen de migración completa ===")
    print(f"Total bases de datos procesadas: {total_dbs}")
    print(f"Total contenedores procesados: {containers_processed}/{total_containers_count}")
    print(f"Total documentos migrados: {total_migrated}")
    print(f"Tiempo total: {duration}")
    print("=====================================")

if __name__ == "__main__":
    main()

