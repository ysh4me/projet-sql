FROM postgres:16-alpine

# Copie des scripts SQL et du script d'initialisation
COPY init_database.sql /docker-entrypoint-initdb.d/init_database.sql
COPY entrypoint.sh /entrypoint.sh

# Donne les droits d'exécution au script d'entrée
RUN chmod +x /entrypoint.sh

# Définition de l'entrypoint
ENTRYPOINT ["/entrypoint.sh"]