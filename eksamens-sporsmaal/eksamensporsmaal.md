# DataModelllering

Konseptuell og logisk dataModelllering basert på Modelller fra tre ulike domener for å gi en bredde i Modellleringstrening. 

## Modelllbeskrivelse (tre domener)

Modelllene er definert med et tabellnavn med stor forbokstav og i flertall (Sykler, Stasjoner osv.), og med kolonnenavn (attributter) med "snake_case"-notasjon og små bokstaver. Ingen primær- eller fremmednøkler er markert.

### Modelll A: Bysykkel-utleie
``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
Brukere (bruker_id, navn, telefon, betalingsmetode)
Utleier/Turer (tur_id, sykkel_id, bruker_id, start_stasjon, slutt_stasjon, start_tid, slutt_tid, pris)
``` 

### Modelll B: E-sport / Dataspill (Racing)
```
Spillere (spiller_id, brukernavn, region, rank)
Turneringer (turnering_id, navn, start_dato, premiepott)
Løp (lop_id, turnering_id, bane_navn, vaerforhold)
Deltakelser (spiller_id, lop_id, plasseringer, beste_rundetid)
Telemetri (NoSQL/Tidsserier): Fart, posisjon (x,y,z), dekkslitasje per millisekund
``` 

### Modelll C: Bedrift og Prosjektstyring
``` 
Ansatte (ansatt_id, navn, avdeling_id, ansettelsesdato)
Avdelinger (avdeling_id, navn, leder_id)
Prosjekter (prosjekt_id, navn, budsjett, start_dato, slutt_dato)
Prosjektdeltakelse (ansatt_id, prosjekt_id, rolle, timer_allokert)
``` 

## Oppgaver

### Konseptuell Modelllering og Entiteter

Konseptuell Modelllering innebærer 
- å finne begreper og navn, som brukes for entitetene (eller objektene) i en dataModelll,
- å bruke diagrammer (ER og/eller UML),
- å angi nøkkelattributter, relasjonstyper (1:1, 1:N, N:M) og kardinalitet (eksempel: en Sykkel kan ha ingen eller mange Utleier/Turer, en Tur kan ha nøyaktig en sykkel),
- å inkludere forretningsregler og identitetsbegrensninger (unikhet, påkrevde verdier),
- å forklare normalisering for skape et grunnlag for en "fysisk" Modelll.

OBS! Når det blir spurt om å gi eksempler fra en spesifikk Modelll, betyr det ikke at all nødvendig informasjon er gitt i Modelllbeskrivelsene. Det forventes at studentene foreslår entiteter, attributter, forhold osv. som er nødvendig for å besvare spørsmål.  

1. I Modell C (Bedrift), hvordan vil du Modelllere at en ansatt kan ha flere telefonnumre?

Tester forståelsen av normalisering, fordeler og ulemper av flerverdiattributter og spesielle objekttyper (eksempel: ARRAY i PostgreSQL). 

2. Hva er en surrogatnøkkel, og hvorfor brukes det ofte i stedet for "naturlige" nøkler? Gi eksempel fra Modelll B (E-sport).

Tester kjennskap til forskjell på "naturlige" og surrogatnøkler, samt kjennskap til fordeler og ulemper med surrogatnøkkler. 

3. I Modelll A (Bysykkel), hvilken entitet fungerer som en koblingstabell (assosiativ entitet), og hvilke entiteter kobler den sammen?

Tester forståelsen av assosiative entiteter (koblingstabeller).

4. Hvordan Modelllerer man en rekursiv (selv-reflekterende) relasjon? Gi et eksempel på hvordan dette kan brukes i Modell C (Bedrift) for å vise hvem som er sjefen til hvem.

Tester forståelse av Modelllering av hierarkiske strukturer i en tabell (relasjonsModelllen).

5. Hva er en sammensatt attributt (composite attribute)? Gi et eksempel på hvordan adresse kunne vært Modelllert som dette for en Bruker i Modelll A (Bysykkel).

Tester forståelse av sammensatte attributter. Sammensatte attributter bryter med høyere normalformer, men kan noen ganger beskrive systemet bedre.

6. Hva er forskjellen på en sterk og en svak entitet? Gi eksempel fra Modelll A (Bysykkel).

Tester forståelsen av Modellleringsdetaljer som gjelder avhengighetsforhold mellom entiteter. 

### Relasjoner og Kardinalitet

7. Forklar kardinaliteten mellom Avdelinger og Ansatte i Modelll C (Bedrift). 

Tester forståelse av begrepet kardinalitet.

8. I Modelll B (E-sport), hva er kardinaliteten mellom Spillere og Lop? Hvordan løses dette i en relasjonsdatabase? 

Tester forståelse av løsning for mange til mange forhold i en relasjonsdatabase.

9. Hva betyr "total deltakelse" i et ER-diagram (entiteter og forhold til andre entiteter er vist med symboler eller tegning)? Må Sykler ha en totaldeltakelse i Uleier/Turer?

Tester forståelsen av typer forhold mellom entiteter:
- 1:N en til mange forhold kan implementeres vha. fremmednøkkel på "mange"-siden, dvs. hvis en ansatt må tilhøre en og bare en avdeling (minimumskardinalitet på "en"-siden er nøyaktig en `||`), så kan dette Modellleres med fremmednøkkel som ikke kan være null på "mange"-siden, dvs. i Ansatte vil avdeling_id ha NOT NULL regelen.
- 1:1 en til en forhold kan ikke implementeres med fremmednøkler (eksempel `Land ||--|| Hovedstad`, dvs. et land har nøyaktig ett hovedstad og et hovedstad tilhører nøyaktig ett land) og man må bruke andre mekanismer, f. eks. å utføre innsetting av data i begge tabellene som èn transaksjon eller å bruke triggere (PostgreSQL har `DEFERRABLE` valget for å markere fremmednøkler sjekkes først når COMMIT blir utført for èn transaksjon, mens i ANDRE DBHS kan man bruke triggere)

10. Illustrer med symboler (se forklaring under) Crow's Foot-notasjonen for relasjon mellom Turneringer og Løp i Modell B (E-sport).

Tester kunnskap/ferdighet til å bruke relevante symboler for å illustrere forhold i en konseptuell Modelll (når man ikke kan tegne hverken på papir eller vha. datamaskin).

**Om notasjon (uten tegning)**

|Kardinalitet|Betydning|Eksempel|Beskrivelse|
|--|--|--|--|
|`\|\|`| nøyaktig én| `Sykler -\|\|--o{ Utleier`| én utleie/tur har **nøyaktig én** sykkel|
|`-o{`| ingen eller mange| `Sykler -\|\|--o{ Utleier`| én sykkel kan brukes i **ingen eller mange** utleier (på ikke overlappende tidsperioder)|
|`-\|{`| en eller mange| `Ansatte }\|--o{ Prosjekter`| en ansatt kan delta i **ingen eller mange** prosjekter og et prosjekt skal ha **én eller mange** ansatte (problematisk å implementere)|

Unicode tegn som brukes i notasjonen
- `|` vertical line, U+007C
- `o` latin small letter o, U+006F
- `{` left curly bracket {, U+007B
- `}` right curly bracket }, U+007D
- `-` Hyphen-Minus -, U+002D

11. I Modell C (Bedrift), en avdeling har én leder (som er ansatt). Hvordan Modellleres denne spesifikke 1:1-relasjonen uten å skape en sirkulær avhengighet ved innsetting av data? 

Basert på Modell C (Bedrift), skriv SQL kommandoer for å lage de to entitetene med de nødvendige attributtene og vis hvordan man kan registrere at 'Bjørn Samuelson' leder avdeling 'Aalesund'.

Tester forståelsen av sirkulære forhold og kunnskapen/ferdigheten til å implementere slike forhold i et databasehåndteringssystem.

12. Hva er forskjellen på et identifiserende og et ikke-identifiserende forhold?

Tester kjennskap til forhold mellom entiteter hvor fremmednøkkelen som refererer til entitet A er en del av primærnøkkelen til entitet B. 

Analyser alle forholdene i Modell A (Bysykkel) og finn ut hvilke forhold er identifiserende og ikke-identifiserende og hvorfor.

** Om notasjon **

Vi bruker symbolmengden `--` for et identifiserende forhold og symbolmengden `..` for et ikke-identifiserende forhold. 

For eksempel, `Spillere -||--o{- Deltakelser }o--||- Løp` viser en assosiativ entitet Deltakelser, som har identifiserende forhold til både Spillere og Løp. 

Et annet eksempel er `Ansatte }o..||- Avdelinger` som viser en ikke-identifiserende forhold mellom Ansatte og Avdelinger.

### Nøkler og integritet

13. Hva er en sammensatt primærnøkkel? Hvilken tabell i Modell B (E-sport) bør ha dette?

Tester forståelse av sammensatte nøkler. 

14. Forklar konseptet referanseintegritet. Hva skjer i Modell A (Bysykkel) hvis man prøver å slette en Stasjon som har tilknyttede Utleier?

Tester forståelse av hvordan primærnøkler sammen med fremmednøkler definerer regler for forhold mellom entiteter.

15. Hva er formålet med ON DELETE CASCADE? Når bør det brukes, og når det farlig? 

Tester kjennskap til og ferdighet til å anvende spesifikke begrensninger i PostgreSQL (som `on delete no action`, `on delete restrict`, `on delete cascade`).

En slik oppgave kan utgjøre en vesentlig del av eksamen: Demonstrer med SQL-kommandoer og SQL-spørringer hvordan sletting av en stasjon kan medføre til sletting av rader i tabellene som har fremmednøkler mot Stasjoner (Utleier, Sykler) ved bruken av ON DELETE CASCADE.

16. I Modell C (Bedrift), bør leder_id i Avdelinger ha en UNIQUE-constraint? Hvorfor/hvorfor ikke?

Tester forståelsen av at kravene fra den reelle verden bestemmer detaljene i databaseskjema.

17. Hva er en kandidatnøkkel? Finn en mulig kandidatnøkkel i tabellen Brukere fra Modell A (Bysykkel).

Tester kunnskapen om hvordan velge nøkler for en relasjon / tabell. 

Supernøkkel: mengde med attributter som alltid har unike verdier i en relasjon / tabell; en relasjon kan ha mange supernøkler og man har en supernøkkel, vil alle utvidelser også være supernøkkel; alle attributtene i en tabell danner alltid en supernøkkel.

Eksempel: gitt følgende relasjon Brukere(brukernavn, fornavn, etternavn, adresse), kan man resonnere seg frem til at det er kun brukernavn som er en potensiell supernøkkel med den forutsetnignen av den er designet for å være unik innenfor den konteksten den skal brukes (Oslomet, for eksempel). Når det gjelder fornavn, etternavn og adresse, så kan alle disse potensielt være like for flere forekomster av Brukere. 
Alle kombinasjoner mellom brukernavn og de andre attributtene er også en supernøkkel. 

Kandidatnøkkel: er en minimal supernøkkel 

Eksempel: for relasjon Brukere er brukernavn den eneste  kandidatnøkkelen; et annet eksempel kan være relasjon Emner(fagkode, emnenummer, tittel, stp), som kan ha både (fagkode, emnenummer) og (tittel) som kandidatnøkler. 

Primærnøkkel: en valgt kandidatnøkkel

Eksempel: for relasjonen Brukere er det kun brukernavn som er primærnøkkel; for relasjonen Emner man velge blant de to kandidatnøklene, for eksempel (fagkode, emnenummer)

Mye av dette kan løses ved å bruke en surrogatnøkkel, som da er både supernøkkel, kandidatnøkkel og primærnøkkel.

18. Hvordan håndterer man at en Sykkel kan være på et verksted eller er utleid og dermed ikke tilknyttet noen Stasjon for øyeblikket?

Tester forståelsen av bruken av fremmednøkler for å tilfredsstille spesifikke krav.

### Avansert Modelllering og historikk

19. Bysykkel-selskapet (Modell A) ønsker å spore historikken til sykkelens status (f.eks. når den gikk fra "Aktiv" til "På verksted"). Hvordan må Modelllen utvides for å støtte dette?

Tester forståelse for lagring av historikken i en Modelll som er satt i produksjon.

20. I Modell C (Bedrift), hvordan Modelllerer du at en ansatt bytter avdeling over tid, og man trenger å vite hvilken avdeling de jobbet i på en bestemt dato?

Tester forståelse for lagring av historikken i en Modelll som er satt i produksjon.

21. Modell B (E-sport) trenger å lagre telemetridata (fart, posisjon) 60 ganger i sekundet per spiller per løp. Horfor er en tradisjonell relasjonsdatabase dårlig egnet for dette, og hvordan bør det modelleres i stedet?

Tester forståelsen om bruksscenarioer som ikke er egnet for relasjonsdatabaser og kunnskapen om alternative løsninger.

22. Hvordan Modelllerer man en hierarki med uendelin dybde (f.eks. kategorier av utstyr i Modell C (Bedrift)).

Tester kunnskapen om modellering av rekursjon i SQL. 

23. Hva er forskjellen på et stjerneskjema og en normalisert transaksjonsmodell (OLTP)? Hvilke av de tre modellene egner seg best for OLTP? 

Tester kunnskapen om grunnleggende modeller innen databehandling som ofte kombineres for å både prosessere transaksjoner trygt og effektivt samt analysere og visualisere data fra de samlede dataene. 

### Praktiske scenarioer og valg

24. Modell A (Bysykkel): En tur kan pågå akkurat nå (den har ingen slutt_tid eller slutt_stasjon ennå). Hvordan påvirker dette datatypene og constraints for disse kolonnene?

Tester ferdighetene for å kunne velge løsninger som gjenspeiler reelle prosesser (praktiske scenarioer) i en relasjonsmodell. 

25. Modell B (E-sport): En turnering kan ha lag i stedet for individuelle spillere. Hvordan må modellen endres for å støtte både lag-baserte og individuelle turneringer?

Tester ferdighetene for å kunne velge løsninger som gjenspeiler reelle prosesser (praktiske scenarioer) i en relasjonsmodell.

26. Modell C (Bedrift): En ansatt kan ha ulik timepris avhengig av hvilket prosjekt de jobber på. Hvor i modellen bør timepris lagres?

Tester ferdighetene for å kunne velge løsninger som gjenspeiler reelle prosesser (praktiske scenarioer) i en relasjonsmodell.

27. Hva er "denormalisering"? Git ett eksempel på når det kan være fornuftig å denormalisere entiteten Utleier i Modell A (Bysykkel) for ytelsens skyld.

Tester forståelsen om at høy grad av normalisering kan skape et ytelsesproblem.

28. Hordan modellerer man at en Sykkel i Modell A (Bysykkel) kan ha ulike typer utstyr (f.eks. barnesete, piggdekk, kurv) der en sykkel kan ha flere typer utstyr, og utstyret kan flyttes mellom sykler?

Tester forståelsen av når det er nødvendig å introdusere nye entiteter som følge av praktiske scenarioer fra domenet (i dette tilfelle bedriften som tilbyr sykkelutleie). Tester også forståelsen av at et modelleringsproblem kan løses på flere forskjellige måter. Tester også ferdigheten til å analysere fordeler og ulemper med de forskjellige måtene å løse modelleringsproblemet på. 

29. I Modell B (E-sport), hvordan vil du lagre "Replay buffer" (de siste 30 sekundene av løpet for alle spillere) for umiddelbar visning ved krasj? Hvilken databaseteknologi/modelleringsteknikk egner seg her?

Tester kunnskapen om å velge egnet datahåndteringssystem for et gitt problem.

### Grunnleggende SQL-spørringer og Filtrering

30. Skriv en SQL-spørring som henter alle ansatte som ble ansatt etter 1. januar 2020. Gjelder Modell C (Bedrift).

Tester kunnskapen for å bygge en grunnleggende SQL-spørring mot en tabell med en betingelse (filtrering).

31. Hvordan finner du alle sykler som har status 'På verksted' eller 'Stjålet'? Bruk IN-operatoren. Gjelder Modell A (Bysykkel).

Tester kunnskapen om å bygge grunnleggende SQL-spørring som inneholder IN-operator (at en verdi matcher en verdi i en liste).

32. Skriv en SQL-spørring som henter alle spillere der brukernavnet starter med 'Pro_'. Gjelder Modell B(E-sport).

Tester kunnskapen om jokernotasjon i SQL. 

33. Hvordan sorterer du utleier slik at den lengste av utleiene (i tid) kommer først? Anta at typen til tidsattributtene er TIMESTAMPTZ, som automatisk returnerer en verdi av typen INTERVAL (en type for varighet).
Hvordan kan man unngå å selektere pågående turer? Gjelder Modell A (Bysykkel).

Tester forståelsen og kunnskapen om å regne med attributter som betegner tid og bruk av NULL-verdier i modeller. 





