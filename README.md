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