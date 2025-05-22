#!/bin/bash

# Script pour créer les fichiers secrets pour Docker Compose
# Ce script doit être exécuté avant de lancer docker-compose

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Création des fichiers secrets pour Odoo 18 avec Docker Compose${NC}"

# Créer le répertoire des secrets s'il n'existe pas
mkdir -p ./secrets

# Charger les variables d'environnement si le fichier .env existe
if [ -f .env ]; then
  echo -e "${YELLOW}Chargement des variables depuis le fichier .env...${NC}"
  source .env
else
  echo -e "${RED}Fichier .env non trouvé. Veuillez exécuter setup.sh d'abord.${NC}"
  exit 1
fi

# Créer les fichiers secrets
echo -e "${YELLOW}Création des fichiers secrets...${NC}"

# Secret pour l'utilisateur PostgreSQL
echo "${POSTGRES_USER}" > ./secrets/postgres_user.txt
echo -e "${GREEN}Secret 'postgres_user.txt' créé avec succès${NC}"

# Secret pour le mot de passe PostgreSQL
echo "${POSTGRES_PASSWORD}" > ./secrets/postgres_password.txt
echo -e "${GREEN}Secret 'postgres_password.txt' créé avec succès${NC}"

# Secret pour l'email PgAdmin
echo "${PGADMIN_DEFAULT_EMAIL}" > ./secrets/pgadmin_email.txt
echo -e "${GREEN}Secret 'pgadmin_email.txt' créé avec succès${NC}"

# Secret pour le mot de passe PgAdmin
echo "${PGADMIN_DEFAULT_PASSWORD}" > ./secrets/pgadmin_password.txt
echo -e "${GREEN}Secret 'pgadmin_password.txt' créé avec succès${NC}"

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

echo "${ADMIN_PASSWORD}" > ./secrets/odoo_admin_password.txt
echo -e "${GREEN}Secret 'odoo_admin_password.txt' créé avec succès${NC}"

echo -e "${GREEN}Tous les fichiers secrets ont été créés avec succès !${NC}"
echo -e "${YELLOW}Vous pouvez maintenant lancer Odoo avec:${NC} docker-compose up -d"
