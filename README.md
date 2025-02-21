# Requêtage SQL - Projet de gestion de transport public

---
## Lancement
### Lancer le service PostgreSQL
```sh
docker compose up -d
```

### Vérifier que la base tourne correctement
```sh
docker compose logs db
```

### Se connecter à PostgreSQL dans le conteneur
```sh
docker compose exec db psql -U postgres
```

---
## Structure du projet
`/init_database.sql` → Script SQL pour créer la base de données et ses tables
`/niveau_1/` → Contient les requêtes SQL pour le niveau 1
`/niveau_2/` → Contient les requêtes SQL pour le niveau 2
`/niveau_3/` → Contient les requêtes SQL pour le niveau 3
`/niveau_4/` → Contient les requêtes SQL pour le niveau 4

---
## Commandes utiles PostgreSQL
### Exécute le script SQL dans PostgreSQL
```sql
\i /init_database.sql
```

### Lister les bases de données
```sql
\l
```

### Lister les tables :
```sql
\dt
```

### Voir la structure d’une table :
```sql
\d stations
```

### Exécuter un script SQL :
```sh
psql -U postgres -d db_ratp_sncf -f exercices/niveau_1/nomdufichier.sql
```

