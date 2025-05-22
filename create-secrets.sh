#!/bin/bash

# Script pour créer les secrets Docker pour le déploiement Swarm
# Ce script doit être exécuté sur le nœud manager du cluster Swarm

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Création des secrets Docker pour Odoo 18 avec Swarm${NC}"

# Vérifier si Docker est en mode Swarm
if ! docker info | grep -q "Swarm: active"; then
  echo -e "${RED}Docker n'est pas en mode Swarm. Veuillez initialiser Swarm avec 'docker swarm init'${NC}"
  exit 1
fi

# Charger les variables d'environnement si le fichier .env existe
if [ -f .env ]; then
  echo -e "${YELLOW}Chargement des variables depuis le fichier .env...${NC}"
  source .env
else
  echo -e "${RED}Fichier .env non trouvé. Veuillez exécuter setup.sh d'abord.${NC}"
  exit 1
fi

# Créer les secrets Docker
echo -e "${YELLOW}Création des secrets Docker...${NC}"

# Secret pour l'utilisateur PostgreSQL
echo "${POSTGRES_USER}" | docker secret create postgres_user -
echo -e "${GREEN}Secret 'postgres_user' créé avec succès${NC}"

# Secret pour le mot de passe PostgreSQL
echo "${POSTGRES_PASSWORD}" | docker secret create postgres_password -
echo -e "${GREEN}Secret 'postgres_password' créé avec succès${NC}"

# Secret pour l'email PgAdmin
echo "${PGADMIN_DEFAULT_EMAIL}" | docker secret create pgadmin_email -
echo -e "${GREEN}Secret 'pgadmin_email' créé avec succès${NC}"

# Secret pour le mot de passe PgAdmin
echo "${PGADMIN_DEFAULT_PASSWORD}" | docker secret create pgadmin_password -
echo -e "${GREEN}Secret 'pgadmin_password' créé avec succès${NC}"

# Secret pour le mot de passe admin d'Odoo
# Extraire le mot de passe admin du fichier odoo.conf s'il existe
if [ -f odoo-data/etc/odoo.conf ]; then
  ADMIN_PASSWORD=$(grep -oP 'admin_passwd = \K.*' odoo-data/etc/odoo.conf)
  if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD="admin_password"
    echo -e "${YELLOW}Mot de passe admin non trouvé dans odoo.conf, utilisation de la valeur par défaut${NC}"
  fi
else
  ADMIN_PASSWORD="admin_password"
  echo -e "${YELLOW}Fichier odoo.conf non trouvé, utilisation du mot de passe admin par défaut${NC}"
fi

echo "${ADMIN_PASSWORD}" | docker secret create odoo_admin_password -
echo -e "${GREEN}Secret 'odoo_admin_password' créé avec succès${NC}"

# Créer la configuration Docker pour odoo.conf
echo -e "${YELLOW}Création de la configuration Docker pour odoo.conf...${NC}"

# Vérifier si le fichier odoo.conf existe
if [ -f odoo-data/etc/odoo.conf ]; then
  docker config create odoo_conf odoo-data/etc/odoo.conf
  echo -e "${GREEN}Configuration 'odoo_conf' créée avec succès${NC}"
else
  # Créer un fichier odoo.conf temporaire
  echo -e "${YELLOW}Fichier odoo.conf non trouvé, création d'un fichier temporaire...${NC}"
  cat > /tmp/odoo.conf << EOF
[options]
# Configuration générale d'Odoo
addons_path = /mnt/extra-addons
data_dir = /var/lib/odoo/filestore

# Sécurité
admin_passwd = ${ADMIN_PASSWORD}

# Performance
workers = 2
max_cron_threads = 1

# Mise en réseau
proxy_mode = True

# Logging
log_level = info
logfile = /var/log/odoo/odoo.log

# Autres options
list_db = True
EOF

  docker config create odoo_conf /tmp/odoo.conf
  echo -e "${GREEN}Configuration 'odoo_conf' créée avec succès${NC}"
  rm /tmp/odoo.conf
fi

echo -e "${GREEN}Tous les secrets et configurations Docker ont été créés avec succès !${NC}"
echo -e "${YELLOW}Vous pouvez maintenant déployer la stack Odoo avec:${NC} docker stack deploy -c docker-stack.yml odoo_stack"
