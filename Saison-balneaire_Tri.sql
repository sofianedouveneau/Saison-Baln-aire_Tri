DROP TABLE IF EXISTS analyses;
DROP TABLE IF EXISTS evenements;
DROP TABLE IF EXISTS sites;
DROP TABLE IF EXISTS communes;
DROP TABLE IF EXISTS departements;
DROP TABLE IF EXISTS regions;
-- table régions
CREATE TABLE regions (
code INT PRIMARY KEY,
nom VARCHAR NOT NULL
);
-- table départements
CREATE TABLE departements (
code VARCHAR PRIMARY KEY,
region INT REFERENCES regions(code) ON DELETE CASCADE,
nom VARCHAR NOT NULL
);
-- table communes
CREATE TABLE communes (
code VARCHAR PRIMARY KEY,
departement VARCHAR REFERENCES departements(code) ON DELETE CASCADE,
nom VARCHAR NOT NULL
);
-- table sites
CREATE TABLE sites (
idSite VARCHAR PRIMARY KEY,
nom VARCHAR NOT NULL,
codeCommune VARCHAR REFERENCES communes(code) ON DELETE CASCADE,
dateDeclaration DATE NOT NULL,
typeEau VARCHAR NOT NULL,
longitude DOUBLE PRECISION NOT NULL,
latitude DOUBLE PRECISION NOT NULL
);
-- table evenements
CREATE TABLE evenements (
idEvenement INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
idSite VARCHAR REFERENCES sites(idSite) ON DELETE CASCADE,
evenement VARCHAR NOT NULL,
debut DATE,
fin DATE,
mesure VARCHAR
);
-- table analyses
CREATE TABLE analyses (
idAnalyse INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
idSite VARCHAR REFERENCES sites(idSite) ON DELETE CASCADE,
datePrelevement DATE NOT NULL,
enterocoques INTEGER,
escherichia INTEGER
);

-- création des tables temporaires

CREATE TEMP TABLE sites_baignade_2024 (
    saison INTEGER,
    nom_region VARCHAR,
    departement VARCHAR,
    idsite VARCHAR,
    idsite_old VARCHAR,
    evolution VARCHAR,
    nomSite VARCHAR,
    codeCommune VARCHAR,
    nomCommune VARCHAR,
    dateDeclaration VARCHAR,
    typeEau VARCHAR,
    longitude VARCHAR,
    latitude VARCHAR
);

CREATE TEMP TABLE evenements_saison_2024 (
    saison INT,
    nom_region VARCHAR,
    departement VARCHAR,
    idsite VARCHAR,
    typeEvenement VARCHAR,
    dateDebut VARCHAR,
    dateFin VARCHAR,
    mesure VARCHAR
);
CREATE TEMP TABLE sites_ecoli_entero (
    annee INTEGER,
    nom_region VARCHAR,
    departement VARCHAR,
    idsite VARCHAR,
    datePrelevement VARCHAR,
    entero INTEGER,
    ecoli INTEGER,
    statut VARCHAR,
    vide1 VARCHAR,
    vide2 VARCHAR,
    vide3 VARCHAR
);

CREATE TEMP TABLE dpt_regions_fra (
    departement VARCHAR,
    nom_departement VARCHAR,
    region INTEGER,
    nom_region VARCHAR
);

-- peuplement des tables temporaires
\copy dpt_regions_fra FROM 'donnees/departements-france.csv' DELIMITER ',' CSV
HEADER ENCODING 'UTF8';
\copy sites_ecoli_entero FROM 'donnees/saison-balneaire-2024-resultatsdanalyses.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1';
\copy evenements_saison_2024 FROM 'donnees/saison-balneaire-2024-informations-surla-saison.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1' ;
\copy sites_baignade_2024 FROM 'donnees/liste-des-sites-de-baignade-saisonbalneaire-2024.csv' DELIMITER ';' CSV HEADER ENCODING 'LATIN1' ; 

-- peuplement des tables définitives 

INSERT INTO regions SELECT DISTINCT region, nom_region FROM dpt_regions_fra;
INSERT INTO departements SELECT DISTINCT LPAD(departement, 3, '0'), region,
nom_departement FROM dpt_regions_fra;
INSERT INTO communes SELECT DISTINCT codeCommune, LPAD(departement, 3, '0'),
nomCommune FROM sites_baignade_2024;
INSERT INTO sites SELECT DISTINCT idsite, nomSite, codeCommune,
TO_DATE(dateDeclaration, 'DD/MM/YYYY'), typeEau, REPLACE(longitude, ',',
'.')::DOUBLE PRECISION, REPLACE(latitude, ',', '.')::DOUBLE PRECISION FROM
sites_baignade_2024;
INSERT INTO evenements(idSite, evenement, debut, fin, mesure) SELECT DISTINCT
idsite, typeEvenement, TO_DATE(dateDebut, 'DD/MM/YYYY'), TO_DATE(dateFin,
'DD/MM/YYYY'), mesure FROM evenements_saison_2024;
INSERT INTO analyses(idSite, datePrelevement, enterocoques, escherichia) SELECT
DISTINCT idsite, TO_DATE(datePrelevement, 'DD/MM/YYYY'), entero, ecoli FROM
sites_ecoli_entero;