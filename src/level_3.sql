-- 1
SELECT TO_CHAR(date_achat, 'Month') AS mois, ROUND(SUM(prix_unitaire_centimes) / 100, 2) AS chiffre_affaires
FROM tickets WHERE date_achat BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY mois, EXTRACT(MONTH FROM date_achat) ORDER BY EXTRACT(MONTH FROM date_achat);

-- 2
SELECT l.nom AS ligne FROM horaires h
JOIN arrets a ON h.id_arret = a.id
JOIN lignes l ON a.id_ligne = l.id
JOIN stations s ON a.id_station = s.id
WHERE s.nom = 'Nation' AND h.horaire BETWEEN '17:24:16' AND '17:32:16' ORDER BY h.horaire;

-- 3
SELECT t.nom AS abonnement, ROUND(COUNT(v.id) / 12.0, 2) AS moy_validation FROM validations v
JOIN supports s ON v.id_support = s.id
JOIN abonnements a ON s.id = a.id_support
JOIN tarifications t ON a.id_tarification = t.id
WHERE v.date_heure_validation >= NOW() - INTERVAL '1 year' GROUP BY t.nom ORDER BY moy_validation DESC, t.nom;

-- 4
CREATE OR REPLACE VIEW moy_passages_par_jour AS SELECT TO_CHAR(v.date_heure_validation, 'Day') AS jour_semaine,
       ROUND(COUNT(v.id) / 52.0, 2) AS moy_passagers
FROM validations v WHERE v.date_heure_validation >= NOW() - INTERVAL '12 months'
GROUP BY jour_semaine ORDER BY ARRAY_POSITION(ARRAY['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI', 'SAMEDI', 'DIMANCHE'], jour_semaine);

-- 5
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