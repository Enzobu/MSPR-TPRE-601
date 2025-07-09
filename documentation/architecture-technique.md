# Architecture Technique - MSPR-TPRE-601

## 🏗️ Vue d'ensemble de l'Architecture

L'architecture du projet MSPR-TPRE-601 est basée sur une approche **multi-cluster** avec des **microservices containerisés**. Chaque cluster est indépendant et peut fonctionner de manière autonome.

## 📐 Architecture Détaillée

### 1. Architecture Multi-Cluster

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cluster FR    │    │   Cluster CH    │    │   Cluster US    │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Frontend │  │    │  │  Frontend │  │    │  │  Frontend │  │
│  │   (5001)  │  │    │  │   (5002)  │  │    │  │   (5003)  │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │   API IA  │  │    │  │   API IA  │  │    │  │   API IA  │  │
│  │   (6001)  │  │    │  │   (6002)  │  │    │  │   (6003)  │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │ PostgreSQL│  │    │  │ PostgreSQL│  │    │  │ PostgreSQL│  │
│  │   (5431)  │  │    │  │   (5432)  │  │    │  │   (5433)  │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  PgAdmin  │  │    │  │  PgAdmin  │  │    │  │  PgAdmin  │  │
│  │   (7081)  │  │    │  │   (7082)  │  │    │  │   (7083)  │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │  ┌───────────┐  │    │  ┌───────────┐  │
│  │  Metabase │  │    │  │    ETL    │  │    │  │ API Tech  │  │
│  │   (3001)  │  │    │  │           │  │    │  │   (5000)  │  │
│  └───────────┘  │    │  └───────────┘  │    │  └───────────┘  │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │                 │    │  ┌───────────┐  │
│  │    ETL    │  │    │                 │    │  │  Metabase │  │
│  │           │  │    │                 │    │  │   (3003)  │  │
│  └───────────┘  │    │                 │    │  └───────────┘  │
│                 │    │                 │    │                 │
│  ┌───────────┐  │    │                 │    │  ┌───────────┐  │
│  │     ML    │  │    │                 │    │  │     ML    │  │
│  │           │  │    │                 │    │  │           │  │
│  └───────────┘  │    │                 │    │  └───────────┘  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2. Architecture des Services

#### Frontend (Vue.js + Nginx)
```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Container                       │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Vue.js    │───▶│    Build    │───▶│   Nginx     │     │
│  │ Application │    │   Process   │    │   Server    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

#### API IA (Flask)
```
┌─────────────────────────────────────────────────────────────┐
│                    API IA Container                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Flask     │───▶│   REST API  │───▶│ PostgreSQL  │     │
│  │ Application │    │   Endpoints │    │   Database  │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

#### ML Services (Spark)
```
┌─────────────────────────────────────────────────────────────┐
│                    ML Container                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   Python    │───▶│ Apache Spark│───▶│ PostgreSQL  │     │
│  │   Scripts   │    │   Engine    │    │   Database  │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## 🔄 Flux de Données

### 1. Flux Principal
```
1. Frontend (Vue.js) ←→ API IA (Flask) ←→ PostgreSQL
2. ETL (Spark) → PostgreSQL
3. ML (Spark) → PostgreSQL
4. PgAdmin → PostgreSQL (Administration)
5. Metabase → PostgreSQL (BI)
```

### 2. Flux de Déploiement
```
GitHub Repository
       ↓
GitHub Actions
       ↓
SSH Connection
       ↓
Docker Compose
       ↓
Container Orchestration
```

## 🐳 Architecture Docker

### 1. Structure des Images
```
base/
├── front/          # Vue.js + Nginx
├── api_ia/         # Flask API
├── ml/             # Python + Spark
├── etl/            # Spark ETL
└── postgres/       # PostgreSQL Database
```

### 2. Multi-Stage Builds
- **Frontend** : 3 stages (base → test → build → nginx)
- **API IA** : Single stage avec optimisations
- **ML** : Single stage avec Spark
- **ETL** : Single stage avec Spark

## 🔗 Communication Inter-Services

### 1. Dépendances
```
Frontend → API IA → PostgreSQL
ETL → PostgreSQL
ML → PostgreSQL
PgAdmin → PostgreSQL
Metabase → PostgreSQL
```

### 2. Variables d'Environnement
- `DB_HOST` : Hôte PostgreSQL
- `DB_USER` : Utilisateur PostgreSQL
- `DB_PASSWORD` : Mot de passe PostgreSQL
- `DB_DATABASE` : Nom de la base
- `DB_PORT` : Port PostgreSQL
- `VITE_API_URL` : URL de l'API pour le frontend

## 🛡️ Sécurité

### 1. Isolation
- Chaque cluster est complètement isolé
- Services dans des conteneurs séparés
- Réseaux Docker isolés

### 2. Authentification
- PgAdmin : admin@admin.com / s5t4v5
- PostgreSQL : mspr502 / s5t4v5

### 3. Ports
- Ports exposés uniquement en local
- Pas d'exposition directe sur Internet

## 📊 Monitoring et Observabilité

### 1. Health Checks
- PostgreSQL : `pg_isready`
- Services : Health checks Docker

### 2. Logs
- Logs centralisés par conteneur
- Rotation automatique des logs

### 3. Métriques
- Utilisation des ressources Docker
- Performance des services

## 🔧 Configuration

### 1. Fichiers de Configuration
- `docker-compose.*.yml` : Orchestration par cluster
- `Dockerfile` : Définition des images
- `nginx.conf` : Configuration Nginx
- `requirements.txt` : Dépendances Python

### 2. Variables d'Environnement
- Configuration par cluster
- Secrets gérés via GitHub Actions
- Variables d'environnement Docker

## 🚀 Scalabilité

### 1. Horizontale
- Clusters indépendants
- Réplication possible des services

### 2. Verticale
- Ressources ajustables par conteneur
- Configuration mémoire/CPU

## 🔄 CI/CD Pipeline

### 1. Déclenchement
- Push sur branche `main`
- Modification des fichiers spécifiques

### 2. Déploiement
- Build des images
- Déploiement via SSH
- Orchestration Docker Compose

### 3. Rollback
- Images précédentes disponibles
- Déploiement manuel possible 