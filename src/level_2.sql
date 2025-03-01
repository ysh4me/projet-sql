-- 1
SELECT s.nom AS station FROM stations s 
JOIN arrets a ON s.id = a.id_station
JOIN lignes l ON a.id_ligne = l.id
GROUP BY s.nom HAVING COUNT(DISTINCT l.type) = 2 ORDER BY s.nom;

-- 2
SELECT t.nom AS nom_forfait, COUNT(a.id) AS nb_abonnements FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id WHERE a.date_fin >= NOW() 
GROUP BY t.nom ORDER BY nb_abonnements DESC LIMIT 3;

-- 3
SELECT s.nom AS station, ROUND(SUM(l.capacite_max) / COUNT(DISTINCT l.id), 2) AS capacite_moy
FROM arrets a JOIN stations s ON a.id_station = s.id JOIN lignes l ON a.id_ligne = l.id
GROUP BY s.nom ORDER BY s.nom;

-- 4
CREATE OR REPLACE VIEW abonnes_par_departement AS
SELECT
  a.departement,
  a.code_postal,
  COUNT(d.id) AS nb_abonnes
FROM dossiers_client d
JOIN adresses_client a ON d.id_adresse_residence = a.id
GROUP BY a.departement, a.code_postal
ORDER BY a.code_postal;

-- 5
SELECT 
    COUNT(CASE WHEN date_naissance > CURRENT_DATE - INTERVAL '18 years' THEN 1 END) AS moins_18,
    COUNT(CASE WHEN date_naissance BETWEEN CURRENT_DATE - INTERVAL '25 years' 
                             AND CURRENT_DATE - INTERVAL '18 years' THEN 1 END) AS "18_24",
    COUNT(CASE WHEN date_naissance BETWEEN CURRENT_DATE - INTERVAL '40 years' 
                             AND CURRENT_DATE - INTERVAL '25 years' THEN 1 END) AS "25_40",
    COUNT(CASE WHEN date_naissance BETWEEN CURRENT_DATE - INTERVAL '60 years' 
                             AND CURRENT_DATE - INTERVAL '40 years' THEN 1 END) AS "40_60",
    COUNT(CASE WHEN date_naissance <= CURRENT_DATE - INTERVAL '60 years' THEN 1 END) AS plus_60
FROM dossiers_client;

-- 6
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

