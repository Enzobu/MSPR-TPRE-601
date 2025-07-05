# MSPR-TPRE-601 – Déploiement multi-cluster

Ce projet est composé de 3 clusters indépendants : France, Suisse et États-Unis. Chaque cluster possède ses propres services (front, API IA, ETL, etc.) et un fichier `docker-compose` dédié.

---

## 🚀 Déploiement automatique via GitHub Actions

Chaque cluster est déployé automatiquement à chaque `push` sur la branche `main`, selon les fichiers modifiés.

### 🔧 Pré-requis

Avant de pouvoir déployer, assurez-vous que :

- Le projet est **cloné** sur le serveur distant (ex: `~/apps/mspr-tpre-601`)
- Une **clé SSH privée** est ajoutée dans GitHub (Secrets)
- La **clé publique** correspondante est installée sur chaque serveur dans `~/.ssh/authorized_keys`

---

## 🇫🇷 Cluster France

- **Fichier compose** : `docker-compose.fr.yml`
- **Dossier source** : `fr/`
- **Workflow GitHub** : `.github/workflows/deploy-fr.yml`

### Secrets requis :
| Nom du secret      | Description                        |
|--------------------|------------------------------------|
| `FR_HOST`          | IP ou domaine du serveur           |
| `FR_USER`          | Utilisateur SSH (ex: ubuntu)       |
| `FR_SSH_KEY`       | Clé privée SSH (format PEM)        |

---

## 🇨🇭 Cluster Suisse

- **Fichier compose** : `docker-compose.ch.yml`
- **Dossier source** : `ch/`
- **Workflow GitHub** : `.github/workflows/deploy-ch.yml`

### Secrets requis :
| Nom du secret      | Description                        |
|--------------------|------------------------------------|
| `CH_HOST`          | IP ou domaine du serveur           |
| `CH_USER`          | Utilisateur SSH                    |
| `CH_SSH_KEY`       | Clé privée SSH                     |

---

## 🇺🇸 Cluster États-Unis

- **Fichier compose** : `docker-compose.us.yml`
- **Dossier source** : `us/`
- **Workflow GitHub** : `.github/workflows/deploy-us.yml`

### Secrets requis :
| Nom du secret      | Description                        |
|--------------------|------------------------------------|
| `US_HOST`          | IP ou domaine du serveur           |
| `US_USER`          | Utilisateur SSH                    |
| `US_SSH_KEY`       | Clé privée SSH                     |

---

## 🔁 Déploiement manuel (si nécessaire)

Depuis GitHub, dans l'onglet **Actions**, vous pouvez relancer un déploiement manuellement en cliquant sur le workflow souhaité (deploy-fr, deploy-ch, deploy-us).

---

## 🐳 Commandes utiles (local)

```bash
# Lancer un cluster local
docker compose -f docker-compose.fr.yml up -d --build

# Arrêter un cluster
docker compose -f docker-compose.fr.yml down

# Lister les logs d’un service
docker logs -f nom_du_conteneur
.