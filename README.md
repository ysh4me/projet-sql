# Requêtage SQL - Projet de gestion de transport public

---
## Lancement
### Lancer le service PostgreSQL
```sh
cd server
docker compose up --build -d
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
`/src/` → Contient les requêtes SQL pour le niveau 1, 2, 3 et 4

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
psql -U postgres -d db_ratp_sncf -f exercices/src/level_X.sql
```

