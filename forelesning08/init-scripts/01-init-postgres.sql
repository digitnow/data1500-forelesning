-- Semesterprosjekt: DATA1500 - PostgreSQL Initialisering

-- Opprett tabeller
CREATE TABLE brukere (
    bruker_id SERIAL PRIMARY KEY,
    brukernavn VARCHAR(50) UNIQUE NOT NULL,
    epost VARCHAR(100) UNIQUE NOT NULL,
    passord_hash VARCHAR(255) NOT NULL,
    opprettet_dato DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE fellesskap (
    fellesskap_id SERIAL PRIMARY KEY,
    navn VARCHAR(100) UNIQUE NOT NULL,
    beskrivelse TEXT,
    opprettet_dato DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE prosjekter (
    prosjekt_id SERIAL PRIMARY KEY,
    tittel VARCHAR(200) NOT NULL,
    sammendrag TEXT,
    opprettet_dato DATE NOT NULL DEFAULT CURRENT_DATE,
    bruker_id INT NOT NULL REFERENCES brukere(bruker_id),
    fellesskap_id INT NOT NULL REFERENCES fellesskap(fellesskap_id)
);

CREATE TABLE diskusjoner (
    diskusjon_id SERIAL PRIMARY KEY,
    tittel VARCHAR(200) NOT NULL,
    opprettet_dato DATE NOT NULL DEFAULT CURRENT_DATE,
    prosjekt_id INT NOT NULL REFERENCES prosjekter(prosjekt_id)
);

CREATE TABLE medier (
    medie_id SERIAL PRIMARY KEY,
    filnavn VARCHAR(255) NOT NULL,
    filtype VARCHAR(50) NOT NULL,
    storrelse_kb INT NOT NULL,
    opplastet_dato DATE NOT NULL DEFAULT CURRENT_DATE,
    prosjekt_id INT NOT NULL REFERENCES prosjekter(prosjekt_id)
);

CREATE TABLE metoder (
    metode_id SERIAL PRIMARY KEY,
    navn VARCHAR(100) NOT NULL,
    beskrivelse TEXT
);

CREATE TABLE bruker_fellesskap (
    bruker_id INT NOT NULL REFERENCES brukere(bruker_id),
    fellesskap_id INT NOT NULL REFERENCES fellesskap(fellesskap_id),
    PRIMARY KEY (bruker_id, fellesskap_id)
);

CREATE TABLE prosjekt_metode (
    prosjekt_id INT NOT NULL REFERENCES prosjekter(prosjekt_id),
    metode_id INT NOT NULL REFERENCES metoder(metode_id),
    PRIMARY KEY (prosjekt_id, metode_id)
);

-- Sett inn testdata
INSERT INTO brukere (brukernavn, epost, passord_hash) VALUES
    ('testbruker1', 'test1@test.com', 'hash1'),
    ('testbruker2', 'test2@test.com', 'hash2');

INSERT INTO fellesskap (navn, beskrivelse) VALUES
    ('Dataingeniør-fellesskapet', 'Et fellesskap for dataingeniører'),
    ('Maskinlæring-gruppa', 'En gruppe for de som er interessert i ML');

INSERT INTO prosjekter (tittel, sammendrag, bruker_id, fellesskap_id) VALUES
    ('Semesterprosjekt i databaser', 'Et prosjekt om databaser', 1, 1),
    ('Analyse av sentiment i tekst', 'Et ML-prosjekt', 2, 2);

INSERT INTO diskusjoner (tittel, prosjekt_id) VALUES
    ('Diskusjon om datamodellering', 1),
    ('Valg av algoritme', 2);

INSERT INTO medier (filnavn, filtype, storrelse_kb, prosjekt_id) VALUES
    ('rapport.pdf', 'PDF', 1024, 1),
    ('dataset.csv', 'CSV', 5120, 2);

INSERT INTO metoder (navn, beskrivelse) VALUES
    ('ER-modellering', 'En metode for datamodellering'),
    ('Lineær regresjon', 'En statistisk metode');

INSERT INTO bruker_fellesskap (bruker_id, fellesskap_id) VALUES
    (1, 1),
    (2, 1),
    (2, 2);

INSERT INTO prosjekt_metode (prosjekt_id, metode_id) VALUES
    (1, 1),
    (2, 2);
