-- ============================================================
-- Testskript: Rekursiv CTE — Kategorihierarki
-- ============================================================
-- Kjøres med:
--   psql -U admin -d testdb -f rekursiv-cte-kategorier.sql
-- Eller i Docker:
--   docker-compose exec postgres psql -U admin -d testdb -f rekursiv-cte-kategorier.sql
-- ============================================================

-- Rydd opp fra tidligere kjøringer
DROP TABLE IF EXISTS kategorier;

-- ============================================================
-- 1. Opprett tabell
-- ============================================================

CREATE TABLE kategorier (
    kategori_id  SERIAL       PRIMARY KEY,
    navn         VARCHAR(100) NOT NULL,
    forelder_id  INTEGER      REFERENCES kategorier(kategori_id)
);

-- ============================================================
-- 2. Sett inn testdata
--
-- Hierarkiet vi bygger:
--
--  Elektronikk (1)
--  ├── Datamaskiner (2)
--  │   ├── Bærbare PC-er (5)
--  │   └── Stasjonære PC-er (6)
--  └── Mobiltelefoner (3)
--      ├── Smarttelefoner (7)
--      └── Tilbehør (8)
--          └── Deksel (9)
--
--  Sport (4)
--  └── Sykkel (10)
--      ├── Terrengsykkel (11)
--      └── Bysykkel (12)
--
-- ============================================================

INSERT INTO kategorier (kategori_id, navn, forelder_id) VALUES
    -- Rotnivå (ingen forelder)
    (1,  'Elektronikk',        NULL),
    (4,  'Sport',              NULL),

    -- Nivå 2 under Elektronikk
    (2,  'Datamaskiner',       1),
    (3,  'Mobiltelefoner',     1),

    -- Nivå 2 under Sport
    (10, 'Sykkel',             4),

    -- Nivå 3 under Datamaskiner
    (5,  'Bærbare PC-er',      2),
    (6,  'Stasjonære PC-er',   2),

    -- Nivå 3 under Mobiltelefoner
    (7,  'Smarttelefoner',     3),
    (8,  'Tilbehør',           3),

    -- Nivå 3 under Sykkel
    (11, 'Terrengsykkel',      10),
    (12, 'Bysykkel',           10),

    -- Nivå 4 under Tilbehør
    (9,  'Deksel',             8);

-- Synkroniser sekvensen etter manuell innsetting av ID-er
SELECT setval('kategorier_kategori_id_seq', (SELECT MAX(kategori_id) FROM kategorier));

-- ============================================================
-- 3. Vis rådata
-- ============================================================

\echo ''
\echo '=== Rådata i kategorier-tabellen ==='
SELECT
    kategori_id,
    navn,
    COALESCE(forelder_id::TEXT, '(ingen)') AS forelder_id
FROM kategorier
ORDER BY kategori_id;

-- ============================================================
-- 4. Rekursiv CTE — Finn alle underkategorier
--    (nøyaktig slik det er vist i presentasjonen)
-- ============================================================

\echo ''
\echo '=== Rekursiv CTE: Hele kategorihierarkiet ==='

WITH RECURSIVE kategorier_hierarki AS (

    -- 1. Ankerleddet (Startpunktet)
    --    Henter alle rotkategorier (de uten forelder)
    SELECT
        kategori_id,
        navn,
        forelder_id,
        1 AS nivaa
    FROM kategorier
    WHERE forelder_id IS NULL

    UNION ALL

    -- 2. Rekursivt ledd (Refererer til seg selv)
    --    Finner barn av kategoriene vi allerede har funnet
    SELECT
        k.kategori_id,
        k.navn,
        k.forelder_id,
        kh.nivaa + 1
    FROM kategorier k
    JOIN kategorier_hierarki kh ON k.forelder_id = kh.kategori_id

)
SELECT *
FROM kategorier_hierarki
ORDER BY nivaa;

-- ============================================================
-- 5. Utvidet versjon: Vis hierarkiet med innrykk og sti
-- ============================================================

\echo ''
\echo '=== Utvidet: Hierarki med innrykk og full sti ==='

WITH RECURSIVE kategorier_hierarki AS (

    -- Ankerleddet: rotkategorier
    SELECT
        kategori_id,
        navn,
        forelder_id,
        1                           AS nivaa,
        navn::TEXT                        AS full_sti,
        LPAD('', 0)::TEXT                 AS innrykk
    FROM kategorier
    WHERE forelder_id IS NULL

    UNION ALL

    -- Rekursivt ledd: barn
    SELECT
        k.kategori_id,
        k.navn,
        k.forelder_id,
        kh.nivaa + 1,
        kh.full_sti || ' → ' || k.navn,
        LPAD('', (kh.nivaa) * 4)    -- 4 mellomrom per nivå
    FROM kategorier k
    JOIN kategorier_hierarki kh ON k.forelder_id = kh.kategori_id

)
SELECT
    nivaa,
    innrykk || navn           AS navn_med_innrykk,
    full_sti
FROM kategorier_hierarki
ORDER BY full_sti;

-- ============================================================
-- 6. Praktisk eksempel: Finn alle underkategorier av "Elektronikk"
-- ============================================================

\echo ''
\echo '=== Alle underkategorier av Elektronikk (kategori_id = 1) ==='

WITH RECURSIVE underkategorier AS (

    -- Startpunkt: kun Elektronikk
    SELECT kategori_id, navn, forelder_id, 0 AS dybde
    FROM kategorier
    WHERE kategori_id = 1

    UNION ALL

    -- Finn alle barn rekursivt
    SELECT k.kategori_id, k.navn, k.forelder_id, u.dybde + 1
    FROM kategorier k
    JOIN underkategorier u ON k.forelder_id = u.kategori_id

)
SELECT
    dybde,
    LPAD('', dybde * 4) || navn AS navn,
    kategori_id
FROM underkategorier
ORDER BY dybde, navn;

-- ============================================================
-- 7. Praktisk eksempel: Finn alle foreldre (opp i hierarkiet)
--    for en gitt kategori — "Deksel" (kategori_id = 9)
-- ============================================================

\echo ''
\echo '=== Alle foreldre til Deksel (kategori_id = 9) ==='

WITH RECURSIVE foreldre AS (

    -- Startpunkt: Deksel
    SELECT kategori_id, navn, forelder_id, 0 AS steg_opp
    FROM kategorier
    WHERE kategori_id = 9

    UNION ALL

    -- Gå ett nivå opp i hierarkiet
    SELECT k.kategori_id, k.navn, k.forelder_id, f.steg_opp + 1
    FROM kategorier k
    JOIN foreldre f ON k.kategori_id = f.forelder_id

)
SELECT
    steg_opp,
    navn,
    kategori_id,
    COALESCE(forelder_id::TEXT, '(rot)') AS forelder_id
FROM foreldre
ORDER BY steg_opp;
