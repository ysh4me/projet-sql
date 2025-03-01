-- 1
SELECT 
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.id IS NOT NULL THEN v.id_support END) / COUNT(DISTINCT v.id_support), 2) AS part_abonnement,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN a.id IS NULL THEN v.id_support END) / COUNT(DISTINCT v.id_support), 2) AS part_ticket
FROM validations v
LEFT JOIN abonnements a ON v.id_support = a.id_support;

-- 2
SELECT TO_CHAR(a.date_debut, 'Month') AS mois, COUNT(a.id) AS nb_nvx_abo FROM abonnements a
WHERE date_debut BETWEEN '2024-01-01' AND '2024-12-31'
AND NOT EXISTS (
    SELECT 1 FROM abonnements a2
    WHERE a2.id_support = a.id_support
    AND a2.date_debut < '2024-01-01'
)
GROUP BY mois, EXTRACT(MONTH FROM a.date_debut) ORDER BY EXTRACT(MONTH FROM a.date_debut);

-- 3
SELECT 
    ROUND(GREATEST(SUM(v_total.nb_validations * t.prix_centimes / 100) - SUM(tarif.prix_centimes / 100), 0), 2) 
    AS montant_economise_euros
FROM (
    SELECT a.id_tarification, COUNT(v.id) AS nb_validations
    FROM validations v
    JOIN abonnements a ON v.id_support = a.id_support
    GROUP BY a.id_tarification
) v_total
JOIN tarifications tarif ON v_total.id_tarification = tarif.id JOIN tarifications t ON t.nom = 'Forfait Navigo Jour';

-- 4
CREATE OR REPLACE VIEW heure_affluante_par_station AS
SELECT s.nom AS nom_station, 
       TO_CHAR(v.date_heure_validation, 'HH24:00') AS heure_affluante,
       COUNT(v.id) AS nb_validations
FROM validations v JOIN stations s ON v.id_station = s.id GROUP BY s.nom, heure_affluante
HAVING COUNT(v.id) = (
    SELECT MAX(val_count)
    FROM (
        SELECT COUNT(id) AS val_count
        FROM validations 
        WHERE id_station = v.id_station
        GROUP BY TO_CHAR(date_heure_validation, 'HH24:00')
    ) AS subquery
)
ORDER BY nb_validations DESC;

-- 5
CREATE OR REPLACE VIEW abonnements_par_zone AS SELECT t.zone_min, t.zone_max, COUNT(a.id) AS nb_abonnements
FROM abonnements a JOIN tarifications t ON a.id_tarification = t.id
WHERE a.date_fin > NOW() GROUP BY t.zone_min, t.zone_max ORDER BY nb_abonnements DESC, t.zone_min, t.zone_max;
