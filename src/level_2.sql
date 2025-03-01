-- 1) Stations doubles
SELECT s.nom AS station
FROM stations s
JOIN arrets a ON s.id = a.id_station
JOIN lignes l ON a.id_ligne = l.id
GROUP BY s.nom
HAVING COUNT(DISTINCT l.moyen_transport) >= 2
ORDER BY s.nom;

-- 2) Forfaits populaires (top 3)
SELECT t.nom AS nom_forfait,
       COUNT(*) AS nb_abonnements
FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
WHERE CURRENT_DATE BETWEEN a.date_debut AND a.date_fin
GROUP BY t.nom
ORDER BY nb_abonnements DESC
LIMIT 3;

-- 3) Capacité moyenne de chaque station
SELECT
  s.nom AS station,
  SUM(l.capacite_max)::numeric / COUNT(l.id) AS capacite_moy
FROM stations s
JOIN arrets a ON s.id = a.id_station
JOIN lignes l ON a.id_ligne = l.id
GROUP BY s.nom
ORDER BY s.nom;

-- 4) Vue abonnes_par_departement
CREATE OR REPLACE VIEW abonnes_par_departement AS
SELECT
  a.departement,
  a.code_postal,
  COUNT(d.id) AS nb_abonnes
FROM dossiers_client d
JOIN adresses_client a ON d.id_adresse_residence = a.id
GROUP BY a.departement, a.code_postal
ORDER BY a.code_postal;

-- 5) Usagers par tranches d’âge
SELECT
  SUM(CASE WHEN date_naissance > CURRENT_DATE - INTERVAL '18 years' THEN 1 ELSE 0 END) AS moins_18,
  SUM(CASE WHEN date_naissance <= CURRENT_DATE - INTERVAL '18 years'
            AND date_naissance > CURRENT_DATE - INTERVAL '25 years' THEN 1 ELSE 0 END) AS "18_24",
  SUM(CASE WHEN date_naissance <= CURRENT_DATE - INTERVAL '25 years'
            AND date_naissance > CURRENT_DATE - INTERVAL '40 years' THEN 1 ELSE 0 END) AS "25_40",
  SUM(CASE WHEN date_naissance <= CURRENT_DATE - INTERVAL '40 years'
            AND date_naissance > CURRENT_DATE - INTERVAL '60 years' THEN 1 ELSE 0 END) AS "40_60",
  SUM(CASE WHEN date_naissance <= CURRENT_DATE - INTERVAL '60 years' THEN 1 ELSE 0 END) AS plus_60
FROM dossiers_client;

-- 6) Vue frequentation_stations (top 10 stations)
CREATE OR REPLACE VIEW frequentation_stations AS
WITH freq AS (
  SELECT s.nom AS station,
         COUNT(v.id) AS frequentation
  FROM validations v
  JOIN stations s ON s.id = v.id_station
  GROUP BY s.nom
  ORDER BY COUNT(v.id) DESC
  LIMIT 10
)
SELECT * FROM freq;