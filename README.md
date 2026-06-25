# Airflow E-commerce Analytics Pipeline

#📖 Descripción del Proyecto
    Pipeline de datos de grado industrial diseñado para transformar datos transaccionales de E-commerce. Implementa una arquitectura Medallion (Bronze/Silver/Gold) para garantizar la trazabilidad, limpieza y disponibilidad de datos para analítica avanzada.

# 🏗 Arquitectura del Pipeline
    El flujo de datos orquestado mediante Apache Airflow sigue estos principios:
    -Bronze (Raw): Ingesta cruda (Load).
    -Silver (Cleaned): Estandarización, desduplicación y manejo de nulos (Clean).
    -Gold (Curated): Modelo estrella (Fact & Dimensions) optimizado para consulta SQL (Transform).

# 🛠 Stack Tecnológico
    -Orquestación: Apache Airflow 2.10.0
    -Data Warehouse: PostgreSQL 15
    -Infraestructura: Docker & Docker Compose
    -Procesamiento: Python 3.12, Pandas, SQLAlchemy

# 🚀 Despliegue (Quick Start)
    - Configuración del Entorno
    -Crea un archivo .env en la raíz del proyecto basándote en .env.example:

## Entorno virtual dentro de notebook
Para que el notebook y el análisis predictivo funcionen de forma aislada, crea el entorno virtual dentro de la carpeta notebook:

```bash
cd notebook
python -m venv .venv
```

Activarlo en Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Instalar dependencias del proyecto principal:

```bash
pip install -r ../requirements.txt
```

Instalar dependencias del notebook y análisis predictivo:

```bash
pip install -r requirements-eda.txt
```

> Importante: todos los entornos virtuales de este proyecto deben quedar dentro de la carpeta notebook.
    1.1 PostgreSQL
        POSTGRES_USER=airflow
        POSTGRES_PASSWORD=airflow
        POSTGRES_DB=airflow

    1.2 Airflow
        AIRFLOW_ADMIN_USER=admin
        AIRFLOW_ADMIN_PASSWORD=admin
        AIRFLOW_SECRET_KEY=tu_clave_secreta

    1.3 DB Externa (Target)
        EXTERNAL_DB_HOST=tu_host
        EXTERNAL_DB_USER=tu_usuario
        EXTERNAL_DB_PASSWORD=tu_password
        EXTERNAL_DB_NAME=tu_db
        EXTERNAL_DB_PORT=6432

# Comandos de Operación
Para inicializar y levantar el pipeline, ejecuta:

    # Limpieza de volúmenes persistentes y contenedores previos
    docker compose down -v

    # Construcción y levantamiento de servicios en modo detach
    docker compose up -d

    # Verificación de logs en tiempo real (Webserver)
    docker compose logs -f airflow-webserver

# Clonación del Repositorio
    Para obtener una copia local del proyecto, ejecuta el siguiente comando en tu terminal:
    git clone https://github.com/r0bins0nurreg07/airflow-ecommerce-analytics.git


# 🏛 ¿Por qué Arquitectura Medallion y no otra?

    Porque  responde a la necesidad de calidad de datos, trazabilidad y rendimiento en entornos de datos a gran escala. El problema de los enfoques tradicionales (Data Silos / Monolitos)
    En modelos antiguos, se solía volcar todo a una única base de datos sin capas. Esto generaba:

    1.1 Datos "sucios" mezclados: Los analistas trabajaban sobre datos sin limpiar, provocando reportes erróneos.
    1.2 Inexistencia de auditoría: Si un reporte salía mal, era imposible saber en qué parte del proceso se corrompió el dato.
    1.3 Rigidez: Cualquier cambio en la lógica de negocio requería modificar el proceso desde cero.

# 📦 Stack de Librerías y Dependencias
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

# 🔍 Análisis Exploratorio (EDA) - Hallazgos Críticos
    -El pipeline fue diseñado tras validar las siguientes anomalías en el dataset:

    -Duplicados: 5,268 filas detectadas (eliminadas en capa Silver).

    -Consistencia: Cantidades negativas identificadas como devoluciones; segregadas del cálculo de ingresos.

    -Integridad: Gestión de nulos en CustomerID mediante filtrado en etapa de transformación.

# 📈 Operación de DAGs
    -Una vez levantado el entorno, accede a http://localhost:8080:

    -El DAG ecommerce_etl se sincronizará automáticamente.

    -Verifica que las tareas bronze_layer, silver_layer y gold_layer se completen satisfactoriamente.

    -Los resultados finales son persistidos en el schema gold de la base de datos destino.

# 🔐 Mantenimiento
    Para actualizar dependencias de Python:

    -Edita requirements.txt.

    -Reinicia los servicios: docker compose up -d --build

## Entornos virtuales
Todos los entornos virtuales que se creen para este proyecto deben ubicarse dentro de la carpeta notebook.
Ejemplo: notebook/.venv
Esto mantiene las dependencias del análisis aisladas y evita conflictos con el resto del proyecto.

# 📝 Informe de lo que se hizo

## Resumen ejecutivo
Se desarrolló un pipeline de analítica de e-commerce basado en una arquitectura Medallion, con el objetivo de transformar datos transaccionales en información útil, consistente y preparada para análisis y modelado predictivo. El trabajo incluyó la construcción de una capa Bronze para ingestión cruda, una capa Silver para limpieza y estandarización, y una capa Gold para disponibilizar datos listos para consumo analítico. Asimismo, se incorporó un notebook de análisis predictivo orientado a identificar clientes con mayor riesgo de devolución.

## Hallazgos principales del dataset
Durante la fase de exploración se detectaron varios patrones relevantes que condicionaron la estrategia de transformación:
- Existencia de registros duplicados, los cuales se eliminaron para evitar sesgos y redundancia en los cálculos.
- Presencia de cantidades negativas, que se interpretaron como devoluciones. En lugar de tratarlas como ventas normales, se separaron del cálculo de ingresos para evitar distorsionar las métricas de negocio y permitir un análisis más preciso del comportamiento de ventas y devoluciones.
- Inconsistencias en identificadores de cliente, especialmente valores nulos o vacíos. Estos registros se trataron con una política explícita: se evitó su uso en métricas que dependieran de la dimensión cliente y se mantuvieron fuera de los análisis que requerían una identificación fiable del consumidor.
- Transacciones asociadas a códigos especiales no relacionados con ventas reales, como gastos de envío, descuentos o cargos administrativos. Estos registros fueron identificados, clasificados y excluidos de la capa analítica final para asegurar que los resultados reflejaran únicamente operaciones comerciales relevantes para análisis de negocio.

## Transformaciones realizadas
La capa Silver se diseñó para convertir los datos crudos en un conjunto de información más confiable y listo para análisis. Entre las acciones implementadas se encuentran:
- Estandarización de columnas clave, como número de factura, código de producto, descripción y país.
- Conversión de tipos de datos para garantizar consistencia en fechas, cantidades, precios y identificadores.
- Normalización de textos para reducir variaciones superficiales que podrían afectar el análisis.
- Separación lógica de transacciones de negocio de registros auxiliares o no operativos.
- Creación de columnas derivadas, como tipo de transacción y bandera de pedidos de alto volumen, para mejorar la utilidad analítica.

## Decisiones tomadas respecto a los valores nulos
Los valores nulos se trataron de forma controlada y alineada con el contexto del negocio. La razón principal de este tratamiento fue evitar que los datos incompletos distorsionaran los análisis, generaran sesgos o afectaran la calidad de los resultados.

En particular:
- Los valores nulos en customer_id no implicaron la eliminación de la transacción, sino que se interpretaron como ventas sin cliente identificado. Estas filas permanecen registradas en la tabla Silver y, en la medida en que sea necesario, pueden ser tratadas como transacciones sin una asociación fiable a un cliente concreto.
- Los valores nulos en customer_id se evitaron en métricas que dependieran de la dimensión cliente, para no introducir sesgos ni atribuciones erróneas en los análisis por consumidor.
- Las descripciones faltantes de producto se completaron mediante una estrategia de fallback basada en el código de producto y la descripción más frecuente observada en el dataset. Cuando no existía una descripción confiable, se asignó un valor estándar de referencia para mantener la consistencia del registro.
- Los registros con información insuficiente o irrelevante para la lógica de negocio fueron excluidos de la tabla final de análisis para preservar la calidad del modelo y evitar ruido.

### ¿Por qué se reemplazaron o gestionaron los valores nulos?
Se hizo porque los nulos pueden afectar directamente la calidad del análisis: dificultan la agregación, generan resultados incompletos, pueden sesgar métricas de cliente y distorsionar interpretaciones de negocio. Por ello, se decidió convertirlos en un valor manejable, asignar una referencia estándar o excluirlos según el impacto que tuvieran sobre la lógica analítica.

## Medidas de robustez implementadas
Además de la limpieza de datos, se tomaron acciones para asegurar la estabilidad del pipeline:
- Se corrigieron dependencias entre la vista Gold y la tabla Silver para que las reejecuciones del DAG no generaran errores.
- Se hizo el flujo de transformación más reproducible y seguro, permitiendo volver a ejecutar las tareas sin afectar la integridad del proceso.
- Se documentó la lógica de negocio y las reglas de transformación para facilitar el mantenimiento y la escalabilidad del proyecto.

## Valor generado
Con estas mejoras, el proyecto pasa de ser un conjunto de scripts aislados a un flujo de datos más sólido, auditable y preparado para decisiones de negocio, análisis exploratorio y modelado predictivo.

# Glosarios de terminos administrativos
    POST : Gasto de envio 
    D: Descuentos 
    M: Adjustes contables 
    DOT: Error sistema
    BANK CHARGES: Comisiones o tarifas bancarias
    Amazonfe: Comisión amazon
    B: Adjuste de inventario
    CRUK/C2: Donaciones





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