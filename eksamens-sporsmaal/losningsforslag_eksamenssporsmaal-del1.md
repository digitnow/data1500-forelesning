# Løsningsforslag relevante eksamensspørsmål del 1

1. Et korrekt svar her innebærer å foreslå en egen tabell for telefonnumre og definere et forhold mellom Ansatt og den nye tabellen med kardinalitet 1 ansatt:1 eller mange telefonnumre. Kan også modelleres me at en ansatt ikke trenger å ha et telefonnummer (Ansatte 1---0{ AnsatteTlfNumre). Se side 195-196 i pensumboken (5. utgave) om sammensatte, flerverdi- og avledede attributter. Bruken av funksjoner som er DBHS-avhengige er ikke en optimal løsning (i tilfelle man må migrere til andre DBHS).

2. "Naturlige" nøkler kan endre seg over tid, derfor bruker man vanligvis surrogatnøkler. Sammensatte nøkler kan gi kompliserte joins og også bidra til at tabellen blir på et lavere normalform (1NF, for eksempel).

Flere typer surrogatnøkler:
- Som SERIAL i Postgresql eller "auto-increment" i andre DBHS, som gir en løpende teller, dvs. 1,2,3 i det nye rader blir satt inn i databasen.
- GUID/UUID som er er tilfeldig generert streng, som er nesten 100% garantert unik

Fordeler med GUID:
- GUIDs kan genereres på klientsiden uten å kontakte databasen. 
- GUIDs er globalt unike (nyttig ved sammenslåing av databaser)
- GUIDs avslører ikke antall rader i tabellen. 

Ulempen er at de tar mer plass og er tregere å indeksere enn heltall.

Se side 71 i pensumboken (5. utgave) hvor forskjellige typer av primærnøkler er omtalt (naturlig, surrogat- og sammensatt nøkkel).

3. Se i side 188 i pensumboken (5. utgave) om forhold mellom 3 eller flere entiteter.

I modellen A kobler koblingstabellen Utleier sammen entitetene Bruker, Sykler og Stasjoner.

4. Se side 141 i pensumboken (5. utgave) om rekursjon. 
I tabellen Ansatte legge inn en fremmednøkkel leder_id som peker på ansatt_id i samme tabell. 

5. Se side 195-196 i pensumboken (5. utgave) om sammensatte, flerverdi- og avledede attributter. Sammensatt attributt adresse deles i gate, postnr, poststed.

6. Se side 184-185 i pensumboken (5. utgave) om svake entiteter og identifiserende forhold. 
En sterk entitet eksisterer uavhengig av andre entiteter, som Sykkel, for eksempel. En svak entitet avhenger av en annen entitet. For å illustrere det kan ma inføre en ny tabell SykkelSkade, som vil gi en historikk over alle skader på sykler (eksistensen til forekomster av SykkelSkade avhenger av eksistensen til forekomsten av entiteten den er knyttet til, - Sykkel).

Identifikatoren til en svak entitet er helt eller delvis arvet fra andre entiteter, for eksempel, SykkelSkade (sykkel_id, skade_dato ...). sykkel_id + skade_dato kan være en identifikator til SykkelSkade. 

7. Se side 180-181 i pensumboken (5. utgave) for omtale av kardinalitet. En avdeling har ingen eller mange ansatte, en ansatt tilhører nøyaktig en avdeling. Man kan også modellere med at en avdeling har minst 1,2,3 osv. eller mange ansatte, dvs. spesifisere kardinalitetene med et konkret tall, hvis det er slik praksisen er i bedriften (man kan da ikke legge inn en ny avdeling uten at man også legger inn 1 eller flere ansatte).

8. Se side 187-188 i pensumboken om koblingsentiteter.
Løses med koblingstabellen Deltakelser.

9. Se side 226-227 for en diskusjon om `total deltakelse`. I Modell A (Bysykkel) hadde en totaldeltakelse vært hvis man ikke kunne registrere en sykkel uten at man samtidig måtte registrere minst en (eller flere) utleier. En naturlig måte å modellere i dette tilfelle skal være at en sykkel kan ha ingen eller mange utleier. Dvs. Sykler trenger ikke å delta i forholdet til Utleier/Turer. I Utleier må sykkel_id ha en verdi som finnes i Sykler og kan ikke være null.

10. `Turneringer ||..|{ Løp` (1:N) En turnering må ha minst ett løp, dvs. man kan ikke registrere en turnering uten å registrere et løp samtidig. Hvis forholdet er `Turneringer ||..o{ Løp` så kan man definere fremmednøkkel direkte i `CREATE TABLE Lop (...);`. 
I praksis er `||..|{` på mange-siden i et ER-diagram et designmål, ikke nødvendigvis noe som håndheves i databasen fra dag én. De fleste systemer:
- Håndhever NOT NULL på FK (løp må ha en turnering) — deklarativt.
- Håndhever "minst ett løp" via applikasjonslogikk eller trigger — imperativt.
- Aksepterer at en nyopprettet turnering midlertidig kan ha null løp (i løpet av én transaksjon) mens løpene legges inn (deferrable kan brukes for sirkulære avhengigheter som `Land ||--|| Hovedstad` og for aggregerte betingelser som "minst ett løp", der turnering og lop har ett forhold hvor de avhenger av hverandre `Turneringer ||..|{ Løp`).


```sql 
-- Med triggere er dette "messy"
CREATE TABLE Turneringer (
	turnering_id serial primary key,
	navn text not null,
	start_dato date not null,
	premiepott numeric(12,2) not null check (premiepott >= 0)
);
CREATE TABLE Lop (
	lop_id serial primary key,
	turnering_id INTEGER NOT NULL, 
	bane_navn text not null,
	vaerforhold text not null default 'Ukjent'
);
CREATE OR REPLACE FUNCTION turneringer_after_insert_lop()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO Lop (turnering_id, bane_navn) values (NEW.turnering_id, 'BaneNord');
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_turnering_after_insert
AFTER INSERT ON Turneringer 
FOR EACH ROW
EXECUTE FUNCTION turneringer_after_insert_lop();

-- Med deferrable noe enklere, men ikke alle DBHS har denne
-- funksjonaliteten og man må innføre sirkularitet (alternativer
-- er triggere eller løsning i applikasjonslaget)
CREATE TABLE Turneringer (
    turnering_id  SERIAL   PRIMARY KEY,
    navn          TEXT     NOT NULL,
    start_dato    DATE     NOT NULL,
    forste_lop_id INTEGER  NOT NULL,         -- sikrer at minst ett løp finnes
    CONSTRAINT fk_tur_forste_lop FOREIGN KEY (forste_lop_id)
        REFERENCES Lop(lop_id)
        DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE Lop (
    lop_id        SERIAL   PRIMARY KEY,
    turnering_id  INTEGER  NOT NULL,
    bane_navn     TEXT     NOT NULL,
    CONSTRAINT fk_lop_turnering FOREIGN KEY (turnering_id)
        REFERENCES Turneringer(turnering_id)
        DEFERRABLE INITIALLY DEFERRED
);
BEGIN;

-- Steg 1: Sett inn turneringen (forste_lop_id=1 finnes ikke ennå — sjekk utsatt)
INSERT INTO Turneringer (turnering_id, navn, start_dato, forste_lop_id)
VALUES (1, 'Nordic Open 2026', '2026-05-01', 1);

-- Steg 2: Sett inn løpet (turnering_id=1 finnes nå)
INSERT INTO Lop (lop_id, turnering_id, bane_navn)
VALUES (1, 1, 'Nürburgring');

-- Ved COMMIT:
-- ✓ forste_lop_id=1 finnes i Lop
-- ✓ turnering_id=1 finnes i Turneringer
COMMIT;

-- Hvis en constraint er DEFERRABLE INITIALLY IMMEDIATE, 
-- kan du utsette den manuelt for én transaksjon
BEGIN;
SET CONSTRAINTS fk_tur_forste_lop DEFERRED;
-- ... gjør innsettinger ...
COMMIT;
```

Den viktigste tommelfingerregelen: DEFERRABLE løser problemer der en enkelt transaksjon trenger å sette inn data i en rekkefølge som midlertidig bryter en constraint, men som er konsistent ved COMMIT.

11. 1:1 leder_id i Avdelinger kan være NULL ved opprettelse, oppdateres etter at lederen er lagt inn i Ansatte.

```sql
CREATE TABLE Avdelinger (
	avdeling_id serial primary key,
	navn text not null,
	leder_id integer -- fremmednøkkel legges til senere
);
CREATE TABLE Ansatte (
	ansatt_id serial primary key,
	navn text not null,
	avdeling_id integer not null references Avdelinger(avdeling_id)
);
ALTER TABLE Avdelinger
	ADD CONSTRAINT fk_avd_leder
	FOREIGN KEY (leder_id) REFERENCES Ansatte(ansatt_id);

BEGIN;
INSERT INTO Avdelinger (navn) values ('Aalesund');
INSERT INTO Ansatte (navn, avdeling_id) values('Bjørn Samuelson', (select avdeling_id from Avdelinger where navn = 'Aalesund' limit 1));
UPDATE Avdelinger SET leder_id = (select ansatt_id from Ansatte where navn = 'Bjørn Samuelson');
COMMIT;
```

12. Identifiserende: svak entitet der fremmednøkkelen er del av primærnøkkelen. Ikke-identifiserende: fremmednøkkelen er ikke del av primærnøkkelen.

Alle forhold i Modell A er identifiserende. 

Man kunne gjort forholdet mellom Sykler og Turer identifiserende ved bruk av en sammensatt nøkkel (sykkel_id, start_tid). 

Se side 220-222 i pensumboken (5. utgave). En svak entitet befinner seg alltid på mange-siden av en-til-mange forholdet. Den mottar fremmednøkkel ved den generelle regelen for en-til-mange forhold. 

Se eksempel i pensumboken (Figur 8.6).
```
Kino -||--o{ Kinosal
Kino (kino_navn, telefon)
Kinosal (kino_navn, kinosal_nr, antall_plasser)
```

En identifiserende en-til-en forhold med en svak entitet blir håndtert på samme måte, ved at den svake entiteten mottar en fremmednøkkel fra den andre entiteten. 

Se eksempel, hvor det er en identifiserende forhold mellom Ansatte og Kontorplasser siden ansatt_id er valgt som primærnøkkel i Kontorplasser (en ansatt per kontor). Man kunne også valgt rom_id som primærnøkkel, siden det er kun en ansatt av gangen som kan befinne seg på ett rom.
```
Ansatte -||--o|- Kontorplasser -|o..||- Rom
Ansatte (ansatt_id, fornavn, etternavn)
Kontorplasser (ansatt_id, rom_id)
Rom (rom_id, kvm)
``` 

Koblingsentiteter (assosiative entiteter) er alltid identifiserende, men betraktes ikke som svake entiteter, siden de brukes for et spesifikt formål, - å løse opp mange-til-mange forhold mellom to sterke entiteter.

Analyse av forskjell på å bruke / ikke bruke surrogatnøkkel:

|                                | Surrogatnøkkel (`tur_id`) | Naturlig nøkkel (`sykkel_id, start_tid`) |
| ------------------------------ | ------------------------- | ---------------------------------------- |
| Relasjon til Sykler            | Ikke-identifiserende      | **Identifiserende**                      |
| Forretningsregel håndhevet     | Krever separat UNIQUE     | Automatisk via PK                        |
| FK i avhengige tabeller        | Enkel (én kolonne)        | Sammensatt (to kolonner)                 |
| Robusthet mot datakorreksjoner | Høy                       | Lav (kaskadeproblemer)                   |
| Lesbarhet i spørringer         | God                       | Mer kompleks                             |
| Vanligst i praksis             | **Ja**                    | Sjeldnere                                | 

13. Hva er en sammensatt primærnøkkel? Hvilken tabell i Modell B (E-sport) bør ha dette?

Deltakelser (spiller_id, lop_id)


14. Forklar konseptet referanseintegritet. Hva skjer i Modell A (Bysykkel) hvis man prøver å slette en Stasjon som har tilknyttede Utleier? Lag "CREATE TABLE" setninger for Modell A med datatyper og de nødvendige betingelsene samt legg inn mockdata (bruk gjerne delspørringer).

Tester forståelse av hvordan primærnøkler sammen med fremmednøkler definerer regler for forhold mellom entiteter. Tester ferdigheter til å velge egnede nøkler (både primære og fremmede), velge datatyper for attributtene og definere betingelser. 
Attributtet status i Sykler defineres slik:  
`status text not null check (status IN ('Aktiv', 'På verksted', 'Stjålet')),`
Legg selv inn en betingelse for kapasitet i Stasjoner (må være mer enn 0).

En fremmednøkkel må peke på en gyldig primærnøkkel. Sletting av stasjon med turer vil feile (hvis ikke CASCADE).

**Praktisk**

Demonstrerer definisjon av skjema og innsetting av mockdata.

```sql 
CREATE TABLE Stasjoner (
    stasjon_id serial primary key,
    navn text not null, 
    kapasitet integer not null check (kapasitet > 0),
    lat numeric(9,6),
    lon numeric(9,6)
);
CREATE TABLE Sykler (
	sykkel_id serial primary key,
	status text not null check (status IN ('Aktiv', 'På verksted', 'Stjålet')),
	stasjon_id integer references Stasjoner(stasjon_id),
	sist_vedlikeholdt date
);
CREATE TABLE Brukere (
	bruker_id serial primary key,
	navn text not null,
	telefon text unique,
	betalingsmetode text not null
);
CREATE TABLE Utleier (
	tur_id serial primary key,
	sykkel_id integer not null references Sykler(sykkel_id),
	bruker_id integer not null references Brukere(bruker_id),
	start_stasjon integer not null references Stasjoner(stasjon_id),
	slutt_stasjon integer references Stasjoner(stasjon_id),
	start_tid timestamptz not null,
	slutt_tid timestamptz,
	pris numeric(8,2)
);
INSERT INTO Stasjoner (navn, kapasitet, lat, lon)
values ('Jernbanetorget', 20, 59.911, 10.750),
('Aker Brygge', 15, 59.909, 10.729);

insert into Sykler (status, stasjon_id, sist_vedlikeholdt)
values ('Aktiv', (select stasjon_id from Stasjoner where navn = 'Jernbanetorget'), NULL),
('Aktiv', (select stasjon_id from Stasjoner where navn = 'Aker Brygge'), '2026-01-10');
insert into Brukere (navn, telefon, betalingsmetode) values ('Ane Andersen', '90100100', 'Vipps');
insert into Utleier (sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris) values (1, (select bruker_id from Brukere where navn = 'Ane Andersen'),(select stasjon_id from Stasjoner where navn = 'Jernbanetorget'), (select stasjon_id from Stasjoner where navn = 'Aker Brygge'), '2026-04-27 08:00:00+02', '2026-04-27 08:30:00+02', 25.00);
update sykler set stasjon_id = 2 where sykkel_id = 1;
``` 

Prøver å slette en stasjon som er registrert i Utleier:
```sql
delete from Stasjoner where navn = 'Jernbanetorget';

ERROR:  update or delete on table "stasjoner" violates foreign key constraint "sykler_stasjon_id_fkey" on table "sykler"
DETAIL:  Key (stasjon_id)=(1) is still referenced from table "sykler".
```

15. Hva er formålet med ON DELETE CASCADE? Når bør det brukes, og når det farlig?

Sletter "barn-rader" automatisk. Farlig fordi det kan slette historikk (Utleier) ved et uhell.

```sql
alter table Sykler drop constraint sykler_stasjon_id_fkey;

alter table Sykler add constraint sykler_stasjon_id_fkey
foreign key (stasjon_id) references Stasjoner(stasjon_id)
on delete cascade;

delete from Stasjoner where navn = 'Jernbanetorget';

ERROR:  update or delete on table "stasjoner" violates foreign key constraint "utleier_start_stasjon_fkey" on table "utleier"
DETAIL:  Key (stasjon_id)=(1) is still referenced from table "utleier".
```
```sql 
alter table Utleier drop constraint utleier_start_stasjon_fkey;

alter table Utleier add constraint utleier_start_stasjon_fkey
foreign key (start_stasjon) references Stasjoner(stasjon_id)
on delete cascade;

-- Nå blir raden i Utliere slettet
delete from Stasjoner where navn = 'Jernbanetorget';
DELETE 1
select * from utleier;
 tur_id | sykkel_id | bruker_id | start_stasjon | slutt_stasjon | start_tid | slutt_tid | pris 
--------+-----------+-----------+---------------+---------------+-----------+-----------+------
(0 rows)

select * from stasjoner;
 stasjon_id |    navn     | kapasitet |    lat    |    lon    
------------+-------------+-----------+-----------+-----------
          2 | Aker Brygge |        15 | 59.909000 | 10.729000
(1 row)

select * from sykler;
 sykkel_id | status | stasjon_id | sist_vedlikeholdt 
-----------+--------+------------+-------------------
         2 | Aktiv  |          2 | 2026-01-10
         1 | Aktiv  |          2 | 
(2 rows)

```

Legg merke til at selv om slutt_stasjon er også en fremmenøkkel som peker på sykkel_id i Sykler, forårsaket det ingen feilmelding. Grunnen er selvsagt at verdien til slutt_stasjon var 2 og ikke 1, dvs. ikke stasjonen som ønsket å slette. Ingen rader ble heller ikke slettet i Sykler, siden ingen av stasjonene hadde stasjon_id lik 1.

16. I Modell C (Bedrift), bør leder_id i Avdelinger ha en UNIQUE-constraint? Hvorfor/hvorfor ikke?

Ja, hvis en ansatt kun kan lede én avdeling. 

17. Hva er en kandidatnøkkel? Finn en mulig kandidatnøkkel i tabellen Brukere fra Modell A (Bysykkel).

Tester kjennskap til betydning av nøkler i relasjonsmodellen og ferdigheter å velge relevante super-, kandidat- og primærnøkler for en relasjon / tabell.

CREATE TABLE Brukere (
	bruker_id serial primary key,
	navn text not null,
	telefon text unique,
	betalingsmetode text not null
);

Anta at vi ønsker å erstatte surrogatnøkkelen bruker_id, som brukes som primærnøkkel, med en annen attributt eller en kombinasjon av attributter.

Både navn og telefon kan være kandidatnøkler. navn er en dårlig kandidatnøkkel da det er forholdsvis vanlig med like navn. telefon er bra og epost kan også være bra, hvis det er lagt til.

18. Hvordan håndterer man at en Sykkel kan være på et verksted eller er utleid og dermed ikke tilknyttet noen Stasjon for øyeblikket?

stasjon_id i Sykler kan være NULL når sykkelen er utleid (status "Aktiv") eller på verksted (status "På verksted").


19. Bysykkel-selskapet ønsker å spore historikken til sykkelens status (f.eks. når den gikk fra "Aktiv" til "På verksted"). Hvordan må modellen utvides for å støtte dette?

Det er vanlig med å lage en ny tabell for historikken. For eksempel kan vi lage tabellen SykkelStatusHistorikk(sykkel_id, status, fra_dato, til_dato). En kandidatnøkkel er (sykkel_id, fra_dato).

20. I Modell C (Bedrift), hvordan modellerer du at en ansatt bytter avdeling over tid, og man trenger å vite hvilken avdeling de jobbet i på en bestemt dato?

Ny tabell AnsattAvdelingHistorikk(ansatt_id, avdeling_id, start_dato, slutt_dato). Kandidatnøkkel (ansatt_id, avdeling_id, start_dato).

21. Modell B (E-sport) trenger å lagre telemetridata (fart, posisjon) 60 ganger i sekundet per spiller per løp. Horfor er en tradisjonell relasjonsdatabase dårlig egnet for dette, og hvordan bør det modelleres i stedet?

Relasjons-DB vil ikke takle skrivehastigheten, så kolonne- eller tidsserie-database må brukes. Man kan bruke Timescaledb (https://timescaledb.org/) sammen med PostgreSQL.


22. Hvordan Modelllerer man en hierarki med uendelin dybde (f.eks. kategorier av utstyr i Modell C (Bedrift)).

Eksempel: 
``` 
Kari (CEO)
├── Ola (IT-sjef)
│   ├── Ane (Utvikler)
│   └── Bjørn (Utvikler)
└── Per (Salgssjef)
    └── Lise (Selger)
```

Hver rad peker på sin direkte forelder via en leder_id-fremmednøkkel. 
```
| ansatt\_id | navn  | leder\_id |
| ---------- | ----- | --------- |
| 1          | Kari  | NULL      |
| 2          | Ola   | 1         |
| 3          | Ane   | 2         |
| 4          | Bjørn | 2         |
| 5          | Per   | 1         |
| 6          | Lise  | 5         |
```

Raskt å oppdatere, tregt å søke.

23. Hva er forskjellen på et stjerneskjema og en normalisert transaksjonsmodell (OLTP)? Hvilke av de tre modellene egner seg best for OLTP? 

OLTP:
- Høy normaliseringsgrad (3NF eller BCNF)
- Mange tabeller med få kolonner
- Mange JOINs nødvendig for å hente sammensatt informasjon
- Optimalisert for skriving og punktlesing (én rad om gangen)
- Eksempel: Bedriftsmodellen, NS 4102-regnskapsmodellen

For å hente data fra en normalisert transaksjonsmodell (OLTP) må man bruke lange spørringer, f.eks. for å besvare et relativt enkelt spørsmål "hvor mange timer er allokert per avdeling per prosjekt?" må følgende SQL-spørring utføres:

```sql 
SELECT av.navn AS avdeling, pr.navn AS prosjekt, SUM(pd.timer_allokert)
FROM Prosjektdeltakelse pd
JOIN Ansatte a   ON pd.ansatt_id   = a.ansatt_id
JOIN Avdelinger av ON a.avdeling_id = av.avdeling_id
JOIN Prosjekter pr ON pd.prosjekt_id = pr.prosjekt_id
GROUP BY av.navn, pr.navn;
``` 

Star schema:
- Lav normaliseringsgrad — dimensjoner er bevisst denormaliserte
- Få tabeller, men brede tabeller (mange kolonner)
- Få JOINs nødvendig — alltid direkte fra fakta til dimensjon
- Optimalisert for lesing og aggregering over store datamengder
- Redundans er akseptert for å oppnå ytelse

> OLTP er for å registrere hva som skjer. Star Schema er for å forstå hva som har skjedd.

Et typisk system bruker begge modeller:
- OLTP-databasen (PostgreSQL) tar imot alle transaksjoner i sanntid — timeregistreringer, prosjektoppdateringer, ansettelser.
- En ETL-prosess (Extract, Transform, Load) kjører nattlig og kopierer og transformerer data fra OLTP til et datavarehus med stjerneskjema.
- Lederrapporter, dashboards og BI-verktøy (Power BI, Tableau) spør mot datavarehuset — ikke mot OLTP-databasen — for å unngå å belaste produksjonssystemet.

24. Model A (Bysykkel): En tur kan pågå akkurat nå (den har ingen slutt_tid eller slutt_stasjon ennå). Hvordan påvirker dette datatypene og constraints for disse kolonnene?

Begge må tillate NULL under pågående tur.

25. Model B (E-sport): En turnering kan ha lag i stedet for individuelle spillere. Hvordan må modellen endres for å støtte både lag-baserte og individuelle turneringer?

(1) Lag en ny tabell Lag (lag_id, navn, region) og Spillere får lag_id. Deltakelser peker på lag_id i stedet for spiller_id. Må diskutere om en spiller kan være med i flere lag i forskjellige tidsperioder. Kan også tillate "lag" med én spiller.

(2) Alternativt kan lage en koblingsentitet mellom Spillere, Lag og Turneringer, LagMedlemmer (lag_id, spiller_id, turnering_id, rolle) med kandidatnøkkel (lag_id, spiller_id, turnering_id). Et lag kan ha ulike spillere i ulike turneringer. Man kunne også velge å skille mellom Spillere og Lag, kan man også vurdere egen tabell for Lag- og Spiller Deltakelser, dvs. splitte Deltakelser tabellen i to tabeller.

Modellen for alternativet (1):
```
Spillere (spiller_id, brukernavn, region, rank, lag_id)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (lag_id, lop_id, plasseringer, beste_rundetid)
Lag (lag_id, navn, region)
``` 

26. Model C (Bedrift): En ansatt kan ha ulik timepris avhengig av hvilket prosjekt de jobber på. Hvor i modellen bør timepris lagres?

I koblingstabellen ProsjektDeltakelser.

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert, timepris)
``` 

27. Hva er "denormalisering"? Git ett eksempel på når det kan være fornuftig å denormalisere entiteten Utleier i Modell A (Bysykkel) for ytelsens skyld. 

Denormalisering betyr å gå tilbake til et lavere normaliseringsgrad, dvs. gå tilbake på kravene om at ingen attributter i en entitet, som ikke inngår i primærnøkkel inngår i funksjonelle avhengigheter, og at ingen attributter avhenger av kun av deler av en sammensatt primærnøkkel og at ingen attributter er sammensatte, fleverdi- eller avledede attributter. 

Et første steg kan være å gå fra 3NF til 2NF, for eksempel, ved å sette inn bruker_navn (som da tilsvarer navn i entiteten brukere) for å unngå en join mot entiteten Brukere, når man skal finne navnet til den som har leid sykkelen. Entiteten Utleier er da ikke lenger på 3NF, siden det er en funksjonell avhengighet mellom bruker_id og bruker_navn, og ingen av disse inngår i primærnøkkelen til Utleier.

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, bruker_navn, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

28. Hordan modellerer man at en Sykkel i Modell A (Bysykkel) kan ha ulike typer utstyr (f.eks. barnesete, piggdekk, kurv) der en sykkel kan ha flere typer utstyr, og utstyret kan flyttes mellom sykler?

Siden utstyr kan flyttes mellom sykler, kan ett sykkel ha ingen eller mange utstyrsenheter (barnesete, piggdekk osv.), og en utstyrsenhet kan tilhøre ingen eller flere sykler, men selvsagt ikke samtidig. Dette gir en mange-til-mange forhold mellom Sykler og Utstyr

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Utstyr (utstyr_id, utstyr_navn, utstyr_status)
SykkelUtstyr(sykkel_id, utstyr_id, montert_dato)
``` 

Legg merke til at når én utstyrsenhet har vært montert på én sykkel, må man bruke en tidsattributt, som må inngå i primærnøkkelen til entiteten SykkelUtstyr for å modellere det faktum at én utstyrsenhet kan ikke samtidig være montert på flere sykler eller at én sykkel kan ikke ha montert den samme utstyrsenheten. 

Vi trenger også å markere at én utstyrsenhet er montert på en sykkel eller er tilgjengelig for montering. Det kan gjøres på forskjellige måter, - modellere med utstyr_status i entiteten Utstyr eller eventuelt legge inn demontert_dato i entiteten SykkelUtstyr. Alle alternativer har sine fordeler og ulemper. En fordel med å legge inn utstyr_status i Utstyr entiteten er at det er enkelt å finne alle utstyrsenheter som er tilgjengelig/ledige. Det krever at dette attributtet blir oppdadert hver gang en utstyrsenhet blir montert/demontert (eventuelt skadet osv.).

29. I Modell B (E-sport), hvordan vil du lagre "Replay buffer" (de siste 30 sekundene av løpet for alle spillere) for umiddelbar visning ved krasj? Hvilken databaseteknologi/modelleringsteknikk egner seg her?

Her må man tenke på en type høyhastighetscache og da kunne man valgt en  nøkkel-verdi databasesystem, f.eks. Redis.

30. Skriv en SQL-spørring som henter alle ansatte som ble ansatt etter 1. januar 2020. Gjelder Modell C (Bedrift).

Analyserer output og input (husk at elementer man operere på i relasjonsmodellen er alltid entiteter / tabeller).

Output (projeksjon): alle attributter fra ansatte (det er ikke spurt eksplisitt om noen spesifikke attributter fra entiteten ansatte, så man skal vise alle (`*`)attributtene fra entiteten ansatte).

Input (from): entiteten Ansatte 

Seleksjon: betingelse "ble ansatt etter 1. januar 2020"; vi må se på modellen for å finne det relevante attributtet og det er ansettelsesdato.

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

Vi kan splitte opp operasjonen i to steg:
- først velger vi alle data fra entiteten Ansatte
- så filtrerer vi ut de radens om tilfredsstiller at ansettelsesdato er etter (større) 1. januar 2020. 

```sql
select * from Ansatte where ansettelsesdato > '2020-01-01';
```  

31. Hvordan finner du alle sykler som har status 'På verksted' eller 'Stjålet'? Bruk IN-operatoren. Gjelder Modell A (Bysykkel).

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

Input: Sykler

Hvis det ikke er eksplisitt spesifiert hvilke attributter skal man vise i outputen brukes det "alle", dvs `*`.

Output: alt fra sykler

Seleksjon: betingelse for hvilke rad skal velges ut av alle dataene i entiteten Sykler; vi må anta her at de relevante tekststrengene for status finnes i tabellen

```sql
select * from Sykler where status IN ('På verksted', 'Stjålet');
-- alternativt 
select * from Sykler where status = 'På verksted' and status = "Stjålet";
```


32. Skriv en SQL-spørring som henter alle spillere der brukernavnet starter med 'Pro_'. Gjelder Modell B (E-sport).

```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plasseringer, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 
Input: Spillere

Output (projeksjon): alle attributter fra spillere

Seleksjon: betingelse "der brukernavnet starter med 'Pro_'"

Bruker operatoren LIKE sammen med jokertegn `%`, som betyr "et eller annet" (se pensumboken 5. utgave, side 48-49).

```sql 
select * from Spillere WHERE brukernavn LIKE 'Pro_%';
```

33. Hvordan sorterer du utleier slik at den lengste av utleiene (i tid) kommer først? Anta at typen til tidsattributtene er TIMESTAMPTZ, som automatisk returnerer en verdi av typen INTERVAL (en type for varighet).
Hvordan kan man unngå å selektere pågående turer? Gjelder Modell A (Bysykkel).

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

Input: Utleier

Output: her skal vi vise varighet av hver utleie i output, så da kan vi ikke bare bruke `*` (alt/alle). Vi må velge noen attributter fra Utleier, f.eks. tur_id, bruker_id, og (slutt_tid - start_tid) as varighet (her bruker vi omdøping). I tillegg er det ikke en god praksis å selektere pågående turer, dvs. der hvor slutt_tid er lik NULL. 

Seleksjon: verdiene for tidspunkter når uleien blir startet og avsluttet

En måte å beregne varighet på er å subtrahere start_tid fra slutt_tid, dvs. (slutt_tid - start_tid). Etterpå kan man sortere på varigheten med ORDER BY. Vi kan bruke "descending" for å vise den lengste turen øverst i outputen.

```sql
select tur_id, bruker_id, (slutt_tid - start_tid) as varighet
from Utleier 
where slutt_tid is not null
order by varighet desc;
```

34. Hva er forskjellen på WHERE og HAVING? Skriv SQL-setninger for følgende spørsmål:
- Finn totalt antall timer allokert per prosjekt, men bare for ansatte i avdeling 1.
- Finn prosjekter der totalt antall timer allokert er over 100.
- Finn avdelinger der ansatte som ble ansatt etter etter 1. januar 2026, til sammen har over 200 timer allokert på prosjekter.

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

- WHERE filtrerer rader før agreggering, HAVING filtrerer grupper etter aggregering.
- HAVING kan bruke agreggatfunksjoner (SUM, COUNT, AVG osv.), mens WHERE kan ikke det.
- WHERE skal alltid være før HAVING i en SQL-spørring.

Eksempel: Finn totalt antall timer allokert per prosjekt, men bare for ansatte i avdeling 1. 

Her filtrerer vi ut alle rader der avdeling er ikke lik 1 før SUM beregnes. 
```sql 
select pd.prosjekt_id, SUM(pd.timer_allokert) as total_timer
from Prosjektdeltakelse pd 
join Ansatte a ON pd.ansatt_id = a.ansatt_id
where a.avdeling_id = 1
group by pd.prosjekt_id;
```
Eksempel: Finn prosjekter der totalt antall timer allokert er over 100.

Her vises kun prosjekter som har mer enn 100 timer allokert og det brukes ingen where-filtrering her. Her trenger vi ingen join, siden all informasjon finnes i tabellen Prosjektdeltakelse (vi hadde strengt tatt ikke trengt å bruke alias `pd` for tabellnavnet `Prosjektdeltalk`).
```sql
select pd.prosjekt_id, SUM(pd.timer_allokert) as total_timer
from Prosjektdeltakelse pd 
group by pd.prosjekt_id
having sum(pd.timer_allokert) > 100;
``` 

Eksempel: Finn avdelinger der ansatte som ble ansatt etter etter 1. januar 2026, til sammen har over 200 timer allokert på prosjekter. Anta at ansettelsesdato er av typen date.
```sql
select a.avdeling_id, sum(pd.timer_allokert) as total_timer
from Prosjektdeltakelse pd 
join Ansatte a on pd.ansatt_id = a.ansatt_id
where a.ansettelsesdato > '2026-01-01' -- filtrerer enkeltposter
group by a.avdeling_id
having sum(pd.timer_allokert) > 200; -- filtrerer grupper
```

Viktig å huske at hvis man trenger å filtrere på en egenskap ved én rad, bruker man WHERE, mens hvis man trenger å filtrere på en egenskap ved en gruppe (sum, antall, gjennomsnitt), bruker man HAVING.


35. Skriv en SQL-spørring som henter de 10 nyeste Utleier for en spesifikk bruker_id X. Gjelder Modell A (Bysykkel).

For å hente et antall rader av et sortert liste med rader brukes set LIMIT-klausulen. Først sortere man rader basert på betingelsen "nyeste utleier", hvor man da kan bruke "descending". 

Med denne spørringene får man også med påbegynte utleier.
```sql
select * from Utleier 
where bruker_id = X 
order by start_tid desc
limit 10
```

36. Skriv en spørring som teller antall ansatte i hver Avdeling. Resultatet skal vise avdelingsnavn og antall. Gjelder Modell C (Bedrift).

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

Bruker her left join for å eventuelt vise avdelingene med ingen ansatte.
```sql 
select a.navn, count(an.ansatt_id)
from Avdelinger a
left join Ansatte an 
on a.avdeling_id = an.avdeling_id
group by a.navn; -- husk at alle attributter i select må også være her
```


37. Hvordan finner du den gjennomsnittlige prisen for en bysykkelutleie? Gjelder Modell A (Bysykkel).

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

```sql
select avg(pris) as gjennomsnittspris
from Utleier;
```

38. Skriv en SQL-spørring som finner den totale premiepotten for alle turneringer i 2025.

Funksjonen for å trekke ut årstallet fra en dato X er `extract(year from X)`.

```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plasseringer, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 

Siden where-klausulen blir evaluert før select-klausulen, blir summen beregnet kun på et utvalg av rader fra Turneringer.
```sql 
select sum(premiepott) from Turneringer 
where extract(year from start_dato) = 2025
```

39. Hvordan finner du den stasjon som har hatt flest utleier som startet der? Hvordan kan man vise flere stasjoner, hvis de har lik antall av flest utleier? Gjelder Modell A (Bysykkel).

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

```sql
select start_stasjon, count(*) as antall_utleier
from Utleier 
group by start_stasjon 
order by antall_utleier desc
limit 1; -- kun en rad, uansett om det er flere stasjoner med samme antall utleier
```

Eksempel: Vis hvordan man kan returnere flere stasjoner som har lik antall utleier som er startet fra stasjonen.
```
select * from stasjoner;
 stasjon_id |      navn      | kapasitet |    lat    |    lon    
------------+----------------+-----------+-----------+-----------
          2 | Aker Brygge    |        15 | 59.909000 | 10.729000
          3 | Jernbanetorget |        20 | 59.911000 | 10.750000
          4 | Youngs torget  |        15 | 59.900000 | 10.000000
          5 | Domskirken     |        15 | 59.921000 | 10.799000
(4 rows)

select * from uleier
 tur_id | sykkel_id | bruker_id | start_stasjon | slutt_stasjon |...
--------+-----------+-----------+---------------+---------------+---
      7 |         1 |         1 |             5 |             2 |... 
      8 |         2 |         1 |             2 |             2 |... 
      9 |         1 |         1 |             3 |             2 |... 
     10 |         2 |         1 |             2 |             2 |... 
     11 |         1 |         1 |             3 |             2 |... 
```

Kan bruke vindufunksjon RANK(), hvor man rangerer antall utleier, for eksempel, hvis to stasjoner har flest utleier og antallet er 2, så får begge rangering 1, den tredje stasjon (eller eventuelt flere stasjoner) får rangering 2 osv.  

```sql
select start_stasjon, count(*) as antall_utleier, rank() over (order by count(*) desc) as rangering
from Utleier 
group by start_stasjon;
-- Output
 start_stasjon | antall_utleier | rangering 
---------------+----------------+-----------
             3 |              2 |         1
             2 |              2 |         1
             5 |              1 |         3
``` 

For å returnere kun de stasjonene som har flest antall utleier må man bruke delspørring:
```sql 
select start_stasjon, antall_utleier
from (
  select start_stasjon, count(*) as antall_utleier, rank() over (order by count(*) desc) as rangering
  from Utleier 
  group by start_stasjon
) as rangert
where rangering = 1;
-- Output
 start_stasjon | antall_utleier 
---------------+----------------
             3 |              2
             2 |              2
```

40. Skriv en SQL-spørring som viser prosjekt_id og totalt antall timer_allokert for prosjekter med mer enn 100 timer totalt. Gjelder Modell C (Bedrift). 

```sql
select prosjekt_id, sum(timer_allokert) as timer
from Prosjektdeltakelse
group by prosjekt_id
having sum(timer_allokert) > 100;
```

41. Hva gjør COUNT(DISTINCT bruker_id) i Utleier-tabellen, og hvordan skiller den seg fra COUNT(bruker_id)? 

`COUNT(DISTINCT bruker_id)` teller hvor mange brukere har leid sykkel. `COUNT(bruker_id)` registrerer hvor mange utleier det har blitt registrert totalt (rader i utleier).

42. Skriv en spørring som lister ut alle ansatte sammen med navnet på deres avdeling. 

- Input: hvilke tabeller? To tabeller, Ansatte og Avdelinger.
- Join: En ansatt tilhører kun en avdeling, derfor må det være en avdeling på ansatt og det er ikke behov for left join. 
- Projeksjon: navn fra både Ansatte og Avdelinger. Gjelder Modell C (Bedrift).

```sql 
select a.navn, av.navn 
from ansatte a 
inner join avdelinger av 
  on a.avdeling_id=av.avdeling_id;
``` 
NATURAL JOIN fungerer ikke her, siden det er to par av like navn i tabellene. 
INNER JOIN er det samme som JOIN.

43. Hvordan finner du alle brukere som aldri har hatt en bysykkeltur? Gjelder Modell A (Bysykkel). Se vedlegg "Tips om joins".

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

```sql 
select b.navn 
from Brukere b 
left join Utleier u 
  on b.bruker_id = u.bruker_id
where u.bruker_id IS NULL;
``` 

44. Skriv en SQL-spørring som lister ut alle spillere og hvilke turneringer de har deltatt i. Gjelder Modell B (E-sport).

```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plasseringer, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 

Input: Spillere, Turneringer og i tillegg Løp og Deltakelser, siden det er ingen direkte forhold mellom Spillere og Turneringer slik som modellene er spesifisert

Join: Spillere, Turneringer, Løp, Deltakelser

Output (projeksjon): velger å vise brukernavn til spiller og navn på turnering

```sql 
select s.brukernavn, t.navn 
from Spillere s
inner join Deltakelser d 
  on s.spiller_id = d.spiller_id
inner join Løp l
   on d.lop_id = l.lop_id  
inner join Turneringer t
   on l.turneringer_id = t.turnering_id
order by s.brukernavn, t.navn;
```
Hvorfor akkurat denne rekkefølgen for joins? 

Det finnes ingen direkte kobling mellom Spillere og Turneringer. For å "komme" fra Spillere til Turneringer "går man gjennom" Deltakelser og Løp. 

Spillere --- d.spiller_id --> Deltakelser --- l.lop_id --> Løp --- t.turnering_id --> Turneringer

Hvis man ønsker å vise alle spillere uten deltakelser kan man bytte ut alle INNER JOINs med LEFT JOINs (alle må byttes ut ellers vil INNER JOIN kansellere effekten av den foregående LEFT JOIN). 

45. Hva er forskjellen på en INNER JOIN og en FULL OUTER JOIN? Gi et eksempel fra Modell C (Bedrift).

INNER JOIN returnerer kun rader der det finnes en match i begge tabeller. Rader uten match på begge sider utelates helt. 

FULL OUTER JOIN returnerer alle rader fra begge tabeller. Der det ikke finnes match fylles den andre sidens kolonner med NULL. 

Et eksempel av INNER JOIN er vist i besvarelsen til oppgave 42. 

Hvis man har defineret i skjema at avdeling_id i ansatte kan være null, så kan det eksistere også ansatte uten avdeling i database. Det finnes også avdelinger uten ansatte. Derfor kan vi med FULL OUTER JOIN finne alle ansatte som ikke har en avdeling og alle avdelinger som ikke har noen ansatte.

```sql 
select a.navn as ansatt_uten_avdeling, av.navn as avdeling_uten_ansatte
from Ansatte a 
full outer join Avdelinger av on a.avdeling_id = av.avdeling_id
where a.avdeling_id IS NULL OR av.avdeling_id IS NULL;
```
Viktig at man bruker OR her og ikke AND, da AND hadde betydd rader som har hverken ansatte eller avdelinger, som gir ikke mening.

46. Skriv en SQL-spørring som finner navnet på lederen for avdeling 'IT'. Gjelder Modell C (Bedrift)

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

- Input: Ansatte og Avdelinger
- Output (projeksjon): Ansatte.navn
- Join (inner): kobler Ansatte.ansatt_id med Avdelinger.leder_id
- Seleksjon: Avdelinger.navn er lik 'IT'

```sql
select a.navn 
from Ansatte a 
inner join Avdelinger av 
  on a.ansatt_id = av.leder_id where av.navn = 'IT'
```

47. Hvordan lister du ut alle sykler og navnet på stasjonen de sist ble parkert på (hvis de er parkert)?

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

- Input: Sykler, Stasjoner, Utleier
- Output (projeksjon): Sykler.sykkel_id, Stasjoner.navn
- Join: kobler Sykler.sykkel_id med Utleier.sykkel_id og kobler Utleier.slutt_stasjon = Stasjon.stasjon_ids
- Seleksjon: max date for slutt_tid 

Må bruke SQL-spørring med flere trinn og da er CTE egnet form. 
Problemet:
- alle sykler skal med, også de som aldri har vært utleid
- "sist parkert" betyr slutt_stasjon fra den utleien med høyest slutt_tid per sykkel
- slutt_stasjon kan være NULL hvis utleie pågår ("ikke parkert")

En mulighet for å finne siste tur per sykkel er å bruke vekselvirkende delspørringer (se side 127-128, pensumboken 5. utgave):
```sql
select
    sykkel_id,
    slutt_stasjon
from Utleier u1
where slutt_tid is not null
and slutt_tid = (
    select max(slutt_tid)
    from Utleier u2 
    where u2.sykkel_id = u1.sykkel_id
    and u2.slutt_tid is not null
);
```
Så kan vi bruke denne spørringen i CTE og få med oss stasjonsnavn. 

```sql
with SisteTur as (
 	select
    	sykkel_id,
    	slutt_stasjon
	from Utleier u1
	where slutt_tid is not null
	and slutt_tid = (
    	select max(slutt_tid)
    	from Utleier u2 
    	where u2.sykkel_id = u1.sykkel_id
    	and u2.slutt_tid is not null
	)
)
select
    s.sykkel_id,
    -- status kan være Aktiv, Stjålet, På verksted
    s.status,
    st.navn as sist_parkert_stasjon
from  Sykler s
left join SisteTur     on s.sykkel_id            = SisteTur.sykkel_id
left join Stasjoner st on SisteTur.slutt_stasjon = st.stasjon_id
order by s.sykkel_id;
``` 

48. Skriv en spørring med en delspørring i WHERE-klausulen for å finne den ansatte med høyest ansatt_id (sist ansatt, hvis man antar at ansatt_id er designet slik at den øker kronologisk). Gjelder Modell C (Bedrift).

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

- Input: Ansatte
- Output (projeksjon): navn
- Join: ikke relevant
- Seleksjon: max ansatt_id som delspørring

Man kunne tenke seg at det er mulig å skrive `select navn, max(ansatt_id) from Ansatte`. Hvorfor skal denne spørringen gi feil?

Det må gjøres i to "omganger", dvs. først finne maksimalt anstatt_id og så selektere navn til ansatt med denne ansatt_id. Trenger å engasjere tabellen Ansatte to ganger. 
```sql
select navn from Ansatte where (select max(ansatt_id) from Ansatte);
``` 

49. Hva er fordelen med å bruke en CTE (WITH) fremfor en delspørring?

- Lesbarhet til CTE er bedre (generelt og spesielt i forhold til delspørringer).
- CTE kan gjenbrukes flere steder i spørringen. 
- CTE kan være rekursiv. 

50. Skriv en CTE som først finner alle utleier over 60 minutter, og deretter en hovedspørring som teller hvor mange slike turer hver bruker har. Gjelder Modell A (Bysykkel).

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

- Struktur: CTE (`with LangeTurer as ( _spørring_ ) select _noe_ from LangeTurer ...` hvor `select _noe_ from SisteTur ...` er hovedspørring)
- Input: i CTE Utleier, i hovedspørringen 
- Output (projeksjon): bruker_id og antall turer over 60 minutter (må bruke spesifikke funksjoner for beregninger med verdier av typen `timestamp/date`)
- Join: hvis navn fra Brukere ønskes, så må man joine LangeTurer med Brukere (eller joine Utleier med Brukere i CTE)
- Seleksjon: i CTE velge kun de utleiene hvor slutt_tid - start_tid er større en 60 minutter og hvor slutt_tid ikke er null (dvs. utelate pågående utleier)

```sql
-- mellomversjon av spørringen
with LangeTurer as ( tabell kun med lange turer over 60 min. ) select bruker_id, count(*) from LangeTurer group by bruker_id;
-- mellomversjon, hvis type av slutt_tid og start_tid er timestamptz så blir resultatet av subtraskjon av typen interval, så spørringen vil gi en feilmelding
with LangeTurer as ( 
	select * from Utleier where slutt_tid - start_tid > 60 and slutt_tid is not null;
)
select bruker_id, count(*)
from LangeTurer 
group by bruker_id;
-- se under for en løsning for beregninger med verdier av typen timestamptz
with LangeTurer as ( 
	select * from Utleier 
	where extract(epoch from (slutt_tid - start_tid))/60 > 60 
		and slutt_tid is not null 
)
select bruker_id, count(*)
from LangeTurer
group by bruker_id;

-- eller hovedspørring med join
select b.navn, count(*)
from LangeTurer lt
join Brukere b on lt.brukere_id = b.brukere_id
group by b.brukere_id, b.navn;
``` 

Dette blir lagt som vedlegg til eksamen, hvis bruken av slike funksjoner blir relavant:

Relevante funksjoner er beskrevet her: https://www.postgresql.org/docs/current/functions-datetime.html

> Subtraction of dates and timestamps can also be complex. One conceptually simple way to perform subtraction is to convert each value to a number of seconds using EXTRACT(EPOCH FROM ...), then subtract the results; this produces the number of seconds between the two values. This will adjust for the number of days in each month, timezone changes, and daylight saving time adjustments. Subtraction of date or timestamp values with the “-” operator returns the number of days (24-hours) and hours/minutes/seconds between the values, making the same adjustments. 

> For timestamp with time zone values, the number of seconds since 1970-01-01 00:00:00 UTC (negative for timestamps before that); for date and timestamp values, the nominal number of seconds since 1970-01-01 00:00:00, without regard to timezone or daylight-savings rules; for interval values, the total number of seconds in the interval.

```sql
-- returenerer sekunder i intervallet
extract(epoch from (slutt_tid - start_tid))
-- minutter i intervallet 
extract(epoch from (slutt_tid - start_tid))/60 
-- seleksjon fra CTE LangeTurer
where extract(epoch from (slutt_tid - start_tid))/60 > 60
``` 



## Vedlegg

### Operatorprioritet

1. `-` (unær minus, f.eks -3)
2. `* / %`
3. `+ -` (binære operatorer f.eks. 2-3)
4. `< <= > >= = <>`
5. NOT
6. AND
7. OR

### Logisk rekkefølge av klausulene i SQL-spørringer

1. FROM      — hvilke tabeller
2. JOIN      — koble tabeller
3. WHERE     — filtrer enkeltposter
4. GROUP BY  — grupper de gjenværende postene
5. HAVING    — filtrer grupper
6. SELECT    — velg kolonner og beregn aggregater (vindusfunksjoner etter select)
7. ORDER BY  — sorter resultatet
8. LIMIT     — begrens antall rader

### Tips om joins

| Situasjon                                 | Bruk                               |
| ----------------------------------------- | ---------------------------------- |
| Vil bare ha rader med match begge steder  | `INNER JOIN`                       |
| Vil beholde alle fra venstre, uansett     | `LEFT JOIN`                        |
| Vil finne rader i A som *ikke* finnes i B | `LEFT JOIN ... WHERE B.id IS NULL` |
| Vil beholde alt fra begge tabeller        | `FULL OUTER JOIN`                  |
| Vil generere alle kombinasjoner           | `CROSS JOIN`                       |
| Tabell refererer til seg selv (hierarki)  | `SELF JOIN`                        |

### Relasjonsalgebra

- PROJEKSJON 𝜋 (eksempel: `𝜋_fornavn,etternavn(studenter)` tilsvarer `select fornavn, etternavn from studenter;`)
- SELEKSJON 𝜎 (eksempel: `𝜎_(fornavn begynner med 'O') ∧ program_id = 1(studenter)` tilsvarer `select * from studenter where fornavn like 'O% and program_id = 1;`)
- OMDØPING 𝜌 (eksempel: `𝜌_fornavn→navn, program_id→studie(studenter)` tilsvarer `select fornavn as navn, program_id as studie from studenter;`
- KARTESISK PRODUKT × tar to argumenter (f.eks. A og B) men skrives "infix", dvs. mellom de to argumentene A × B (eksempel: `studenter × programmer` tilsvarer `select * from studenter, programmer;`)
- JOIN ⋈ (eksempel: `𝜌_program_id→program(studenter) ⋈_program = program_id programmer` tilsvarer `select program_id as program from studenter join programmer on program = program_id;`)
- UNION ∪, SNITT ∩ og DIFFERANSE ∖ kan kun brukes på relasjoner som har nøyaktig de samme attributtene

**Nyttige tegn for relasjonsalbebra**
```
∪ union 222A
∩ intersection 2229)
∖ Set minus 2216
⋈ relation 22C8
∏ N-ary product 220F
∑ N-ary summation 2211
∕ Division slash 2215
− Minus sign 2212
𝜎 mathematical greek small sigma 1D70E
𝜋 mathematical greek small pi 1D70B
𝜌 mathematical greek rho 1D70C
𝛱 stor pi
𝛴 stor sigma 
≔ colon equals 2254 (kan også skrives med "vanlige" tegn :=)
∨ logical OR 2228
∧ logical AND 2227
¬ not sign 00AC (utvidet latin)
= equals sign 003D (ascii)
≤ less-than or equal 2264
≥ greater-than or equal 2263
`>` greater-than 003E
`<` less-than 003C
→ 
× kartesisks produkt, multiplikasjon 00D7
≠ not equal 2260
```

### Datatyper i PostgreSQL

Fra https://www.postgresql.org/docs/current/datatype.html

|Name 	|Aliases 	|Description|
|--|--|--|
|bigint 	|int8 	|signed eight-byte integer|
|bigserial 	|serial8 	|autoincrementing eight-byte integer|
|bit [ (n) ] |	  	|fixed-length bit string|
|bit varying [ (n) ] 	|varbit [ (n) ]| 	variable-length bit string|
|boolean 	|bool 	|logical Boolean (true/false)|
|box |	  	|rectangular box on a plane|
|bytea |	  	|binary data (“byte array”)|
|character [ (n) ] |	char [ (n) ] |	fixed-length character string|
|character varying [ (n) ] |	varchar [ (n) ] |	variable-length character string|
|cidr| 	  	|IPv4 or IPv6 network address|
|circle |	  	|circle on a plane|
|date |	  	|calendar date (year, month, day)|
|double precision| 	float, float8 	|double precision floating-point number (8 bytes)|
|inet |	  	|IPv4 or IPv6 host address|
|integer |	int, int4 	|signed four-byte integer|
|interval [ fields ] [ (p) ] |	  	|time span|
|json |	  	|textual JSON data|
|jsonb |	  	|binary JSON data, decomposed|
|line |	  	|infinite line on a plane|
|lseg |	  	|line segment on a plane|
|macaddr| 	  	|MAC (Media Access Control) address|
|macaddr8 |	  	|MAC (Media Access Control) address (EUI-64 format)|
|money 	|  	|currency amount|
|numeric [ (p, s) ] |	decimal [ (p, s) ] |	exact numeric of selectable precision|
|path |	  	|geometric path on a plane|
|pg_lsn |	  	|PostgreSQL Log Sequence Number|
|pg_snapshot| 	  	|user-level transaction ID snapshot|
|point 	|  	|geometric point on a plane|
|polygon |	  	|closed geometric path on a plane|
|real| 	float4 	|single precision floating-point number (4 bytes)|
|smallint| 	int2 |	signed two-byte integer|
|smallserial |	serial2 |	autoincrementing two-byte integer|
|serial 	|serial4 |	autoincrementing four-byte integer|
|text |	  	|variable-length character string|
|time [ (p) ] [ without time zone ] |	  	|time of day (no time zone)
|time [ (p) ] with time zone| 	timetz |	time of day, including time zone|
|timestamp [ (p) ] [ without time zone ] |	  	|date and time (no time zone)|
|timestamp [ (p) ] with time zone| 	timestamptz 	|date and time, including time zone|
|tsquery |	  	|text search query|
|tsvector |	  	|text search document|
|txid_snapshot| 	  	|user-level transaction ID snapshot (deprecated; see pg_snapshot)|
|uuid |	  	|universally unique identifier|
|xml |	|  	XML data|
