# Maintenance et Opérations - MSPR-TPRE-601

## 📋 Vue d'ensemble

Ce document détaille les procédures de maintenance, de monitoring et d'exploitation du système MSPR-TPRE-601.

## 🔧 Maintenance Préventive

### Tâches Quotidiennes

#### Vérification de l'État des Services
```bash
# Script de vérification quotidienne
#!/bin/bash
echo "=== Vérification quotidienne MSPR-601 ==="
echo "Date: $(date)"

# Vérifier les conteneurs
echo "1. Statut des conteneurs:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Vérifier les ressources
echo "2. Utilisation des ressources:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Vérifier les logs d'erreur
echo "3. Logs d'erreur récents:"
docker logs --since 24h mspr601_postgres_fr 2>&1 | grep -i error | tail -10

# Vérifier l'espace disque
echo "4. Espace disque:"
df -h | grep -E "(Filesystem|/dev/)"

echo "=== Vérification terminée ==="
```

#### Monitoring des Performances
```bash
# Vérifier les performances PostgreSQL
docker exec mspr601_postgres_fr psql -U mspr502 -d mspr502 -c "
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_tuples,
    n_dead_tup as dead_tuples
FROM pg_stat_user_tables
ORDER BY n_tup_ins DESC;
"
```

### Tâches Hebdomadaires

#### Nettoyage des Logs
```bash
# Script de nettoyage des logs
#!/bin/bash
echo "=== Nettoyage des logs ==="

# Nettoyer les logs Docker anciens
docker system prune -f

# Nettoyer les logs d'application
find /var/log -name "*.log" -mtime +7 -delete

# Nettoyer les sauvegardes anciennes
find /backups -name "backup_*.sql.gz" -mtime +30 -delete

echo "Nettoyage terminé"
```

#### Vérification de Sécurité
```bash
# Vérifier les mises à jour de sécurité
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}"

# Vérifier les vulnérabilités
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image mspr-601-front-fr:latest
```

### Tâches Mensuelles

#### Sauvegarde Complète
```bash
#!/bin/bash
# backup_monthly.sh

BACKUP_DIR="/backups/monthly"
DATE=$(date +%Y%m)
DB_NAME="mspr502"
DB_USER="mspr502"

mkdir -p $BACKUP_DIR

# Sauvegarde de la base de données
echo "Sauvegarde de la base de données..."
docker exec mspr601_postgres_fr pg_dump -U $DB_USER $DB_NAME > $BACKUP_DIR/db_$DATE.sql

# Sauvegarde des volumes
echo "Sauvegarde des volumes..."
docker run --rm -v mspr601_pg-data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/volumes_$DATE.tar.gz -C /data .

# Sauvegarde des configurations
echo "Sauvegarde des configurations..."
tar czf $BACKUP_DIR/config_$DATE.tar.gz docker-compose.*.yml Makefile

echo "Sauvegarde mensuelle terminée: $BACKUP_DIR"
```

## 📊 Monitoring en Temps Réel

### Dashboard de Monitoring
```bash
# Script de création d'un dashboard simple
#!/bin/bash
echo "=== Dashboard MSPR-601 ==="
echo "Timestamp: $(date)"
echo ""

# Services status
echo "🔍 SERVICES STATUS"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -10
echo ""

# Resource usage
echo "📊 RESOURCE USAGE"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
echo ""

# Database connections
echo "🗄️ DATABASE CONNECTIONS"
docker exec mspr601_postgres_fr psql -U mspr502 -d mspr502 -c "
SELECT count(*) as active_connections 
FROM pg_stat_activity 
WHERE state = 'active';
"
echo ""

# Recent errors
echo "⚠️ RECENT ERRORS"
docker logs --since 1h mspr601_api_ia_flask_fr 2>&1 | grep -i error | tail -5
echo ""
```

### Alertes Automatisées
```bash
#!/bin/bash
# check_alerts.sh

# Vérifier si les services sont en cours d'exécution
if ! docker ps | grep -q mspr601_postgres_fr; then
    echo "ALERTE: PostgreSQL France n'est pas en cours d'exécution!"
    # Envoyer une notification (email, Slack, etc.)
fi

# Vérifier l'utilisation de la mémoire
MEMORY_USAGE=$(docker stats --no-stream --format "{{.MemPerc}}" mspr601_postgres_fr | sed 's/%//')
if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
    echo "ALERTE: Utilisation mémoire élevée: ${MEMORY_USAGE}%"
fi

# Vérifier l'espace disque
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "ALERTE: Espace disque faible: ${DISK_USAGE}%"
fi
```

## 🔄 Procédures de Maintenance

### Mise à Jour des Services

#### Mise à Jour Frontend
```bash
# Mise à jour du frontend
echo "Mise à jour du frontend..."

# Arrêter le service
docker compose -f docker-compose.fr.yml stop front_fr

# Reconstruire l'image
docker compose -f docker-compose.fr.yml build --no-cache front_fr

# Redémarrer le service
docker compose -f docker-compose.fr.yml up -d front_fr

# Vérifier le statut
docker ps | grep front_fr
echo "Mise à jour frontend terminée"
```

#### Mise à Jour API
```bash
# Mise à jour de l'API
echo "Mise à jour de l'API..."

# Sauvegarde avant mise à jour
docker exec mspr601_postgres_fr pg_dump -U mspr502 mspr502 > backup_pre_update.sql

# Mise à jour
docker compose -f docker-compose.fr.yml stop api_ia_fr
docker compose -f docker-compose.fr.yml build --no-cache api_ia_fr
docker compose -f docker-compose.fr.yml up -d api_ia_fr

# Vérification
curl -f http://localhost:6001/health || echo "ERREUR: API non accessible"
echo "Mise à jour API terminée"
```

### Gestion des Incidents

#### Procédure de Récupération
```bash
#!/bin/bash
# recovery_procedure.sh

echo "=== Procédure de récupération MSPR-601 ==="

# 1. Arrêter tous les services
echo "1. Arrêt des services..."
make down_fr

# 2. Vérifier l'état du système
echo "2. Vérification de l'état du système..."
df -h
docker system df

# 3. Nettoyer les ressources
echo "3. Nettoyage des ressources..."
docker system prune -f

# 4. Redémarrer les services
echo "4. Redémarrage des services..."
make up_fr

# 5. Vérification
echo "5. Vérification des services..."
sleep 30
docker ps
curl -f http://localhost:5001 || echo "ERREUR: Frontend non accessible"
curl -f http://localhost:6001/health || echo "ERREUR: API non accessible"

echo "Procédure de récupération terminée"
```

#### Rollback en Cas de Problème
```bash
#!/bin/bash
# rollback.sh

echo "=== Rollback MSPR-601 ==="

# 1. Arrêter les services
make down_fr

# 2. Restaurer la version précédente
git checkout HEAD~1

# 3. Restaurer la base de données si nécessaire
if [ -f "backup_pre_update.sql" ]; then
    echo "Restauration de la base de données..."
    docker exec -i mspr601_postgres_fr psql -U mspr502 mspr502 < backup_pre_update.sql
fi

# 4. Redémarrer avec l'ancienne version
make up_fr

echo "Rollback terminé"
```

## 🗄️ Maintenance de la Base de Données

### Optimisation PostgreSQL
```sql
-- Script d'optimisation mensuelle
-- maintenance_postgres.sql

-- Analyser les tables
ANALYZE;

-- VACUUM des tables
VACUUM ANALYZE;

-- Vérifier les index
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- Nettoyer les anciennes données
DELETE FROM statement WHERE _date < CURRENT_DATE - INTERVAL '1 year';
DELETE FROM prediction WHERE ds < CURRENT_DATE - INTERVAL '6 months';

-- Réindexer si nécessaire
REINDEX DATABASE mspr502;
```

### Monitoring des Performances
```sql
-- Requêtes de monitoring
-- monitoring_queries.sql

-- Connexions actives
SELECT 
    datname,
    usename,
    application_name,
    client_addr,
    state,
    query_start
FROM pg_stat_activity
WHERE state = 'active';

-- Taille des tables
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Performances des requêtes
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

## 🔧 Maintenance des Conteneurs

### Nettoyage des Images
```bash
#!/bin/bash
# cleanup_images.sh

echo "=== Nettoyage des images Docker ==="

# Supprimer les images non utilisées
docker image prune -f

# Supprimer les images MSPR-601 anciennes
docker images | grep mspr-601 | awk '{print $3}' | xargs -r docker rmi

# Nettoyer les volumes non utilisés
docker volume prune -f

# Nettoyer les réseaux non utilisés
docker network prune -f

echo "Nettoyage terminé"
```

### Mise à Jour des Images de Base
```bash
#!/bin/bash
# update_base_images.sh

echo "=== Mise à jour des images de base ==="

# Mettre à jour les images de base
docker pull node:20-alpine
docker pull python:3.11-slim
docker pull python:3.10-slim
docker pull nginx:stable-alpine
docker pull metabase/metabase:v0.52.x

# Reconstruire les images MSPR-601
make build

echo "Mise à jour des images terminée"
```

## 📈 Métriques et Rapports

### Rapport de Performance
```bash
#!/bin/bash
# performance_report.sh

echo "=== Rapport de Performance MSPR-601 ==="
echo "Date: $(date)"
echo ""

# Utilisation des ressources
echo "📊 UTILISATION DES RESSOURCES"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
echo ""

# Performance de la base de données
echo "🗄️ PERFORMANCE BASE DE DONNÉES"
docker exec mspr601_postgres_fr psql -U mspr502 -d mspr502 -c "
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_tuples
FROM pg_stat_user_tables
ORDER BY n_tup_ins DESC;
"
echo ""

# Logs d'erreur
echo "⚠️ ERREURS RÉCENTES"
docker logs --since 24h mspr601_api_ia_flask_fr 2>&1 | grep -i error | wc -l
echo "erreurs dans les dernières 24h"
echo ""

# Disponibilité des services
echo "✅ DISPONIBILITÉ DES SERVICES"
curl -s -o /dev/null -w "%{http_code}" http://localhost:5001 && echo " - Frontend OK" || echo " - Frontend ERREUR"
curl -s -o /dev/null -w "%{http_code}" http://localhost:6001/health && echo " - API OK" || echo " - API ERREUR"
echo ""
```

### Script de Surveillance Continue
```bash
#!/bin/bash
# continuous_monitoring.sh

while true; do
    echo "=== Surveillance MSPR-601 - $(date) ==="
    
    # Vérifier les services
    if ! docker ps | grep -q mspr601_postgres_fr; then
        echo "ALERTE: PostgreSQL arrêté!"
        # Notification
    fi
    
    # Vérifier les ressources
    MEMORY=$(docker stats --no-stream --format "{{.MemPerc}}" mspr601_postgres_fr | sed 's/%//')
    if (( $(echo "$MEMORY > 85" | bc -l) )); then
        echo "ALERTE: Mémoire élevée: ${MEMORY}%"
    fi
    
    # Attendre 5 minutes
    sleep 300
done
```

## 🔄 Procédures de Sauvegarde

### Sauvegarde Automatique
```bash
#!/bin/bash
# auto_backup.sh

BACKUP_DIR="/backups/auto"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p $BACKUP_DIR

# Sauvegarde de la base de données
docker exec mspr601_postgres_fr pg_dump -U mspr502 mspr502 | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Sauvegarde des configurations
tar czf $BACKUP_DIR/config_$DATE.tar.gz docker-compose.*.yml Makefile

# Nettoyage des anciennes sauvegardes
find $BACKUP_DIR -name "*.gz" -mtime +$RETENTION_DAYS -delete

echo "Sauvegarde automatique terminée: $DATE"
```

### Restauration
```bash
#!/bin/bash
# restore.sh

BACKUP_FILE=$1
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

echo "Restauration depuis: $BACKUP_FILE"

# Arrêter les services
make down_fr

# Restaurer la base de données
gunzip -c $BACKUP_FILE | docker exec -i mspr601_postgres_fr psql -U mspr502 mspr502

# Redémarrer les services
make up_fr

echo "Restauration terminée"
``` 