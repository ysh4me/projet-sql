-- 1
WITH supports_ayant_valide AS (
  SELECT DISTINCT v.id_support
  FROM validations v
),
abo_supports AS (
  SELECT DISTINCT a.id_support
  FROM abonnements a
),
counts AS (
  SELECT
    (SELECT COUNT(*)
     FROM supports_ayant_valide sav
     JOIN abo_supports ab ON ab.id_support = sav.id_support
    ) AS nb_abo,
    (SELECT COUNT(*)
     FROM supports_ayant_valide sav
     WHERE sav.id_support NOT IN (SELECT id_support FROM abo_supports)
    ) AS nb_ticket
)
SELECT
  CASE WHEN (nb_abo + nb_ticket) = 0 THEN 0
       ELSE ROUND(nb_abo * 100.0 / (nb_abo + nb_ticket), 2)
  END AS part_abonnement,
  CASE WHEN (nb_abo + nb_ticket) = 0 THEN 0
       ELSE ROUND(nb_ticket * 100.0 / (nb_abo + nb_ticket), 2)
  END AS part_ticket
FROM counts;


-- 2
SELECT
  TO_CHAR(a.date_debut, 'YYYY-MM') AS mois,
  COUNT(*) AS nb_nvx_abo
FROM abonnements a
WHERE a.date_debut >= '2024-01-01'
  AND a.date_debut <  '2025-01-01'
  AND NOT EXISTS (
    SELECT 1
    FROM abonnements oldA
    WHERE oldA.id_support = a.id_support
      AND oldA.date_debut < '2024-01-01'
  )
GROUP BY TO_CHAR(a.date_debut, 'YYYY-MM')
ORDER BY TO_CHAR(a.date_debut, 'YYYY-MM');


-- 3
WITH abo_period AS (
  SELECT
    a.id AS id_abonnement,
    a.id_support,
    a.date_debut,
    a.date_fin,
    t.prix_centimes AS cost_abo
  FROM abonnements a
  JOIN tarifications t ON t.id = a.id_tarification
),
validations_abo AS (
  SELECT
    p.id_abonnement,
    COUNT(v.id) AS nb_validations
  FROM abo_period p
  JOIN validations v ON v.id_support = p.id_support
  WHERE v.date_heure_validation >= p.date_debut
    AND v.date_heure_validation <= p.date_fin
  GROUP BY p.id_abonnement
),
calcul_economies AS (
  SELECT
    p.id_abonnement,
    GREATEST(
      0,
      (COALESCE(va.nb_validations, 0) * 200) - p.cost_abo
    ) AS econ_centimes
  FROM abo_period p
  LEFT JOIN validations_abo va ON va.id_abonnement = p.id_abonnement
)
SELECT
  SUM(econ_centimes)/100.0 AS montant_economise_euros
FROM calcul_economies;


-- 4
CREATE OR REPLACE VIEW heure_plus_affluente_station AS
WITH station_hour AS (
  SELECT
    s.nom AS nom_station,
    DATE_TRUNC('minute', v.date_heure_validation)::time AS heure_minute,
    COUNT(*) AS nb_val
  FROM validations v
  JOIN stations s ON s.id = v.id_station
  GROUP BY s.nom, DATE_TRUNC('minute', v.date_heure_validation)
),
ranked AS (
  SELECT
    nom_station,
    heure_minute,
    nb_val,
    ROW_NUMBER() OVER (
      PARTITION BY nom_station 
      ORDER BY nb_val DESC
    ) AS rk
  FROM station_hour
)
SELECT
  r.nom_station,
  r.heure_minute AS heure_affluente
FROM ranked r
WHERE r.rk = 1
ORDER BY r.nb_val DESC;


-- 5
CREATE OR REPLACE VIEW abonnements_actifs_par_zone AS
SELECT
  t.zone_min,
  t.zone_max,
  COUNT(a.id) AS nb_abonnements
FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
WHERE CURRENT_DATE BETWEEN a.date_debut AND a.date_fin
GROUP BY t.zone_min, t.zone_max
ORDER BY nb_abonnements DESC, t.zone_min, t.zone_max;
