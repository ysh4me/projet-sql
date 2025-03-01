-- 1
SELECT COUNT(*) AS nb_dossiers_incomplets FROM dossiers_client WHERE statut = 'incomplet';

-- 2 
SELECT 
  l.nom AS ligne,
  STRING_AGG(s.nom, ', ' ORDER BY s.nom) AS stations
FROM lignes l
JOIN arrets a ON a.id_ligne = l.id
JOIN stations s ON s.id = a.id_station
GROUP BY l.nom
ORDER BY l.nom;

-- 3
SELECT
  l.moyen_transport,
  COUNT(DISTINCT a.id_station) AS nb_stations
FROM lignes l
JOIN arrets a ON l.id = a.id_ligne
GROUP BY l.moyen_transport
ORDER BY nb_stations DESC;

-- 4
SELECT t.nom AS nom_tarification, COUNT(a.id) AS nb_abonnements FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
WHERE a.date_fin BETWEEN '2025-01-31 00:00:00' AND '2025-01-31 23:59:59'
GROUP BY t.nom ORDER BY nb_abonnements ASC;

-- 5
CREATE OR REPLACE VIEW dossiers_en_validation AS SELECT * FROM dossiers_client
WHERE statut = 'validation' ORDER BY date_creation ASC;

