# 🧩 Daniel Katić, dokumentacija – članovi i članarine

## 1. Opis modula

Ovaj modul pokriva **vođenje članova i članarina fitness centra**.  
Svrha je omogućiti praćenje statusa članova, vrsta članarina i njihovog trajanja.

### Funkcionalnosti:

- Evidencija osobnih podataka članova  
- Definiranje tipova članarina (mjesečna, godišnja, premium...)  
- Praćenje statusa svake članarine (aktivna, istekla, zamrznuta)  
- Povezivanje članova s njihovim članarinama  
- Priprema podataka za obračun plaćanja i automatsku deaktivaciju članova  

## 2. Relacije i veze

### 2.1 `clan`

**Opis:** osnovni podaci o članovima fitness centra.  
**Veze:**  

- 1:N s `clanarina`  
- 1:N s `placanje` *(izvan ovog modula)*  
- 1:N s `rezervacija` *(izvan ovog modula)*  
- 1:N s `trening_clan` *(izvan ovog modula)*  

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator člana |
| `ime` | VARCHAR(50) |  | Ime člana |
| `prezime` | VARCHAR(50) |  | Prezime člana |
| `oib` | CHAR(11) |  | OIB člana |
| `spol` | ENUM('M', 'Ž', 'Drugo') |  | Spol člana |
| `datum_rodenja` | DATE |  | Datum rođenja |
| `adresa` | VARCHAR(150) |  | Adresa člana |
| `grad` | VARCHAR(100) |  | Grad člana |
| `email` | VARCHAR(100) | UQ | Kontakt e-mail |
| `telefon` | VARCHAR(20) |  | Broj telefona |
| `datum_uclanjenja` | DATE |  | Datum kada je član upisan |
| `datum_posljednje_aktivnosti` | DATE |  | Datum posljednje aktivnosti |
| `aktivan` | BOOLEAN |  | Označava je li član trenutno aktivan |

> **Napomena:** Polje `aktivan` planirano je automatizirati **triggerom** koji deaktivira člana kad istekne članarina.

### 2.2 `tip_clanarine`

**Opis:** definira vrste članarina dostupne u fitness centru.  
**Veza:** 1:N s `clanarina`.

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator tipa |
| `naziv` | VARCHAR(50) |  | Naziv članarine |
| `trajanje_mjeseci` | INT |  | Trajanje članarine u mjesecima |
| `cijena` | DECIMAL(8,2) |  | Cijena u eurima |
| `opis` | VARCHAR(255) |  | Dodatne informacije o tipu |

**Primjeri podataka:**

| id | naziv | trajanje_mjeseci | cijena | opis |
|----|--------|------------------|--------|------|
| 1 | Mjesečna | 1 | 40.00 | Osnovni pristup svim dvoranama |
| 2 | Godišnja | 12 | 400.00 | Popust 2 mjeseca gratis |
| 3 | Premium | 12 | 600.00 | Uključuje osobnog trenera |

### 2.3 `status_clanarine`

**Opis:** omogućava praćenje trenutnog statusa članarine.  
**Veza:** 1:N s `clanarina`.

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Identifikator statusa |
| `naziv` | VARCHAR(50) |  | Naziv statusa (Aktivna, Istekla, Zamrznuta...) |
| `opis` | VARCHAR(255) |  | Kratki opis značenja statusa |

**Primjeri:**

| id | naziv | opis |
|----|--------|------|
| 1 | Aktivna | Članarina je važeća |
| 2 | Istekla | Rok članarine je prošao |
| 3 | Zamrznuta | Privremeno pauzirana |

### 2.4 `clanarina`

**Opis:** veza između člana, tipa i statusa članarine.  
**Veze:**  

- N:1 prema `clan`  
- N:1 prema `tip_clanarine`  
- N:1 prema `status_clanarine`

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Identifikator članarine |
| `id_clan` | INT | FK | Poveznica na člana |
| `id_tip` | INT | FK | Poveznica na tip članarine |
| `id_status` | INT | FK | Poveznica na status članarine |
| `datum_pocetka` | DATE |  | Datum početka članarine |
| `datum_zavrsetka` | DATE |  | Datum završetka članarine |

### 2.5 `statistika_potrosnje`

**Opis:** pohrana kvartalne statistike potrošnje svakog člana. 

Svaki zapis predstavlja ukupni iznos koji je član potrošio na članarine unutar određenog kvartala i godine. 
Tablica je automatski popunjena pomoću procedure `statistika_potrosnje()` i event `event_statistika_potrosnje` azurira podatke prvog dana novog kvartala.

**Veza:** N:1 s `clan` (svaki član ima više kvartalnih zapisa) 

| Atribut | Tip | Ključ | Opis |
|---------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator zapisa |
| `id_clan` | INT | FK | Poveznica na člana |
| `ukupno_u_periodu` | DECIMAL(10,2) || Ukupan iznos potrošen u kvartalu |
| `godina` | YEAR || Godina na koju se statistika odnosi |
| `kvartal` | INT || Kvartal (1–4) |  

---

## 3. Logičke veze (ER shema – opisno)

- **clan** `1—N` **clanarina**  
- **tip_clanarine** `1—N` **clanarina**  
- **status_clanarine** `1—N` **clanarina**
- **clan** `1—N` **statistika_potrosnje**

Ovim odnosima moguće je pratiti svaku članarinu pojedinog člana, njezin tip i trenutačni status.

## 4. Složeni upiti

Implementirao sam složene SQL upite koji služe za analizu poslovanja fitness centra i ponašanja članova.

### 4.1 Aktivne članarine po tipu

Upit vraća broj trenutno aktivnih članarina grupiran po tipu članarine, zajedno s cijenom i trajanjem.
Koristi se za uvid u popularnost pojedinih tipova članarina i planiranje ponuda.

### 4.2 Broj članova po mjestu

Upit prikazuje koliko članova dolazi iz svakog mjesta.
Omogućuje geografsku analizu članstva i identifikaciju područja s najvećim interesom.

### 4.3 Članarine kojima uskoro istječe rok

Upit pronalazi članove kojima članarina istječe u narednih 7 dana.
Koristan je za pravovremeno obavještavanje članova i poticanje obnove članarine.

### 4.4 Broj članarina po statusu

Upit daje pregled koliko je članarina aktivno, isteklo ili zamrznuto, što omogućuje praćenje općeg stanja članstva.

### 4.5 Novi članovi

Upit dohvaća članove učlanjene u posljednjih godinu dana, što se koristi za analizu rasta baze korisnika.

## 5. Pogledi

Za lakši pristup podacima i čitljivije upite implementirani su sljedeći pogledi:

## 5.1 aktivni_clanovi

Pogled prikazuje sve aktivne članove zajedno s njihovim osobnim podacima, tipom članarine i razdobljem važenja.
Koristi se za administrativni pregled aktivnih korisnika.

## 5.2 zadnje_istekle_clanarine

Pogled sadrži članarine koje su istekle u zadnjih 30 dana.
Predviđen je za marketinške svrhe, poput slanja ponuda za obnovu članarine.

## 5.3 clanovi_po_mjestu

Pogled kombinira podatke iz tablica clan i mjesto kako bi se dobio pregled broja članova po mjestu.

## 5.4 clanarine_po_spolu

Pogled omogućuje analizu članarina prema spolu i statusu, što može pomoći pri planiranju marketinških kampanja.

## 6. Funkcije

### 6.1 preostalo_trajanje_clanarine(oib_clana)

Funkcija vraća broj dana do isteka zadnje članarine člana identificiranog OIB-om.
Ako je članarina istekla, funkcija vraća vrijednost -1.

### 6.2 potrosnja_clana_za_period(oib, pocetak, kraj)

Funkcija računa koliko je određeni član potrošio na članarine unutar zadanog vremenskog razdoblja.
Koristi se u analitičke i marketinške svrhe.

### 6.3 broj_aktivnih_clanova(mjesec, godina)

Funkcija vraća broj članova koji su imali aktivnu članarinu barem jedan dan u zadanom mjesecu i godini.
Korištena je u proceduri za godišnju statistiku aktivnih članova.

## 7. Procedure

### 7.1 azuriraj_status_clanarina()

Procedura automatski ažurira statuse članarina na temelju datuma početka i završetka.

Transakcije:
Procedura koristi transakciju (START TRANSACTION, COMMIT, ROLLBACK) kako bi se osiguralo da se sve promjene izvrše atomski.
U slučaju pogreške, sve promjene se poništavaju čime se sprječava nekonzistentno stanje baze.

Procedura se automatski pokreće jednom dnevno pomoću eventa.

### 7.2 aktivni_po_godini(godina)

Procedura vraća tablicu s brojem aktivnih članova po mjesecima u zadanoj godini.
Koristi privremenu tablicu i petlju za iteraciju kroz mjesece.

### 7.3 statistika_potrosnje()

Procedura računa kvartalnu potrošnju svih članova koristeći cursor.
Rezultati se spremaju u tablicu statistika_potrosnje, pri čemu se u slučaju postojećeg zapisa radi ažuriranje podataka.

## 8. Okidači (TRIGGER)

Implementirani okidači služe za automatizaciju i održavanje integriteta podataka:

- automatsko postavljanje datuma učlanjenja

- automatska aktivacija člana pri unosu nove aktivne članarine

- automatska deaktivacija člana ako više nema nijednu aktivnu članarinu

- postavljanje zadane godine u tablici statistike potrošnje

Time se smanjuje mogućnost pogreške i potreba za ručnim ažuriranjem podataka

## 9. Eventi

### 9.1 event_azuriraj_status_clanarina

Event se izvršava jednom dnevno i automatski poziva proceduru za ažuriranje statusa članarina.

### 9.2 event_statistika_potrosnje

Event se izvršava svaka tri mjeseca i pokreće izračun kvartalne statistike potrošnje članova.

## 10. Autentifikacija i autorizacija

Za pristup bazi iz Flask aplikacije koristi se poseban korisnik baze podataka s ograničenim pravima.

Aplikacijski korisnik ima dopuštene CRUD operacije, čitanje pogleda i izvršavanje procedura, dok administrativna prava nisu dopuštena.

Time se izbjegava korištenje root korisnika i povećava sigurnost sustava.

## 11. Transakcije

Transakcije sam demonstrirao u procedurami azuriraj_status_clanarina.

Svrha je osigurati da se poslovne operacije izvršavaju kao cjelina i da ne dođe do djelomičnih ili nekonzistentnih promjena podataka.
