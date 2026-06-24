Airflow E-commerce Analytics Pipeline
📖 Descripción del Proyecto
Pipeline de datos de grado industrial diseñado para transformar datos transaccionales de E-commerce. Implementa una arquitectura Medallion (Bronze/Silver/Gold) para garantizar la trazabilidad, limpieza y disponibilidad de datos para analítica avanzada.

🏗 Arquitectura del Pipeline
El flujo de datos orquestado mediante Apache Airflow sigue estos principios:

Bronze (Raw): Ingesta cruda (Load).

Silver (Cleaned): Estandarización, desduplicación y manejo de nulos (Clean).

Gold (Curated): Modelo estrella (Fact & Dimensions) optimizado para consulta SQL (Transform).

🛠 Stack Tecnológico
Orquestación: Apache Airflow 2.10.0

Data Warehouse: PostgreSQL 15

Infraestructura: Docker & Docker Compose

Procesamiento: Python 3.12, Pandas, SQLAlchemy

🚀 Despliegue (Quick Start)
1. Configuración del Entorno
Crea un archivo .env en la raíz del proyecto basándote en .env.example:
# PostgreSQL
POSTGRES_USER=airflow
POSTGRES_PASSWORD=airflow
POSTGRES_DB=airflow

# Airflow
AIRFLOW_ADMIN_USER=admin
AIRFLOW_ADMIN_PASSWORD=admin
AIRFLOW_SECRET_KEY=tu_clave_secreta

# DB Externa (Target)
EXTERNAL_DB_HOST=tu_host
EXTERNAL_DB_USER=tu_usuario
EXTERNAL_DB_PASSWORD=tu_password
EXTERNAL_DB_NAME=tu_db
EXTERNAL_DB_PORT=6432

2. Comandos de Operación
Para inicializar y levantar el pipeline, ejecuta:

# Limpieza de volúmenes persistentes y contenedores previos
docker compose down -v

# Construcción y levantamiento de servicios en modo detach
docker compose up -d

# Verificación de logs en tiempo real (Webserver)
docker compose logs -f airflow-webserver

3. Clonación del Repositorio
Para obtener una copia local del proyecto, ejecuta el siguiente comando en tu terminal:
git clone https://github.com/r0bins0nurreg07/airflow-ecommerce-analytics.git


🏛 ¿Por qué Arquitectura Medallion y no otra?

La elección de la arquitectura Medallion no es azarosa; responde a la necesidad de calidad de datos, trazabilidad y rendimiento en entornos de datos a gran escala.

- El problema de los enfoques tradicionales (Data Silos / Monolitos)
En modelos antiguos, se solía volcar todo a una única base de datos sin capas. Esto generaba:

# Datos "sucios" mezclados: Los analistas trabajaban sobre datos sin limpiar, provocando reportes erróneos.
# Inexistencia de auditoría: Si un reporte salía mal, era imposible saber en qué parte del proceso se corrompió el dato.
# Rigidez: Cualquier cambio en la lógica de negocio requería modificar el proceso desde cero.

📦 Stack de Librerías y Dependencias
    Este proyecto utiliza un ecosistema de librerías enfocado en el procesamiento robusto, la transformación eficiente y la orquestación.
# Análisis y Procesamiento
pandas==2.2.0              # Manipulación y análisis de datos tabulares
numpy==1.26.0              # Soporte para operaciones matemáticas vectorizadas

# Visualización (EDA)
seaborn==0.13.0            # Visualización estadística avanzada
matplotlib==3.8.0          # Gráficos base para reportes técnicos

# Orquestación y Conectividad
apache-airflow-providers-postgres # Interacción nativa con PostgreSQL
sqlalchemy                 # Capa de abstracción para conexiones SQL

# Entorno de Desarrollo
jupyter                    # Utilizado para el EDA y validación inicial de scripts

🔍 Análisis Exploratorio (EDA) - Hallazgos Críticos
El pipeline fue diseñado tras validar las siguientes anomalías en el dataset:

Duplicados: 5,268 filas detectadas (eliminadas en capa Silver).

Consistencia: Cantidades negativas identificadas como devoluciones; segregadas del cálculo de ingresos.

Integridad: Gestión de nulos en CustomerID mediante filtrado en etapa de transformación.

📈 Operación de DAGs
Una vez levantado el entorno, accede a http://localhost:8080:

El DAG ecommerce_etl se sincronizará automáticamente.

Verifica que las tareas bronze_layer, silver_layer y gold_layer se completen satisfactoriamente.

Los resultados finales son persistidos en el schema gold de la base de datos destino.

🔐 Mantenimiento
Para actualizar dependencias de Python:

Edita requirements.txt.

Reinicia los servicios: docker compose up -d --build





airflow-ecommerce-analytics/
├── dags/                  # Lógica de orquestación
│   └── ecommerce_etl.py   # El orquestador del pipeline
├── sql/                   # Transformaciones SQL (Capas)
│   ├── 01_bronze.sql      # Carga desde CSV a tabla cruda
│   ├── 02_silver.sql      # Limpieza y estandarización
│   └── 03_gold.sql        # Creación del Modelo Estrella
├── data/                  # Aquí pondrás el CSV descargado de Kaggle
├── logs/                  # Logs generados por Airflow (se crea solo)
├── requirements.txt       # Librerías (psycopg2-binary, pandas, etc.)
├── docker-compose.yaml    # Configuración de los contenedores
└── .env                   # Variables de entorno (seguridad)