# Fra pensumsboken
- Man kan gjøre en del av beregninger og analyser på databaselaget
- **views** - virtuelle tabeller eller *navngitte* spørringer.
- **delspørringer** - *nøstede* spørringer, f.eks. skrive en spørring som en del av en spørring (*nøste* spørringer i hverandre).
- Utførelsen begynner med den *innerste* spørringen. 
- Kan sammenlignes med funksjoner f(g(x)), hvor en funksjon er et argument til en annen funksjon. 
- Avanserte aggregeringsteknikker med grupperingsvarianter.
- Vindusfunksjoner. 

## CASE
- Valguttrykk i SQL, - CASE (MySQL har også IF)
- For å generere forskjellig output basert på flere betingelser.
- Se eksempel på slide #5 (hvordan *bevise* at spørringen produserer korrekt også "Ingen medier" og "Mange medier"?).
- Et eksempel mot "hobbyhuset"-modellen.
- **use case** marker alle varer som koster 
    - mindre enn 100 kr med "billig",
    - mellom 100 og 500 med "middels", 
    - og over 500 (alle andre) med "dyr"

```sql
select vnr, betegnelse, pris,
    case 
        when Pris < 100 then 'billig'
        when Pris <= 500 then 'middels'
        else 'dyr'
    end as prisklasse
from vare;
```

- **use case**: Tell antall varer i de tre kategoriene (billig, middels, dyr):
```sql
select count(*) as ant,     
    case
        when Pris < 100 then 'billig'
        when Pris <= 500 then 'middels'
        else 'dyr'
    end as prisklasse
from vare group by prisklasse;
-- output:
   ant | prisklasse 
-------+------------
    80 | billig
    17 | dyr
    64 | middels
```

- **use case**: Sorter slik at `dyr` er på toppen, så `middels` og så `billig` eller eventuelt omvendt (med desc):
```sql
select ant, prisklasse
from 
-- eksempel på delspørring i from delen av spørringen, dvs. input
   (select count(*) as ant,
        case
            when Pris < 100 then 'billig'
            when Pris <= 500 then 'middels'
            else 'dyr'
        end as prisklasse
    from vare group by prisklasse) as varer_klasse
order by
    case 
        when prisklasse = 'dyr' then 1
        when prisklasse = 'middels' then 2
        when prisklasse ='billig' then 3
    end; -- eventuelt desc
-- output:
 ant | prisklasse 
-----+------------
  17 | dyr
  64 | middels
  80 | billig
``` 

I løsningen for denne "use case" bruker vi en ny `case-end`-konstruksjon for å definere heltallsverdier for sortering. 

## Ekstra: Bruken av CASE for å generere testdata
- Vi kan også bruke `case-end`-konstruksjon for å generere testdata.
- **use case**: generer testdata for 100 sykler i tabellen `sykler` (ref. modellen fra oblig 1) basert på eksisterende data `stasjoner` og `laaser`:
```sql 
insert into sykler (modell, innkjopsdato, stasjon_id, laas_id)
select
    case (random() * 2)::int
        when 0 then 'City Bike Pro'
        when 1 then 'Urban Cruiser'
        else 'EcoBike 3000'
    end as modell,
    date '2026-01-01' - (random() * 365)::int as innkjopsdato,
    case 
        when random() < 0.85 then sl.stasjon_id   -- Sett til stasjon_id
        else NULL                                  -- NULL dersom utleid
    end as stasjon_id,
    case 
        when random() < 0.85 then sl.laas_id   -- Sett til stasjon_id
        else NULL                                  -- NULL dersom utleid
    end as laas_id
from ( 
    select s.stasjon_id, l.laas_id
    from laaser l
    join stasjoner s on l.stasjon_id = s.stasjon_id
    ) as sl;
```

- For detaljer om funksjonen `random()` se "Table 9.6. Random Functions" i https://www.postgresql.org/docs/15/functions-math.html
- `status` er ikke nødvendlig, hvis vi bruker `stasjon_id` og `laas_id`for sykler som er utleid (blir satt til `tilgjengelig`, kunne bli satt til `udefinert`; eller man kunne bruke status for å sykkel trenger reparasjon, f.eks.).
- Kun med `CASE` kan vi ikke sette både `stasjon_id` og `laas_id` til NULL på samme rad. 
- Hvis vi ønsker å sette NULL der hvor enten `stasjon_id` og `laas_id` er NULL, må vi utføre en ekstra SQL-kommando (eller eventuelt bruke en `procedure` eller `function`; eventuelt en do-end blokk?)

```sql
select * from sykler where stasjon_id IS NULL or laas_id IS NULL;
``` 
- Men i eksisterende modellen er det ingen sykler som er utleid
```sql 
select * from (select
    case (random() * 2)::int
        when 0 then 'City Bike Pro'
        when 1 then 'Urban Cruiser'
        else 'EcoBike 3000'
    end as modell,
    date '2026-01-01' - (random() * 365)::int as innkjopsdato,
    case 
        when random() < 0.85 then sl.stasjon_id   -- Sett til stasjon_id
        else NULL                                  -- NULL dersom utleid
    end as stasjon_id,
    case 
        when random() < 0.85 then sl.laas_id   -- Sett til stasjon_id
        else NULL                                  -- NULL dersom utleid
    end as laas_id
from ( 
    select s.stasjon_id, l.laas_id
    from laaser l
    join stasjoner s on l.stasjon_id = s.stasjon_id
    ) as sl ) as alle_sykler where stasjon_id IS NULL or laas_id IS NULL;
```

- Vi kan også bruke `CREATE TABLE ny_tabell AS` for å lage en *temporær* tabell for eksperimentering. Q: hvordan lage en serial id type som ikke kommer fra grunnlagstabellen?

```sql
select * from temp_sykler where stasjon_id IS NULL or laas_id IS NULL;
```

- Og så kan vi oppdatere `stasjon_id` eller `laas_id` til NULL der hvor en av verdiene allerede er NULL.

```sql
update temp_sykler set stasjon_id = NULL, laas_id = NULL where stasjon_id IS NULL or laas_id IS NULL;
```

## Ekstra: om funksjoner og triggere i Postgres
- La oss tenke en ekstra-"use case" (vil bli brukt når vi går gjennom transaksjoner og NoSQL) hvor vi ønsker å lagre lokasjon for hver sykkel. Koordinatene for stasjonenen er faste, men hva hvis vi også ønsker å se på hvor de utleide syklene er til enhver tid. 
- Kan bruke Postgis utvidelse, men i demoen her bruker vi en array-type i Postgres. 

```sql 
ALTER TABLE temp_sykler
ADD COLUMN lokasjon TEXT[];

ALTER TABLE temp_sykler
RENAME COLUMN "?column?" TO innkjøpsdato;

ALTER TABLE temp_sykler
ADD COLUMN sykkel_id SERIAL PRIMARY KEY;

update temp_sykler set lokasjon = '{59°55''12.2''''N, 10°43''40.3''''E}' where innkjøpsdato = '2025-10-02';

select modell, 
    innkjøpsdato, 
    lokasjon[1] as latitude, 
    lokasjon[2] as longitude 
from temp_sykler 
where lokasjon IS NOT NULL;

create table IF not exists ny_pos (
    sykkel_id INTEGER NOT NULL,
    siste_lokasjon_tidspunkt TIMESTAMP NOT NULL,
    pos text[]
);
ALTER TABLE ny_pos
ADD COLUMN pos TEXT[];

-- i postgres må opprette en triggerfunksjon først før man kan definere en trigger
CREATE OR REPLACE FUNCTION fn_ny_pos()
RETURNS TRIGGER AS $$
BEGIN
    -- Betingelsen er nå korrekt: den sjekker om 'pos'-kolonnen er endret.
    IF (OLD.pos IS DISTINCT FROM NEW.pos) THEN
        RAISE NOTICE 'Posisjon for sykkel % er endret. Oppdaterer temp_sykler.', NEW.sykkel_id;
        
        -- Oppdaterer riktig tabell ('temp_sykler')
        UPDATE temp_sykler
        SET lokasjon = NEW.pos
        WHERE sykkel_id = OLD.sykkel_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Dropper den gamle triggeren for å unngå konflikt
DROP TRIGGER IF EXISTS trigger_ny_pos ON ny_pos;

-- Oppretter triggeren på nytt med FOR EACH ROW
CREATE TRIGGER trigger_ny_pos
AFTER UPDATE ON ny_pos
FOR EACH ROW -- VIKTIG: Må spesifiseres for å få tilgang til OLD og NEW
EXECUTE FUNCTION fn_ny_pos();


UPDATE ny_pos 
SET 
    pos = ARRAY['59°55''09.1"N', '10°44''05.0"E'], -- Bruker riktig kolonnenavn 'pos' og korrekt array-syntaks
    siste_lokasjon_tidspunkt = NOW()  
WHERE sykkel_id = 100;


\d ny_pos 
                                  Table "public.ny_pos"
          Column          |            Type             | Collation | Nullable | Default 
--------------------------+-----------------------------+-----------+----------+---------
 sykkel_id                | integer                     |           | not null | 
 siste_lokasjon_tidspunkt | timestamp without time zone |           | not null | 
 pos                      | text[]                      |           |          | 


\d temp_sykler
                                   Table "public.temp_sykler"
    Column    |  Type   | Collation | Nullable |                    Default                     
--------------+---------+-----------+----------+------------------------------------------------
 modell       | text    |           |          | 
 innkjøpsdato | date    |           |          | 
 stasjon_id   | integer |           |          | 
 laas_id      | integer |           |          | 
 lokasjon     | text[]  |           |          | 
 sykkel_id    | integer |           | not null | nextval('temp_sykler_sykkel_id_seq'::regclass)
Indexes:
    "temp_sykler_pkey" PRIMARY KEY, btree (sykkel_id)
```


## Views
### Eksemepel på felleskaps-modellen

```sql 
CREATE VIEW aktive_prosjekter AS
  SELECT p.tittel, 
         COUNT(m.medie_id) AS antall_medier
  FROM prosjekter p
  LEFT JOIN medier m 
         ON p.prosjekt_id = m.prosjekt_id
  GROUP BY p.prosjekt_id, p.tittel;
 
-- Bruk som vanlig tabell
SELECT * FROM aktive_prosjekter 
  WHERE antall_medier > 5;
``` 

### Eksemepler på hobbyhuset-modellen
-oppdaterbarhet:
```sql 
create view antallvarerprkategori as 
    select katnr, count(*) as antall
    from vare
    group by katnr;
-- output: 
     katnr | antall 
-------+--------
     4 |     18
    21 |      4
    14 |     11
-- ...........
``` 
- Kan vi oppdatere view? For eksempel endre antall for kategori 12 fra 4 til 1? Men hvilke tre at radene i varer skal vi da slette? Det vil ikke funksjonere. Views med `GROUP BY` og `COUNT` er ikke oppdaterbare. 
- Feilmeldning man får hvis man prøver `update antallvarerprkategori set antall = 1 where katnr = 21;`:
```
ERROR:  cannot update view "antallvarerprkategori"
DETAIL:  Views containing GROUP BY are not automatically updatable.
HINT:  To enable updating the view, provide an INSTEAD OF UPDATE trigger or an unconditional ON UPDATE DO INSTEAD rule.
```
- Også views hvor primærnøkkel er ikke med i SELECT-delen, og hvor SELECT-delen inneholder uttrykk med funksjoner eller konstanter, samt delspørringer og koblinger av flere tabeller er **ikke oppdaterbare**. 
- Et annet eksempel for oppdaterbarhet:
```sql 
create view varermedkategorinavn (vnr, betegnelse, vkatnr, kkatnr, navn) as 
    select v.vnr, v.betegnelse, v.katnr, k.katnr, k.navn 
    from vare v, kategori k
    where v.katnr = k.katnr;
```
- Postgres gir en feilmelding hvis vi prøver på `update varermedkategorinavn set vkatnr = 3 where vnr = '10820';`:
```
ERROR:  cannot update view "varermedkategorinavn"
DETAIL:  Views that do not select from a single table or view are not automatically updatable.
HINT:  To enable updating the view, provide an INSTEAD OF UPDATE trigger or an unconditional ON UPDATE DO INSTEAD rule.
```

### Eksempel på materialisert view (hobbyhuset-modellen)

- Eksempel på vanlig view (ikke materialisert, dvs. utfører grunnspørring(-er) hver gang man kaller opp view).
```sql
create view kunder_haugesund_omraadet as 
    select ordre.*, fornavn, etternavn, poststed
    from ordre join 
        (kunde join poststed on kunde.postnr = poststed.postnr)
    on ordre.knr = kunde.knr 
    where poststed.postnr::int between 5500 and 5599;
```
```sql
create materialized view mv_kunder_haugesund_omraadet as 
    select ordre.*, fornavn, etternavn, poststed
    from ordre join 
        (kunde join poststed on kunde.postnr = poststed.postnr)
    on ordre.knr = kunde.knr 
    where poststed.postnr::int between 5500 and 5599;
```

- Sjekke status i databasen:
```sql
hobbyhuset=# \dv
                 List of relations
 Schema |           Name            | Type | Owner 
--------+---------------------------+------+-------
 public | antallvarerprkategori     | view | admin
 public | kunder_haugesund_omraadet | view | admin
 public | varermedkategorinavn      | view | admin
(3 rows)

hobbyhuset=# \dm
                         List of relations
 Schema |             Name             |       Type        | Owner 
--------+------------------------------+-------------------+-------
 public | mv_kunder_haugesund_omraadet | materialized view | admin
(1 row)
```

- Sammenligner **view** og **materialized view**:
```sql
explain analyze select * from kunder_haugesund_omraadet;
                                                                   QUERY PLAN                                                                   
------------------------------------------------------------------------------------------------------------------------------------------------
 Hash Join  (cost=139.32..200.59 rows=11 width=42) (actual time=1.089..1.466 rows=34 loops=1)
   Hash Cond: (ordre.knr = kunde.knr)
   ->  Seq Scan on ordre  (cost=0.00..52.92 rows=2192 width=21) (actual time=0.016..0.204 rows=2192 loops=1)
   ->  Hash  (cost=139.29..139.29 rows=3 width=25) (actual time=1.031..1.033 rows=5 loops=1)
         Buckets: 1024  Batches: 1  Memory Usage: 9kB
         ->  Nested Loop  (cost=0.29..139.29 rows=3 width=25) (actual time=0.174..1.010 rows=5 loops=1)
               ->  Seq Scan on kunde  (cost=0.00..10.12 rows=512 width=22) (actual time=0.004..0.057 rows=512 loops=1)
               ->  Memoize  (cost=0.29..0.67 rows=1 width=13) (actual time=0.002..0.002 rows=0 loops=512)
                     Cache Key: kunde.postnr
                     Cache Mode: logical
                     Hits: 336  Misses: 176  Evictions: 0  Overflows: 0  Memory Usage: 12kB
                     ->  Index Scan using poststedpn on poststed  (cost=0.28..0.66 rows=1 width=13) (actual time=0.004..0.004 rows=0 loops=176)
                           Index Cond: (postnr = kunde.postnr)
                           Filter: (((postnr)::integer >= 5500) AND ((postnr)::integer <= 5599))
                           Rows Removed by Filter: 1
 Planning Time: 0.945 ms
 Execution Time: 1.580 ms
(17 rows)
```

```sql 
explain analyze select * from mv_kunder_haugesund_omraadet;
                                                         QUERY PLAN                                                         
----------------------------------------------------------------------------------------------------------------------------
 Seq Scan on mv_kunder_haugesund_omraadet  (cost=0.00..12.00 rows=200 width=375) (actual time=0.019..0.023 rows=34 loops=1)
 Planning Time: 0.502 ms
 Execution Time: 0.050 ms
(3 rows)
```

- Men hva med oppdaterbarhet? 
- Hvis du bruker en **materialized view**, lagres dataene, og oppdateringene skjer ikke automatisk. Du trenger å kjøre REFRESH MATERIALIZED VIEW for å oppdatere dataene i materialized view-en.

```sql
update ordre set erbetalt = false where ordrenr = 22418; 
select * from ordre where ordrenr = 22418;
select * from mv_kunder_haugesund_omraadet where ordrenr = 22418;
refresh materialized view mv_kunder_haugesund_omraadet;
select * from mv_kunder_haugesund_omraadet where ordrenr = 22418;`
```

## Delspørringer
Se slides 7-16. 


## Vindusfunksjoner (Window Functions)

Window functions utfører beregninger på et sett med rader som er relatert til den nåværende raden, uten å kollapse radene til én (slik `GROUP BY` gjør). De brukes til rangeringer, løpende totaler, og sammenligninger innenfor grupper.

**Generell syntaks:**
```sql
funksjon() OVER (
    [PARTITION BY kolonne]  -- Del opp i grupper
    [ORDER BY kolonne]      -- Sorter innenfor gruppen
)
```

**Vanlige window functions:**

| Funksjon | Beskrivelse |
|----------|-------------|
| `RANK()` | Gir rang med hopp ved like verdier (1, 2, 2, 4) |
| `DENSE_RANK()` | Gir rang uten hopp ved like verdier (1, 2, 2, 3) |
| `ROW_NUMBER()` | Gir unikt løpenummer per rad |
| `SUM() OVER (...)` | Løpende sum |
| `AVG() OVER (...)` | Løpende eller partisjonert gjennomsnitt |

```sql
-- Ranger prosjekter innenfor hvert fellesskap basert
-- på antall medier de bruker
SELECT 
    f.navn AS fellesskap, 
    p.tittel AS prosjekt, 
    COUNT(m.medie_id) AS antall_medier, 
    RANK() OVER ( 
PARTITION BY f.fellesskap_id 
ORDER BY COUNT(m.medie_id) DESC ) 
  AS rangering 
FROM fellesskap f 
JOIN prosjekter p 
    ON f.fellesskap_id = p.fellesskap_id 
LEFT JOIN medier m 
    ON p.prosjekt_id = m.prosjekt_id 
GROUP BY 
    f.fellesskap_id, 
    f.navn, 
    p.prosjekt_id, 
    p.tittel;
-- output:
        fellesskap         |           prosjekt           | antall_medier | rangering 
---------------------------+------------------------------+---------------+-----------
 Dataingeniør-fellesskapet | Semesterprosjekt i databaser |             1 |         1
 Maskinlæring-gruppa       | Analyse av sentiment i tekst |             1 |         1
(2 rows)
``` 
- hva skal til for å få et mer meningsfull output?

- Annet eksempel (hobbyhuset-modellen)

```sql
SELECT
    V.Betegnelse,
    K.Navn AS Kategori,
    V.Pris,
    RANK() OVER (PARTITION BY K.Navn ORDER BY V.Pris DESC) AS Rang
FROM Vare V
JOIN Kategori K ON V.KatNr = K.KatNr
where k.navn = 'Busker';¨
-- output:
     betegnelse     | kategori |  pris  | rang 
--------------------+----------+--------+------
 Gul søyletuja      | Busker   | 550.00 |    1
 Hengebjørk         | Busker   | 412.50 |    2
 Dvergtuja          | Busker   | 412.00 |    3
 Japanbarlind       | Busker   | 412.00 |    3
 Sølvgran 'Globosa' | Busker   | 329.50 |    5
 Røsslyng           | Busker   | 274.50 |    6
 Europabarlind      | Busker   | 274.50 |    6
 Einer 'Tyrihans'   | Busker   | 247.00 |    8
 Hvitgran           | Busker   | 221.00 |    9
 Einer 'Blåmann'    | Busker   | 220.50 |   10
 Gran, standard     | Busker   | 166.00 |   11
(11 rows)
``` 

```sql
SELECT
    V.Betegnelse,
    K.Navn AS Kategori,
    V.Pris,
    DENSE_RANK() OVER (PARTITION BY K.Navn ORDER BY V.Pris DESC) AS Rang
FROM Vare V
JOIN Kategori K ON V.KatNr = K.KatNr
where k.navn = 'Busker';
-- output:
     betegnelse     | kategori |  pris  | rang 
--------------------+----------+--------+------
 Gul søyletuja      | Busker   | 550.00 |    1
 Hengebjørk         | Busker   | 412.50 |    2
 Dvergtuja          | Busker   | 412.00 |    3
 Japanbarlind       | Busker   | 412.00 |    3
 Sølvgran 'Globosa' | Busker   | 329.50 |    4
 Røsslyng           | Busker   | 274.50 |    5
 Europabarlind      | Busker   | 274.50 |    5
 Einer 'Tyrihans'   | Busker   | 247.00 |    6
 Hvitgran           | Busker   | 221.00 |    7
 Einer 'Blåmann'    | Busker   | 220.50 |    8
 Gran, standard     | Busker   | 166.00 |    9
(11 rows)
``` 

## Common Table Expressions (CTEs)

En CTE (Common Table Expression) er en midlertidig, navngitt resultattabell som defineres med `WITH`-nøkkelordet. CTEs gjør komplekse spørringer mer lesbare ved å dele dem opp i logiske steg.

**Generell syntaks:**
```sql
WITH navn_paa_cte AS (
    SELECT ...   -- Definer den midlertidige tabellen
)
SELECT *         -- Bruk den midlertidige tabellen
FROM navn_paa_cte
WHERE ...;
```

## Rekursjon: er det mulig i SQL?
```sql 
-- som bruker 'admin' i db-shell
create database rekursivitet;
```

```bash
# fra kommandovinduet på vertsmaskinen
docker-compose exec postgres psql -U admin -d rekursivitet -f test-scripts/rekursiv-cte-kategorier.sql
```

```sql
-- Konseptuelt eksempel: Finn alle underkategorier 
WITH RECURSIVE kategorier_hierarki AS (

-- 1. Ankerleddet (Startpunktet) 
SELECT kategori_id, navn, forelder_id, 1 AS nivaa 
FROM kategorier 
WHERE forelder_id IS NULL 

UNION ALL

-- 2. Rekursivt ledd (Refererer til seg selv) 
SELECT k.kategori_id, k.navn, k.forelder_id, kh.nivaa + 1 
FROM kategorier k 
JOIN kategorier_hierarki kh 
    ON k.forelder_id = kh.kategori_id ) 
SELECT * FROM kategorier_hierarki ORDER BY nivaa;

-- outuput:
 kategori_id |       navn       | forelder_id | nivaa 
-------------+------------------+-------------+-------
           1 | Elektronikk      |             |     1
           4 | Sport            |             |     1
           2 | Datamaskiner     |           1 |     2
           3 | Mobiltelefoner   |           1 |     2
          10 | Sykkel           |           4 |     2
           5 | Bærbare PC-er    |           2 |     3
           6 | Stasjonære PC-er |           2 |     3
           7 | Smarttelefoner   |           3 |     3
           8 | Tilbehør         |           3 |     3
          11 | Terrengsykkel    |          10 |     3
          12 | Bysykkel         |          10 |     3
           9 | Deksel           |           8 |     4
(12 rows)
``` 
- output bygges opp rekursivt:
```sql
(SELECT kategori_id, navn, forelder_id, 1 AS nivaa FROM kategorier WHERE forelder_id IS NULL) UNION ALL (SELECT k.kategori_id, k.navn, k.forelder_id, kh.nivaa + 1 FROM kategorier k JOIN (SELECT kategori_id, navn, forelder_id, 1 AS nivaa FROM kategorier WHERE forelder_id IS NULL) as kh ON k.forelder_id = kh.kategori_id);
```

## Diverse
### Liste ut alle triggere i en database

```sql
SELECT
    tgname AS trigger_name,
    relname AS table_name,
    n.nspname AS schema_name,
    tgtype AS trigger_type,
    tgenabled AS enabled
FROM
    pg_trigger t
JOIN
    pg_class c ON c.oid = t.tgrelid
JOIN
    pg_namespace n ON n.oid = c.relnamespace
WHERE
    NOT tgisinternal;  -- Filter out internal triggers
``` 

### Liste ut alle funksjoner (og prosedurer)
`\df` 