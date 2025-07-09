# Déploiement et CI/CD - MSPR-TPRE-601

## 📋 Vue d'ensemble

Le système de déploiement MSPR-TPRE-601 utilise une approche **multi-cluster** avec **GitHub Actions** pour l'automatisation et **Docker Compose** pour l'orchestration.

## 🚀 Architecture de Déploiement

### Flux de Déploiement
```
GitHub Repository
       ↓
GitHub Actions (CI/CD)
       ↓
SSH Connection
       ↓
Docker Compose
       ↓
Container Orchestration
       ↓
Services Running
```

### Clusters Disponibles
- **🇫🇷 France** : Cluster principal avec Metabase
- **🇨🇭 Suisse** : Cluster avec ETL spécialisé
- **🇺🇸 États-Unis** : Cluster avec API technique et Metabase

## 🔧 Configuration GitHub Actions

### Prérequis
1. **Repository GitHub** configuré
2. **Serveurs distants** avec Docker installé
3. **Clés SSH** configurées
4. **Secrets GitHub** configurés

### Secrets Requis par Cluster

#### France (FR)
| Secret | Description | Exemple |
|--------|-------------|---------|
| `FR_HOST` | IP ou domaine du serveur | `192.168.1.100` |
| `FR_USER` | Utilisateur SSH | `ubuntu` |
| `FR_SSH_KEY` | Clé privée SSH (PEM) | `-----BEGIN RSA PRIVATE KEY-----` |

#### Suisse (CH)
| Secret | Description | Exemple |
|--------|-------------|---------|
| `CH_HOST` | IP ou domaine du serveur | `192.168.1.101` |
| `CH_USER` | Utilisateur SSH | `ubuntu` |
| `CH_SSH_KEY` | Clé privée SSH (PEM) | `-----BEGIN RSA PRIVATE KEY-----` |

#### États-Unis (US)
| Secret | Description | Exemple |
|--------|-------------|---------|
| `US_HOST` | IP ou domaine du serveur | `192.168.1.102` |
| `US_USER` | Utilisateur SSH | `ubuntu` |
| `US_SSH_KEY` | Clé privée SSH (PEM) | `-----BEGIN RSA PRIVATE KEY-----` |

## 🔄 Workflows GitHub Actions

### Structure des Workflows
```
.github/workflows/
├── deploy-fr.yml    # Déploiement France
├── deploy-ch.yml    # Déploiement Suisse
└── deploy-us.yml    # Déploiement États-Unis
```

### Déclenchement Automatique
- **Push sur `main`** : Déclenche le déploiement
- **Modification de fichiers** : Déploiement ciblé par cluster
- **Déploiement manuel** : Via l'interface GitHub Actions

### Exemple de Workflow (France)
```yaml
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

## 🐳 Déploiement Docker

### Commandes de Déploiement

#### Déploiement Complet
```bash
# Démarrage de tous les clusters
make up

# Démarrage par cluster
make up_fr    # France
make up_ch    # Suisse
make up_us    # États-Unis
```

#### Déploiement avec Reconstruction
```bash
# Reconstruction complète
make build

# Reconstruction par cluster
make build_fr    # France
make build_ch    # Suisse
make build_us    # États-Unis
```

#### Arrêt des Services
```bash
# Arrêt complet
make down

# Arrêt par cluster
make down_fr    # France
make down_ch    # Suisse
make down_us    # États-Unis
```

### Orchestration Docker Compose

#### France (docker-compose.fr.yml)
```yaml
services:
  front_fr:
    build: ./base/front
    ports: ["5001:80"]
    
  api_ia_fr:
    build: ./base/api_ia
    ports: ["6001:5000"]
    
  postgres_fr:
    build: ./base/postgres
    ports: ["5431:5432"]
    
  metabase_fr:
    image: metabase/metabase:v0.52.x
    ports: ["3001:3000"]
    
  pgadmin4_fr:
    build: ./fr/pg_admin
    ports: ["7081:80"]
```

#### Suisse (docker-compose.ch.yml)
```yaml
services:
  front_ch:
    build: ./base/front
    ports: ["5002:80"]
    
  api_ia_ch:
    build: ./base/api_ia
    ports: ["6002:5000"]
    
  postgres_ch:
    build: ./base/postgres
    
  pgadmin4_ch:
    build: ./ch/pg_admin
    ports: ["7082:80"]
```

#### États-Unis (docker-compose.us.yml)
```yaml
services:
  front_us:
    build: ./base/front
    ports: ["5003:80"]
    
  api_ia_us:
    build: ./base/api_ia
    ports: ["6003:5000"]
    
  postgres_us:
    build: ./base/postgres
    ports: ["5433:5432"]
    
  api_technique_us:
    build: ./us/api_technique
    ports: ["5000:5000"]
    
  metabase_us:
    image: metabase/metabase:v0.52.x
    ports: ["3003:3000"]
    
  pgadmin4_us:
    build: ./us/pg_admin
    ports: ["7083:80"]
```

## 🔐 Configuration SSH

### Génération des Clés SSH
```bash
# Générer une nouvelle paire de clés
ssh-keygen -t rsa -b 4096 -C "mspr-601-deployment"

# Copier la clé publique sur le serveur
ssh-copy-id -i ~/.ssh/id_rsa.pub user@server

# Tester la connexion
ssh user@server
```

### Configuration sur les Serveurs
```bash
# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Cloner le repository
git clone https://github.com/user/mspr-tpre-601.git ~/apps/mspr-tpre-601
```

## 📊 Monitoring du Déploiement

### Vérification des Services
```bash
# Statut des conteneurs
docker ps

# Logs en temps réel
docker logs -f mspr601_front_fr
docker logs -f mspr601_api_ia_flask_fr
docker logs -f mspr601_postgres_fr

# Statistiques des ressources
docker stats
```

### Health Checks
```bash
# Vérifier les endpoints
curl http://localhost:5001  # Frontend FR
curl http://localhost:6001  # API FR
curl http://localhost:5431  # PostgreSQL FR

# Vérifier les health checks
docker exec mspr601_postgres_fr pg_isready -U mspr502
```

## 🔄 Rollback et Récupération

### Rollback Automatique
```bash
# Arrêter les services
make down_fr

# Restaurer une version précédente
git checkout HEAD~1

# Redémarrer
make up_fr
```

### Sauvegarde avant Déploiement
```bash
# Sauvegarder la base de données
docker exec mspr601_postgres_fr pg_dump -U mspr502 mspr502 > backup_$(date +%Y%m%d_%H%M%S).sql

# Sauvegarder les images
docker save mspr-601-front-fr > front_fr_backup.tar
docker save mspr-601-api-ia-fr > api_fr_backup.tar
```

## 🚨 Gestion des Erreurs

### Erreurs Courantes

#### 1. Échec de Connexion SSH
```bash
# Vérifier les clés SSH
ssh -i ~/.ssh/id_rsa user@server

# Vérifier les permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

#### 2. Ports en Conflit
```bash
# Vérifier les ports utilisés
netstat -tulpn | grep :5001

# Arrêter les services conflictuels
sudo systemctl stop apache2  # Si nécessaire
```

#### 3. Manque d'Espace Disque
```bash
# Nettoyer Docker
docker system prune -a

# Vérifier l'espace
df -h
```

### Logs de Déploiement
```bash
# Logs GitHub Actions
# Accessibles via l'interface GitHub

# Logs Docker
docker logs mspr601_front_fr
docker logs mspr601_api_ia_flask_fr

# Logs système
journalctl -u docker
```

## 🔧 Configuration Avancée

### Variables d'Environnement
```bash
# Fichier .env pour chaque cluster
# .env.fr
VITE_API_URL_fr=http://localhost:6001
DB_HOST_fr=postgres_fr

# .env.ch
VITE_API_URL_ch=http://localhost:6002
DB_HOST_ch=postgres_ch

# .env.us
VITE_API_URL_us=http://localhost:6003
DB_HOST_us=postgres_us
```

### Configuration des Ressources
```yaml
# docker-compose.fr.yml
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
```

## 📈 Métriques de Déploiement

### Temps de Déploiement
- **Build des images** : 5-10 minutes
- **Déploiement complet** : 10-15 minutes
- **Rollback** : 2-3 minutes

### Indicateurs de Performance
- **Taux de succès** : >95%
- **Temps de disponibilité** : <30 secondes
- **Temps de récupération** : <5 minutes

## 🔍 Troubleshooting Avancé

### Diagnostic Complet
```bash
# Script de diagnostic
#!/bin/bash
echo "=== Diagnostic MSPR-601 ==="
echo "1. Vérification Docker"
docker --version
docker-compose --version

echo "2. Statut des conteneurs"
docker ps -a

echo "3. Utilisation des ressources"
docker stats --no-stream

echo "4. Logs d'erreur"
docker logs --tail 50 mspr601_postgres_fr 2>&1 | grep -i error

echo "5. Connexions réseau"
netstat -tulpn | grep docker
```

### Commandes de Récupération
```bash
# Redémarrer un service spécifique
docker restart mspr601_api_ia_flask_fr

# Reconstruire une image
docker compose -f docker-compose.fr.yml build --no-cache api_ia_fr

# Nettoyer et redémarrer
make down_fr && make up_fr
``` 