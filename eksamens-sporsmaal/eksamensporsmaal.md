# Datamodellering

Konseptuell og logisk datamodellering basert på modeller fra tre ulike domener for å gi en bredde i modelleringstrening. 

## Modellbeskrivelse (tre domener)

Modellene er definert med et tabellnavn med stor forbokstav og i flertall (Sykler, Stasjoner osv.), og med kolonnenavn (attributter) med "snake_case"-notasjon og små bokstaver. Ingen primær- eller fremmednøkler er markert.

### Modell A: Bysykkel-utleie
``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasistet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

### Modell B: E-sport / Dataspill (Racing)
```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plasseringer, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 

### Modell C: Bedrift og Prosjektstyring
``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

## Oppgaver

### Konseptuell modellering og Entiteter

Konseptuell modellering innebærer 
- å finne begreper og navn, som brukes for entitetene (eller objektene) i en datamodell,
- å bruke diagrammer (ER og/eller UML),
- å angi nøkkelattributter, relasjonstyper (1:1, 1:N, N:M) og kardinalitet (eksempel: en Sykkel kan ha ingen eller mange Utleier/Turer, en Tur kan ha nøyaktig en sykkel),
- å inkludere forretningsregler og identitetsbegrensninger (unikhet, påkrevde verdier),
- å forklare normalisering for skape et grunnlag for en "fysisk" modell.

OBS! Når det blir spurt om å gi eksempler fra en spesifikk modell, betyr det ikke at all nødvendig informasjon er gitt i modellbeskrivelsene. Det forventes at studentene foreslår nødvendige entiteter, attributter, forhold osv. for å besvare spørsmålet.  

1. I Model C (Bedrift), hvordan vil du modellere at en ansatt kan ha flere telefonnumre?

Tester forståelsen av normalisering, fordeler og ulemper av flerverdiattributter og spesielle objekttyper (eksempel: ARRAY i PostgreSQL). 

2. Hva er en surrogatnøkkel, og hvorfor brukes det ofte i stedet for "naturlige" nøkler? Gi eksempel fra Modell B (E-sport).

Tester kjennskap til forskjell på "naturlige" og surrogatnøkler, samt kjennskap til fordeler og ulemper med surrogatnøkkler. 

3. I Modell A (Bysykkel), hvilken entitet fungerer som en koblingstabell (assosiative entitet), og hvilke entiteter kobler den sammen?

Tester forståelsen av assosiative entiteter (koblingstabell).

4. Hvordan modellerer man en rekursiv (selv-reflekterende) relasjon? Gi et eksempel på hvordan dette kan brukes i Model C (Bedrift) for å vise hvem som er sjefen til hvem.

Tester forståelse av modellering av hierarkiske strukturer i en tabell (relasjonsmodellen).

5. Hva er en sammensatt attributt (composite attribute)? Gi et eksempel på hvordan adresse kunne vært modellert som dette for en Bruker i Modell A (Bysykkel).

Tester forståelse av sammensatte attributter. Sammensatte attributter bryter med høyere normalformer, men kan noen ganger beskrive systemet bedre.

6. Hva er forskjellen på en sterk og en svak entitet? Gi eksempel fra Modell A (Bysykkel).

Tester forståelsen av modelleringsdetaljer som gjelder avhengighetsforhold mellom entiteter. 

### Relasjoner og Kardinalitet

7. Forklar kardinaliteten mellom Avdelinger og Ansatte i Modell C (Bedrift). 

Tester forståelse av begrepet kardinalitet.

8. I modell B (E-sport), hva er kardinaliteten mellom Spillere og Lop? Hvordan løses dette i en relasjonsdatabase? 

Tester forståelse av løsning for mange til mange forhold i en relasjonsdatabase.

9. Hva betyr "total deltakelse" i et ER-diagram (entiteter og forhold til andre entiteter er vist med symboler eller tegning)? Må Sykler ha en totaldeltakelse i Uleier/Turer?

Tester forståelsen av typer forhold mellom entiteter:
- 1:N en til mange forhold kan implementeres vha. fremmednøkkel på "mange"-siden, dvs. hvis en ansatt må tilhøre en og bare en avdeling (minimumskardinalitet på "en"-siden er nøyaktig en `||`), så kan dette modelleres med fremmednøkkel som ikke kan være null på "mange"-siden, dvs. i Ansatte vil avdeling_id ha NOT NULL regelen.
- 1:1 en til en forhold kan ikke implementeres med fremmednøkler (eksempel `Land ||--|| Hovedstad`, dvs. et land har nøyaktig ett hovedstad og et hovedstad tilhører nøyaktig ett land) og man må bruke andre mekanismer, f. eks. å utføre innsetting av data i begge tabellene som èn transaksjon eller å bruke triggere (PostgreSQL har `DEFERRABLE` valget for å markere fremmednøkler sjekkes først når COMMIT blir utført for èn transaksjon, mens i ANDRE DBHS kan man bruke triggere)

10. Illustrer med symboler Crow's Foot-notasjonen for relasjon mellom Turneringer og Løp i Model B (E-sport).

Relasjoner noteres på følgende måte:
|Kardinalitet|Betydning|Eksempel|Beskrivelse|
|--|--|--|--|
|`\|\|`| nøyaktig èn| `Sykler -\|\|--o{ Utleier`| èn utleie/tur har **nøyaktig èn** sykkel|
|`-o{`| ingen eller mange| `Sykler -\|\|--o{ Utleier`| èn sykkel kan brukes i **ingen eller mange** utleier (på ikke overlappende tidsperioder)|
|`-\|{`| en eller mange| `Ansatte }\|--o{ Prosjekter`| en ansatt kan delta i **ingen eller mange** prosjekter og et prosjekt skal ha **en eller mange** ansatte (problematisk å implementere)|

Unicode tegn som brukes i notasjonen
- `|` vertical line, U+007C
- `o` latin small letter o, U+006F
- `{` left curly bracket {, U+007B
- `}` right curly bracket }, U+007D
- `-` Hyphen-Minus -, U+002D












