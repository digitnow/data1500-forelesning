# Øvingssett for eksamen i DATA1500 våren 2026 (del 2) 

## Modellbeskrivelse (tre domener)

Modellene er definert med et tabellnavn med stor forbokstav og i flertall (Sykler, Stasjoner osv.), og med kolonnenavn (attributter) med "snake_case"-notasjon og små bokstaver. Ingen primær- eller fremmednøkler er markert.

### Modell A: Bysykkel-utleie
``` 
Sykler (sykkel_id, status, sist_vedlikeholdt)
Stasjoner (stasjon_id, navn, kapasitet, lat, lon)
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

### Delspørringer og CTE (Common Table Expressions)
*Fortsettelse fra Del 1*

--- 

51. Hvordan bruker du en vekselvirkende delspørring (se pensumboken side 127 5. utgave) for å finne den beste rundetid for hver spiller på tvers av alle løp? Gjelder Modell B (E-sport).

Tester kunnskap om vekselvirkende delspørringer. 

--- 

52. Skriv en spørring som finner alle avdelinger der gjennomsnittlig timer_allokert per ansatt er høyere enn bedriftens totale gjennomsnitt. Gjelder Modell C (Bedrift).

Tester kunnskap om anvendelse av delspørringer. 

--- 

53. Skriv en vindusfunksjon-spørring som rangerer (RANK()) spillere basert på deres beste_rundetid i et spesifikt løp. Gjelder Modell B (E-sport).

Tester kunnskap om anvendelse av vindusfunksjoner. 

--- 

54. Hvordan beregner du en løpende sum av pris for alle utleier en bestemt bruker har tatt, sortert på start_tid? Gjelder Modell A (Bysykkel).

Tester kunnskap om anvendelse av vindusfunksjoner.

---

55. Utvid Modell C (Bedrift) slik at det kan brukes rekursiv spørring (tips: legg inn en selvreferanse i tabellen Ansatte). Skriv en rekursiv CTE (WITH RECURSIVE) for å finne alle underordnede (i alle ledd) til en spesifikk leder i den modifiserte versjonen av Modell C (Bedrift).

Tester kunnskap om rekursive spørringer (i Postgresql) og krav for modellen for å kunne bruke rekursive spørringer (hint: selvreferanse).

---

56. Hvordan bruker du LAG() eller LEAD() for å finne tidsdifferansen mellom en brukers forrige bysykkeltur (utleie) og deres nåværende tur (utleie)? Gjelder Modell A (Bysykkel).

Tester kunnskap om anvendelse av vindusfunksjoner.

---

57. Skriv en spørring som bruker COALESCE for å returnere 'Ukjent' hvis en sykkel ikke har en registrert `sist_vedlikeholdt` dato. Anta at `sist_vedlikeholdt` kan ha NULL-verdier og er av typen DATE. Vis også `sykkel_id` i resultatet. Gjelder Modell A (Bysykkel).

Tester forståelsen av funksjonen COALESCE. 

--- 

58. Hva er en MATERIALIZED VIEW, og hvorfor kan den passe for en ledertavle basert på Modell B (E-sport)?

Tester kunnskap om MATERIALIZED VIEW. 

---

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
Tester kunnskap om praktisk anvendelse av materialisert view og ferdigheter til å designe SQL-spørringer med mange joins, agreggerings- og vindusfunksjoner.

--- 

### ACID-egenskapene

60. Hva står bokstavene i ACID for? Forklar hver av dem kort. 

Tester kunnskap om ACID.

--- 

61. En bruker leier en sykkel. Dette krever at sykkelens status endres til 'Utleid', og en ny rad opprettes i Utleier. Hvilken ACID-egenskap sikrer at enten begge eller ingen av disse endringene lagres?

Tester forståelsen av og ferdigheter for anvendelse av ACID-egenskapene.

--- 

62. Hva betyr "Consistency" i ACID-sammenheng? Gi et eksempel på et konsistensbrudd i NS 4102-modellen (dobbelt bokholderi). 

Tester forståelsen av og ferdigheter for anvendelse av ACID-egenskapene.

--- 

63. Forklar "Isolation". Hvorfor er det viktig når to brukere prøver å leie den samme bysykkelen tilnærmet samtidig?

Tester forståelsen av og ferdigheter for anvendelse av ACID-egenskapene.

--- 

64. Hva innebærer "Durability"? Hvordan sikrer PostgreSQL at data overlever et strømbrudd rett etter en COMMIT?

Tester forståelsen av og ferdigheter for anvendelse av ACID-egenskapene.

--- 

65. Er det mulig å ha et databasesystem som er "A", "C" og "D", men ikke "I"? Hva ville konsekvensen vært? 

Tester forståelsen av og ferdigheter for anvendelse av ACID-egenskapene.

--- 

66. Hva er en "dirty read"? Gi et eksempel fra Modell C (Bedrift) der en leder leser et budjsett som er under oppdatering, men som senere blir rullet tilbake (ROLLBACK).

Tester forståelsen av transaksjons-anomalier.

--- 

67. Forklar "non-repeatable read". Hvordan kan dette oppstå hvis en E-sport-kommentator leser en spillers poengsum to ganger i samme transaksjon, mens en annen transaksjon oppdaterer poengsummen i mellomtiden?

Tester forståelsen av transaksjons-anomalier.

--- 

68. Hva er "phantom read"? Hvordan skiller det seg fra en "non-repeatable read"? Bruk et eksempel der man teller antall aktive sykler i Modell A (Bysykkel).

Tester forståelsen av transaksjons-anomalier.

--- 

69. Hva er "lost update"? Beskriv et scenario i NS 4201-modellen der to regnskapsførere oppdaterer saldoen på samme konto samtidig (Read-Calculate-Write).

Tester forståelsen av transaksjons-anomalier.

--- 

70. Forklar "write skew". Hvordan kan dette skje hvis to leger i en sykehusdatabase (eller to prosjektledere i Modell C (Bedrift)) sjekker om det er nok budsjett igjen, og begge trekker fra budsjettet samtidig? 

Tester forståelsen av transaksjons-anomalier.

---

71. Hvilken samtidighetsproblem er det mest kritiske å unngå i et finansielt system (som NS 4102), og hvorfor? 

Tester kjennskap til et reelt domen og hvordan modelleringen må ta hensyn til typiske egenskaper til modellen. 

---

72. Hvilke fire isolasjonsnivåer definerer SQL-standard? 

Tester kjennskap til en transkasjonshåndtering i relasjonsdatabaser og SQL-standard. 

--- 

73. Hvilket isolasjonsnivå er standard (default) i PostgreSQL, og hvilke anomalier forhindrer det?

Tester kjennskap til isolasjonsnivåer og transaksjonsanomalier.

--- 

74. Hvilket isolasjonsnivå må du bruke for å garantere at hverken "dirty read", "non-repeatable read" eller "phantom read" kan forekomme?

Tester kjennskap til isolasjonsnivåer og transaksjonsanomalier.

--- 

75. I Modell A (Bysykkel), hvis du bruke READ UCOMMITTED, hva er risikoen når du beregner total inntjening  for dagen? 

Tester kjennskap til isolasjonsnivåer og transaksjonsanomalier.

---

76. Hvorfor bruker man ikke alltid SERIALIZABLE hvis det er det tryggeste nivået?

Tester kjennskap til isolasjonsnivåer og transaksjonsanomalier.

---

77. Hva er de fire hovedkategoriene av NoSQL-systemer? Nevn et populært produkt for hver kategori.

Tester kunnskap om typer av NoSQL-systemer.

---

78. Forklar hva en Dokumentdatabase (NoSQL-system) er? Hvordan lagres vanligvis dataene (format)?

Tester kunnskap om Dokumentdatabaser.

--- 

79. Hva er Nøkkel-Verdi-database (Key-Value store)? Hvorfor er en Nøkkel-Verdi-database vanligvis veldig rask (spesielt å hente ut data)?

Tester kunnskap om "Key-value"-databaser.

---

80. Forklar hva en "Wide-Column-store" (Kolonne-familie database som NoSQL-system) er. Hvordan skiller den seg fra en tradisjonell relasjonsdatabase?

Tester kunnskap om Kolonne-familie databaser og evne til å sammenligne med tradisjonell relasjonsdatabase.

---

81. Hva er en Grafdatabase? Hvilke to hovedkomponenter brukes for å abstrahere dataene?

Tester kjennskap til Graf-databaser.

---

82. Hva står bokstavene i CAP-teoremet for? Forklar hver av dem kort. 

Tester kjennskap til basisprinsippene i distribuerte systemer (NoSQL-systemer er ofte distribuerte).

--- 

83. Ifølge CAP-teoremet, hvor mange av disse tre egenskapene kan et distribuert system garantere samtidig under en nettverkspartisjon (Partition)? 

Tester kjennskap til basisprinsippene i distribuerte systemer (NoSQL-systemer er ofte distribuerte).

---

84. Hva står BASE for? Hvordan er dette i motsetning til ACID? 

Tester kunnskap til basisprinsippene i distribuerte systemer (NoSQL-systemer er ofte distribuerte) og relasjonelle databasemodeller.

---

85. Hva er "Soft state" i BASE-prinsippene? Hvordan henger det sammen med "Eventual consistency"?

Tester kunnskap til basisprinsippene i distribuerte systemer (NoSQL-systemer er ofte distribuerte).


SLUTT.


