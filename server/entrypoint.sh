#!/bin/bash
set -e

echo "Démarrage du conteneur Postgres..."
# Lance l’entrypoint officiel en arrière-plan
docker-entrypoint.sh postgres &

# Attendre que Postgres soit prêt
echo "Attente de la connexion à PostgreSQL..."
until pg_isready -h localhost -p 5432 -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  sleep 2
done
echo "PostgreSQL est prêt !"

# Vérifier si la base existe déjà
DB_EXISTS=$(psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$POSTGRES_DB'")

if [ -z "$DB_EXISTS" ]; then
  echo "Création de la base de données '$POSTGRES_DB'..."
  psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $POSTGRES_DB;"

  echo "Exécution du script d'initialisation (init_database.sql)..."
  psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /tmp/init_database.sql
else
  echo "La base '$POSTGRES_DB' existe déjà. Pas de réinitialisation."
fi

echo "PostgreSQL est prêt."
# Maintenir Postgres au premier plan
wait