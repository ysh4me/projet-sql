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
CREATE OR REPLACE VIEW taux_remplissage_lignes AS
WITH moyenne_passagers AS (
    SELECT a.id_ligne, COUNT(v.id) / 365.0 AS passagers_par_jour
    FROM validations v
    JOIN arrets a ON v.id_station = a.id_station
    WHERE v.date_heure_validation >= NOW() - INTERVAL '1 year'
    GROUP BY a.id_ligne
),
trains_par_jour AS (
    SELECT id, 
           CASE 
               WHEN type = 'metro' THEN 240
               WHEN type = 'rer' THEN 64  
           END AS nb_trains_par_jour
    FROM lignes
)
SELECT l.nom AS nom_ligne, ROUND((mp.passagers_par_jour / (tpj.nb_trains_par_jour * l.capacite_max)) * 100, 2) AS taux_remplissage
FROM moyenne_passagers mp JOIN lignes l ON mp.id_ligne = l.id
JOIN trains_par_jour tpj ON l.id = tpj.id ORDER BY taux_remplissage DESC;
