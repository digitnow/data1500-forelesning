# Forelesningsmanus 2026-01-27: Relasjonsalgebra og relasjonsmodell 
- (noe inspirert av kilde IN2090, UiO)
- Historikken om databaseteorien: begynte med grafer (nettverksmodell) eksponert for et spesifikt programmeringsspråk.
- Historikken om databaseteorien: hierarkiske databaser som en forenkling av nettverksdatabaser.
- Historikken om databaseteorien: 1970 E. F. Codd introduserte relasjonsdatabaser og i 1977 laget Oracle et databasehåndteringssystem basert på relasjonsmodellen
- Den mest kjente eksempel på data representert i relasjonsmodellen, er tabell med rader og kolonner. 
- Relasjonsmodellen (RM) er en matematisk beskrivelse av en tabell med rader og kolonner, samt referanser til data i andre tabeller (tabell kalles relasjon). 
- RM definerer hva en relasjon (tabell) består av og når er relasjoner (tabeller) like. 
- RM beskriver data med relasjoner, dvs. hvilken struktur data har, hvordan man takler identitet og referanser.
- RM beskriver henting og manipulering av data, som er representert som relasjoner.
- RM er en full beskrivelse (formell og presis) av hvordan relasjoner brukes for å beskrive data.
- En relasjon består av en signatur og en mengde med tupler.
- Mengde er en samling av unike elementer som er uordnet, f. eks. {1,2,3} = {3,1,2}.
- Tuppel er en liste med verdier som er ordnet, f. eks. {1,2,Mickey} ikke lik {1,Mickey,2}.
- Kan representere en tabell med mengde og tupler, dvs. med en signatur (studenter(student_id, fornavn, etternavn, program)) og en mengde med tupler (101,Mickey,CS), (102,Daffy,EE), ...
- Tupler er rader med felt/attributter/kolonneverdier, som er ordnet. 
- Tabell er en mengde av tupler, som er uordnet (rader er ikke ordnet/sortert). 
- Tabell kalles en relasjon når man bruker språket til relasjonsalgebra.
- Kan være nyttig å beskrive matematisk, slik at man kan studere spørringer basert på den matematiske teorien (basert på sammenhenger mellom operander og operatorer).
- En signatur består av et navn (f.eks. "studenter", som blir kalt tabell- eller entitetsnavn) og en mengde med attributter/kolonner (student_id: int, fornavn: text, etternavn: text, program: text) eller (student_id, fornavn, etternavn, program), - med eller uten spesifikasjon av type for hvert attributt (type blir også kalt domene).
- En signatur kan også inneholde nøkler (brukes for å gi identitet til hver tuppel/rad).
- En signatur er nok for å kunne bruke relasjonen (kan også tenkes på som et format / et skjema for datalagring).
- Relasjonsskjema er en mengde med relasjonssignaturer (mengde med tabeller). 
- Et attributt (kan betraktes som en verdi i en kolonne i en tabell) består av et navn og en type (også kalt domene).
- To attributter kan ikke ha samme navn i samme relasjon (unike navn for kolonner i en tabell).
- Dataene i en relasjon representeres med tupler (student_id: 101, fornavn: "Mickey", program: "CS").
- Mer oversiktlig å presentere som navn-og-verdi-par (key-value på engelsk) enn som tupler med bare verdier (101, "Mickey", "CS"), hvor man må referere til elementene i tuppelen med posisjon, f. eks. posisjon 1: 101, posisjon 2: "Mickey", posisjon 3: "CS".
- En tuppel kalles instans og mengden av tupler kalles for relasjonsinstans (noen ganger refereres det til likhet med klasse og instans i den objekt-orienterte modellen).
- En tuppel skal inneholdet kun atomære verdier og av samme type (gjelder relasjonsmodellen, dvs. det som brukes i relasjonsdatabaser, som er en spesifikk type av databaser og som vi fokuserer på mest i dette emne).
- "atomært" er vagt, det avhenger av kontekst, men man kan si at verdien må kunne brukes som en enhet uten at den må "pakkes ut" (f. eks. ett telefonnummer +4794939493 og ikke en liste med telefonnumre [+4794939493, +4723449434], som man kunne modellert som (navn: text, telefonnummer: liste?); liste er ikke atomær).
- NULL: markerer manglende eller ukjent verdi (ofte vises som blanke celler i presentasjoner i grensesnitt programer og regnark). 
- Kan bruke NULL på alle typer (int, float, varchar, osv.).
- Rekkefølgen av rader er ikke en egenskap av en relasjon/tabell (det er en uordnet mengde). 
- Vanligvis vises relasjoner som tabeller, men husk at rekkefølgen på radene har ikke noe å si.
- Eksempel med modellen som er blitt brukt tidligere i emne: 
	- hvilke feil inneholder denne relasjonen? 
```
	{{student_id: int, navn: text, program: , : text, pin_kode: int},
	{{101, "Mickey", "CS", "mickey@oslomet", 2323},
	 {102, "Daffy", "EE", "daffy@oslomet", "ukjent"},
	 {"103", "Donald", "PSY", "donald@oslomet", NULL}
	}}
```

- Eksempel på modellering:
	- husk slide #15 i "Gjennomgang av OS1-1: Fra Filer til Databaser" (presentasjon fra etterlesingen), hvor vi argumenterte for å splitte opp relasjon i flere relasjoner for å unngå at data må lagres og oppdateres flere steder, dvs. vi endrer navn på et emne, så må vi oppdatere flere rader/tupler i en tabell/relasjon og for å kunne garantere integritet av data, dvs. at alle logiske sammenhenger i data blir opprettholdt etter oppdateringer/slettinger/nyinnsettinger
	- vi bruker modellen fra OS1.1: studenter, emner, paameldinger 
	- i OS1-3 bruker vi en litt annerledes navn på tabellene og bruker flere attributter i hver tabell, men prinsippet å splitte opp i flere tabeller blir det samme
	- vi kaller denne "splitte opp"-prosessen for normalisering
	- modellen fra OS1-3 har fire relasjoner, - studenter, emner, emneregistreringer og programmer
	- relasjonssignaturer i relasjonsmodellen er (her bør også referanser mellom tabellene inkluderes, noe vi skal se på straks):
		- **{studenter: {student_id: int, fornavn: varchar, etternavn: varchar, epost: varchar, program_id: int, opprettet: timestamp}}**
		- **{emner: {emne_id : int, emne_kode: varchar, emne_navn: text, studiepoeng: int, beskrivelse: text, opprettet: timestamp}}**
		- **{emneregistreringer: {registrering_id: int, student_id: int, emne_id: int, semester: text, karakter: varchar, registrert_dato: timestamp}}** (her kunne vi også valgt en sammensatt identifikator/primærnøkkel istedenfor å lage egen identifikator, for å unikt identifisere hver tuppel i relasjonen; ser mer på det straks
		- **{programer: {program_id: int, program_navn: text, beskrivelse: text, opprettet: timestamp}}**

- En relasjon per entitet (tabell, relasjon og entitet er navn brukt på samme ting; kan være forvirrende; representerer entiteter som biler, studenter, personer, kunder, datamaskiner osv., dvs. mye av det som vi bruker substantiver i språket for å beskrive ting rundt oss). 
- En relasjon per forhold (en student for en karakter i et emne, en foreleser er anvarlig for et emne, en arbeidstaker jobber for en arbeidsgiver osv.).
- Aldri ønsker å repetere data (helst lagre informasjon kun ett sted).
- En database skal beskrive ting og deres forhold.
- Hvis vi bruker fornavn som identifikasjon av en student er det en stor sannsynlighet at det ikke blir unikt (mange personer har samme navn).
- Vi trenger noe som kan identifisere en student eller et emne unikt (emner - emne_kode, student - student_id eller studentnummer, ...)
- For emneregistrering kunne flere attributter sammen gi en unik kombinasjon og entydig identifisere tuppelen/raden, for eksempel (student_id + emne_id + semester), siden en student kan registrere seg på det samme emne (bestemt av emne_id) i forskjellige semestre. 
- emne_kode kan være en kombinasjon av fagkode og emnenummer.
- {student_id, emne_id, semester} kan identifisere en emneregistrering (fordi at en student kan registrerer seg på det samme emne flere ganger på forskjellige tidspunkt, som her er modellert med semester)
- {emne_kode, fagkode} kan identifisere et emne, f.eks. {1500 + DATA}, {1700 + DAPE}
- {mobil_nr} identifiserer en person
- Slike identifikatorer kalles supernøkkel og den kan brukes for å unikt identifisere en rad/ting. 
- Alle utvidelser av en supernøkkel er også en supernøkkel (mengden av alle attributter vil alltid være supernøkkel).
- Selv om en relasjon endrer seg, skal en nøkkel fortsett identifisere raden/relasjonen unikt. 
- fornavn, etternavn er ikke gode kandidate for supernøkkel (det er ikke adresse heller, siden to personer med samme navn og etternavn kan i prinsippet ha samme adresse).
- epost kan designes slikt at det er unikt innenfor en kontekst (universiteter har forskjellige design av dette, blant annet hvor epost er en kombinasjon av et "lokalt designet" brukernavn og et domene, f.eks. jagai7334 er mitt brukernavn og domenet for epost er oslomet.no -> jaga7334 at oslomet dot no).
- Ikke supernøkkel: {fornavn, etternavn}, {fornavn, etternavn, adresse} (vi har ikke tatt med adresse i vår eksempel-modell)
- Supernøkkel blir vanligvis "lokalt designet", for eksempel brukernavn eller studentnummer ved Oslomet (lokalt); finn ut hvilket design har Oslomet for brukernavn og epostadresser!
- Vi kunne delt opp emne_kode i fag_kode og emne_nummer, men i eksempel-modellen er {emne_kode} "lokalt designet" for å være unik (det skal ikke være to like emnekoder ved Oslomet, men det kan være to like emne_koder ved to forskjellige universiteter; refleksjon: hvis vi ønsket unikhet for alle universiteter i verden, så bær vi velge en supernøkkel som inkluderer en identifikator universitet og legge sammen med emne_kode, eventuelt også bruke en identifikator for land, siden det kan i prinsippet være to universiteter med samme navn i to forskjellige land).  
- {emne_navn} kan være unikt, hvis den er "lokalt designet" til å være det, dvs. at systemet ikke tillater en administrativ bruker å sette inn to emner med like titler
- {emne_kode} er en god kandidat til supernøkkel og blir kalt en "vandrende nøkkel", som kan beskrives som en nøkkel som gir mening til brukere av databasen; det kan være en fordel å spørre "selekter fornavn og etternavn på alle studenter som har en karakter i emne DATA1500" enn "selekter student_id på alle studenter som har en karakter i emne emne_id"
- Hvorfor har vi da valgt en attributt emne_id? 
- Det er et designvalg som har både fordeler og ulemper
- Fordeler:
    - meningsfulle navn på identifikatorer 
    - enklere å designe spørringer (naturlige joins)
    - redusert kompleksitet (færre kunstige ID-er å håndtere)
    - potensielt bedre ytelse for spørringer (direkte søk på nøkler)
    - alt dette tilsammen kan gi en selvdokumenterende database
- ulemper (utfordringer og begrensninger):
    - nøkkelstabilitet (naturlige nøkler kan endres, for eksempel emne_kode, og da kreves det "cascade" oppdateringer)
    - nøkkellengde (sammensatte nøkler kan bli lange, f. eks. student_id + emne_id + semester og det kan påvirke ytelse for indekser)
    - referanseintegritet (mer utfordrende å håndtere endringer, krever nøye planlegging av begrensninger/constraints)
    - migrering (overføring av data fra et sted til et annen, f. eks. i tilfelle backup eller oppdatering av applikasjoner) kan være komplekst
- Kunstige (ikke vandrede) ID-er er generelt det tryggeste valget.
- Finn alle supernøkler for **{emneregistreringer: {registrering_id: int, student_id: int, emne_id: int, semester: text, karakter: varchar, registrert_dato: timestamp}}** 
    - (1) alle attributter er en supernøkkel
    - (2) kunstig ID registrering_id er en supernøkkel, som et bevisst valg
    - (3) registrering_id sammen med alle kombinasjoner av andre attributter er supernøkler
    - (4) hvis vi ikke velger en kunstig ID, så kan student_id+emne_id+semester være en vandrende supernøkkel og illustrerer problemet med bygging av indeks, hvor man må sjekke alle kombinasjoner av de tre attributtene (semester er en type timestamp, dvs. man kunne også brukt timestamp for når en karakter blir registrert istedenfor semester, som blir en kandidat til videre normalisering og lokalt spesialdesign, som Vår2024, Høst2023 forutsatt at man opererer med to semestre osv.; dette er typiske valg som en databasemodelldesigner må ofte gjøre)
- Ofte bruker man kandidatnøkler istedenfor supernøkler, som kan ha en del unødvendige attributter
- Kandidatnøkkel er en supernøkkel hvor man ikke kan fjerne noen attributter og nøkkel blir fortsatt en supernøkkel.
- Kandidatnøkklene for emneregistreringer er registrering_id og den vandrende nøkkelen student_id+emne_id+semester (hvis vi velger registrering_id, så må vi bruke en begrensning i tabellen, såkalt UNIQUE CONSTRAINT for å beholde integriteten i data i forhold til kravet om at en student kan registrere seg på et emne flere ganger, men ikke på samme tid / samme semester)
- En primærnøkkel er "den best egnede" kandidatnøkkel basert på lengde og andre betraktninger (hvor ofte attributter involvert i kandidatnøkkel kan potensielt bli endret?).
- Alle ting som representeres i en database får en primærnøkkel, dvs. en unik og entydig måte å skille hver tuppel i relasjonen fra hverandre eller unikt identifisere hver tuppel). 
- Primærnøkkelen brukes for å danne en referanse til en anne relasjon/tabell, for eksempel en "finn alle emneregistreringer for student med student_id"; da bruker vi student_id til den relevante tuppelen i tabellen/entiteten/relasjonen studenter og søker etter denne student_id i tabellen/entiteten/relasjonen emneregistreringer
- Fra eksemplet over, så er student_id i emneregistreringer en *fremmednøkkel*, dvs. den refererer til relasjonen studenter (dette er alltid sant i vår modell)
- Formell notasjon for referase: emneregistreringer(student_id) -> studenter(student_id) (noter: fordel å ha det samme navn på attributtene/kolonner i begge tabellene/entitetene/relasjonene for å kunne bruke natural join)
- Formell notasjon med nøkkler: **{emneregistreringer: {registrering_id (PK): int, student_id (FK): int, emne_id (FK): int, semester: text, karakter: varchar, registrert_dato: timestamp}}**
- Det brukes ofte understreking en strek for kandidatnøkler og en dobbelstrek for primærnøkkel, men det er vanskelig å vise i en tekstbasert presentasjon, samt at det kan være vanskelig å tolke, så vi bruker forkortelsene PK for primærnøkkel og FK for fremmednøkkel; sammensatte nøkler kan vi skrive ut eksplisitt, f.eks. 
    - PK: (student_id, emne_id, semester) eventuelt (student_id, emne_id, oppdatert)
    - eventuelt det samme for FK og Kandidatnøkler
- holde styr på identitet og referanser

- relasjonsalgebra spesial:
- husk at relasjoner består av tuppler, attributter og nøkkler
- nå må vi se hvordan vi kan bruke dataene i tabeller/relasjoner/eniteter med ved hjelp av diverse operasjoner på vår relasjonsmodell
- vi må kunne
    - hente ut spesifikke data basert på en eller flere relasjoner ("selekter fornavn og etternavn på alle studenter som har minst én emneregistrering"; henter data fra to relasjoner)
    - kombinere og transformere relasjoner til nye relasjoner
- relasjonsalgebra er et matematisk språk for å bruke data som relasjoner beskriver
- relasjonsalgebra danner fundamentet for SQL
- En operasjon er en handling eller prosess som utføres på én eller flere elementer for å danne et nytt element.
- En operator er et symbol eller tegn, som representerer en spesifikk operasjon. 
- Algebra betyr at man definerer og klassifiserer operasjoner / funksjoner på generelle mengder; i hverdagen klassifiserer vi hele tiden; en mengde mennesker, som har spesifikke karakteristikker eller tilhører spesifikke institusjoner, f. eks. mengden av alle studentene på Oslomet, mengden av alle norske statsborgere; mengden av alle bilmerker; mengdene av alle flyavganger; mengden av pulsmålinger over en tidsperiode ... 
- Man kan definere generelle operasjoner på disse mengdene, uansett hvilke konkrete områder de tilhører (en liste med elementer, som har et visst antall attributter/egenskaper, hvor attributter kan selv være elementer, som igjen har sine egne attributter/egenskaper osv.; dette er en generell måte mennesker takler en kompleks verden på, klassifiserer ting i mengder, gir mengder spesifikke egenskaper, legger sammen mengder basert på egenskaper osv. og alt er kode-basert, dvs. basert på språk som vi lærer gjennom barndommen)
- Vanligvis behandler man en (eller flere) mengde(-r) med en operasjon, og får et resultat av samme type elementer, for eksempel, når man anvender operasjon for summering (representet med operator +) på to tall fra mengde #1, får man et resultat av samme type, dvs. fra mengde #1 (2 + 3 = 5), hvor mengde #1 er, f.eks. tall {... ,-2,-1,0,1,2, ...}
- Eventuelt kan man også definere andre mengder som f.eks. {1}, {3,4}, {4,5}, {1,2,3}, og bruke operasjoner (operatorer) ∪ (union 222A), ∩ (intersection 2229), ∖ (set minus 2216, dvs. A ∖ B er alle elementene i A, som ikke er i B, f.eks. {3,4} ∖ {4,5} = {3}), osv.

```
Eksempel: ( {1} ∪ ( {3,4} ∖ {4,5} ) ) ∩ {1,2,3} ? 
    - svar: ( {1} ∪ ( {3,4} ∖ {4,5} ) ) ∩ {1,2,3} = ( {1} ∪ {3} ) ∩ {1,2,3} = {1,3} ∩ {1,2,3} = {1,3}
```

- I relasjonsalgebra er mengder relasjoner og resulatet etter anvendelse av oparasjoner er også relasjoner
- En operasjon i relasjonsalgebra tar en eller flere relasjoner (tabeller/entiteter) som argument, og returnerer en ny relasjon
- Med en slik algebra kan vi hente ut og kombinere data fra relasjoner
- Operasjoner klassifiseres (ja, vi kan også klassifisere operasjoner i egne mengder, for å kunne oppnå en bedre oversikt når vi resonnerer abstrakt, dvs. på elementer og mengder generelt og ikke på studenter, biler, Mickey og Audi, f.eks.) i unære og binære, - unær tar en relasjon og returenerer en ny relasjon, binær tar to relasjoner og returnerer en ny relasjon

- PROJEKSJON 𝜋 
- 𝜋_fornavn,etternavn(studenter) 
- 𝜋 tar ett argument `studenter` (er unær) og tar attributter som subskript (her viser jeg det med `_` siden jeg skriver i ren tekst)
- i vårt eksempel er studenter følgende relasjon: **{studenter: {student_id: int, fornavn: varchar, etternavn: varchar, epost: varchar, program_id: int, opprettet: timestamp}}**
- med følgende eksempel-tupler (@ er byttet ut med _ for å unngå automatisk konvertering til lenker):
    - (1, 'Ola', 'Nordmann', 'ola.nordmann_student.oslomet.no', 1, '2026-01-20 19:42:24.242378')
    - (2, 'Kari', 'Normann', 'kari.normann_student.oslomet.no', 1, '2026-01-20 19:42:24.242378')
- 𝜋 projiserer ned på (velger ut / velger bort) de attributtene til relasjonene `studenter`, som er listet i subskript (`_fornavn,etternavn`) 
- resultatet blir en ny relasjon som inneholder kun dataene om fornavn og etternavn
    - ('Ola', 'Nordmann')
    - ('Kari', 'Normann')
- 𝜋_fornavn,etternavn(studenter) = (('Ola', 'Nordmann'), ('Kari', 'Normann'))
- den nye relasjonen har intet navn, men det er mulig å gi det ett navn
- da kan den "matematiske" setningen skrives slikt
    - student_navn ≔ 𝜋_fornavn,etternavn(studenter)
- data1500_db=# select fornavn, etternavn from studenter as student_navn;
```
 fornavn | etternavn 
---------+-----------
 Ola     | Nordmann
 Kari    | Normann
 ```
 - akkurat her gir det ikke mye mening, siden en slik operasjon lagrer ikke det nye navnet utover avgrensningen til operasjonen
 - du kan sjekke at dette navnet blir faktisk lagret med følgende eksempel:
    - data1500_db=# select student_navn.fornavn from (select fornavn, etternavn from studenter) as student_navn;
- du kan fritt velge aliaser i dine spørringer og setninger:
    - data1500_db=# select student_navn.f from (select fornavn f, etternavn e from studenter) as student_navn;
```
  f   
------
 Ola
 Kari
 ```

 - SELEKSJON 𝜎 
 - 𝜎_(fornavn begynner med 'O') ∧ program_id = 1(studenter)
 - 𝜎 tar ett argument (unær operasjon) `studenter` og tar ett uttrykk som subskript (ikke attributtnavn som for projeksjon), hvor attributtnavn brukes som variable
   - i uttrykk brukes symboler ∨, ∧, ¬, `>`, `<`, ≤, ≥, =
   - i uttrykk brukes konstanter 3423, 10, IN osv.
 - hvis vi ser på relasjon `studenter` fra forrige eksemplet, så blir det en seleksjon av alle studentene hvis fornavn begynner med 'O' (Ola, f.eks.) og som tilhører program med program_id 1 
     - resulatet blir en ny relasjon som inneholder dataene for alle attributter som har fornavn som begynner med 'O' og hvor program_id er 1
     - (1, 'Ola', 'Nordmann', 'ola.nordmann at student.oslomet.no', 1, '2026-01-20 19:42:24.242378')
 - `begynner med 'O'` i Postgresql-syntaks blir `like 'O%'`, ∧ blir and
     - hvor % representerer null eller flere tegn, dvs. at det kan være hvilke som helst tegn (eller ingen tegn) etter den spesifiserte bokstaven.
 ```
 data1500_db=# select * from studenter where fornavn like 'O%' and program_id = 1;
 student_id | fornavn | etternavn |              epost              | program_id |         opprettet          
------------+---------+-----------+---------------------------------+------------+----------------------------
          1 | Ola     | Nordmann  | ola.nordmann_student.oslomet.no |          1 | 2026-01-20 19:42:24.242378
```
- @ er erstattet med _ for å unngå automatisk lenke på epostadresse
- seleksjonsoperatoren 𝜎 velger ut radene som matsjer betingelsene i uttrykket, mens projeksjon velger ut de attributtene som er spesifisert i attributtliste som subskript til projeksjonsoperatoren 𝜋

- OMDØPING 𝜌
- 𝜌_fornavn→navn, program_id→studie(studenter)
- attributt-pil-attributt konstruksjon som subskript
- fornavn skal omdøpes til navn, program_id skal omdøpes til studie
```
data1500_db=# select student_id, fornavn navn, etternavn, epost, program_id studie, opprettet from studenter;
 student_id | navn | etternavn |              epost               | studie |         opprettet          
------------+------+-----------+----------------------------------+--------+----------------------------
          1 | Ola  | Nordmann  | ola.nordmann_student.oslomet.no  |      1 | 2026-01-20 19:42:24.242378
          2 | Kari | Normann   | kari.normann_student.oslomet.no  |      1 | 2026-01-20 19:42:24.242378
```

- vi kan også kombinerer disse unære operasjonene for å oppnå et resultat-relasjon, f.eks. hvis vi ønsker å finne fornavn og etternavn til studenter som går på program med program_id 1 og hvis fornavn begynner med 'O', samt vise i signaturen til relasjonen navn istedenfor fornavn, kan vi først begynne med seleksjonen, så utføre projeksjon og til slutt omdøping:
    - 𝜎_(fornavn begynner med 'O') ∧ program_id = 1(studenter)
    - 𝜋_fornavn,etternavn(𝜎_(fornavn begynner med 'O') ∧ program_id = 1(**studenter**))
    - 𝜌_fornavn→navn(𝜋_fornavn,etternavn(𝜎_(fornavn begynner med 'O') ∧ program_id = 1(**studenter**))) som gir svar på vårt spørsmål i en ny relasjon
```
 navn | etternavn | 
------+-----------+
    1 | Ola       | 
```

- KARTESISK PRODUKT ×
- tar to argumenter (f.eks. A og B) men skrives "infix", dvs. mellom de to argumentene A × B 
- resultat-relasjon består av alle attributtene til begge relasjonene og alle kombinasjonene av tupler fra begge relasjonene
- eksempel med studenter × programmer 
- dette er innholdet i relasjonen studenter (4 tupler)
data1500_db=# select * from studenter;
 student_id | fornavn | etternavn |              epost               | program_id |         opprettet          
------------+---------+-----------+----------------------------------+------------+----------------------------
          1 | Ola     | Nordmann  | ola.nordmann_student.oslomet.no  |          1 | 2026-01-20 19:42:24.242378
          2 | Kari    | Normann   | kari.normann_student.oslomet.no  |          1 | 2026-01-20 19:42:24.242378
          3 | Per     | Larsen    | per.larsen_student.oslomet.no    |          2 | 2026-01-20 19:42:24.242378
          4 | Anna    | Johansen  | anna.johansen_student.oslomet.no |          3 | 2026-01-20 19:42:24.242378
- dette er innholdet i relasjonen programmer (3 tupler)
data1500_db=# select * from programmer;
 program_id |  program_navn  |        beskrivelse        |         opprettet          
------------+----------------+---------------------------+----------------------------
          1 | Informatikk    | Bachelor i Informatikk    | 2026-01-20 19:42:24.241526
          2 | Data Science   | Bachelor i Data Science   | 2026-01-20 19:42:24.241526
          3 | Cybersikkerhet | Bachelor i Cybersikkerhet | 2026-01-20 19:42:24.241526
- dette er kartesisk produkt av begge relasjonene (3 x 4 = 12 tupler)
- data1500_db=# select * from studenter, programmer;
 student_id | fornavn | etternavn |              epost               | program_id |  opprettet    | program_id |  program_navn  |        beskrivelse        |  opprettet    
------------+---------+-----------+----------------------------------+------------+---------------+------------+----------------+---------------------------+---------------
          1 | Ola     | Nordmann  | ola.nordmann_student.oslomet.no  |          1 | 2026-01-20... |          1 | Informatikk    | Bachelor i Informatikk    | 2026-01-20 ...
          2 | Kari    | Normann   | kari.normann_student.oslomet.no  |          1 | 2026-01-20... |          1 | Informatikk    | Bachelor i Informatikk    | 2026-01-20 ...
          3 | Per     | Larsen    | per.larsen_student.oslomet.no    |          2 | 2026-01-20... |          1 | Informatikk    | Bachelor i Informatikk    | 2026-01-20 ...
          4 | Anna    | Johansen  | anna.johansen_student.oslomet.no |          3 | 2026-01-20... |          1 | Informatikk    | Bachelor i Informatikk    | 2026-01-20 ...
          1 | Ola     | Nordmann  | ola.nordmann_student.oslomet.no  |          1 | 2026-01-20... |          2 | Data Science   | Bachelor i Data Science   | 2026-01-20 ...
          2 | Kari    | Normann   | kari.normann_student.oslomet.no  |          1 | 2026-01-20... |          2 | Data Science   | Bachelor i Data Science   | 2026-01-20 ...
          3 | Per     | Larsen    | per.larsen_student.oslomet.no    |          2 | 2026-01-20... |          2 | Data Science   | Bachelor i Data Science   | 2026-01-20 ...
          4 | Anna    | Johansen  | anna.johansen_student.oslomet.no |          3 | 2026-01-20... |          2 | Data Science   | Bachelor i Data Science   | 2026-01-20 ...
          1 | Ola     | Nordmann  | ola.nordmann_student.oslomet.no  |          1 | 2026-01-20... |          3 | Cybersikkerhet | Bachelor i Cybersikkerhet | 2026-01-20 ...
          2 | Kari    | Normann   | kari.normann_student.oslomet.no  |          1 | 2026-01-20... |          3 | Cybersikkerhet | Bachelor i Cybersikkerhet | 2026-01-20 ...
          3 | Per     | Larsen    | per.larsen_student.oslomet.no    |          2 | 2026-01-20... |          3 | Cybersikkerhet | Bachelor i Cybersikkerhet | 2026-01-20 ...
          4 | Anna    | Johansen  | anna.johansen_student.oslomet.no |          3 | 2026-01-20... |          3 | Cybersikkerhet | Bachelor i Cybersikkerhet | 2026-01-20 ...
(12 rows)
- må være forsiktig med kartesisk produkt med store (mye data) relasjoner og vi har skjeldent behov for kartesisk produkt, siden kun slavisk kombinerer alle tupler i to relasjoner og det har sjeldent en mening for spørsmål som stilles til vår datamodell
- det er derfor vanlig å bruke en seleksjon på kartesisk produkt, f.eks. selekter alle tupler/rader, som viser hvilket program studenten går på 
- avhengig av hvordan vi har implementert den faktiske databasen (med CREATE kommandoen), så har vi vanligvis like navn på tabeller som er koblet sammen ved hjelp av en fremmednøkkel
- en seleksjon som dette vil ikke være korrekt, siden det blir tvetydig uttrykk i subskript 𝜎_(program_id = program_id)(studenter × programmer)
- hvis vi har like navn på attributter i de relasjonene som kartesisk produkt bruker, kan vi døpe om navn i en av relasjonene før vi utfører seleksjonen
- f.eks. 𝜌_program_id→program(studenter)
- 𝜎_(program = program_id)(𝜌_program_id→program(studenter) × programmer)
- i postgresql: 
	- data1500_db=# select * from (select student_id, fornavn, etternavn, epost, program_id program, opprettet from studenter) as omdopt_studenter, programmer where program = program_id;
	- dette blir noe "klønete", så det finnes snarveier i syntaksen for de fleste dbhs-er, som dere vil finne ut etterhvert
 student_id | fornavn | etternavn |              epost               | program_id |  opprettet    | program_id |  program_navn  |        beskrivelse        |  opprettet    
------------+---------+-----------+----------------------------------+------------+---------------+------------+----------------+---------------------------+---------------
          1 | Ola     | Nordmann  | ola.nordmann_student.oslomet.no  |          1 | 2026-01-20... |          1 | Informatikk    | Bachelor i Informatikk    | 2026-01-20 ...
          2 | Kari    | Normann   | kari.normann_student.oslomet.no  |          1 | 2026-01-20... |          1 | Informatikk    | Bachelor i Informatikk    | 2026-01-20 ...
          4 | Anna    | Johansen  | anna.johansen_student.oslomet.no |          3 | 2026-01-20... |          3 | Cybersikkerhet | Bachelor i Cybersikkerhet | 2026-01-20 ...
          3 | Per     | Larsen    | per.larsen_student.oslomet.no    |          2 | 2026-01-20... |          2 | Data Science   | Bachelor i Data Science   | 2026-01-20 ...
- her ser vi en relasjon som besvarer vårt spørsmål, dvs. vi kombinerer dataene fra flere relasjoner
- gjør selv en projekson 𝜋_fornavn,etternavn,program_navn,beskrivelse på seleksjon anvendt på kartesisk produkt
- 𝜋_fornavn,etternavn,program_navn,beskrivelse(𝜎_(program = program_id)(𝜌_program_id→program(studenter) × programmer))
- data1500_db=# select fornavn, etternavn, program_navn, beskrivelse from (select student_id, fornavn, etternavn, epost, program_id program, opprettet from studenter) as omdopt_studenter, programmer where program = program_id;
 fornavn | etternavn |  program_navn  |        beskrivelse        
---------+-----------+----------------+---------------------------
 Kari    | Normann   | Informatikk    | Bachelor i Informatikk
 Ola     | Nordmann  | Informatikk    | Bachelor i Informatikk
 Per     | Larsen    | Data Science   | Bachelor i Data Science
 Anna    | Johansen  | Cybersikkerhet | Bachelor i Cybersikkerhet
(4 rows)
- trenger `as omdopt_studenter`, dvs. trenger å spesifisere en alias i postgresql for å få utført spørringen over
- observer at relasjon `studenter` refererer til relasjon `programmer` , - det vi kalte for fremmednøkkel (FK)
- **{programer: {program_id (PK): int, program_navn: text, beskrivelse: text, opprettet: timestamp}}**
- **{studenter: {student_id (PK): int, fornavn: varchar, etternavn: varchar, epost: varchar, program_id (FK): int, opprettet: timestamp}}**
- en kartesisk produkt sammen med en seleksjon som bruker fremmednøkkel er så vanlig/viktig i spørringer mot data at den har fått et eget navn "join" og det betegnes med symbol ⋈

- JOIN ⋈
- 𝜌_program_id→program(studenter) `⋈_program = program_id` programmer
- den forrige blir da ekvivalent med 𝜎_(program = program_id)(𝜌_program_id→program(studenter) × programmer)
- på samme måten kan man gjøre projeksjon på setningen med "join"-syntaksen:
	- 𝜋_fornavn,etternavn,program_navn,beskrivelse(𝜌_program_id→program(studenter) `⋈_program = program_id` programmer)
- i postgresql:
    - data1500_db=# select fornavn, etternavn, program_navn, beskrivelse from (select student_id, fornavn, etternavn, epost, program_id program, opprettet from studenter) as omdopt_studenter join programmer on program = program_id;
- oppgave: skriv relasjonsalgebrauttrykk for følgende spørsmål mot modellen "list ut emnenavn med tilsvarende karakter" 


- UNION ∪, SNITT ∩ og DIFFERANSE ∖ kan kun brukes på relasjoner som har nøyaktig de samme attributtene, for eksempel: 
    - **{studenter: {person_id (PK): int, fornavn: varchar, etternavn: varchar, epost: varchar, telefon: varchar}}**
    - **{laeringsassistenter: {person_id (PK): int, fornavn: varchar, etternavn: varchar, epost: varchar, telefon: varchar}}**
    - studenter ∪ laeringsassistenter - alle personer i begge tabellene uten duplikater, dvs. både learingsassistene og studentene
    	- select * from studenter union select * from laeringsassistenter;
    - studenter ∩ laeringsassistenter - finner de studentene som også er laeringsassistenter
    	- select * from studenter intersect select * from laeringsassistenter;
    - studenter ∖ laeringsassistenter - alle studenter som ikke er læringsassistenter (læringsassistentene blir trukket ut)
    	- select * from studenter except select * from laeringsassistenter;
- brukes ikke ofte, siden vi sjeldent har to relasjoner med helt like attributter

- her er sql setnignene for å prøve ut union, intersect og except i postgresql (lager en test_database først)
data1500_db=# \l
data1500_db=# CREATE DATABASE test_database WITH TEMPLATE template0;
ata1500_db=# \l
data1500_db=# \c test_database
test_database=# \dt eller \d
test_database=# create table studenter (person_id serial primary key, fornavn varchar(50) not null, etternavn varchar(50) not null, epost varchar(50) not null unique, telefon varchar(20) not null unique);
CREATE TABLE
test_database=# create table laeringsassistenter (person_id serial primary key, fornavn varchar(50) not null, etternavn varchar(50) not null, epost varchar(50) not null unique, telefon varchar(20) not null unique);
CREATE TABLE

test_database=# INSERT INTO studenter (fornavn, etternavn, epost, telefon) VALUES
    ('Ola', 'Nordmann', 'ola.nordmann_student.oslomet.no', '+4766445544'),
    ('Kari', 'Normann', 'kari.normann_student.oslomet.no', '+4766443544'),
    ('Per', 'Larsen', 'per.larsen_student.oslomet.no', '+4766443543'), 
    ('Anna', 'Johansen', 'anna.johansen_student.oslomet.no', '+4766443540')
ON CONFLICT DO NOTHING;
test_database=# INSERT INTO laeringsassistenter (fornavn, etternavn, epost, telefon) VALUES
    ('Ola', 'Nordmann', 'ola.nordmann_student.oslomet.no', '+4766445544'),
    ('Mari', 'Svendsen', 'mari.svendsen_student.oslomet.no', '+4766443000'),
    ('Per', 'Larsen', 'per.larsen_student.oslomet.no', '+4766443543'), 
    ('Hannah', 'Johansoo', 'hannah.johansoo_student.oslomet.no', '+4766202540')
ON CONFLICT DO NOTHING;

- oppgave "finn navn på alle studenten som kun har fått A"
- svar med postgresql syntaks: 
	- mellomledd (finner student_id for alle som kun har fått A) select student_id from emneregistreringer where karakter = 'A' except select student_id from emneregistreringer where karakter != 'A';
	- select fornavn, etternavn from (select student_id from emneregistreringer where karakter = 'A' except select student_id from emneregistreringer where karakter != 'A') as studenter_med_kun_a join (select student_id s_id, fornavn, etternavn from studenter) as omdopt_studenter on student_id = s_id;
- svar med relasjonsalgebra:
    - 𝜋_student_id(𝜎_(karakter='A')(emneregistreringer))
 student_id  
------------+
          1 
          3 
    - 𝜋_student_id(𝜎_(karakter≠'A')(emneregistreringer))
 student_id |  
------------+
          1 
          2 
          4 
	- 𝜋_student_id(𝜎_(karakter='A')(emneregistreringer)) ∖ 𝜋_student_id(𝜎_(karakter≠'A')(emneregistreringer)) 
	student_id  
------------+ 
          3 
	- 𝜋_student_id(𝜎_(karakter='A')(emneregistreringer)) ∖ 𝜋_student_id(𝜎_(karakter≠'A')(emneregistreringer)) `⋈_student_id = s_id` 𝜌_student_id→s_id(studenter))
	 fornavn | etternavn 
---------+-----------
 Per     | Larsen


- oppgave fra OS1-3-2 **Hent studentene med høyeste karakter per emne**
- svar med postgresql syntaks:
```sql
data1500_db=# select * from studenter;
 student_id | fornavn | etternavn |              epost               | program_id |         opprettet          
------------+---------+-----------+----------------------------------+------------+----------------------------
          1 | Ola     | Nordmann  | ola.nordmann_student.oslomet.no  |          1 | 2026-01-20 19:42:24.242378
          2 | Kari    | Normann   | kari.normann_student.oslomet.no  |          1 | 2026-01-20 19:42:24.242378
          3 | Per     | Larsen    | per.larsen_student.oslomet.no    |          2 | 2026-01-20 19:42:24.242378
          4 | Anna    | Johansen  | anna.johansen_student.oslomet.no |          3 | 2026-01-20 19:42:24.242378
data1500_db=# select * from emneregistreringer;
 registrering_id | student_id | emne_id | semester | karakter |      registrert_dato       
-----------------+------------+---------+----------+----------+----------------------------
               1 |          1 |       1 | 2024H    | A        | 2026-01-20 19:42:24.242995
               2 |          1 |       2 | 2024H    | B        | 2026-01-20 19:42:24.242995
               3 |          2 |       1 | 2024H    | B        | 2026-01-20 19:42:24.242995
               4 |          3 |       3 | 2024H    | A        | 2026-01-20 19:42:24.242995
               5 |          4 |       4 | 2024H    | C        | 2026-01-20 19:42:24.242995


data1500_db=# INSERT INTO emneregistreringer (student_id, emne_id, semester, karakter) VALUES
    (4, 4, '2025H', 'B')
ON CONFLICT DO NOTHING;
data1500_db=# select * from emneregistreringer;
 registrering_id | student_id | emne_id | semester | karakter |      registrert_dato       
-----------------+------------+---------+----------+----------+----------------------------
               1 |          1 |       1 | 2024H    | A        | 2026-01-20 19:42:24.242995
               2 |          1 |       2 | 2024H    | B        | 2026-01-20 19:42:24.242995
               3 |          2 |       1 | 2024H    | B        | 2026-01-20 19:42:24.242995
               4 |          3 |       3 | 2024H    | A        | 2026-01-20 19:42:24.242995
               5 |          4 |       4 | 2024H    | C        | 2026-01-20 19:42:24.242995
               6 |          4 |       4 | 2025H    | B        | 2026-01-27 20:56:13.548454

```
- vi kan tenke i flere steg:
    - vi må gruppere på emne_id, siden vi blir spurt om å hente karakter per emne
    - så vi må også gruppere på student_id siden vi blir spurt om å finne studentene med høyeste karakter
    - gruppering kan bare gjøres hvis vi bruker funksjoner i projeksjon 
    - siden det spørres om "høyeste" karakter, må vi finne en funksjon som kan rangere A høyest og F lavest
    - siden dette er alfabetisk, så gir funksjon min den bokstaven som er først i alfabetet og karakterer er i en alfabetisk rekkefølge (viktig å sørge for at det ikke er mulig å registrere andre bokstaver enn A-F, eller kan mange spørringer gi andre svar enn forventet; vi ser på constraints senere)
    - for hovedjobben kan følgende spørring testes:
```sql
data1500_db=# select student_id, emne_id, min(karakter) as beste from emneregistreringer group by emne_id, student_id;
``` 
    - så gjenstår det eventuelt å finne fornavn og etternavn til studentene og emne_navn for emne med join operasjon
    - group by (agreggering) og order by har ikke spesifikk operasjoner i relasjonsalgebra, men de kan uttrykkes med prosjeksjon (viser agreggeringsfunksjon) og seleksjon

- oppgave fra OS1-3-2 **Lag en rapport som viser hver student, deres program, og antall emner de er registrert på**
- oppgave fra OS1-3-2 **Hent alle studenter som er registrert på både DATA1500 og DATA1100**

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
```sql
Fil(er) som database: 
emner.csv
DATA1500,Intro to Databases
PROG1001,Programming 1
MATH2000,Calculus
PHYS1500,Physics

studenter.csv
101,Mickey,CS
102,Daffy,EE
103,Donald,CS
104,Minnie,PSY
105,Goofy,EE

paameldinger.csv
101,DATA1500
101,PROG1001
101,MATH2000
102,DATA1500
102,PHYS1500
103,DATA1500
103,PROG1001
104,MATH2000
105,PROG1001
105,PHYS1500

Postgresql database (utvidet fra "Fil som database"/OS1-3):
-- Opprett grunnleggende tabeller
CREATE TABLE IF NOT EXISTS programmer (
    program_id SERIAL PRIMARY KEY,
    program_navn VARCHAR(100) NOT NULL UNIQUE,
    beskrivelse TEXT,
    opprettet TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS emner (
    emne_id SERIAL PRIMARY KEY,
    emne_kode VARCHAR(20) NOT NULL UNIQUE,
    emne_navn VARCHAR(100) NOT NULL,
    studiepoeng INT NOT NULL CHECK (studiepoeng > 0),
    beskrivelse TEXT,
    opprettet TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS studenter (
    student_id SERIAL PRIMARY KEY,
    fornavn VARCHAR(50) NOT NULL,
    etternavn VARCHAR(50) NOT NULL,
    epost VARCHAR(100) NOT NULL UNIQUE,
    program_id INT REFERENCES programmer(program_id),
    opprettet TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS emneregistreringer (
    registrering_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES studenter(student_id),
    emne_id INT NOT NULL REFERENCES emner(emne_id),
    semester VARCHAR(10) NOT NULL,
    karakter VARCHAR(2),
    registrert_dato TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(student_id, emne_id, semester)
);
```

# Eksempler fra IN2090
- eksempel (endre eksemplet i forhold til den modellen som vi har brukt til nå) på en relasjon som inneholder 6 feil: {studenter: {student_id: text, : text, Nummer: text, By: , Gate: text, Nummer: int, Postnummer: int}, {{"ola at online dot no", "Ola Norman", "01028912345", "Oslo", "Gateveien", 2, "ukjent"}, {}, {}}}
	- 1: mangler navn på attributt med andre sekvensielle posisjonen fra venstre til høyre
	- 2-3: to attributter med samme navn "Nummer" (men forskjellige typer, men fortsatte feil)
	- 4: attributt By mangler type (kanskje mulig?)
	- 5: Postnummer har typen int og kan derfor ikke være "ukjent"
	- 6: i Nummer: int kolonne er det en tekst "første"
- to tabeller, som har både kolonner og rader i forskjellig rekkefølgen, kan være like, hvis innen sammen mengden av tupler, attributt-rekkefølgen er lik
- Eksempel:
	- For studenter: Brukernavn, navn, etternavn, adresse ... 
	- For emne: emnenavn (fagkode + emnekode), tittel, beskrivelse, studiepoeng ....
	- Mulig spørring: hvem har fått hvilken karakter i hva
	- Forslag med alt i en relasjon: Brnavn, Navn, Etternavn, Adresse, Emnekode, Emnenummer, Tittel, Beskrivelse, AntSP, Kara
	- Ulemper med en relasjon: duplisering av data, utfordrende å opprettholde integritet
	- Forslag: modellere med flere relasjoner, - studenter, emner, emneregistreringer, programmer


# Caser for K7
- [CASE1] En bygning er en identifisert ved en bygningsnummer. For hver bygning blir det registrert antall etasjer, areal og bygningstype (fritidsbygg, enebolig, garasjebygg osv.). Tegn ER-diagrammet. Anta så at bygningstyper blir ulikt avgiftsbelagt. Endre modeller slik at avgiftsbeløp for hver bygningstype blir lagret. 
- [CASE2] Et universitet tilbyr flere studier. Hvert studium er bygd opp fra emne. Hvert emne har en emnekode, en tittel, en beskrivelse og gir et antall studiepoeng. Noen kurs bygger på andre. Studenter blir tatt opp til studier, og får et unikt studentnummer. Om hver student blir navn, adresse og telefonnummer lagret. En student avlegger eksamen i et antall emner hvert semester, og får en karakter (A til F) i hvert emne. Studentene kan seinere forbedre karakteren i et kurs ved å gå opp til ny eksamen. Ved gjentatt eksamen i samme emne vil den beste karakteren gjelde, men samtlige eksamenskarakterer skal lagres. Om hver eksamensavvikling skal rom og tidspunkt lagres. 
- [CASE3] Betrakt en database for å representere enkle ER-diagrammer. Tenk at databasen skal brukes av et modelleringsverktøy for å lagre diagrammer som brukerne konstruerer (som et alternativ til lagring av filer). Krav: (1) Til et ER-diagram er det knyttet et entydig navn, en forfatter, dato diagrammet ble opprettet og dato når den sist ble endret. Et diagram inneholder entiteter og forhold. (2) Enhver entitet har et navn og et antall attributter. Hvert attributt har at navn og en datatype. Lovlige datatyper er INTEGER, FLOAT, CHAR og BOOLEAN. Attributter med datatypen CHAR har en spesifisert lengde (antall tegn). (3) En eller flere attributter utgjør identifikatoren til en entitet. (4) Et forhold knytter sammen to entiteter, som kalles fra-entiteten og til-entiteten. Ethvert forhold har et navn. I et forhold har både fra-entiteten og til-entiteten maksimums- og minimumsverdier. Lovlige minimumsverdier er 0 og 1, mens lovlige maksimumsversdier er 1 og MANGE. (5) Navn på entiteter og forhold er unike innen et diagram, og det finnes ikke to attributter med samme navn i en entitet. Systemet skal lagre data om mange diagrammer, og det er tillatt å bruke samme navn på entiteter og forhold i forskjellige diagrammer. (6) Det skal også lagres informasjon som har å gjøre med presentasjon av diagrammene. Det skal være mulig å velge fonter og farger for navn på entiteter og attributter. Brukeren kan styre plassering av entiteter på skjermen. Posisjon og størrelse entitetene skal lagrs. Lag en datamodell for systemet, det vil si et ER-diagram som beskriver ER! Merk at beskrivelsen over er en forenkling av ER. Blant annet så er svake entiteter, identifiserende forhold og subtyper utelatt. 
- [CASE4] Et idrettsforbund trenger å lage data om klubber og utøvere. Hver klubb har et navn og en lokasjon. En klubb drives av en styre som består av styreleder, kasserer, rosjef og materialsjef. Klubben har også enten ansatte eller frivillige trenere, Klubbmedlemmene (utøvere) kan deles inn i U13, U15, U17, U19, U23, senior, masters og mosjons klasser. Utøvere i alle klasser kan gjennomføre standardiserte tester tre ganger i sesongen (uke 44, 2 og 11). En sesong varer fra oktober til september. Idrettsforbund registrerer også flere typer tester for de beste utøvere fra klubbene. Eksempel på tester er standardiserte laktatmålinger og VO2max-målinger. Det skal også registreres målinger fra diverse sensorer fra enkelte treningsøkter. Om en treningsøkt registreres det dato, starttid, sluttid (kan være NULL hvis økten ikke blir gjennomført), beskrivelse, intensitet og filer med sensormålinger (kan være store mengder med data). 


https://mermaid.ai/open-source/syntax/entityRelationshipDiagram.html