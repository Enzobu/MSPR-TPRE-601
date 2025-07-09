# Troubleshooting - MSPR-TPRE-601

## 📋 Vue d'ensemble

Ce document fournit un guide complet pour diagnostiquer et résoudre les problèmes courants dans le système MSPR-TPRE-601.

## 🔍 Diagnostic Système

### Vérification de l'État Général
```bash
#!/bin/bash
# diagnostic_system.sh

echo "=== Diagnostic Système MSPR-601 ==="
echo "Date: $(date)"
echo ""

# 1. Vérifier Docker
echo "1. État de Docker:"
docker --version
docker-compose --version
docker info | grep -E "(Containers|Images|Storage Driver)"
echo ""

# 2. Vérifier les conteneurs
echo "2. Conteneurs en cours d'exécution:"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# 3. Vérifier les ressources
echo "3. Utilisation des ressources:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
echo ""

# 4. Vérifier l'espace disque
echo "4. Espace disque:"
df -h
echo ""

# 5. Vérifier les ports
echo "5. Ports utilisés:"
netstat -tulpn | grep -E "(5001|5002|5003|6001|6002|6003|5431|5433|7081|7082|7083|3001|3003)"
echo ""

echo "=== Diagnostic terminé ==="
```

### Script de Diagnostic Avancé
```bash
#!/bin/bash
# advanced_diagnostic.sh

echo "=== Diagnostic Avancé MSPR-601 ==="

# Vérifier les logs d'erreur
echo "📋 LOGS D'ERREUR RÉCENTS"
for container in $(docker ps --format "{{.Names}}"); do
    echo "--- $container ---"
    docker logs --tail 20 $container 2>&1 | grep -i error | tail -5
done
echo ""

# Vérifier les connexions réseau
echo "🌐 CONNEXIONS RÉSEAU"
docker network ls
docker network inspect bridge | grep -A 10 "Containers"
echo ""

# Vérifier les volumes
echo "💾 VOLUMES"
docker volume ls
docker volume inspect mspr601_pg-data 2>/dev/null | grep -E "(Mountpoint|Status)"
echo ""

# Vérifier les images
echo "🖼️ IMAGES"
docker images | grep mspr-601
echo ""

# Vérifier les processus système
echo "⚙️ PROCESSUS SYSTÈME"
ps aux | grep -E "(docker|postgres)" | head -10
echo ""
```

## 🚨 Problèmes Courants

### 1. Conteneurs qui ne démarrent pas

#### Symptômes
- Conteneurs en statut "Exited"
- Erreurs dans les logs Docker
- Services non accessibles

#### Diagnostic
```bash
# Vérifier les logs du conteneur
docker logs mspr601_postgres_fr

# Vérifier les ressources disponibles
docker system df
free -h
df -h

# Vérifier les conflits de ports
netstat -tulpn | grep :5431
```

#### Solutions
```bash
# Solution 1: Nettoyer et redémarrer
docker system prune -f
make down_fr
make up_fr

# Solution 2: Reconstruire les images
make build_fr

# Solution 3: Vérifier les variables d'environnement
docker compose -f docker-compose.fr.yml config
```

### 2. Problèmes de Connexion Base de Données

#### Symptômes
- Erreurs "Connection refused"
- Timeout de connexion
- API ne peut pas se connecter à PostgreSQL

#### Diagnostic
```bash
# Vérifier si PostgreSQL est en cours d'exécution
docker ps | grep postgres

# Tester la connexion PostgreSQL
docker exec mspr601_postgres_fr pg_isready -U mspr502

# Vérifier les logs PostgreSQL
docker logs mspr601_postgres_fr | tail -20

# Tester la connexion depuis l'API
docker exec mspr601_api_ia_flask_fr python -c "
import psycopg2
try:
    conn = psycopg2.connect(
        host='postgres_fr',
        database='mspr502',
        user='mspr502',
        password='s5t4v5'
    )
    print('Connexion réussie')
    conn.close()
except Exception as e:
    print(f'Erreur: {e}')
"
```

#### Solutions
```bash
# Solution 1: Redémarrer PostgreSQL
docker restart mspr601_postgres_fr

# Solution 2: Vérifier les variables d'environnement
docker exec mspr601_api_ia_flask_fr env | grep DB_

# Solution 3: Reconstruire le conteneur PostgreSQL
docker compose -f docker-compose.fr.yml build --no-cache postgres_fr
docker compose -f docker-compose.fr.yml up -d postgres_fr
```

### 3. Problèmes de Performance

#### Symptômes
- Réponses lentes de l'API
- Interface utilisateur lente
- Utilisation élevée de CPU/mémoire

#### Diagnostic
```bash
# Vérifier l'utilisation des ressources
docker stats --no-stream

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

# Vérifier les requêtes lentes
docker exec mspr601_postgres_fr psql -U mspr502 -d mspr502 -c "
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
"
```

#### Solutions
```bash
# Solution 1: Optimiser PostgreSQL
docker exec mspr601_postgres_fr psql -U mspr502 -d mspr502 -c "
VACUUM ANALYZE;
REINDEX DATABASE mspr502;
"

# Solution 2: Ajuster les ressources
# Modifier docker-compose.fr.yml pour augmenter les limites

# Solution 3: Nettoyer les données anciennes
docker exec mspr601_postgres_fr psql -U mspr502 -d mspr502 -c "
DELETE FROM statement WHERE _date < CURRENT_DATE - INTERVAL '1 year';
DELETE FROM prediction WHERE ds < CURRENT_DATE - INTERVAL '6 months';
"
```

### 4. Problèmes de Réseau

#### Symptômes
- Services ne peuvent pas communiquer
- Erreurs de connexion entre conteneurs
- Ports non accessibles

#### Diagnostic
```bash
# Vérifier les réseaux Docker
docker network ls
docker network inspect bridge

# Tester la connectivité entre conteneurs
docker exec mspr601_api_ia_flask_fr ping postgres_fr
docker exec mspr601_api_ia_flask_fr curl -f http://postgres_fr:5432

# Vérifier les ports exposés
docker port mspr601_front_fr
docker port mspr601_api_ia_flask_fr
docker port mspr601_postgres_fr
```

#### Solutions
```bash
# Solution 1: Recréer le réseau
docker network prune -f
make down_fr
make up_fr

# Solution 2: Vérifier les dépendances dans docker-compose
# S'assurer que les services dépendants sont correctement configurés

# Solution 3: Utiliser le réseau host si nécessaire
# Modifier docker-compose.fr.yml pour utiliser network_mode: host
```

### 5. Problèmes de Déploiement

#### Symptômes
- Échec des GitHub Actions
- Déploiement incomplet
- Services non mis à jour

#### Diagnostic
```bash
# Vérifier les logs GitHub Actions
# Accessible via l'interface GitHub

# Vérifier l'état du serveur distant
ssh user@server "cd ~/apps/mspr-tpre-601 && git status"

# Vérifier les permissions SSH
ssh -T git@github.com

# Vérifier les secrets GitHub
# Vérifier dans Settings > Secrets and variables > Actions
```

#### Solutions
```bash
# Solution 1: Déploiement manuel
ssh user@server
cd ~/apps/mspr-tpre-601
git pull origin main
make down_fr
make up_fr

# Solution 2: Vérifier les clés SSH
ssh-keygen -t rsa -b 4096 -C "deployment"
ssh-copy-id -i ~/.ssh/id_rsa.pub user@server

# Solution 3: Rollback manuel
git checkout HEAD~1
make down_fr
make up_fr
```

## 🔧 Outils de Diagnostic

### Script de Diagnostic Complet
```bash
#!/bin/bash
# complete_diagnostic.sh

echo "=== Diagnostic Complet MSPR-601 ==="
echo "Date: $(date)"
echo ""

# Informations système
echo "📊 INFORMATIONS SYSTÈME"
echo "OS: $(uname -a)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"
echo ""

# État des conteneurs
echo "🐳 ÉTAT DES CONTENEURS"
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"
echo ""

# Utilisation des ressources
echo "💻 UTILISATION DES RESSOURCES"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
echo ""

# Logs d'erreur récents
echo "⚠️ ERREURS RÉCENTES"
for container in $(docker ps --format "{{.Names}}"); do
    echo "--- $container ---"
    docker logs --since 1h $container 2>&1 | grep -i error | tail -3
done
echo ""

# Tests de connectivité
echo "🌐 TESTS DE CONNECTIVITÉ"
echo "Frontend: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:5001 || echo "ERREUR")"
echo "API: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:6001/health || echo "ERREUR")"
echo "PostgreSQL: $(docker exec mspr601_postgres_fr pg_isready -U mspr502 && echo "OK" || echo "ERREUR")"
echo ""

# État de la base de données
echo "🗄️ ÉTAT DE LA BASE DE DONNÉES"
docker exec mspr601_postgres_fr psql -U mspr502 -d mspr502 -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    n_live_tup as rows
FROM pg_tables
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
LIMIT 5;
" 2>/dev/null || echo "Impossible de se connecter à la base de données"
echo ""

echo "=== Diagnostic terminé ==="
```

### Script de Récupération Automatique
```bash
#!/bin/bash
# auto_recovery.sh

echo "=== Récupération Automatique MSPR-601 ==="

# Fonction de vérification
check_service() {
    local service=$1
    local port=$2
    
    if ! docker ps | grep -q $service; then
        echo "❌ $service n'est pas en cours d'exécution"
        return 1
    fi
    
    if [ ! -z "$port" ]; then
        if ! curl -s -f http://localhost:$port > /dev/null 2>&1; then
            echo "❌ $service ne répond pas sur le port $port"
            return 1
        fi
    fi
    
    echo "✅ $service fonctionne correctement"
    return 0
}

# Vérifier et récupérer les services
echo "Vérification des services..."

# PostgreSQL
if ! check_service mspr601_postgres_fr; then
    echo "Redémarrage de PostgreSQL..."
    docker restart mspr601_postgres_fr
    sleep 10
fi

# API
if ! check_service mspr601_api_ia_flask_fr 6001; then
    echo "Redémarrage de l'API..."
    docker restart mspr601_api_ia_flask_fr
    sleep 5
fi

# Frontend
if ! check_service mspr601_front_fr 5001; then
    echo "Redémarrage du Frontend..."
    docker restart mspr601_front_fr
    sleep 5
fi

echo "Récupération terminée"
```

## 📋 Checklist de Diagnostic

### Vérifications de Base
- [ ] Docker est installé et fonctionne
- [ ] Docker Compose est installé
- [ ] Les ports requis sont disponibles
- [ ] L'espace disque est suffisant
- [ ] La mémoire est suffisante

### Vérifications des Services
- [ ] Tous les conteneurs sont en cours d'exécution
- [ ] PostgreSQL répond aux health checks
- [ ] L'API est accessible
- [ ] Le frontend est accessible
- [ ] PgAdmin est accessible

### Vérifications de la Base de Données
- [ ] Connexion PostgreSQL réussie
- [ ] Tables existent et sont accessibles
- [ ] Permissions utilisateur correctes
- [ ] Pas d'erreurs dans les logs PostgreSQL

### Vérifications Réseau
- [ ] Communication inter-conteneurs
- [ ] Ports exposés correctement
- [ ] Pas de conflits de ports
- [ ] DNS résolution fonctionne

## 🆘 Procédures d'Urgence

### Service Critique Arrêté
```bash
# Procédure d'urgence pour service critique
echo "🚨 SERVICE CRITIQUE ARRÊTÉ - PROCÉDURE D'URGENCE"

# 1. Arrêter tous les services
make down_fr

# 2. Nettoyer complètement
docker system prune -a -f
docker volume prune -f

# 3. Redémarrer avec reconstruction
make build_fr

# 4. Vérification
sleep 30
docker ps
curl -f http://localhost:5001 || echo "ERREUR CRITIQUE"
```

### Perte de Données
```bash
# Procédure de récupération de données
echo "💾 RÉCUPÉRATION DE DONNÉES"

# 1. Arrêter les services
make down_fr

# 2. Restaurer depuis la dernière sauvegarde
if [ -f "/backups/latest_backup.sql" ]; then
    docker exec -i mspr601_postgres_fr psql -U mspr502 mspr502 < /backups/latest_backup.sql
    echo "Données restaurées"
else
    echo "Aucune sauvegarde trouvée"
fi

# 3. Redémarrer
make up_fr
```

### Problème de Sécurité
```bash
# Procédure de sécurité
echo "🔒 PROBLÈME DE SÉCURITÉ"

# 1. Arrêter tous les services
make down

# 2. Changer les mots de passe
# Modifier les variables d'environnement

# 3. Vérifier les logs de sécurité
docker logs --since 24h mspr601_api_ia_flask_fr | grep -i "security\|auth\|login"

# 4. Redémarrer avec nouvelles configurations
make up
``` 