# Løsningsforslag relevante eksamensspørsmål del 1 (51-85)

---

51. Hvordan bruker du en vekselvirkende delspørring (se pensumboken side 127 5. utgave) for å finne den beste rundetid for hver spiller på tvers av alle løp? Gjelder Modell B (E-sport).

En delspørring er selvstendig hvis den også fungerer som en hovedspørring. En delspørring er vekselvirkende hvis den avhenger av hovedspørring (bruker attributter som er definert i hovedspørring). 

```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plasseringer, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 

Tenk at hovedspørringen og delspørringen jobber mot hver sin kopi av tabellen Deltakelser. Man kan da joine begge kopiene på spiller_id for å få den beste rundetid for hver spiller på tvers av alle løp. 

Hovedspørring undersøker hver rad i kopi d1. Delspørringen finner den beste rundetiden til den spilleren som blir undersøkt i hovedspørringen.

Projeksjon: enten alle kolonner i tabellen `*` eller spesifikt spiller_id og beste_rundetid.


```sql 
select d1.spiller_id, d1.beste_rundetid from Deltakelser d1 
where beste_rundetid = (
	select min(beste_rundetid) from Deltakelser d2 
	where d1.spiller_id = d2.spiller_id
);
``` 
---

52. Skriv en spørring som finner alle avdelinger der gjennomsnittlig timer_allokert per ansatt er høyere enn bedriftens totale gjennomsnitt. Gjelder Modell C (Bedrift).

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

Input: Avdelinger, Ansatt, Prosjektdeltakelse

Output (projeksjon): Avdelinger.navn, gjennomsnittlig timer allokert per ansatt

Betingelser: gjennomsnittlig timer allokert per ansatt > bedriftens totale gjennomsnitt

Struktur: 
- delspørring for å beregne bedriftens totale gjennomsnitt of timer_allokert `select avg(timer_allokert) from Prosjektdeltakelse;`
- hovedspørring må joine tre tabeller `select av.navn, avg(pd.timer_allokert)` from Prosjektdeltakelse join Ansatte a on a.ansatt_id = pd.ansatt_id join Avdelinger av on a.avdeling_id = av.avdeling_id group by av.avdeling_id having avg(pd.timer_allokert) > (delspørring);


```sql 
SELECT av.navn, avg(pd.timer_allokert) 
FROM Prosjektdeltakelse pd 
JOIN Ansatte a ON a.ansatt_id = pd.ansatt_id
JOIN Avdelinger av ON a.avdeling_id = av.avdeling_id
GROUP BY av.avdeling_id, av.navn -- tar med av.navn for kompatibilitet med andre DBHS
HAVING avg(timer_allokert) > (
SELECT avg(timer_allokert) FROM Prosjektdeltakelse);
```

---

53. Skriv en vindusfunksjon-spørring som rangerer (RANK()) spillere basert på deres beste_rundetid i et spesifikt løp.

En vindusfunksjon beregner en verdi for hver rad basert på et sett av relaterte rader - kalt et "vindu" uten å kollapse radene til én gruppe slik som group by gjør. Hver rad beholder sin identitet i resultatet men får en ekstra kolonne med et beregnet verdi. 

``` 
funksjon(...) over (
	[partition by kolonne(r)]
	[order by kolonne(r) [asc|desc]]
	[ramme_klausulen] 
(standardramme når order by er spesifisert er RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, dvs. alle rader opp til den gjeldende raden)
	)

ROW_NUMBER() - ulike løpenummer per rad - ingen like verdier
RANK() - rang med hopp ved like verdier (1,1,3,4)
DENSE_RANK() - rang uten hopp ved like verdier (1,1,2,3)
NTILE(n) - deler radene i n like store grupper (kvartiler, desiler)
PERCENT_RANK() - relativ rang som desimaltall mellom 0 og 1
``` 

Vindusfunksjoner utføres etter SELECT (steg 6) og kan derfor ikke brukes i GROUP BY og HAVING. Bruk CTE eller delspørring for å filtrere på et vindusverdi.

```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plasseringer, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 

```sql
select spiller_id, lop_id, beste_rundetid, 
rank() over (partition by lop_id order by beste_rundetid asc) as rang
from Deltakelser;
```

---

54. Hvordan beregner du en løpende sum av pris for alle utleier en bestemt bruker har tatt, sortert på start_tid? 

```sql
select bruker_id, start_tid,
sum(pris) over (partition by bruker_id order by start_tid) as sum_timer
from Utleier;
```

---

55. Utvid Modell C (Bedrift) slik at det kan brukes rekursiv spørring (tips: legg inn en selvreferanse i tabellen Ansatte). Skriv en rekursiv CTE (WITH RECURSIVE) for å finne alle underordnede (i alle ledd) til en spesifikk leder i den modifiserte versjonen av Modell C (Bedrift).

``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

Endre modellen slik at en rekursiv spørring kan brukes.
```sql 
ALTER TABLE Ansatte ADD COLUMN leder_id INTEGER REFERENCES Ansatte(ansatt_id);

with recursive Underordnede as (
	select ansatt_id, navn, avdeling_id, ansettelsesdato, leder_id, 0 AS nivå 
	from Ansatte where leder_id = 2 
	union all 
	select a.ansatt_id, a.navn, a.avdeling_id, a.ansettelsesdato, a.leder_id, u.nivå + 1 
	from Ansatte a 
	join Underordnede u 
	on a.leder_id = u.ansatt_id
) select * from Underordnede;

```

Uten å endre den eksisterende modellen, kan man finne svar uten rekursjon. 
```sql
SELECT a.ansatt_id, a.navn, av.navn AS avdeling
FROM Ansatte a
JOIN Avdelinger av ON a.avdeling_id = av.avdeling_id
WHERE av.leder_id = 2;
```

---

56. Hvordan bruker du LAG() eller LEAD() for å finne tidsdifferansen mellom en brukers forrige bysykkeltur (utleie) og deres nåværende tur (utleie)? Gjelder Modell A (Bysykkel).

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

| Funksjon            | Beskrivelse                               |
| ------------------- | ----------------------------------------- |
| `LAG(kol, n)`       | Verdien fra n rader *før* gjeldende rad   |
| `LEAD(kol, n)`      | Verdien fra n rader *etter* gjeldende rad |
| `FIRST_VALUE(kol)`  | Verdien fra første rad i vinduet          |
| `LAST_VALUE(kol)`   | Verdien fra siste rad i vinduet           |
| `NTH_VALUE(kol, n)` | Verdien fra n-te rad i vinduet            |

Den samme strukturen gjelder som i øving #53. 

``` 
funksjon(...) over (
	[partition by kolonne(r)]
	[order by kolonne(r) [asc|desc]]
	[ramme_klausulen] 
(standardramme når order by er spesifisert er RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW, dvs. alle rader opp til den gjeldende raden)
	)
``` 

```sql 
select bruker_id, 
start_tid - LAG(slutt_tid, 1) over (partition by bruker_id order by start_tid)
as tidsdiff_forrige_tur
from Utleier
order by bruker_id, start_tid;
``` 
---

57. Skriv en spørring som bruker COALESCE for å returnere 'Ukjent' hvis en sykkel ikke har en registrert `sist_vedlikeholdt` dato. Anta at `sist_vedlikeholdt` kan ha NULL-verdier og er av typen DATE. Vis også `sykkel_id` i resultatet. Gjelder Modell A (Bysykkel).

Funksjonen COALESCE returnerer den første av argumentene som ikke er NULL. NULL returneres kun hvis alle argumentene er NULL. Brukes vanligvis for å erstatte NULL-verdier med en mer forklarende verdi (f.eks. 'Ukjent' eller 'Aldri vedlikeholdt').

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

```sql 
select sykkel_id, coalesce(sist_vedlikeholdt::text, 'Ukjent') as vedlikeholdt_dato from Sykler;
```

--- 

58. Hva er en MATERIALIZED VIEW, og hvorfor kan den passe for en ledertavle basert på Modell B (E-sport)?

En vanlig VIEW kjører den underliggende spørringen på nytt hver gang den leses. En MATERIALIZED VIEW lagrer resultatet fysisk på disk — som en tabell — og oppdateres kun når man eksplisitt ber om det med REFRESH. Dette gjør den svært rask å lese, men den kan være utdatert mellom oppdateringer.

For en ledertavle i et e-sport-system er MATERIALIZED VIEW det riktige valget: 
- ledertavlen trenger ikke oppdateres hvert millisekund, men den leses svært ofte av mange brukere. En REFRESH etter hvert løp er tilstrekkelig.

59. Lag en MATERIALIZED VIEW `mv_turneringer_ledertavle` for en ledertavle per turnering med følgende attributter / kolonner:
- `turnering_id`
- `turnering_navn`
- `spiller_id`
- `brukernavn`
- `lop_i_turnering` antall løp brukeren har deltatt i (tips: COUNT(lop_id))
- `snitt_plassering` gjennomsnittsplassering (tips: AVG(plassering))
- `beste_tid_i_rundetid` beste_rundetid (husk at en turnering kan inneholde flere løp)
- `rang_i_turnering` (plass) i turnering (tips: bruk RANK(), partisjoner på turnering_id og ordne på gjennomsnittsplassering)

**Tips:** Bruk omdøping for å vise selvforklarende kolonnenavn (gitt i oppgaveteksten). Join Turneringer med Lop, Deltakelser og Spillere. 

Syntaksen for å lage en MATERIALIZED VIEW er:
```sql 
CREATE MATERIALIZED VIEW mv_turnering_ledertavle AS
SELECT ...;
```

Løsningsforslag:

```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plassering, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 

```sql 
create materialized view mv_turnering_ledertavle as
select
    t.turnering_id,
    t.navn                                   as turnering_navn,
    s.spiller_id,
    s.brukernavn,
    COUNT(d.lop_id)                          as løp_i_turnering,
    AVG(d.plassering)                        as snitt_plassering,
    MIN(d.beste_rundetid)                    as beste_tid_i_turnering,
    RANK() OVER (
        PARTITION BY t.turnering_id
        ORDER BY AVG(d.plassering) ASC
    )                                        as rang_i_turnering
from Turneringer t
join Løp l         on t.turnering_id = l.turnering_id
join Deltakelser d on l.lop_id       = d.lop_id
join Spillere s    on d.spiller_id   = s.spiller_id
group by t.turnering_id, t.navn, s.spiller_id, s.brukernavn
WITH DATA;
```

`WITH DATA` betyr at tabellen for den materialiserte view blir laget umiddelbart. `WITH NO DATA` må man eksplisitt bruke `REFRESH` for å oppdatere view.

---

60. Hva står bokstavene i ACID for? Forklar hver av dem kort. 

- Atomicity, alt eller ingenting
- Consistency, gyldig tilstand
- Isolation, uavhengige transaksjoner
- Durability, lagret permanent

--- 

61. En bruker leier en sykkel. Dette krever at sykkelens status endres til 'Utleid', og en ny rad opprettes i Utleier. Hvilken ACID-egenskap sikrer at enten begge eller ingen av disse endringene lagres?

Atomicity: sikrer at vi ikke får en utleid sykkel uten en registrert tur.

--- 

62. Hva betyr "Consistency" i ACID-sammenheng? Gi et eksempel på et konsistensbrudd i NS 4102-modellen (dobbelt bokholderi). 

Summen av debet og kredit i et bilag må være null.

--- 

63. Forklar "Isolation". Hvorfor er det viktig når to brukere prøver å leie den samme bysykkelen tilnærmet samtidig?

Hindrer at begge får tildelt samme sykkel.

---

64. Hva innebærer "Durability"? Hvordan sikrer PostgreSQL at data overlever et strømbrudd rett etter en COMMIT?

Skriver til Write-Ahead Log (WAL) på disk før COMMIT bekreftes.

---

65. Er det mulig å ha et databasesystem som er "A", "C" og "D", men ikke "I"? Hva ville konsekvensen vært? 

Isolasjon er relatert til samtidige transaksjoner, som har tilgang til det samme datagrunnlaget (database).

Uten isolasjon åpnes det for samtidighetsanomalier:
- "dirty read"; transaksjon B leser data som transaksjon A har endret, men ennå ikke committed; hvis A deretter gjør rollback, har B lest data som aldri ble permanente. 
```sql
T1 (A): update saldo set belop = 0 where konto_id = 1; -- ikke committed ennå
T2 (B): select belop from saldo where konto_id = 1; -- leser 0 -> dirty read
T1 (A): rollback; -- saldo er egentlig uendret
```
- "non-repeatable read"; tranaksjon A leser en rad, transaksjon B oppdaterer og committer den samme raden, A leser raden igjen og får et annet resultat.
```sql 
T1 (A): select belop from saldo where konto_id = 1; -- leser 1000
T2 (B): update saldo set belop = 500 where konto_id = 1;
T2 (B): commit;
T1 (A): select belop from saldo where konto_id = 1; -- leser 500 som er endret 
``` 
- "phantom read"; transaksjon A kjører en spørring med en betingelse som returnerer et sett rader; transaksjon B setter inn nye rader som matcher betingelsen; når A kjører spørringen igjen, dukkuer det opp nye ("fantom") rader.
```sql 
T1 (A): select * from Utleier where bruker_id = 1; -- returnerer 3 rader 
T2 (B): insert into Utleier (bruker_id, ...) values (1, ...);
T2 (B): commit;
T1 (A): select * from Utleier where bruker_id = 1; -- returnerer 4 rader (fantomrad)
``` 
- "lost update"; to transaksjoner leser samme verdi, beregner en ny verdi basert på den, og skriver tilbake til disk; den siste overskriver den første uten å vite om den.
```sql
T1 (A): les saldo 1000
T2 (B): les saldo 1000
T1 (A): skriv saldo = 1000 + 200 = 1200
T2 (B): skriv saldo = 1000 + 300 = 1300 -- T1 sin oppdatering er tapt
``` 
- "write skew"; to transaksjoner leser overlappende data, tar beslutninger basert på det de ser, og skriver til ulike rader og den kombinerte effekten bryter en forretningsregel.
```sql 
Regel: minst én lege må alltid være på vakt 
T1 (A): ser at lege A og B er på vakt -> melder av lege A 
T2 (B): ser at lege A og B er på vakt -> melder av lege B 
Resultat: ingen leger på vakt <- regelen er brutt
``` 

Kun full isolasjon (SERIALIZABLE) eliminerer alle anomalier men det kan medføre "et tregt system". De fleste DBHS i produksjon velger et kompromiss - typisk READ COMMITTED (eliminerer "dirty read") eller REPEATABLE READ (utelukker "dirty read" og "non-repeatable read") og aksepterer de gjenværende risikoene.

Det er mange systemer som bruker ACD uten I for å øke ytelsen, f.eks., 
- NoSQL-systemer som tilbyr eventuell konsistens og ingen isolasjon i tradisjonell forstand;
- BASE-systemer ofrer I og deler av C for tilgjengelighet (Basically Available, Soft state, Eventually consistent);
- Redis har ikke transaksjoner, dermed ingen isolasjon mellom kommandoer som standard.

66. Hva er en "dirty read"? Gi et eksempel fra Modell C (Bedrift) der en leder leser et budjsett som er under oppdatering, men som senere blir rullet tilbake (ROLLBACK).
```sql
T1 (BUDSJETTANSVARLIG): oppdaterer budsjett for en post -- reklame 25000
T2 (LEDER): leser budsjett for en post -- reklame 25000 som er ikke committed
T1 (BUDSJETTANSVARLIG): rollback
``` 
Se også besvarelsen på øving #65.

67. Forklar "non-repeatable read". Hvordan kan dette oppstå hvis en E-sport-kommentator leser en spillers poengsum to ganger i samme transaksjon, mens en annen transaksjon oppdaterer poengsummen i mellomtiden?

Leser samme rad to ganger, men verdien har endret seg fordi en annen transaksjon committed i mellomtiden. 

Se også besvarelsen på øving #65 for et annet eksempel. 

68. Hva er "phantom read"? Hvordan skiller det seg fra en "non-repeatable read"? Bruk et eksempel der man teller antall aktive sykler i Modell A (Bysykkel).

En annen transaksjon **setter inn / sletter rader** som matcher where-klausulen mellom to lesinger. "non-repeatable read" en annen transaksjon **oppdaterer** data mellom to lesinger.

``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

```Sql
T1: select count(*) from Sykler where status = 'Aktiv'; -- 20 
T2: insert into Sykler (sykkel_id, status, ...) values (43, 'Aktiv', ...); -- fantomrad
T1: select count(*) from Sykler where status = 'Aktiv'; -- 21
``` 

Se også besvarelsen på øving #65 for et annet eksempel.

69. Hva er "lost update"? Beskriv et scenario i NS 4201-modellen der to regnskapsførere oppdaterer saldoen på samme konto samtidig (Read-Calculate-Write).

A og B leser saldo 100 kr. A legger til 50 kr, skriver 150 kr. B trekker fra 20 kr, skriver 80 kr. A sin oppdatering er tapt. 

Se også besvarelsen på øving #65 for et annet eksempel.

70. Forklar "write skew". Hvordan kan dette skje hvis to leger i en sykehusdatabase (eller to prosjektledere i Modell C (Bedrift)) sjekker om det er nok budsjett igjen, og begge trekker fra budsjettet samtidig? 

Begge prosjektledere sjekker budsjett (80000 kr). Begge trekker 50000 kr. Totalen blir -20000 kr, selv om ingen av dem isolert sett brøt regelen. Konsistensen (C) er brutt.

Se også besvarelsen på øving #65 for et annet eksempel.

71. Hvilken samtidighetsproblem er det mest kritiske å unngå i et finansielt system (som NS 4102), og hvorfor? 

"lost update" som oppstår i "read-calculate-write"-møsteret
```
T1: les saldo på konto 1920 = 10 000 kr
T2: les saldo på konto 1920 = 10 000 kr
T1: beregn ny saldo = 10 000 - 500 = 9 500 kr
T2: beregn ny saldo = 10 000 + 1 000 = 11 000 kr
T1: skriv saldo = 9 500 kr  → COMMIT
T2: skriv saldo = 11 000 kr → COMMIT   ← T1 sin uttak på 500 kr er tapt
``` 

"write skew" kan også være kritisk, siden kontoen kan være overtrukket (se besvarelsen i øving #70). 

"dirty read" er alvorlig, men oppdages ved rollback. "non-repeatable read" og "phantom read" er mindre kritiske.

72. Hvilke fire isolasjonsnivåer definerer SQL-standard? 

- READ UNCOMMITTED
- READ COMMITTED
- REPEATABLE READ
- SERIALIZABLE

73. Hvilket isolasjonsnivå er standard (default) i PostgreSQL, og hvilke anomalier forhindrer det?

- READ COMMITTED, forhindrer "dirty read"

74. Hvilket isolasjonsnivå må du bruke for å garantere at hverken "dirty read", "non-repeatable read" eller "phantom read" kan forekomme?

- SERIALIZABLE, som forhindrer alle anomalier.

75. I Modell A (Bysykkel), hvis du bruke READ UCOMMITTED, hva er risikoen når du beregner total inntjening  for dagen? 

Kan inkludere turer som senere blir rullet tilbake (f.eks. ved feil betaling).

76. Hvorfor bruker man ikke alltid SERIALIZABLE hvis det er det tryggeste nivået?

Dårlig ytelse. 

77. Hva er de fire hovedkategoriene av NoSQL-systemer? Nevn et populært produkt for hver kategori.

Dokument (MongoDB), Nøkkel-verdi (Redis), "wide"-Kolonne (Cassandra), Graf (Neo4j).

78. Forklar hva en Dokumentdatabase (NoSQL-system) er? Hvordan lagres vanligvis dataene (format)?

Dataene lagres i et fleksibelt skjema som abstraheres som "dokument". 
For eksempel, Spiller og Deltakelser er to entiteter i en relasjonell modell, mens en spiller med alle deltakelser kan lagres som et "dokument" i en Dokumentdatabase som et fleksibelt skjema og i JSON-format.
{"spiller_id":1, "navn":"Pro", "deltakelser": [{"lop_id":5, "plass":1}]}

MongoDB bruker BSON-format (Binary JSON). Sammenlignet med JSON, BSON er designet for både lagrings- og parsings-effektivitet.

79. Hva er Nøkkel-Verdi-database (Key-Value store)? Hvorfor er en Nøkkel-Verdi-database vanligvis veldig rask (spesielt å hente ut data)?

Nøkkel-Verdi-database er som en oppslagstabell (ordbok, indeks) og er meget effektiv, spesielt når dataene ligger i RAM (Random Access Memory).

80. Forklar hva en "Wide-Column-store" (Kolonne-familie database som NoSQL-system) er. Hvordan skiller den seg fra en tradisjonell relasjonsdatabase?

Et NoSQL-system som lagrer data i tabeller organisert rundt kolonnefamilier i stedet for faste rader med forhåndsdefinerte kolonner. Rad kan ha ulike kolonner. 
Optimalisert for lese- og skriveoperasjoner på store datasett hvor operasjoner gjelder et sett kolonner for en gitt nøkkel (punktoppslag) eller sekvensielle skanninger etter sortert nøkkel.

Eksempel: 
``` 
Raden med nøkkel "bruker:123" kan ha kolonnefamilien "profil" med kolonner {navn:"A", alder:30} og kolonnefamilien "aktivitet" med dynamiske kolonner {2026-05-27: "login", 2026-05-28: "purchase"} — andre brukere kan ha helt andre kolonner.
``` 

81. Hva er en Grafdatabase? Hvilke to hovedkomponenter brukes for å abstrahere dataene?

Noder (entiteter) og Kanter (forhold mellom entiteter).

82. Hva står bokstavene i CAP-teoremet for? Forklar hver av dem kort. 

- Consistency: Alle noder ser samme data samtidig (hver lesing får siste skriving).
- Availability: Systemet svarer alltid på forespørsler (selv om dataene kanskje ikke er de aller nyeste).
- Partition Tolerance: Systemet fortsetter å fungere selv om nettverksforbindelsen mellom noder brytes.

83. Ifølge CAP-teoremet, hvor mange av disse tre egenskapene kan et distribuert system garantere samtidig under en nettverkspartisjon (Partition)? 

Teoremet sier at ved et nettverksbrudd (P) må man velge mellom C og A.

84. Hva står BASE for? Hvordan er dette i motsetning til ACID? 

Basically Available, Soft state (tilstand er ikke hele tiden permanent, f.eks. ikke alle oppdateringene er lagret på alle replikeringene), Eventual consistency. Motsatt av ACID (Atomicity, Consistency, Isolation, Durability) som krever streng konsistens og alltid permanent tilstand lagret.

85. Hva er "Soft state" i BASE-prinsippene? Hvordan henger det sammen med "Eventual consistency"?

Tilstanden til systemet kan endre seg over tid selv uten input, fordi data synkroniseres i bakgrunnen. Data blir synkronsert til slutt og derfor kan man kalle systemet eventuelt konsistent.

--- 

## Vedlegg 

Legge til en ny rad i en eksisterende tabell:
```
ALTER TABLE [ IF EXISTS ] [ ONLY ] name [ * ]
    action [, ... ]
hvor action kan være 
ADD [ COLUMN ] [ IF NOT EXISTS ] column_name data_type [ COLLATE collation ] [ column_constraint [ ... ] ]
```

Lage en ny tabell:
``` 
CREATE [ [ GLOBAL | LOCAL ] { TEMPORARY | TEMP } | UNLOGGED ] TABLE [ IF NOT EXISTS ] table_name
    [ (column_name [, ...] ) ]
    [ USING method ]
    [ WITH ( storage_parameter [= value] [, ... ] ) | WITHOUT OIDS ]
    [ ON COMMIT { PRESERVE ROWS | DELETE ROWS | DROP } ]
    [ TABLESPACE tablespace_name ]
    AS query
    [ WITH [ NO ] DATA ]
``` 

Innsetting av verdier en en tabell:
```
INSERT INTO table_name [ AS alias ] [ ( column_name [, ...] ) ]
    { VALUES ( { expression | DEFAULT } [, ...] ) [, ...] | query }
```

Håndtering av NULL-verdier (COALESCE: 
```

COALESCE(value [, ...])

The COALESCE function returns the first of its arguments that is not null. Null is returned only if all arguments are null. It is often used to substitute a default value for null values when data is retrieved for display
``` 
