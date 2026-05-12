# Løsningsforslag og Sensorveiledning
**Prøveeksamen i Databaser våren 2026**

---

## Oppgave 1: SQL-spørringer og avanserte funksjoner (33 %)

### a) Grunnleggende spørring (3 %)
**Løsningsforslag:**
```sql
SELECT kontonummer, navn
FROM Kontoer
WHERE mva_pliktig = TRUE
ORDER BY kontonummer ASC;
```
**Sensorveiledning:**
- Full uttelling (3 %): Korrekt `SELECT`, `FROM`, `WHERE` og `ORDER BY`.
- Trekk for manglende sortering eller feil kolonnenavn.

### b) Filtrering og sortering (3 %)
**Løsningsforslag:**
```sql
SELECT bilagsnummer, posteringsdato, beskrivelse
FROM Transaksjoner
WHERE posteringsdato >= '2026-03-01' AND posteringsdato <= '2026-03-31'
ORDER BY posteringsdato DESC;
```
*(Alternativt kan `BETWEEN '2026-03-01' AND '2026-03-31'` eller `EXTRACT(MONTH FROM posteringsdato) = 3 AND EXTRACT(YEAR FROM posteringsdato) = 2026` brukes).*

**Sensorveiledning:**
- Full uttelling (3 %): Korrekt `SELECT`, `FROM`, `WHERE` (med riktig datointervall) og `ORDER BY DESC`.
- Trekk for manglende sortering (`DESC`) eller feil datohåndtering.

### c) Aggregering og JOIN (7 %)
**Løsningsforslag:**
```sql
SELECT k.kontonummer, k.navn, SUM(p.belop_teller::numeric / p.belop_nevner) AS saldo
FROM Kontoer k
JOIN Posteringer p ON k.guid = p.konto_guid
GROUP BY k.kontonummer, k.navn;
```
**Sensorveiledning:**
- Full uttelling (7 %): Korrekt `JOIN`, `GROUP BY` og `SUM`-funksjon med brøkdivisjon.
- Trekk hvis `GROUP BY` mangler eller er ufullstendig (f.eks. mangler `k.navn`).
- Trekk hvis de ikke håndterer divisjonen (selv om casting til `numeric` ikke er strengt påkrevd for full pott, er det et pluss).

### d) Aggregering med NULL-håndtering (7 %)
**Løsningsforslag:**
```sql
SELECT h.kontonummer, h.navn, COUNT(u.guid) AS antall_underkontoer
FROM Kontoer h
LEFT JOIN Kontoer u ON h.guid = u.overordnet_guid
WHERE h.overordnet_guid IS NULL
GROUP BY h.kontonummer, h.navn;
```
**Sensorveiledning:**
- Full uttelling (7 %): Korrekt bruk av `LEFT JOIN` (eller `LEFT OUTER JOIN`) for å inkludere hovedkontoer uten underkontoer. Riktig `COUNT(u.guid)` (eller en annen kolonne fra underkonto-tabellen, men ikke `COUNT(*)` da det vil gi 1 for kontoer uten barn). Korrekt `WHERE h.overordnet_guid IS NULL` og `GROUP BY`.
- Delvis uttelling: Bruker `INNER JOIN` (mister kontoer med 0 underkontoer), eller bruker `COUNT(*)` som gir feil antall for tomme kontoer.

### e) Rekursiv CTE (13 %)
**Løsningsforslag:**
```sql
WITH RECURSIVE Kontotre AS (
    -- Ankerledd: Finn startkontoen (nivå 0)
    SELECT guid, kontonummer, navn, 0 AS nivaa
    FROM Kontoer
    WHERE kontonummer = 3000

    UNION ALL

    -- Rekursivt ledd: Finn alle barn av kontoene i forrige nivå
    SELECT k.guid, k.kontonummer, k.navn, kt.nivaa + 1
    FROM Kontoer k
    JOIN Kontotre kt ON k.overordnet_guid = kt.guid
)
SELECT kontonummer, navn, nivaa
FROM Kontotre;
```
**Sensorveiledning:**
- Full uttelling (13 %): Korrekt struktur med `WITH RECURSIVE`, ankerledd, `UNION ALL` og rekursivt ledd med riktig `JOIN`-betingelse (`k.overordnet_guid = kt.guid`).
- Delvis uttelling (5-8 %): Forstår konseptet, men har syntaksfeil eller feil join-betingelse.
- Trekk hvis nivå-telleren (`nivaa + 1`) mangler eller er feil implementert.

---

## Oppgave 2: Datamodellering og normalisering (Vekt: 22 %, Anbefalt tid: 40 min)

**a) ER-diagram (8 %)**
*Løsningsforslag:*

```
Modell:
Ansatte (ansatt_id (PK), ansatt_navn)
Valutaer (valuta_kode (PK), valuta_navn)
Valutakurser (valuta_kode (PK,FK), dato, kurs)
Valutahandler (handel_id (PK), valuta_kode (FK), dato, ansatt_id (FK), handlet_belop_teller, handlet_belop_nevner, avtalt_kurs)

Forhold: 
Valutaer -||--o{ Valutakurser (identifiserende forhold, siden PK til Valutaer inngår i PK til Valutakurser og er også FK i Valutakurser; kan også modelleres med en surrogatnøkkel og da blir forholdet ikke-identifiserende)

Valutaer -||..o{ Valutahandler

```

*Sensorveiledning:*
- 3 poeng for riktige entiteter med fornuftige attributter.
- 3 poeng for riktige primær- og fremmednøkler (spesielt sammensatt PK for Valutakurser, eller en surrogatnøkkel).
- 2 poeng for riktige kardinaliteter (En valuta kan ha mange kurser og mange handler).

**b) Normalisering (8 %)**
**Løsningsforslag:**
Tabellen er på **1NF** fordi den har en sammensatt primærnøkkel (`faktura_nr`, `vare_nr`) for å unngå duplikater (en faktura kan ha flere varer), men den inneholder partielle avhengigheter. For eksempel avhenger `dato` og `kunde_nr` kun av deler av nøkkelen (`faktura_nr`), ikke hele nøkkelen.

*Normalisering til 3NF:*
1. **Kunder**(`kunde_nr` (PK), `kunde_navn`, `kunde_adresse`)
2. **Varer**(`vare_nr` (PK), `vare_navn`, `enhetspris`)
3. **Fakturaer**(`faktura_nr` (PK), `dato`, `kunde_nr` (FK))
4. **Fakturalinjer**(`faktura_nr` (PK/FK), `vare_nr` (PK/FK), `antall`)

**Sensorveiledning:**
- Full uttelling (8 %): Korrekt identifisering av 1NF med begrunnelse (partielle avhengigheter). Korrekt oppdeling i 4 tabeller med riktige primær- og fremmednøkler.
- Delvis uttelling: Feil utgangsform, men riktig normalisering, eller manglende tabeller (f.eks. glemmer Fakturalinje-koblingstabellen).

**c) Relasjonsalgebra (6 %)**
**Løsningsforslag:**
π<sub>kunde_navn</sub> (
  σ<sub>vare_navn='Bærbar PC'</sub> (
    Kunde ⨝ Faktura ⨝ Fakturalinje ⨝ Vare
  )
)

**Sensorveiledning:**
- Full uttelling (6 %): Korrekt bruk av projeksjon (π), seleksjon (σ) og naturlig join (⨝) mellom de fire nødvendige tabellene.
- Delvis uttelling: Feil symbolbruk, men logikken er riktig, eller mangler en join for å koble Kunde til Vare.



## Oppgave 3: Transaksjonsanalyse og Samtidighet (22 %)

### a) Forklar konseptet (10 %)
**Løsningsforslag:**
"Lost Update" (tapt oppdatering) oppstår når to samtidige transaksjoner leser samme data, utfører en beregning basert på den leste verdien, og deretter skriver resultatet tilbake. Den siste transaksjonen som skriver, overskriver den førstes endringer uten å ta hensyn til dem.

*Scenario:*
- **T1 (Ane):** Leser saldo på konto 1920 (f.eks. 10 000 kr).
- **T2 (Bjørn):** Leser saldo på konto 1920 (10 000 kr).
- **T1 (Ane):** Beregner ny saldo: 10 000 + 5 000 = 15 000 kr.
- **T2 (Bjørn):** Beregner ny saldo: 10 000 - 2 000 = 8 000 kr.
- **T1 (Ane):** Skriver 15 000 kr til databasen.
- **T2 (Bjørn):** Skriver 8 000 kr til databasen.

*Resultat:* Anes innbetaling på 5 000 kr er tapt. Sluttsaldoen er 8 000 kr, mens den korrekte saldoen skulle vært 13 000 kr.

**Sensorveiledning:**
- Full uttelling (10 %): Klar definisjon av Read-Calculate-Write-mønsteret og et tydelig, trinnvis scenario som viser hvordan oppdateringen går tapt.

### b) Løsning (12 %)
**Løsningsforslag:**
1. **Pessimistisk låsing (`SELECT ... FOR UPDATE`):**
   Når Ane leser raden, låser hun den. Bjørn må vente med å lese raden til Ane har utført sin `UPDATE` og `COMMIT`. Da vil Bjørn lese den oppdaterte verdien (15 000 kr) og beregne riktig ny saldo (13 000 kr).
2. **Endre isolasjonsnivå til `REPEATABLE READ` (eller `SERIALIZABLE`):**
   I PostgreSQL vil `REPEATABLE READ` oppdage at raden har blitt endret av en annen transaksjon siden den ble lest. Når Bjørn forsøker å utføre sin `UPDATE`, vil databasen kaste en serialiseringsfeil ("could not serialize access due to concurrent update"), og applikasjonen må fange feilen og prøve transaksjonen på nytt.

**Sensorveiledning:**
- Full uttelling (12 %): Beskriver to gyldige metoder (f.eks. eksplisitt låsing og isolasjonsnivå) og forklarer mekanismen bak dem (venting vs. feilmelding/retry).

---

## Oppgave 4: NoSQL og Dokumentdatabaser (23 %)

### a) Datamodellering i NoSQL (13 %)
**Løsningsforslag:**
I en dokumentdatabase som MongoDB kan vi bygge inn (embed) posteringene direkte i transaksjonsdokumentet.

```json
{
  "_id": "tx-1001",
  "bilagsnummer": "B-2026-01",
  "posteringsdato": "2026-03-15",
  "beskrivelse": "Kjøp av kontorrekvisita",
  "posteringer": [
    {
      "kontonummer": 6800,
      "belop": 5000.00
    },
    {
      "kontonummer": 1920,
      "belop": -5000.00
    }
  ]
}
```

**Sensorveiledning:**
- Full uttelling (13 %): Viser et gyldig JSON-dokument der posteringene er lagret som et array (liste) av sub-dokumenter inne i hoveddokumentet for transaksjonen.
- Trekk hvis de modellerer det som separate dokumenter med referanser (som i en relasjonsdatabase), da dette ikke utnytter dokumentmodellens styrke for dette spesifikke caset.

### b) Sammenligning (10 %)
**Løsningsforslag:**
*Fordeler med NoSQL (embedded dokument):*
- **Spørreytelse (Lesing):** Hele transaksjonen med alle posteringer kan hentes med én enkelt databaseoperasjon (ingen JOINs nødvendig).
- **Fleksibilitet:** Enkelt å legge til nye felt (f.eks. "vedlegg_url" eller "godkjent_av") på enkelte transaksjoner uten å endre et rigid skjema.

*Ulemper med NoSQL:*
- **Dataintegritet (ACID):** Mens moderne dokumentdatabaser støtter transaksjoner, er de primært designet for atomisitet på dokumentnivå. Å garantere at summen av posteringer er 0 (dobbelt bokholderi) må ofte håndteres i applikasjonslogikken, ikke via database-constraints (som CHECK eller triggers i SQL).
- **Aggregering på tvers:** Å beregne saldoen for en spesifikk konto (f.eks. 1920) krever at databasen må søke gjennom arrayene i *alle* transaksjonsdokumenter, noe som er mindre effektivt enn en enkel `SUM()` med `GROUP BY` i en relasjonsdatabase (med mindre man bygger komplekse indekser eller aggregerings-pipelines).

**Sensorveiledning:**
- Full uttelling (10 %): Diskuterer både fordeler (leseytelse, fleksibilitet) og ulemper (manglende constraints for dobbelt bokholderi, tyngre aggregering på tvers av dokumenter).
- Delvis uttelling: Nevner bare overfladiske forskjeller (f.eks. "NoSQL har ikke skjema") uten å knytte det til caset med transaksjoner og posteringer.
