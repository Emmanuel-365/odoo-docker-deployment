#!/bin/bash

# Script de configuration pour le déploiement d'Odoo 18 avec Docker
# Ce script prépare l'environnement pour le déploiement d'Odoo

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Installation d'Odoo 18 avec Docker${NC}"
echo -e "${YELLOW}Création des répertoires nécessaires...${NC}"

# Création des répertoires
mkdir -p odoo-data/addons
mkdir -p odoo-data/etc

# Copie des fichiers de configuration
if [ ! -f odoo-data/etc/odoo.conf ]; then
    echo -e "${YELLOW}Création du fichier de configuration odoo.conf...${NC}"
    cp odoo.conf.example odoo-data/etc/odoo.conf
    echo -e "${GREEN}Fichier odoo.conf créé avec succès${NC}"
else
    echo -e "${YELLOW}Le fichier odoo.conf existe déjà, conservation de la configuration actuelle${NC}"
fi

# Création du fichier d'environnement
if [ ! -f .env ]; then
    echo -e "${YELLOW}Création du fichier d'environnement .env...${NC}"
    cp .env.example .env
    
    # Génération de mots de passe aléatoires
    PG_PASSWORD=$(openssl rand -base64 12)
    PGADMIN_PASSWORD=$(openssl rand -base64 12)
    
    # Remplacer les valeurs par défaut par des mots de passe aléatoires
    sed -i "s/votre_mot_de_passe_securise/$PG_PASSWORD/g" .env
    sed -i "s/votre_mot_de_passe_securise_pgadmin/$PGADMIN_PASSWORD/g" .env
    
    echo -e "${GREEN}Fichier .env créé avec des mots de passe aléatoires${NC}"
    echo -e "${YELLOW}⚠️  IMPORTANT: Notez vos mots de passe ou consultez le fichier .env${NC}"
else
    echo -e "${YELLOW}Le fichier .env existe déjà, conservation des variables actuelles${NC}"
fi

echo -e "${GREEN}Configuration terminée !${NC}"
echo -e "${YELLOW}Pour lancer Odoo, exécutez:${NC} docker-compose up -d"
echo -e "${YELLOW}Pour accéder à Odoo:${NC} http://localhost:8069"
echo -e "${YELLOW}Pour accéder à pgAdmin:${NC} http://localhost:5050"