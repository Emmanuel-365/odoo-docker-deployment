# Odoo Docker Deployment

Ce dépôt contient les fichiers nécessaires pour déployer Odoo 18 avec PostgreSQL et PgAdmin en utilisant Docker Compose et Docker Swarm.

## Prérequis

- Docker et Docker Compose installés
- Pour la partie Swarm : un cluster Docker Swarm initialisé avec au moins 2 nœuds

## Structure du projet

```
odoo-docker-deployment/
├── docker-compose.yml      # Configuration pour Docker Compose
├── docker-stack.yml        # Configuration pour Docker Swarm
├── .env.example            # Exemple de fichier de variables d'environnement
├── odoo.conf.example       # Exemple de fichier de configuration Odoo
├── setup.sh                # Script d'initialisation de l'environnement
├── setup-secrets.sh        # Script de création des secrets pour Docker Compose
└── create-secrets.sh       # Script de création des secrets pour Docker Swarm
```

## Partie 1 : Déploiement avec Docker Compose

### Étape 1 : Initialisation de l'environnement

1. Cloner ce dépôt :
   ```bash
   git clone https://github.com/Emmanuel-365/odoo-docker-deployment.git
   cd odoo-docker-deployment
   ```

2. Exécuter le script d'initialisation :
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```
   Ce script crée les répertoires nécessaires, copie les fichiers de configuration et génère un fichier `.env` avec des mots de passe aléatoires.

3. Créer les fichiers secrets :
   ```bash
   chmod +x setup-secrets.sh
   ./setup-secrets.sh
   ```
   Ce script crée les fichiers secrets nécessaires pour Docker Compose à partir des variables du fichier `.env`.

### Étape 2 : Démarrage des services

Lancer les services avec Docker Compose :
```bash
docker-compose up -d
```

### Étape 3 : Accès aux services

- **Odoo** : http://localhost:8069
- **PgAdmin** : http://localhost:5050
  - Email : admin@example.com (ou la valeur définie dans `.env`)
  - Mot de passe : celui défini dans `.env`

## Partie 2 : Déploiement avec Docker Swarm

### Étape 1 : Initialisation du cluster Swarm

Si vous n'avez pas encore initialisé votre cluster Swarm :

```bash
# Sur le nœud manager
docker swarm init --advertise-addr <IP_MANAGER>

# Sur les nœuds workers (utiliser la commande fournie par l'initialisation)
docker swarm join --token <TOKEN> <IP_MANAGER>:2377
```

### Étape 2 : Création des secrets et configurations Docker

Sur le nœud manager, exécuter le script de création des secrets :

```bash
chmod +x create-secrets.sh
./create-secrets.sh
```

Ce script crée les secrets Docker et la configuration pour Odoo à partir des variables du fichier `.env`.

### Étape 3 : Déploiement de la stack

Sur le nœud manager, déployer la stack :

```bash
docker stack deploy -c docker-stack.yml odoo_stack
```

### Étape 4 : Vérification du déploiement

```bash
docker stack services odoo_stack
docker stack ps odoo_stack
```

### Étape 5 : Accès aux services

- **Odoo** : http://<IP_MANAGER>:8069
- **PgAdmin** : http://<IP_MANAGER>:5050
  - Email : admin@example.com (ou la valeur définie dans `.env`)
  - Mot de passe : celui défini dans `.env`

## Caractéristiques de la configuration

Cette configuration respecte les exigences suivantes :

1. **Services distincts** :
   - odoo (serveur applicatif)
   - postgres (base de données)
   - pgadmin (interface d'administration de PostgreSQL)

2. **Spécifications pour chaque service** :
   - container_name : nom explicite du conteneur
   - hostname : nom réseau interne
   - ports : ports exposés
   - image : image Docker officielle
   - networks : intégration à un réseau Docker privé
   - volumes : volume persistant selon le service

3. **Redémarrage automatique et gestion des dépendances** :
   - Utilisation de l'option 'restart: always' pour chaque service
   - Utilisation de l'option 'depends_on' pour que PostgreSQL soit lancé avant Odoo

4. **Gestion de la sécurité** :
   - Utilisation de secrets pour configurer les accès d'authentification
   - Utilisation du fichier .env pour les variables d'environnement non sensibles

5. **Volumes persistants pour Odoo** :
   - /var/lib/odoo/filestore : stockage des pièces jointes
   - /mnt/extra-addons : modules personnalisés

6. **Mise en cluster avec Docker Swarm** :
   - Configuration adaptée pour le déploiement en stack Swarm
   - Support pour un cluster d'au moins 2 nœuds

## Personnalisation

Vous pouvez personnaliser le déploiement en modifiant les fichiers suivants :

- `.env` : variables d'environnement pour les services
- `odoo.conf` : configuration spécifique d'Odoo
- `docker-compose.yml` ou `docker-stack.yml` : configuration des services Docker

## Maintenance

### Sauvegarde de la base de données

```bash
# Pour Docker Compose
docker-compose exec postgres pg_dump -U odoo postgres > odoo_backup.sql

# Pour Docker Swarm
POSTGRES_CONTAINER=$(docker ps -q -f name=postgres)
docker exec $POSTGRES_CONTAINER pg_dump -U odoo postgres > odoo_backup.sql
```

### Restauration de la base de données

```bash
# Pour Docker Compose
cat odoo_backup.sql | docker-compose exec -T postgres psql -U odoo -d postgres

# Pour Docker Swarm
POSTGRES_CONTAINER=$(docker ps -q -f name=postgres)
docker cp odoo_backup.sql $POSTGRES_CONTAINER:/tmp/
docker exec $POSTGRES_CONTAINER psql -U odoo -d postgres -f /tmp/odoo_backup.sql
```

### Mise à jour des services

```bash
# Pour Docker Compose
docker-compose pull
docker-compose up -d

# Pour Docker Swarm
docker service update --image odoo:latest odoo_stack_odoo
```

## Sécurité

Cette configuration utilise des secrets Docker pour sécuriser les informations sensibles :

- Pour Docker Compose : les secrets sont stockés dans des fichiers dans le répertoire `./secrets/`
- Pour Docker Swarm : les secrets sont gérés par Docker Swarm et injectés dans les conteneurs

Ne partagez jamais vos fichiers `.env` ou le contenu du répertoire `./secrets/` dans des dépôts publics.
