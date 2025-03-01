-- 1
SELECT COUNT(*) AS nb_dossiers_incomplets FROM dossiers_client WHERE statut = 'incomplet';

-- 2 
SELECT l.nom AS ligne, s.nom AS station FROM arrets a 
JOIN stations s ON a.id_station = s.id
JOIN lignes l ON a.id_ligne = l.id ORDER BY l.nom, s.nom;

-- 3
SELECT l.type AS moyen_transport, COUNT(DISTINCT a.id_station) AS nb_stations FROM arrets a
JOIN lignes l ON a.id_ligne = l.id
GROUP BY l.type ORDER BY nb_stations DESC;

-- 4
SELECT t.nom AS nom_tarification, COUNT(a.id) AS nb_abonnements FROM abonnements a
JOIN tarifications t ON a.id_tarification = t.id
WHERE a.date_fin BETWEEN '2025-01-31 00:00:00' AND '2025-01-31 23:59:59'
GROUP BY t.nom ORDER BY nb_abonnements ASC;

-- 5
CREATE OR REPLACE VIEW dossiers_en_validation AS SELECT * FROM dossiers_client
WHERE statut = 'validation' ORDER BY date_creation ASC;
