# Prøveeksamen i Databaser våren 2026

**Tid:** 3 timer

**Hjelpemidler:** Ingen

## Introduksjon til datamodellen
Denne eksamenen tar utgangspunkt i en forenklet versjon av NS 4102-modellen for dobbelt bokholderi. Modellen brukes til å registrere økonomiske transaksjoner for en bedrift.

Følgende tabeller er relevante for oppgavene:

**Kontoer**
- `guid` (CHAR(32), PK)
- `kontonummer` (INTEGER, Unik)
- `navn` (TEXT)
- `overordnet_guid` (CHAR(32), FK til Kontoer.guid)
- `mva_pliktig` (BOOLEAN)

**Transaksjoner**
- `guid` (CHAR(32), PK)
- `bilagsnummer` (TEXT)
- `posteringsdato` (DATE)
- `beskrivelse` (TEXT)

**Posteringer**
- `guid` (CHAR(32), PK)
- `transaksjon_guid` (CHAR(32), FK til Transaksjoner.guid)
- `konto_guid` (CHAR(32), FK til Kontoer.guid)
- `belop_teller` (BIGINT)
- `belop_nevner` (BIGINT)

**Valutaer**
- `valuta_kode` (CHAR(3), PK, f.eks. 'NOK', 'USD', 'EUR')
- `navn` (TEXT)

*Merk: Beløp lagres som en brøk for å unngå avrundingsfeil. Den faktiske verdien er `belop_teller / belop_nevner`.*

*FK - Fremmednøkkel*

*PK - Primærnøkkel*

---

## Oppgave 1: SQL-spørringer og avanserte funksjoner (Vekt: 33 %, Anbefalt tid: 60 min)

I denne oppgaven skal du skrive SQL-spørringer mot datamodellen beskrevet over.

**a) Grunnleggende spørring (3 %)**
Skriv en SQL-spørring som lister ut `kontonummer` og `navn` for alle kontoer som er MVA-pliktige (`mva_pliktig = TRUE`). Sorter resultatet stigende på kontonummer.

**b) Filtrering og sortering (3 %)**
Skriv en SQL-spørring som lister ut `bilagsnummer`, `posteringsdato` og `beskrivelse` for alle transaksjoner som ble registrert i mars 2026 (fra og med 1. mars til og med 31. mars). Sorter resultatet slik at de nyeste transaksjonene kommer først.

**c) Aggregering og JOIN (7 %)**
Skriv en SQL-spørring som beregner den totale saldoen for hver konto. Resultatet skal inneholde `kontonummer`, `navn` og `saldo`. Saldoen beregnes som summen av `(belop_teller / belop_nevner)` for alle posteringer knyttet til kontoen. Kontoer uten posteringer trenger ikke å være med i resultatet.

**d) Aggregering med NULL-håndtering (7 %)**
Skriv en SQL-spørring som beregner antall underkontoer for hver hovedkonto. Resultatet skal vise `kontonummer` og `navn` for hovedkontoen, samt antallet direkte underkontoer (`antall_underkontoer`). Hovedkontoer er definert som kontoer der `overordnet_guid` er NULL. Kontoer som ikke har noen underkontoer skal også være med i resultatet (med antall 0).

**e) Rekursiv CTE (13 %)**
Kontoplanen er hierarkisk bygget opp, der `overordnet_guid` peker på foreldrekontoen. Skriv en rekursiv CTE (`WITH RECURSIVE`) som finner alle underkontoer (i alle ledd nedover) for kontoen med kontonummer `3000`. Resultatet skal inkludere `kontonummer`, `navn` og hvilket `nivaa` (dybde) kontoen befinner seg på i forhold til konto 3000 (for konto 3000 er nivå 0).

---

## Oppgave 2: Datamodellering og normalisering (Vekt: 22 %, Anbefalt tid: 40 min)

Bedriften ønsker å utvide systemet for å håndtere **Valutakurser** og **Valutahandel**.

**Kravspesifikasjon:**
1. Systemet må lagre historiske valutakurser. En valutakurs angir prisen på én enhet av en fremmed valuta (f.eks. USD) målt i basisvalutaen (NOK) på en gitt dato.
2. Det kan kun være én offisiell kurs per valuta per dato.
3. Systemet må også registrere selve valutahandlene (kjøp/salg av valuta). En valutahandel gjennomføres av en spesifikk ansatt, på en spesifikk dato, og gjelder et bestemt beløp av en spesifikk valuta til en avtalt kurs (som kan avvike fra den offisielle kursen den dagen).

**a) ER-diagram (8 %)**
Noter et Entity-Relationship (ER) diagram (Crow's Foot, tekstuelt, se om notasjon under) som modellerer denne utvidelsen. Diagrammet må inkludere de nye entitetene (`Valutakurser`, `Valutahandler`), den eksisterende entiteten (`Valutaer`), alle relevante attributter, primærnøkler (PK), fremmednøkler (FK), og relasjonene mellom dem med korrekt kardinalitet.

### Om notasjon (uten tegning, tekstuelt) Kommer i vedlegg på eksamen

**Eksempler**

|Kardinalitet|Betydning|Eksempel|Beskrivelse|
|--|--|--|--|
|`\|\|`| nøyaktig én| `Sykler -\|\|..o{ Utleier`| én utleie/tur har **nøyaktig én** sykkel|
|`-o{`| ingen eller mange| `Sykler -\|\|..o{ Utleier`| én sykkel kan brukes i **ingen eller mange** utleier (på ikke overlappende tidsperioder)|
|`-\|{`| en eller mange| `Ansatte }\|..o{ Prosjekter`| en ansatt kan delta i **ingen eller mange** prosjekter og et prosjekt skal ha **én eller mange** ansatte (problematisk å implementere)|

Forhold:
- `--` **identifiserende** (fremmednøkkelen er en del av primærnøkkelen og ikke NULL) 
  - eksempel: `Kino -||--o{ Kinosal` i følgende modell:

```
Kino -||--o{ Kinosal
Kino (kino_navn (PK), telefon)
Kinosal (kino_navn (PK,FK), kinosal_nr (PK), antall_plasser)
```

- `..` **ikke-identifiserende** (fremmednøkkel er ikke en del av primærnøkkelen og den kan være NULL)
  - eksempel: `Sykler -||..o{ Utleier` (fremmednøkkelen i Utleier mot Sykler er ikke en del av primærnøkkelen til Utleier) i følgende modell:

``` 
Sykler (sykkel_id (PK), status, sist_vedlikeholdt)
Utleier/Turer (tur_id (PK), sykkel_id (FK), bruker_id (FK), start_stasjon (FK), slutt_stasjon (FK), start_tid, slutt_tid, pris)
``` 


Unicode tegn som brukes i notasjonen
- `|` vertical line, U+007C
- `o` latin small letter o, U+006F
- `{` left curly bracket {, U+007B
- `}` right curly bracket }, U+007D
- `-` Hyphen-Minus -, U+002D
- `.` Full Stop ., U+002E


**b) Normalisering (8 %)**

Gitt følgende u-normaliserte tabell for å registrere fakturaer:

**FakturaOversikt**(`faktura_nr`, `dato`, `kunde_nr`, `kunde_navn`, `kunde_adresse`, `vare_nr`, `vare_navn`, `antall`, `enhetspris`)

Anta følgende funksjonelle avhengigheter:
- `faktura_nr` → `dato`, `kunde_nr`
- `kunde_nr` → `kunde_navn`, `kunde_adresse`
- `vare_nr` → `vare_navn`, `enhetspris`
- `faktura_nr`, `vare_nr` → `antall`

Forklar hvilken normalform tabellen `FakturaOversikt` befinner seg på (1NF, 2NF eller 3NF), og hvorfor. Normaliser deretter databasen til 3NF. Vis de nye tabellene med primærnøkler (markert med PK) og fremmednøkler (markert med FK). For eksempel, `faktura_nr (PK), vare_nr (FK) ...`

**c) Relasjonsalgebra (6 %)**
Skriv et relasjonsalgebraisk uttrykk som finner `kunde_navn` for alle kunder som har kjøpt en vare med `vare_navn` lik 'Bærbar PC'. Ta utgangspunkt i de normaliserte tabellene fra oppgave b).

---

## Oppgave 3: Transaksjonsanalyse og Samtidighet (Vekt: 22 %, Anbefalt tid: 40 min)

To regnskapsmedarbeidere, Ane og Bjørn, jobber samtidig mot databasen. Begge forsøker å oppdatere saldoen på konto 1920 (Bankinnskudd).

Anta at databasen bruker et isolasjonsnivå som tillater "Lost Update" (tapt oppdatering).

**a) Forklar konseptet (10 %)**
Forklar i detalj hva "Lost Update" er, og beskriv et konkret scenario med Ane og Bjørn der dette problemet oppstår når de oppdaterer konto 1920. Bruk en tidslinje (T1, T2, etc.) for å illustrere rekkefølgen av operasjoner (Read, Calculate, Write).

**b) Løsning (12 %)**
Hvordan kan man forhindre "Lost Update" i PostgreSQL? Beskriv to ulike metoder (for eksempel ved bruk av spesifikke SQL-kommandoer eller endring av isolasjonsnivå) og forklar kort hvordan de løser problemet.

---

## Oppgave 4: NoSQL og Dokumentdatabaser (Vekt: 23 %, Anbefalt tid: 40 min)

Bedriften vurderer å migrere deler av systemet til en dokumentdatabase (som MongoDB) for å håndtere bilagsvedlegg og metadata som ikke passer inn i den relasjonelle modellen.

**a) Datamodellering i NoSQL (13 %)**
Design et JSON-dokument som representerer en `Transaksjon` med tilhørende `Posteringer`. Dokumentet skal inneholde informasjon tilsvarende det som finnes i relasjonsmodellen (bilagsnummer, dato, beskrivelse, og en liste med posteringer som inneholder kontonummer og beløp). Vis et konkret eksempel på et slikt JSON-dokument.

**b) Sammenligning (10 %)**
Diskuter fordeler og ulemper ved å lagre transaksjoner og posteringer som ett samlet dokument i en NoSQL-database, sammenlignet med å fordele dem over flere tabeller i en relasjonsdatabase. Fokuser spesielt på aspekter som dataintegritet (ACID), spørreytelse og fleksibilitet.
