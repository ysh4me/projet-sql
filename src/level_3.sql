-- 1) Chiffre d'affaires des tickets par mois (2024)
SELECT 
  TO_CHAR(date_achat, 'Month') AS mois,
  SUM(prix_unitaire_centimes)/100.0 AS chiffre_affaires
FROM tickets
WHERE date_achat >= '2024-01-01'
  AND date_achat <  '2025-01-01'
GROUP BY TO_CHAR(date_achat, 'Month'), EXTRACT(MONTH FROM date_achat)
ORDER BY EXTRACT(MONTH FROM date_achat);

-- 2) Lignes à Nation à 17:28:16 ± 4 min
SELECT 
  l.nom AS ligne,
  h.horaire
FROM horaires h
JOIN arrets a ON h.id_arret = a.id
JOIN stations s ON a.id_station = s.id
JOIN lignes l ON a.id_ligne = l.id
WHERE s.nom = 'Nation'
  AND h.horaire BETWEEN '17:24:16' AND '17:32:16'
ORDER BY h.horaire;

-- 3) Moyenne de validations / mois / tarification
SELECT
  t.nom AS abonnement,
  (COUNT(v.id) * 1.0) 
    / COUNT(DISTINCT DATE_TRUNC('month', v.date_heure_validation)) AS moy_validation
FROM validations v
JOIN supports sup ON sup.id = v.id_support
JOIN abonnements a ON a.id_support = sup.id
JOIN tarifications t ON t.id = a.id_tarification
GROUP BY t.nom
ORDER BY moy_validation DESC, t.nom ASC;

-- 4) Vue : moyenne des passages par jour de la semaine (12 derniers mois)
CREATE OR REPLACE VIEW moyenne_passagers_par_jour AS
WITH daily AS (
  SELECT date_trunc('day', v.date_heure_validation) AS dte,
         COUNT(*) AS nb_val
  FROM validations v
  WHERE v.date_heure_validation >= CURRENT_DATE - INTERVAL '12 months'
  GROUP BY 1
),
by_weekday AS (
  SELECT
    EXTRACT(DOW FROM dte) AS weekday_num,
    TO_CHAR(dte, 'Day') AS jour_semaine,
    nb_val
  FROM daily
)
SELECT
  TRIM(b.jour_semaine) AS jour_semaine,
  AVG(b.nb_val) AS moy_passagers
FROM by_weekday b
GROUP BY b.weekday_num, b.jour_semaine
ORDER BY b.weekday_num;

-- 5) Vue : taux de remplissage moyen des lignes
CREATE OR REPLACE VIEW taux_remplissage_ligne AS
WITH val_par_jour_ligne AS (
  SELECT
    l.id AS id_ligne,
    l.nom AS nom_ligne,
    date_trunc('day', v.date_heure_validation) AS jour,
    COUNT(v.id) AS nb_validations
  FROM validations v
  JOIN stations s ON s.id = v.id_station
  JOIN arrets a ON a.id_station = s.id
  JOIN lignes l ON l.id = a.id_ligne
  GROUP BY l.id, l.nom, date_trunc('day', v.date_heure_validation)
),
moy_val_par_ligne AS (
  SELECT
    id_ligne,
    nom_ligne,
    AVG(nb_validations) AS avg_passagers_jour
  FROM val_par_jour_ligne
  GROUP BY id_ligne, nom_ligne
),
train_count AS (
  SELECT
    l.id AS id_ligne,
    l.nom AS nom_ligne,
    CASE
      WHEN l.moyen_transport = 'metro' THEN 205
      WHEN l.moyen_transport = 'rer'   THEN 82
      ELSE 1
    END AS trains_par_jour,
    l.capacite_max
  FROM lignes l
)
SELECT
  m.nom_ligne,
  ROUND(
    (m.avg_passagers_jour / (t.trains_par_jour * t.capacite_max)) * 100,
    2
  ) AS taux_remplissage
FROM moy_val_par_ligne m
JOIN train_count t ON t.id_ligne = m.id_ligne
ORDER BY taux_remplissage DESC;