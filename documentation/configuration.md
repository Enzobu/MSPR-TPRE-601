# Configuration - MSPR-TPRE-601

## 📋 Vue d'ensemble

Ce document détaille toutes les configurations nécessaires pour le déploiement et l'exploitation du projet MSPR-TPRE-601.

## 🔧 Variables d'Environnement

### Variables Globales

#### Base de Données
```bash
# Configuration PostgreSQL commune
DB_USER=mspr502
DB_PASSWORD=s5t4v5
DB_DATABASE=mspr502
DB_PORT=5432
```

#### Frontend
```bash
# Configuration Vue.js
VITE_APP_TITLE=MSPR-601
```

### Variables par Cluster

#### France (FR)
```bash
# URLs des services
VITE_API_URL_fr=http://localhost:6001
DB_HOST_fr=postgres_fr

# Ports exposés
FRONTEND_PORT=5001
API_PORT=6001
DB_PORT=5431
PGADMIN_PORT=7081
METABASE_PORT=3001
```

#### Suisse (CH)
```bash
# URLs des services
VITE_API_URL_ch=http://localhost:6002
DB_HOST_ch=postgres_ch

# Ports exposés
FRONTEND_PORT=5002
API_PORT=6002
PGADMIN_PORT=7082
```

#### États-Unis (US)
```bash
# URLs des services
VITE_API_URL_us=http://localhost:6003
DB_HOST_us=postgres_us

# Ports exposés
FRONTEND_PORT=5003
API_PORT=6003
DB_PORT=5433
PGADMIN_PORT=7083
METABASE_PORT=3003
API_TECHNIQUE_PORT=5000
```

## 🐳 Configuration Docker

### Images Docker

#### Frontend
```dockerfile
# base/front/Dockerfile
FROM node:20-alpine AS base
# Configuration multi-stage
ARG VITE_API_URL
ARG VITE_APP_TITLE
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_APP_TITLE=$VITE_APP_TITLE
```

#### API IA
```dockerfile
# base/api_ia/Dockerfile
FROM python:3.11-slim
# Dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
    libffi-dev \
    libpq-dev \
    gcc \
    git
```

#### ML Service
```dockerfile
# base/ml/Dockerfile
FROM python:3.10-slim
# Configuration Spark
ENV SPARK_HOME=/opt/spark-3.4.4-bin-hadoop3
ENV PATH=$SPARK_HOME/bin:$PATH
ENV PYTHONPATH=/app
```

### Configuration Docker Compose

#### Variables d'Environnement dans Compose
```yaml
# docker-compose.fr.yml
services:
  front_fr:
    build:
      args:
        - VITE_API_URL=${VITE_API_URL_fr}
        - VITE_APP_TITLE=${VITE_APP_TITLE}
    
  api_ia_fr:
    environment:
      - DB_HOST=${DB_HOST_fr}
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_DATABASE=${DB_DATABASE}
      - DB_PORT=${DB_PORT}
```

## 🔐 Configuration de Sécurité

### Authentification

#### PgAdmin
```yaml
# Configuration PgAdmin
environment:
  - PGADMIN_DEFAULT_EMAIL=admin@admin.com
  - PGADMIN_DEFAULT_PASSWORD=s5t4v5
```

#### PostgreSQL
```yaml
# Configuration PostgreSQL
environment:
  POSTGRES_DB: mspr502
  POSTGRES_USER: mspr502
  POSTGRES_PASSWORD: s5t4v5
```

### Réseaux et Isolation
```yaml
# Configuration réseau par défaut
networks:
  default:
    driver: bridge
```

## 📊 Configuration des Services

### Frontend (Nginx)
```nginx
# base/front/nginx.conf
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
    }
    
    # Configuration CORS
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Methods "GET, POST, OPTIONS";
    add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range";
}
```

### API IA (Flask)
```python
# Configuration Flask
app.config['SECRET_KEY'] = 'your-secret-key'
app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_DATABASE}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Configuration CORS
CORS(app, resources={r"/api/*": {"origins": "*"}})
```

### PostgreSQL
```sql
-- Configuration de base
-- base/postgres/database/initdb.sql

-- Création des tables
CREATE TABLE IF NOT EXISTS disease (
    id_disease SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    is_pandemic BOOLEAN DEFAULT FALSE
);

-- Index pour les performances
CREATE INDEX IF NOT EXISTS idx_statement_date ON statement(_date);
CREATE INDEX IF NOT EXISTS idx_prediction_date ON prediction(ds);
```

## 🔄 Configuration CI/CD

### GitHub Actions Secrets
```yaml
# Configuration des secrets
secrets:
  FR_HOST: "192.168.1.100"
  FR_USER: "ubuntu"
  FR_SSH_KEY: "-----BEGIN RSA PRIVATE KEY-----"
  
  CH_HOST: "192.168.1.101"
  CH_USER: "ubuntu"
  CH_SSH_KEY: "-----BEGIN RSA PRIVATE KEY-----"
  
  US_HOST: "192.168.1.102"
  US_USER: "ubuntu"
  US_SSH_KEY: "-----BEGIN RSA PRIVATE KEY-----"
```

### Workflow Configuration
```yaml
# .github/workflows/deploy-fr.yml
name: Deploy France Cluster

on:
  push:
    branches: [main]
    paths:
      - 'base/**'
      - 'fr/**'
      - 'docker-compose.fr.yml'
      - 'Makefile'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to France Server
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.FR_HOST }}
          username: ${{ secrets.FR_USER }}
          key: ${{ secrets.FR_SSH_KEY }}
          script: |
            cd ~/apps/mspr-tpre-601
            git pull origin main
            docker compose -f docker-compose.fr.yml down
            docker compose -f docker-compose.fr.yml build --no-cache
            docker compose -f docker-compose.fr.yml up -d
```

## 🛠️ Configuration Makefile

### Commandes Disponibles
```makefile
# Makefile
help:
	@echo "Makefile commands:"
	@echo "  up          - Start all services"
	@echo "  up_fr       - Start French services"
	@echo "  up_ch       - Start Swiss services"
	@echo "  up_us       - Start US services"
	@echo "  down        - Stop all services"
	@echo "  build       - Clean images and rebuild all services"
	@echo "  help        - Show this help message"

up:
	$(MAKE) up_fr
	$(MAKE) up_ch
	$(MAKE) up_us

up_fr:
	docker compose -f docker-compose.fr.yml build --no-cache
	docker compose -f docker-compose.fr.yml up -d
```

## 📁 Structure des Fichiers de Configuration

```
MSPR-TPRE-601/
├── .env.fr                    # Variables d'environnement France
├── .env.ch                    # Variables d'environnement Suisse
├── .env.us                    # Variables d'environnement États-Unis
├── docker-compose.fr.yml      # Orchestration France
├── docker-compose.ch.yml      # Orchestration Suisse
├── docker-compose.us.yml      # Orchestration États-Unis
├── Makefile                   # Commandes de déploiement
├── base/
│   ├── front/
│   │   ├── Dockerfile         # Image Frontend
│   │   └── nginx.conf         # Configuration Nginx
│   ├── api_ia/
│   │   ├── Dockerfile         # Image API IA
│   │   └── requirements.txt   # Dépendances Python
│   ├── ml/
│   │   ├── Dockerfile         # Image ML
│   │   └── requirements.txt   # Dépendances ML
│   ├── etl/
│   │   └── Dockerfile         # Image ETL
│   └── postgres/
│       ├── Dockerfile         # Image PostgreSQL
│       └── database/
│           ├── initdb.sql     # Script d'initialisation
│           └── MCD.md         # Modèle conceptuel
└── .github/
    └── workflows/
        ├── deploy-fr.yml      # Workflow France
        ├── deploy-ch.yml      # Workflow Suisse
        └── deploy-us.yml      # Workflow États-Unis
```

## 🔧 Configuration Avancée

### Ressources Docker
```yaml
# Configuration des ressources par service
services:
  api_ia_fr:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
        reservations:
          memory: 512M
          cpus: '0.25'
  
  postgres_fr:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
```

### Health Checks
```yaml
# Configuration des health checks
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U mspr502"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### Volumes et Persistance
```yaml
# Configuration des volumes
volumes:
  pg-data:
    driver: local
  
  metabase-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./fr/metabase
```

## 🔍 Configuration de Monitoring

### Logs
```yaml
# Configuration des logs
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Métriques
```yaml
# Configuration des métriques
deploy:
  resources:
    limits:
      memory: 1G
    reservations:
      memory: 512M
  restart_policy:
    condition: on-failure
    delay: 5s
    max_attempts: 3
    window: 120s
```

## 🚨 Configuration de Sécurité Avancée

### Variables Sensibles
```bash
# Fichier .env.secrets (non versionné)
DB_PASSWORD=your-secure-password
JWT_SECRET_KEY=your-jwt-secret
API_KEY=your-api-key
```

### Configuration SSL/TLS
```nginx
# Configuration SSL pour la production
server {
    listen 443 ssl;
    ssl_certificate /etc/ssl/certs/cert.pem;
    ssl_certificate_key /etc/ssl/private/key.pem;
    
    # Configuration de sécurité
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
}
```

## 📊 Configuration de Performance

### Optimisations PostgreSQL
```sql
-- Configuration PostgreSQL optimisée
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
```

### Configuration Nginx
```nginx
# Optimisations Nginx
worker_processes auto;
worker_connections 1024;

# Gzip compression
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
```

## 🔄 Configuration de Sauvegarde

### Script de Sauvegarde
```bash
#!/bin/bash
# backup.sh

# Variables
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="mspr502"
DB_USER="mspr502"

# Créer le répertoire de sauvegarde
mkdir -p $BACKUP_DIR

# Sauvegarde PostgreSQL
docker exec mspr601_postgres_fr pg_dump -U $DB_USER $DB_NAME > $BACKUP_DIR/backup_$DATE.sql

# Compression
gzip $BACKUP_DIR/backup_$DATE.sql

# Nettoyage des anciennes sauvegardes (garder 7 jours)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Sauvegarde terminée: backup_$DATE.sql.gz"
```

### Configuration Cron
```bash
# Ajouter au crontab
0 2 * * * /path/to/backup.sh >> /var/log/backup.log 2>&1
``` 