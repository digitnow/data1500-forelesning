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
- UC01-1: marker alle varer som koster 
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

UC01-2: Tell antall varer i de tre kategoriene (billig, middels, dyr):
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

UC01-3: Sorter slik at `dyr` er på toppen, så `middels` og så `billig` eller eventuelt omvendt (med desc):
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

I løsningen for UC01-3 bruker vi en ny `case-end`-konstruksjon for å definere heltallsverdier for sortering. 

- Vi kan også bruke case-end`-konstruksjon for å generere testdata.
- UC02: generer testdata for 100 sykler i tabellen `sykler` (ref. modellen fra oblig 1) basert på eksisterende data `stasjoner` og `laaser`:
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

## Litt ekstra om funksjoner og triggere i Postgres
- La oss tenke en "use case" hvor vi ønsker å lagre lokasjon for hver sykkel. Koordinatene for stasjonenen er faste, men hva hvis vi også ønsker å se på hvor de utleide syklene er til enhver tid. 
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


## 


## DO-END (Postgres)
Eller med ´do-end´ og ´loop´ konstruksjoner i Postgres:

```sql 
do $$
declare 
    for i in 1..100 loop
        insert into sykler (modell, innkjopsdato, status, stasjon_id, laas_id)
        values ('Modell ' || i, current_date - (i % 30), 'tilgenelig', (i % 7 + 1), (i % (7 *20) + 1));
    end loop
end $$

```

```sql
create procedure int_div (
    in x int,
    in y int,
    out d int,
    out r int
)
begin
    set d = x div y;
    set r = x mod y;
end
``` 

## Liste ut alle triggere i en database

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

## Liste ut alle funksjoner (og prosedurer)
`\df` 
