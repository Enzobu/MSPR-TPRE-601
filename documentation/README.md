# Documentation MSPR-TPRE-601 - Déploiement Multi-Cluster

## 📋 Vue d'ensemble

Ce projet implémente un système de déploiement multi-cluster pour une application de gestion de données épidémiologiques. L'architecture est conçue pour déployer trois clusters indépendants (France, Suisse, États-Unis) avec des services identiques mais isolés.

## 🏗️ Architecture Générale

```
MSPR-TPRE-601/
├── base/                    # Services communs à tous les clusters
│   ├── front/              # Interface utilisateur (Vue.js + Nginx)
│   ├── api_ia/             # API IA (Flask)
│   ├── ml/                 # Services Machine Learning (Spark)
│   ├── etl/                # Extraction, Transformation, Loading
│   └── postgres/           # Base de données PostgreSQL
├── fr/                     # Configuration spécifique France
├── ch/                     # Configuration spécifique Suisse
├── us/                     # Configuration spécifique États-Unis
├── docker-compose.fr.yml   # Orchestration France
├── docker-compose.ch.yml   # Orchestration Suisse
├── docker-compose.us.yml   # Orchestration États-Unis
└── .github/workflows/      # CI/CD GitHub Actions
```

## 🚀 Services Disponibles

### Services Communs (Tous Clusters)
- **Frontend** : Interface utilisateur Vue.js servie par Nginx
- **API IA** : API Flask pour l'intelligence artificielle
- **ML** : Services de Machine Learning avec Apache Spark
- **ETL** : Pipeline de données avec Spark
- **PostgreSQL** : Base de données principale
- **PgAdmin** : Interface d'administration PostgreSQL

### Services Spécifiques
- **France** : Metabase (BI)
- **États-Unis** : API Technique + Metabase (BI)

## 🌍 Clusters Disponibles

| Cluster | Port Frontend | Port API | Port DB | Port PgAdmin | Port Metabase |
|---------|---------------|----------|---------|--------------|---------------|
| France  | 5001         | 6001     | 5431    | 7081         | 3001          |
| Suisse  | 5002         | 6002     | -       | 7082         | -             |
| US      | 5003         | 6003     | 5433    | 7083         | 3003          |

## 📚 Documentation Détaillée

- [Architecture Technique](./architecture-technique.md) - Détails techniques de l'architecture
- [Services](./services.md) - Documentation des services individuels
- [Base de Données](./database.md) - Schéma et structure de données
- [Déploiement](./deployment.md) - Guide de déploiement et CI/CD
- [Configuration](./configuration.md) - Variables d'environnement et configuration
- [Maintenance](./maintenance.md) - Opérations de maintenance
- [Troubleshooting](./troubleshooting.md) - Résolution de problèmes

## 🛠️ Commandes Rapides

```bash
# Démarrage complet
make up

# Démarrage par cluster
make up_fr    # France
make up_ch    # Suisse  
make up_us    # États-Unis

# Arrêt complet
make down

# Reconstruction complète
make build

# Aide
make help
```

## 🔐 Accès par Défaut

- **PgAdmin** : admin@admin.com / s5t4v5
- **PostgreSQL** : mspr502 / s5t4v5
- **Base de données** : mspr502

## 📊 Monitoring

- **Logs** : `docker logs -f nom_conteneur`
- **Statut** : `docker ps`
- **Ressources** : `docker stats`

## 🔗 Liens Utiles

- [GitHub Actions](../.github/workflows/)
- [Makefile](../Makefile)
- [Architecture Originale](./architecture.md) 