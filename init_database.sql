DROP DATABASE IF EXISTS db_ratp_sncf;
CREATE DATABASE db_ratp_sncf;

\c db_ratp_sncf;

CREATE TYPE moyen_transport AS ENUM ('metro', 'rer');
CREATE TYPE statut_dossier_client AS ENUM ('incomplet', 'validation', 'validé', 'rejeté');


CREATE TABLE stations (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    zone INT NOT NULL
);

CREATE TABLE lignes (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(32) NOT NULL,
    moyen_transport moyen_transport NOT NULL,
    capacite_max INT NOT NULL
);

CREATE TABLE arrets (
    id SERIAL PRIMARY KEY,
    id_station INT NOT NULL,
    id_ligne INT NOT NULL,
    FOREIGN KEY (id_station) REFERENCES stations(id) ON DELETE CASCADE,
    FOREIGN KEY (id_ligne) REFERENCES lignes(id) ON DELETE CASCADE
);

CREATE TABLE horaires (
    id SERIAL PRIMARY KEY,
    id_arret INT NOT NULL,
    horaire TIME NOT NULL,
    FOREIGN KEY (id_arret) REFERENCES arrets(id) ON DELETE CASCADE
);

CREATE TABLE adresses_client (
    id SERIAL PRIMARY KEY,
    ligne_1 TEXT NOT NULL,
    ligne_2 TEXT,
    ville VARCHAR(255),
    departement VARCHAR(255),
    code_postal VARCHAR(5),
    pays VARCHAR(255)
);

CREATE TABLE dossiers_client (
    id SERIAL PRIMARY KEY,
    statut statut_dossier_client NOT NULL,
    prenoms TEXT,
    nom_famille TEXT,
    date_naissance DATE,
    id_adresse_residence INT,
    id_adresse_facturation INT,
    email VARCHAR(128),
    tel VARCHAR(15),
    iban VARCHAR(34),
    bic VARCHAR(11),
    date_creation TIMESTAMP NOT NULL,
    FOREIGN KEY (id_adresse_residence) REFERENCES adresses_client(id) ON DELETE SET NULL,
    FOREIGN KEY (id_adresse_facturation) REFERENCES adresses_client(id) ON DELETE SET NULL
);

CREATE TABLE supports (
    id SERIAL PRIMARY KEY,
    identifiant VARCHAR(12) NOT NULL UNIQUE,
    date_achat TIMESTAMP NOT NULL
);

CREATE TABLE tarifications (
    id SERIAL PRIMARY KEY,
    nom TEXT NOT NULL,
    zone_min INT NOT NULL,
    zone_max INT NOT NULL,
    prix_centimes INT NOT NULL
);

CREATE TABLE abonnements (
    id SERIAL PRIMARY KEY,
    id_support INT NOT NULL,
    id_dossier INT NOT NULL,
    id_tarification INT NOT NULL,
    date_debut TIMESTAMP NOT NULL,
    date_fin TIMESTAMP NOT NULL,
    FOREIGN KEY (id_support) REFERENCES supports(id) ON DELETE CASCADE,
    FOREIGN KEY (id_dossier) REFERENCES dossiers_client(id) ON DELETE CASCADE,
    FOREIGN KEY (id_tarification) REFERENCES tarifications(id) ON DELETE CASCADE
);

CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    id_support INT NOT NULL,
    date_achat TIMESTAMP NOT NULL,
    date_expiration TIMESTAMP NOT NULL,
    prix_unitaire_centimes INT NOT NULL,
    id_station INT NOT NULL,
    date_heure_validation TIMESTAMP,
    FOREIGN KEY (id_support) REFERENCES supports(id) ON DELETE CASCADE,
    FOREIGN KEY (id_station) REFERENCES stations(id) ON DELETE CASCADE
);

CREATE TABLE validations (
    id SERIAL PRIMARY KEY,
    id_support INT NOT NULL,
    id_station INT NOT NULL,
    date_heure_validation TIMESTAMP NOT NULL,
    FOREIGN KEY (id_support) REFERENCES supports(id) ON DELETE CASCADE,
    FOREIGN KEY (id_station) REFERENCES stations(id) ON DELETE CASCADE
);
