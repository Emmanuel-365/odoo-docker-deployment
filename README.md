# 🚀 Odoo 18 Docker Deployment Guide

[![Odoo Version](https://img.shields.io/badge/Odoo-18-success)](https://www.odoo.com/)
[![Docker](https://img.shields.io/badge/Docker-20.10.0+-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Ce repository contient des configurations Docker pour déployer Odoo 18 facilement et efficacement, que ce soit pour le développement, les tests ou la production. Deux configurations sont proposées : une simple avec Docker Compose et une avancée avec Docker Swarm pour la haute disponibilité.

## 📋 Prérequis

- Docker Engine v20.10.0+
- Docker Compose v2.0.0+
- Pour le déploiement Swarm : au moins deux machines (physiques ou virtuelles)
- Accès à Internet pour télécharger les images Docker

## 🏗️ Structure du Repository

```
odoo18-docker/
├── docker-compose.yml     # Configuration pour déploiement simple
├── docker-stack.yml       # Configuration pour déploiement Swarm (haute disponibilité)
├── .env.example           # Modèle pour les variables d'environnement
├── odoo-data/             # Contient les données d'Odoo
│   ├── addons/            # Pour les modules personnalisés
│   └── etc/               # Fichiers de configuration
│       └── odoo.conf      # Configuration principale d'Odoo
└── README.md              # Ce fichier
```

## 🚀 Déploiement Simple (Docker Compose)

Idéal pour le développement, les tests ou les petites entreprises.

### Installation rapide

1. Clonez ce repository :
   ```bash
   git clone https://github.com/Emmanuel-365/odoo18-docker.git
   cd odoo18-docker
   ```

2. Créez les dossiers nécessaires et configurez l'environnement :
   ```bash
   mkdir -p odoo-data/addons odoo-data/etc
   cp odoo.conf.example odoo-data/etc/odoo.conf
   cp .env.example .env
   ```

3. Modifiez le fichier `.env` avec vos propres valeurs, particulièrement les mots de passe :
   ```bash
   nano .env
   ```

4. Lancez les conteneurs :
   ```bash
   docker-compose up -d
   ```

5. Accédez à Odoo via http://localhost:8069 et à pgAdmin via http://localhost:5050

### Services inclus

- **Odoo 18** : Système ERP/CRM complet (port 8069)
- **PostgreSQL 15** : Base de données pour stocker les données d'Odoo
- **pgAdmin 4** : Interface d'administration web pour PostgreSQL (port 5050)

## 🌐 Déploiement Avancé (Docker Swarm)

Pour les environnements de production nécessitant haute disponibilité et tolérance aux pannes.

### Configuration du cluster Swarm

1. Sur la machine manager :
   ```bash
   docker swarm init --advertise-addr <IP_DU_MANAGER>
   ```

2. Sur la/les machine(s) worker, exécutez la commande affichée par l'initialisation du Swarm.

3. Copiez les fichiers de configuration sur le manager :
   ```bash
   scp docker-stack.yml .env.example <USER>@<IP_DU_MANAGER>:~/odoo18-docker/
   ```

4. Sur le manager, configurez l'environnement :
   ```bash
   cp .env.example .env
   nano .env  # Modifiez avec vos propres valeurs
   ```

5. Déployez la stack Odoo :
   ```bash
   docker stack deploy -c docker-stack.yml odoo-stack
   ```

### Caractéristiques du déploiement Swarm

- **Haute disponibilité** : Plusieurs instances d'Odoo réparties sur différentes machines
- **Tolérance aux pannes** : Le service reste disponible même si une machine tombe en panne
- **Mise à jour sans interruption** : Les mises à jour se font sans arrêter le service

## 🔧 Configuration

### Configuration d'Odoo

Modifiez le fichier `odoo-data/etc/odoo.conf` pour personnaliser Odoo selon vos besoins. Exemple de configuration de base :

```ini
[options]
addons_path = /mnt/extra-addons
data_dir = /var/lib/odoo
admin_passwd = admin_password  # À changer pour la production !
```

### Modules personnalisés

Placez vos modules personnalisés dans le dossier `odoo-data/addons/` pour qu'ils soient automatiquement disponibles dans Odoo.

## 🛡️ Sécurité

Pour un environnement de production, n'oubliez pas de :

1. **Ne jamais commiter votre fichier `.env` dans Git** - il contient des informations sensibles
2. Utiliser des mots de passe forts dans votre fichier `.env`
3. Mettre en place HTTPS avec un certificat SSL
4. Configurer un pare-feu pour restreindre l'accès aux ports
5. Considérer l'utilisation d'un proxy inverse comme Nginx ou Traefik pour ajouter une couche de sécurité supplémentaire
6. Changer régulièrement les mots de passe et mettre à jour les images Docker

## 📊 Maintenance

### Sauvegarde de la base de données

```bash
docker exec -t $(docker ps -f name=postgres -q) pg_dump -U odoo postgres > backup_$(date +%Y%m%d).sql
```

### Restauration d'une sauvegarde

```bash
docker cp backup.sql $(docker ps -f name=postgres -q):/tmp/
docker exec -t $(docker ps -f name=postgres -q) psql -U odoo -d postgres -f /tmp/backup.sql
```

### Mise à jour d'Odoo

1. Modifiez la version de l'image dans `docker-compose.yml` ou `docker-stack.yml`
2. Redéployez avec `docker-compose up -d` ou `docker stack deploy -c docker-stack.yml odoo-stack`

## 🔍 Dépannage

### Consulter les logs

```bash
# Pour Docker Compose
docker-compose logs -f odoo

# Pour Docker Swarm
docker service logs odoo-stack_odoo
```

### Problèmes courants

- **Odoo ne démarre pas** : Vérifiez la connexion à PostgreSQL et les permissions des volumes
- **Erreurs de base de données** : Consultez les logs PostgreSQL pour identifier les problèmes
- **Modules non disponibles** : Vérifiez le chemin `addons_path` dans `odoo.conf`

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou soumettre une pull request.

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.