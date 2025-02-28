#!/bin/bash
set -e

echo "Démarrage de PostgreSQL..."
docker-entrypoint.sh postgres &

# Attendre que PostgreSQL soit prêt
echo "Attente de la connexion à PostgreSQL..."
until pg_isready -h localhost -p 5432 -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  sleep 2
done

echo "PostgreSQL est prêt !"

# Vérifier si la base de données existe déjà
DB_EXISTS=$(psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$POSTGRES_DB'")

if [ -z "$DB_EXISTS" ]; then
  echo "Création de la base de données '$POSTGRES_DB'..."
  psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $POSTGRES_DB;"

  echo "Exécution du script d'initialisation..."
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/init_database.sql
else
  echo "La base de données '$POSTGRES_DB' existe déjà, aucune réinitialisation nécessaire."
fi

echo "PostgreSQL est prêt."

# Maintenir PostgreSQL au premier plan
wait