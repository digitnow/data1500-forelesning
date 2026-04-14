# Transaksjoner (8-Apr-2026)

## Teori

- I en kontekst av databasehåndteringssystemer er en **transaksjon** er en mekanisme som beskriver logiske enheter i databaseprosessering.
- Transaksjonsprosesseringssystemer er mest relevant for systemer med store databaser og et stort antall av samtidige brukere.
- Eksempler er systemer for reservasjon av flybilletter, bankoperasjoner, kreditkortprosessering, elektronisk handel, aksjemarked, butikkjeder osv. 
- En **transaksjon** representerer en logisk enhet i databaseprosessering som må fullføres i sin helhet for å garantere korrekthet av data i databasen til envher tid. 
- En transaksjon er typisk implementert i et dataprogram som inkluderer databasekommandoer som innsetting, henting, sletting og oppdatering (CRUD).
- Problemer som oppstår når flere samtididige brukere har tilgang til det samme minneområdet er knyttet til samtidighetskontroll for å forsikre at flere uavhengige prosesser kan skrive til og lese fra det samme minneområdet og beholde en korrekt tilstand i dataene.  
- Det er også vanlig med problemer som oppstår når transaksjoner feiler og problemer som er relatert til gjenoppretting av data etter feil. 
- ACID-egenskaper er ønskelig å tilfredsstille i transaksjonsprosesseringssystemer. ACID - Atomicity, Concurrency, Isolation, Durability.
- En transaksjon skal være **atomisk**, dvs. enten alle deloppgavene skal fullføres eller ingen. 
- En transaksjon skal bevare **konsistens** i den forstand at hvis den blir utført fullstendig fra beginnelse til slutten (BEGIN til COMMIT), så skal den ta database fra en konsistent tilstand til en annen konsistent tilstand (f.eks. i tilfellet dobbelt bokholderi, skal balansen forbli 0 etter hver transaksjon).
- En transaksjon skal fremstå som utført uavhengig av (**isolert fra**) andre transaksjoner, selv om flere transaksjoner blir utført samtidig. Utførelsen av en transaksjon skal ikke bli påvirket av andre transaksjoner i et databasesystem, som utføres i samme tidsrom.
- Alle endringene i databasen, som blir gjort av en transaksjon, skal bli **værende** i databasen. Disse endringene må ikke gå tapt uansett feil. 
- Datamaskinarkitektur er vanligvis basert på **multiprogrammering**, dvs. at flere programmer kan utføres på en databehandlingsenhet "samtidig". 
- "Samtidighet" i datasystemer er ofte ikke reell, siden databehandlingsenheten vanligivs har kun en prosessor (i nyere tid opererer man med begrepet "core", som kan skape en viss pseudo-samtidighet). I en slik situasjon må programmer (les prosesser) konkurrere om ressursene (CPU, RAM o.a.). Hvis databehandlingsenheten har flere prosessorer, så kan prosesser utføres parallellt. I DBHS sammenhengen snakker vi kun om **konkurranse** mellom prosesser som deler på den samme ressursen og derfor ikke om **parallelitet**. Prosessene utføres vekslevis. Det er programmer som hører til operativsystemet, som sørger for det. I DBHS er det implementert et nytt lag av funksjoner (på toppen av operativsystemets funksjoner), som sørger for transaksjonsprosessering.
- En transaksjon inkluderer en eller flere databasetilgangsoperasjoner, - innsetting, sletting, modifikasjon eller henting. Disse operasjonene kan enten være innebygd i en applikasjon (skrevet i et programmeringsspråk) eller de kan være spesifisert interaktivt ved hjelp av et høyt-nivå spørringsspråk som SQL (med utvidelser, som f. eks. PL/pgSQL, som er en proseduralt språk for PostgreSQL databasehåndteringssystemet; https://www.postgresql.org/docs/current/plpgsql.html). 
- En applikasjon kan inneholde mer enn en transaksjon, hvis den inneholder transaksjonsgrenser (dvs. hvis en slik funksjonalitet er implementert).
- Hvis databaseoperasjoner i en transaksjon kun henter data og ikke oppdaterer data, kalles den for en `read-only` transaksjon. Ellers kalles den for en `read-write` transaksjon.
- Databasemodell som blir brukt for å presentere transaksjonsprosessering er enklere enn, f. eks. relasjonsmodellen. Database blir presentert som **en kolleksjon av navngitte dataelementer**. 
- Størrelsen til et dataelement blir kalt for dets **granularitet** (beskriver detaljnivå). Et dataelement kan være en databaserad, en blokk på disken eller kun en felt- (attributt-) verdi i en databaserad. Transaksjonsprosesseringskonsepter avhenger ikke av granulariteten til dataelementene.
- Hvert dataelement har et unikt navn, men det brukes vanligvis ikke av en programmerer (det er kun for å identifisere hvert dataelement unikt). For eksempel, for en diskblokk kan adressen til blokken brukes som navn til dette dataelementet.
- Hvis man bruker denne forenklede modellen, så kan databasetilgangsoperasjoner, som en transaksjon kan inneholde, være følgende:
  - `read_item(X)` leser et dataelement med navnet X i et programvariabel (for enkelhets skyld kan vi anta at variabelnavn er også X).
  - `write_item(X)` skriver en verdi av programvariabel X til et databaseelement med navnet X.

- I tilfelle overføring av data fra disk til hovedminne, kan et dataelement være en diskblokk (diskside). 
- Utførelsen av `read_item(X)` inneholder følgende steg:
  1. Finn adressen til diskblokken som inneholder dataelementet X. 
  2. Kopier denne diskblokken i en buffer i hovedminne (hvis den allerede ikke finnes i hovedminne; `cache` administrasjonsfunksjoner tar seg av dette).
  3. Kopier dataelementet X fra en buffer (hovedminne) til programvariabelen med navnet X.
- Utførelsen av `write_item(X)` inneholder følgende steg:
  1. Finn adressen til diskblokken som inneholder dataelementet X.
  2. Kopier denne diskblokken i en buffer i hovedminne (hvis den allerede ikke finnes i hovedminne; `cache` administrasjonsfunksjoner tar seg av dette).
  3. Kopier dataelementet X fra programvariabelen med navnet X i dets korrekte posisjonen i bufferen (hovedminne).
  4. Lagre den oppdaterte dataelementet fra en buffer i hovedminne tilbake til disk (enten umiddelbart eller på et senere tidspunkt). Det er dette steget hvor en database blir oppdatert på disken (i sekundært og varig minne).
- Avgjørelsen om når en buffer blir lagret på disken styres av gjenopprettingsadministrasjonsfunksjon i DBHS i samarbeid med operativsystemet. - DBHS holder et antall buffere i hovedminne for database-cache. Når alle buffere er fult opp, blir det brukt en algoritme for å erstatte buffere i hovedminne med nye dataelementer fra disk (f. eks. `least recently used`). 
- Flere problemer kan oppstå som konsekvens av **applikasjonslogikken**. Behovet for transaksjonsadministrasjon oppstår for spesifikke brukstilfeller, spesielt når det må gjennomføres flere operasjoner for å opprettholde integriteten / korektheten i data.
- Eksempel:
  - T1: en transaksjon som overfører N seter som er reservert på ett fly til seter på et annet fly:
```
read_item(X);
X := X - N;
write_item(X);
read_item(Y)
Y := Y + N;
write_item(Y);
``` 
  - T2: reserverer M seter på et det flyet som var betegnet med X i T1:
```
read_item(X);
X := X + M;
write_item(X);
```
- Det er flere problemer som kan oppstå hvis T1 og T2 overlapper (f. eks. **lost update**, **dirty read**, **ukorrekt summering/inconsistent read**, **nonrepeatable read**, **phantom read**).
- **lost update** problem:
  - Problemet oppstår når to transaksjoner som aksesserer de samme dataelementene i en database har operasjoner som overlapper på en måte som resulterer at verdier til noen databaseelementer er ukorrekte.
  - La oss anta at T1 og T2 blir utført i samme tidsperioden på følgende måte:
```
--- "lost update" ---
T1              T2
---------------|--------------
read_item(X);
X := X - N;
                read_item(X);
                X := X + M;
write_item(X);
read_item(Y);
                write_item(X);  <- her overskrives verdien X - N med X - M
Y := Y + N;                        og X - N går tapt ("lost update")
write_item(Y);
```

```
--- Konkret eksempel av "lost update" ---
-- X = 80 (reserverte seter på fly X)
-- Y = 90 (reserverte seter på fly Y)
-- N = 5 (skal overføres far fly X til fly Y)
-- M = 3 (seter som skal overfres til Y)
-- Korrekt svar: 80 - 5 + 3 = 78
T1              T2
---------------|--------------
read_item(X);                   <- T1: henter verdien 80 fra disk til buffer
X := X - N;                     <- T1: fra buffer til prog. var. 80 - 5 = 75
                read_item(X);   <- T2: henter verdien 80 fra disk til buffer
                X := X + M;     <- T2: fra buffer til prog. var. 80 + 3 = 83 
write_item(X);                  <- T1: verdien 75 lagres på disken
read_item(Y);                   <- T1: henter verdien 90 fra disk til buffer
                write_item(X);  <- T2: overskriver verdien 75 med verdien 83
Y := Y + N;                        og 75 går tapt ("lost update")
write_item(Y);                  <- T1: verdien 95 lagres på disken

Resultat: X = 83, Y = 95, men X skulle vært 78 (5 seter blir "ledig" på X)
```
- **dirty read** eller problemet med temporær oppdatering
  - Oppstår når en transaksjon oppdaterer et databaseelement og så feiler av en eller annen grunn, f. eks. fordi at
  	- maskinvare-, programvare-, nettverks-feil oppstår, 
  	- en beregningsfeil oppstår som deling med null eller "integer overflow", 
  	- det er feil i parameterverdier eller en logisk programmeringsfeil i koden kalt "bug", 
  	- et spesialtilfelle inntreffer som gjør at transaksjon må kanselleres, for eksempel, at data ikke finnes, som at dekning på en konto mangler (hvis et unntak er programmert inn i koden som implementerer transaksjonen, betraktes dette ikke som en transaksjonsfeil),
  	- en implementert metode for kontroll over delte ressurser (konkurranse) kan avbryte transaksjonen pga. brudd på serialiserbarhet (en tidsplan for en transaksjon er serialiserbar når den er betraktet som korrekt selv om konkurrerende transaksjoner blir utført i samme tidsperioden ... T1->T2 eller T2->T1 er serielle tidsplaner).
  - Før DBHS har gjennomført "rollback" og satt verdien til databaseelementet tilbake til den forrige verdien, leser en annen transaksjon den oppdaterte verdien til databaseelementet.
  - Verdien X som leses av T2 kalles for "dirty data" siden den er laget av en transaksjon som ennå ikke har kommet til "commit" (eller "rollback").

``` 
--- "dirty read" ---
T1              T2
---------------|--------------
read_item(X);
X := X - N;
write_item(X);
                read_item(X);
                X := X + M;
                write_item(X); 

                              <- T1 feiler og må gjøre "rollback" på X
                              	i mellomtiden har T2 lest en midlertidig
                              	ukorrekt verdi av X
read_item(Y)
...
``` 
- **Problem med ukorrekt summering** ("inconsistent read", må eventuelt låse store områder)
  - Hvis en transaksjon gjennomfører en beregning (agreggering med funksjoner som COUNT, AVG, SUM, MIN, MAX) basert på flere databaseelementer mens andre transaksjoner oppdaterer noen av disse databaseelementene, agreggeringsfunksjonen kan ta i betraktning noen av verdiene før de ble oppdatert og noen etter at de ble oppdatert.
  - Eksempel: Ane kjører en rapport som summerer saldoene på alle kontoer. Bjørn overfører 5 000 kr fra konto 1920 til konto 2400 mens Anes spørring leser radene.
```
Kontoer i databasen:
  1920 Bankinnskudd    10 000 kr
  2400 Leverandørgjeld  8 000 kr
  Total korrekt:       18 000 kr

Tid   Transaksjon A (Ane — SUM)        Transaksjon B (Bjørn — overføring)
────  ──────────────────────────────   ──────────────────────────────────
T1    BEGIN
T2    LES konto 1920 → 10 000          BEGIN
T3                                     UPDATE 1920: 10 000 → 5 000
                                       UPDATE 2400:  8 000 → 13 000
                                       COMMIT
T4    LES konto 2400 → 13 000
      (leser den oppdaterte verdien)
T5    SUM = 10 000 + 13 000 = 23 000
T6    COMMIT

Korrekt svar:  18 000 kr  (før overføring)
               18 000 kr  (etter overføring — summen er uendret)
Feil svar:     23 000 kr  (blanding av før og etter)
```

- **Non-repeatable read** 
  - T1 leser en verdi fra en tabell. Hvis en annen transaksjon T2 senere oppdaterer denne verdien og T1 leser denne verdien på nytt, vil T1 "se" den siste verdien, som er forskjellig fra den første.
  - For eksempel, under flybestilling en kunde sjekker tilgjengelighet av ledige plasser på flere flighter før kunden bestemmer for en flight, kan antall ledige plasser være endret når kunden bestemmer seg for en flight, dvs. når transaksjonen leser antall ledige seter andre gangen. 
- **Phantom read**
  - Phantom read handler om at nye rader dukker opp (eller forsvinner) mellom to kjøringer av samme spørring.


| Fenomen                 | Hva som er ustabilt                                               | Antall rader endres?              | Verdier endres?                              |
| ----------------------- | ----------------------------------------------------------------- | --------------------------------- | -------------------------------------------- |
| **Phantom Read**        | *Mengden* av rader som matcher en WHERE-betingelse                | **Ja** — rader legges til/slettes | Nei (eksisterende rader uendret)             |
| **Non-repeatable Read** | Verdien av *én bestemt rad* lest to ganger                        | Nei                               | **Ja** — én rad er oppdatert                 |
| **Inconsistent Read**   | *Kombinasjonen* av verdier på tvers av flere rader lest *én gang* | Nei                               | **Ja** — ulike rader lest på ulike tidspunkt |

- **Isolasjonsnivåer** spesifiserer hvordan transaksjoner er isolert fra hverandre basert på diverse feil / konflikter som kan oppstå med overlappende transaksjoner (dvs. når to eller flere transaksjoner gjennomføres i samme tidsrom og leser / skriver de samme databaseelementene i databasen). 
  - READ UCOMMITED (anomalier som "dirty read", "nonrepeatable read" og "phantom record" kan alle inntreffe)
  - READ COMMITTED ("dirty read" er utelukket)
  - REPEATABLE READ ("dirty read" og "unrepeatable read" er utelukket)
  - SERIALIZABLE (garanterer at ingen av anomaliene kan inntreffe)
- OBS! Databaseadministrator og database programmerer kan bruke isolasjonsnivåer for å finjustere transaksjonsytelse ved å, for eksempel, ikke kreve serialiserbarhet.
- Man bruker også et begret "snapshot isolation", hvor en transaksjon kun ser verdier som var i databasen ("commited") når transaksjonen startet, dvs. transaksjon jobber på en "snapshot" av databasen på oppstartstidspunktet.
- PostgreSQL har en implementert mekanisme for "shapshot isolation" som heter Multi-Version Concurrancy Control (MVCC). 

... fortsettelsen kommer 2026-04-15 ...

- **Mer om MVCC**

Moderne databasehåndteringssystemer har innebygde mekanismer for behandling av samtidige oppdateringer og lesinger. PostgreSQL har en mekanisme kalt Multi-Version Concurrency Control som håndterer samtidige lesere og skrivere uten låsing. Låsing betyr at man ikke tillater noen prosesser å fullføre før en annen prosess, som trenger samme ressursen har avsluttet. Låsing kan, blant annet, gi ytelses- og vranglås-problemer. 

> Når en verdi skal endres, ikke overskriv den på stedet (disk) - skriv den nye verdien et nytt sted, og la den gamle stå inntil ingen lenger trenger den (eller "for alltid").

Dette ligner på mekanismen implementert i versjonskotrollsystemet `git`. 

| Aspekt             | Git                                | PostgreSQL MVCC                                             |
| ------------------ | ---------------------------------- | ----------------------------------------------------------- |
| **Enhet**          | Filer og commits                   | Individuelle databaserader                                  |
| **Formål**         | Historikk, samarbeid, branching    | Samtidige transaksjoner uten låsing                         |
| **Tidslinje**      | Permanent — historikk beholdes     | Midlertidig — gamle versjoner slettes når ingen trenger dem |
| **Merge-strategi** | Manuell (du løser konflikter selv) | Automatisk (databasen avviser eller velger)                 |
| **Branching**      | Eksplisitt og langvarig            | Implisitt og kortvarig (én transaksjon)                     |

MVCC kan sees også i forhold til isolasjonsnivåer. 

| Isolasjonsnivå            | MVCC-snapshot?                         | Beskytter mot Inconsistent Read?                    |
| ------------------------- | -------------------------------------- | --------------------------------------------------- |
| Read Committed (standard) | **Delvis** — nytt snapshot per setning | **Nei** — hver `SELECT` ser siste committed versjon |
| Repeatable Read           | **Ja** — ett snapshot per transaksjon  | **Ja**                                              |
| Serializable              | **Ja** + ekstra sjekker                | **Ja**                                              |

Man trenger ikke å bruke de strengeste isolasjonsnivåene. MVCC gir det beste fra begge verdener:
- Høy parallellitet: Lesere blokkerer ikke skrivere, og skrivere blokkerer ikke lesere.
- Konsistens: Hver transaksjon ser et konsistent øyeblikksbilde av databasen fra det tidspunktet den startet.

Kostnaden er lagringsplass (gamle versjoner må beholdes til ingen transaksjon trenger dem lenger) og vedlikehold (VACUUM i PostgreSQL rydder opp døde versjoner). Men dette er en langt billigere kostnad enn å serialisere alle transaksjoner.

Oppbygging etter feil er implementert forskjellig i de forskjellige databasehåndteringssystemer, men det er noen hovedprinsipper som er oppsummert her:

| Begrep       | Hva det er                           | Hvem utfører det                     | Når                                       |
| ------------ | ------------------------------------ | ------------------------------------ | ----------------------------------------- |
| **REDO**     | Anvend en WAL-oppføring på datafilen | PostgreSQL automatisk                | Ved oppstart etter krasj                  |
| **UNDO**     | Marker en transaksjon som abortert   | PostgreSQL automatisk (via pg\_xact) | Ved oppstart / lazy ved første tilgang    |
| **ROLLBACK** | SQL-kommando du skriver selv         | Deg som bruker                       | Når du vil avbryte en transaksjon manuelt |
| **WAL**      | Loggen som gjør REDO mulig           | PostgreSQL skriver, du leser ikke    | Kontinuerlig under drift                  |

- **REDO** betyr: ta en endring som er registrert i WAL-loggen, og anvend den på datafilen på disk. Dette brukes når databasen krasjet etter at en transaksjon ble committed, men før de endrede sidene (pages) ble skrevet fra RAM til disk. WAL-loggen er skrevet til disk (det er garantien ved COMMIT), men datafilen er ikke oppdatert ennå.
- **UNDO** betyr: ta en endring som er registrert i WAL-loggen, og reverser den i datafilen.
Dette brukes når databasen krasjet midt i en transaksjon som aldri ble committed. Noen av endringene kan allerede ha blitt skrevet til disk (PostgreSQL skriver dirty pages til disk løpende for å frigjøre RAM), men transaksjonen er ikke ferdig.

- Når Postgresql starter etter en krasj/feil, følgende skjer:
1. ANALYSE:   Les WAL fra siste checkpoint. Finn hvilke transaksjoner som er committed og hvilke som ikke er det.

2. REDO-fase: Spill av alle WAL-oppføringer fra checkpointet frem til krasjet. Dette bringer datafilen til den tilstanden den hadde rett før krasjet
— inkludert uncommitted endringer som tilfeldigvis var skrevet til disk.

3. UNDO-fase: Marker alle transaksjoner uten COMMIT som aborterte i pg_xact. (I PostgreSQL skjer dette "lazy" — ikke ved oppstart, men første gang en annen transaksjon møter en slik rad og sjekker dens synlighet.)

> Det er verden av spennende løsninger i DBHS, som er blitt utviklet under mange iterasjoner med prøving og feiling over flere tiår, slik mange DBHS tilfredstiller ACID i rimelige stor grad og kan brukes for de fleste behov.


## Video
https://www.youtube.com/watch?v=RlM9AfWf1WU (concurrency and parallelism)

Parallellismen er relatert til `serialiserbarhet` (hva er en `seriell` oppgave?). 














