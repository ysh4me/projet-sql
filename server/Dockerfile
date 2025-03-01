FROM postgres:16-alpine

# On copie les scripts AILLEURS que /docker-entrypoint-initdb.d/
# pour éviter qu'ils ne soient exécutés automatiquement et dans le désordre
COPY 01-init_database.sql /docker-entrypoint-initdb.d/

# Copie du script entrypoint personnalisé
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# On remplace l'entrypoint officiel par le nôtre
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Commande par défaut du conteneur
CMD ["postgres"]