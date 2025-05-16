from azure.data.tables import TableServiceClient
import os
from datetime import datetime
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configuración de destino (PPRD)
DEST_CONNECTION_STRING = os.getenv("DEST_CONNECTION_STRING")  # Cadena de conexión para stgptpprd

# Lista de tablas a crear
TABLES_TO_CREATE = [
    "CarpetaCompartida",
    "EjecucionCodigo",
    "EjecucionLogica",
    "FormularioCodigo",
    "frmCampo",
    "frmForma",
    "LogsChatbot",
    "SkillStudioResultadoURLQR",
    "tbfImage",
    "tbfLogsRedis",
    "tbfMetadata",
    "tbfOpenAI",
    "tbfQuestions",
    "tbfRedis",
    "tbfService",
    "tokenLTI",
    "VerificadorCodigo"
]

def create_tables():
    """Crea las tablas en la cuenta de destino si no existen"""
    print(f"Iniciando creación de tablas")
    start_time = datetime.now()
    
    # Conectar a destino
    table_service = TableServiceClient.from_connection_string(conn_str=DEST_CONNECTION_STRING)
    
    # Obtener lista de tablas existentes
    existing_tables = [table.name for table in table_service.list_tables()]
    print(f"Tablas existentes: {existing_tables}")
    
    created_count = 0
    already_exists_count = 0
    failed_count = 0
    
    for table_name in TABLES_TO_CREATE:
        try:
            if table_name in existing_tables:
                print(f"Tabla {table_name} ya existe en destino.")
                already_exists_count += 1
                continue
                
            # Crear tabla
            table_service.create_table(table_name)
            print(f"Tabla {table_name} creada exitosamente.")
            created_count += 1
            
        except Exception as e:
            print(f"Error al crear tabla {table_name}: {str(e)}")
            failed_count += 1
    
    end_time = datetime.now()
    duration = end_time - start_time
    
    print(f"\nResumen de creación de tablas:")
    print(f"Total tablas a crear: {len(TABLES_TO_CREATE)}")
    print(f"Tablas creadas exitosamente: {created_count}")
    print(f"Tablas que ya existían: {already_exists_count}")
    print(f"Tablas con error: {failed_count}")
    print(f"Tiempo total: {duration}")

if __name__ == "__main__":
    create_tables()

