from azure.storage.blob import BlobServiceClient, ContainerClient
import os
from datetime import datetime
from dotenv import load_dotenv
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm

# Cargar variables de entorno
load_dotenv()

# Configuración de origen (DEV)
SOURCE_CONNECTION_STRING = os.getenv("SOURCE_CONNECTION_STRING")  # Cadena de conexión para stgptdev01

# Configuración de destino (PPRD)
DEST_CONNECTION_STRING = os.getenv("DEST_CONNECTION_STRING")  # Cadena de conexión para stgptpprd

# Lista de contenedores a migrar
CONTAINERS_TO_MIGRATE = [
    "skillstudio",
    "skillstudioavatar",
    "skillstudioicons"
]

def migrate_container(container_name):
    """Migra todos los blobs de un contenedor desde la cuenta origen a la destino"""
    print(f"Iniciando migración del contenedor: {container_name}")
    
    # Conectar a origen
    source_blob_service = BlobServiceClient.from_connection_string(SOURCE_CONNECTION_STRING)
    source_container = source_blob_service.get_container_client(container_name)
    
    # Conectar a destino
    dest_blob_service = BlobServiceClient.from_connection_string(DEST_CONNECTION_STRING)
    
    # Crear contenedor en destino si no existe
    dest_container = dest_blob_service.get_container_client(container_name)
    if not dest_container.exists():
        print(f"Creando contenedor {container_name} en destino...")
        dest_container.create_container()
    
    # Listar todos los blobs en el contenedor origen
    blob_list = list(source_container.list_blobs())
    total_blobs = len(blob_list)
    print(f"Total de blobs a migrar: {total_blobs}")
    
    # Función para migrar un blob
    def migrate_blob(blob):
        try:
            # Obtener el blob desde origen
            source_blob = source_container.get_blob_client(blob.name)
            source_data = source_blob.download_blob()
            
            # Verificar si el blob ya existe en destino
            dest_blob = dest_container.get_blob_client(blob.name)
            
            # Crear el blob en destino
            dest_blob.upload_blob(source_data.readall(), overwrite=True, metadata=source_blob.get_blob_properties().metadata)
            return True
        except Exception as e:
            print(f"Error al migrar blob {blob.name}: {str(e)}")
            return False
    
    # Migrar blobs en paralelo
    migrated_count = 0
    failed_count = 0
    
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(migrate_blob, blob) for blob in blob_list]
        
        # Mostrar progreso
        with tqdm(total=total_blobs) as pbar:
            for future in as_completed(futures):
                try:
                    result = future.result()
                    if result:
                        migrated_count += 1
                    else:
                        failed_count += 1
                except Exception as e:
                    print(f"Error: {str(e)}")
                    failed_count += 1
                finally:
                    pbar.update(1)
    
    print(f"Migración completa para {container_name}. Blobs migrados: {migrated_count}/{total_blobs}, Fallidos: {failed_count}")
    return migrated_count, failed_count

def main():
    print(f"Iniciando migración de {len(CONTAINERS_TO_MIGRATE)} contenedores")
    start_time = datetime.now()
    
    total_migrated = 0
    total_failed = 0
    
    for container in CONTAINERS_TO_MIGRATE:
        migrated, failed = migrate_container(container)
        total_migrated += migrated
        total_failed += failed
    
    end_time = datetime.now()
    duration = end_time - start_time
    
    print(f"\nResumen de migración:")
    print(f"Total contenedores: {len(CONTAINERS_TO_MIGRATE)}")
    print(f"Total blobs migrados: {total_migrated}")
    print(f"Total blobs fallidos: {total_failed}")
    print(f"Tiempo total: {duration}")

if __name__ == "__main__":
    main()

