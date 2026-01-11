# Dokumentacija – Modul opreme i održavanja

## 1. Opis modula

Modul opreme i održavanja služi za evidenciju i praćenje opreme unutar sustava. Omogućuje praćenje osnovnih podataka o opremi, njezina stanja, lokacije (prostorije), dobavljača te povijesti održavanja.

Glavne ideje modula:
- **Oprema** je “glavni objekt” (svaka sprava/uređaj ima svoj zapis).
- **Dobavljač** daje kontekst od koga je oprema nabavljena i omogućuje statistike (kvaliteta isporuke, količina opreme, učestalost problema).
- **Održavanje** je dnevnik događaja (tko je radio, kada, što je napravljeno) i koristi se za izvještaje, planiranje servisa i dokazivanje intervencija.
- **Prostorija** je lokacija gdje se oprema nalazi (vanjski modul kolege), što je važno za organizaciju teretane i logistiku održavanja.
- **Zaposlenik** (vanjski modul kolege) je servisna osoba koja evidentira održavanje; prikazuje se u problematičnim slučajevima (tko je zadnji dirao opremu).

Modul je realiziran pomoću:
- **pregleda (SELECT upita)** – “ad-hoc” analitika i operativni izvještaji,
- **pogleda (VIEW)** – standardizirani izvještaji koje je lakše pozivati i koristiti u aplikaciji,
- **funkcija** – ponovljivi izračuni (npr. zadnje održavanje),
- **procedura** – kontrolirani unos/izmjene (npr. evidentiraj održavanje, ažuriraj opremu).

---

## 2. Opis tablica

### 2.1 Tablica: `oprema`

| Atribut        | Tip podataka                                        | Ključ / ograničenje                          | Opis |
|---------------|------------------------------------------------------|-----------------------------------------------|------|
| id            | INT                                                  | PK                                            | Jedinstveni identifikator opreme. |
| naziv         | VARCHAR(150)                                         | NOT NULL                                      | Naziv opreme (sprava/uređaj). |
| prostorija_id | INT                                                  | FK → prostorija(id), NOT NULL                 | Referenca na prostoriju gdje se oprema nalazi. |
| dobavljac_id  | INT                                                  | FK → dobavljac(id), NOT NULL                  | Referenca na dobavljača opreme. |
| datum_nabave  | DATE                                                 | NOT NULL                                      | Datum nabave opreme. |
| stanje        | ENUM('ispravno','neispravno','u servisu','otpisano')  | NOT NULL, DEFAULT 'ispravno'                  | Trenutno stanje opreme. |

**Svrha tablice:**
- Ova tablica je “centralna” jer se sve ostalo u modulu veže na nju.
- Omogućuje da svaka sprava ima:
  - identitet (`id`),
  - naziv radi prepoznavanja (`naziv`),
  - lokaciju gdje fizički stoji (`prostorija_id`),
  - dobavljača radi odgovornosti i statistike (`dobavljac_id`),
  - datum nabave radi starosti i računanja “koliko dugo nije servisirano” kad nema zapisa održavanja (`datum_nabave`),
  - trenutno stanje (`stanje`) radi filtriranja problematične opreme i praćenja statusa.

**Zašto je `stanje` bitno:**
- `ispravno` – normalno stanje (oprema radi i može se koristiti).
- `neispravno` – oprema je pokvarena i ne smije se koristiti.
- `u servisu` – oprema je poslana na servis / čeka servis / u postupku.
- `otpisano` – oprema se više ne koristi (zastarjela, neisplativa za popravak).

**Veze (FK) i njihov smisao:**
- `prostorija_id → prostorija(id)`: osigurava da oprema uvijek ima validnu prostoriju. Ne može se upisati oprema s prostorijom koja ne postoji.
- `dobavljac_id → dobavljac(id)`: osigurava da oprema uvijek ima validnog dobavljača i da se statistike po dobavljaču mogu raditi pouzdano.

**Indeksi:**
- Index na `prostorija_id`: ubrzava upite tipa “prikaži svu opremu u prostoriji” i joinove s tablicom `prostorija`.
- Index na `dobavljac_id`: ubrzava upite tipa “prikaži svu opremu dobavljača” i joinove s tablicom `dobavljac`.

---

### 2.2 Tablica: `dobavljac`

| Atribut | Tip podataka | Ključ / ograničenje | Opis |
|--------|--------------|---------------------|------|
| id     | INT          | PK                  | Jedinstveni identifikator dobavljača. |
| naziv  | VARCHAR(150) | NOT NULL, UNIQUE    | Naziv dobavljača. |
| oib    | CHAR(11)     | NOT NULL, UNIQUE    | OIB dobavljača (11 znamenki). |
| kontakt| VARCHAR(150) | NOT NULL            | Kontakt (email ili telefon). |
| adresa | VARCHAR(200) | NOT NULL            | Adresa dobavljača. |

**Svrha tablice:**
- Čuva podatke o dobavljačima opreme kako bi se mogla:
  - pratiti oprema po dobavljaču,
  - raditi statistika (koliko opreme, kakva su stanja, raspon nabava),
  - imati kontakt podatke za reklamacije / servis / nabavu dijelova.

**Zašto `UNIQUE` na `naziv` i `oib`:**
- `oib` je jedinstven identifikator tvrtke – sprječava duple dobavljače.
- `naziv` sprječava da se ista tvrtka unese dvaput pod istim nazivom.

**CHECK za OIB (format):**
- Provjera `^[0-9]{11}$` osigurava da OIB ima točno 11 znamenki.
- U praksi pomaže da se ne unesu slova, razmaci ili kriva duljina.

---

### 2.3 Tablica: `prostorija` (vanjski modul)

| Atribut | Tip podataka | Ključ / ograničenje | Opis |
|--------|--------------|---------------------|------|
| id     | INT          | PK                  | Jedinstveni identifikator prostorije. |
| oznaka | VARCHAR(10)  | NOT NULL            | Kratka oznaka prostorije. |
| lokacija | VARCHAR(50) | NOT NULL           | Tekstualni opis lokacije. |
| kapacitet | INT       | CHECK (kapacitet > 0) | Maksimalni kapacitet prostorije. |
| tip_prostorije_id | INT | FK → tip_prostorije(id), NOT NULL | Tip prostorije. |
| podruznica_id | INT   | FK → podruznica(id), NOT NULL | Podružnica kojoj prostorija pripada. |

**Svrha tablice:**
- Prostorija predstavlja fizičku lokaciju unutar fitness centra.
- U ovom modulu se koristi za vezu `oprema.prostorija_id` kako bi se znalo gdje se oprema nalazi.
- U izvještajima se prostorija prikazuje kao `CONCAT(oznaka, ' - ', lokacija)` radi čitljivosti.

---

### 2.4 Tablica: `odrzavanje`

| Atribut        | Tip podataka | Ključ / ograničenje                | Opis |
|---------------|--------------|------------------------------------|------|
| id            | INT          | PK                                 | Jedinstveni identifikator zapisa održavanja. |
| oprema_id     | INT          | FK → oprema(id), NOT NULL          | Oprema na koju se održavanje odnosi. |
| zaposlenik_id | INT          | FK → zaposlenik(id), NOT NULL      | Zaposlenik koji je izvršio održavanje. |
| datum         | DATE         | NOT NULL                            | Datum održavanja. |
| opis          | VARCHAR(300) | NOT NULL                            | Opis intervencije/servisa. |

**Svrha tablice:**
- Ovo je “servisni dnevnik” za opremu.
- Svaki zapis predstavlja jednu intervenciju ili servisni događaj.
- Na temelju ove tablice se računaju:
  - **broj održavanja** po opremi,
  - **zadnje održavanje** (MAX datum),
  - “koliko dana bez servisa” (DATEDIFF od zadnjeg datuma).

**Zašto se veže na zaposlenika:**
- Omogućuje odgovornost i praćenje tko je radio održavanje.
- U problematičnim situacijama može se brzo vidjeti “tko je zadnji servisirao” opremu.

**Indeksi:**
- Index na `oprema_id`: ubrzava dohvat svih održavanja za određenu opremu i agregacije (COUNT/MAX).
- Index na `zaposlenik_id`: ubrzava izvještaje i provjere po zaposleniku (npr. koliko održavanja je radio netko).

---

### 2.5 Tablica: `zaposlenik` (vanjski modul)

| Atribut | Tip podataka | Ključ / ograničenje | Opis |
|--------|--------------|---------------------|------|
| id     | INT          | PK                  | Jedinstveni identifikator zaposlenika. |
| ime    | VARCHAR(50)  | NOT NULL            | Ime zaposlenika. |
| prezime| VARCHAR(50)  | NOT NULL            | Prezime zaposlenika. |
| oib    | CHAR(13)     | UNIQUE, NOT NULL    | OIB zaposlenika. |
| datum_rodenja | DATE | (može biti NULL)    | Datum rođenja zaposlenika. |
| spol   | ENUM('M','Ž','Drugo') | (može biti NULL) | Spol zaposlenika. |
| adresa | VARCHAR(100) | (može biti NULL)    | Adresa zaposlenika. |
| id_mjesto | INT       | FK → mjesto(id), NOT NULL | Mjesto (poveznica na tablicu mjesto). |
| telefon | VARCHAR(20) | (može biti NULL)    | Kontakt telefon. |
| email  | VARCHAR(100) | (može biti NULL)    | Email adresa. |
| datum_zaposlenja | DATE | NOT NULL          | Datum zaposlenja. |
| datum_prestanka | DATE | DEFAULT NULL       | Datum prestanka rada (ako postoji). |
| status_zaposlenika | ENUM('aktivan','neaktivan') | NOT NULL | Status zaposlenika. |
| placa  | DECIMAL(10,2) | CHECK (placa >= 0), DEFAULT 0 | Plaća zaposlenika. |
| id_radno_mjesto | INT | FK → radno_mjesto(id), NOT NULL | Radno mjesto zaposlenika. |
| id_podruznica | INT  | FK → podruznica(id), NOT NULL | Podružnica zaposlenika. |

**Svrha tablice:**
- Tablica sadrži podatke o zaposlenicima sustava.
- U ovom modulu se koristi preko veze `odrzavanje.zaposlenik_id` kako bi se znalo tko je evidentirao ili izvršio održavanje.
- U izvještajima se prikazuje ime i prezime zadnjeg servisera radi lakše provjere odgovornosti i praćenja intervencija.

---

## 3. Pregledi (SELECT upiti)

### 3.1 Pregled sve opreme s dobavljačem, prostorijom, brojem održavanja i zadnjim održavanjem

```sql
SELECT
    o.id AS oprema_id,
    o.naziv AS naziv_opreme,
    o.stanje,
    d.naziv AS dobavljac,
    CONCAT(p.oznaka, ' - ', p.lokacija) AS prostorija,
    COUNT(od.id) AS broj_odrzavanja,
    MAX(od.datum) AS zadnje_odrzavanje,
    DATEDIFF(CURDATE(), COALESCE(MAX(od.datum), o.datum_nabave)) AS dana_od_zadnjeg_odrzavanja
FROM oprema o
JOIN dobavljac d ON o.dobavljac_id = d.id
JOIN prostorija p ON o.prostorija_id = p.id
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
GROUP BY
    o.id, o.naziv, o.stanje, d.naziv, p.oznaka, p.lokacija, o.datum_nabave
ORDER BY dana_od_zadnjeg_odrzavanja DESC;
```

**Svrha upita:**
- Ovo je “glavni pregled” koji spaja sve bitno za opremu na jednom mjestu.
- Koristi se kad želiš brzo dobiti odgovor na pitanja:
  - Koja oprema postoji?
  - U kojoj prostoriji je?
  - Od kojeg dobavljača je?
  - Koliko puta je servisirana?
  - Kada je zadnji put servisirana?
  - Koliko je dana prošlo od zadnjeg servisa?

**Kako radi:**
- `JOIN dobavljac` i `JOIN prostorija` dodaju opisne informacije (naziv dobavljača, oznaka/lokacija prostorije).
- `LEFT JOIN odrzavanje` omogućuje da se pokaže i oprema koja **nema održavanja** (tada COUNT/MAX budu 0/NULL).
- `COUNT(od.id)` broji održavanja po opremi.
- `MAX(od.datum)` dohvaća zadnje održavanje.
- `COALESCE(MAX(od.datum), o.datum_nabave)` osigurava da se “dani od zadnjeg” računaju i kada nema održavanja (onda se računa od nabave).
- `ORDER BY dana_od_zadnjeg_odrzavanja DESC` stavlja “najkritičnije” (najduže bez servisa) na vrh.

**Praktična uporaba:**
- planiranje preventivnog servisa,
- prioritetni popis opreme koja dugo nije servisirana,
- brzi uvid u stanje i lokaciju za osoblje u teretani.

---

### 3.2 Statistika opreme po dobavljačima

```sql
SELECT
    d.id,
    d.naziv AS dobavljac,
    COUNT(o.id) AS ukupno_komada,
    SUM(o.stanje = 'ispravno')   AS broj_ispravnih,
    SUM(o.stanje = 'neispravno') AS broj_neispravnih,
    SUM(o.stanje = 'u servisu')  AS broj_u_servisu,
    SUM(o.stanje = 'otpisano')   AS broj_otpisanih,
    MIN(o.datum_nabave) AS najstarija_nabava,
    MAX(o.datum_nabave) AS najnovija_nabava
FROM dobavljac d
LEFT JOIN oprema o ON o.dobavljac_id = d.id
GROUP BY d.id, d.naziv
ORDER BY ukupno_komada DESC;
```

**Svrha upita:**
- Ovaj upit radi **analitiku dobavljača**: koliko opreme dolazi od kojeg dobavljača i kakvo je stanje te opreme.
- Pomaže odgovoriti na pitanja:
  - Koji dobavljač je isporučio najviše opreme?
  - Kod kojeg dobavljača je najviše neispravne opreme?
  - Je li neki dobavljač “problematičan” (puno servisa/neispravnosti)?
  - Kada je krenula suradnja (najstarija nabava) i kada je zadnja nabava?

**Kako radi:**
- `LEFT JOIN oprema` osigurava da se pokažu i dobavljači koji trenutno nemaju opreme (tada COUNT bude 0).
- `SUM(o.stanje = '...')` u MySQL-u radi kao brojanje “true” vrijednosti (true=1, false=0), pa dobiješ koliko je komada u određenom stanju.
- `MIN/MAX datum_nabave` daje raspon nabava (od prve do zadnje isporuke).

**Praktična uporaba:**
- usporedba dobavljača,
- donošenje odluka o budućim nabavama,
- argumenti za reklamacije (ako se vidi trend problema).

---

### 3.3 Neispravna ili servisirana oprema bez održavanja duže od 180 dana

```sql
SELECT
    o.id AS oprema_id,
    o.naziv,
    o.stanje,
    COALESCE(MAX(od.datum), o.datum_nabave) AS zadnji_servis_ili_nabava,
    DATEDIFF(CURDATE(), COALESCE(MAX(od.datum), o.datum_nabave)) AS dana_bez_servisa
FROM oprema o
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
WHERE o.stanje IN ('neispravno', 'u servisu')
GROUP BY
    o.id, o.naziv, o.stanje, o.datum_nabave
HAVING dana_bez_servisa > 180
ORDER BY dana_bez_servisa DESC;
```

**Svrha upita:**
- Ovaj upit filtrira samo opremu koja je **problematična** (neispravna ili u servisu) i provjerava je li dugo bez intervencije.
- Pomaže identificirati “zaboravljenu” opremu koja stoji mjesecima bez rješenja.

**Kako radi:**
- `WHERE o.stanje IN (...)` ograniči samo na problematična stanja.
- `MAX(od.datum)` traži zadnji servisni zapis.
- Ako nema održavanja, računa se od `datum_nabave` (da se ipak dobije broj dana).
- `HAVING dana_bez_servisa > 180` filtrira tek nakon agregacije (jer je `dana_bez_servisa` izračun na temelju MAX).

**Praktična uporaba:**
- upozorenje menadžmentu da se oprema predugo ne rješava,
- prioritizacija servisa i nabave dijelova,
- evidencija za otpis (ako dugo stoji bez rješenja).

---

## 4. Pogledi (VIEW)

### 4.1 VIEW: `v_oprema_zadnje_odrzavanje`

```sql
CREATE OR REPLACE VIEW v_oprema_zadnje_odrzavanje AS
SELECT
    o.id AS oprema_id,
    o.naziv AS naziv_opreme,
    o.stanje,
    o.datum_nabave,
    d.naziv AS dobavljac,
    CONCAT(p.oznaka, ' - ', p.lokacija) AS prostorija,
    COUNT(od.id) AS broj_odrzavanja,
    MAX(od.datum) AS zadnje_odrzavanje
FROM oprema o
JOIN dobavljac d ON o.dobavljac_id = d.id
JOIN prostorija p ON o.prostorija_id = p.id
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
GROUP BY
    o.id, o.naziv, o.stanje, o.datum_nabave, d.naziv, p.oznaka, p.lokacija;
```

**Svrha view-a:**
- View je “spremanjeni izvještaj” – nema potrebe svaki put pisati dugi JOIN + agregacije.
- Koristi se kao baza za:
  - jednostavne SELECT upite (npr. `SELECT * FROM v_oprema_zadnje_odrzavanje;`),
  - filtriranja (npr. oprema bez održavanja, oprema u servisu),
  - aplikacijski prikaz liste opreme s osnovnim servisnim informacijama.

**Zašto je korisno imati view:**
- lakše održavanje koda (jednom se promijeni logika u view-u),
- standardizacija (svi koriste isti izvještaj),
- smanjuje šansu greške u JOIN-ovima i GROUP BY-u.

---

### 4.2 VIEW: `v_dobavljac_statistika`

```sql
CREATE OR REPLACE VIEW v_dobavljac_statistika AS
SELECT
    d.id AS dobavljac_id,
    d.naziv,
    COUNT(o.id) AS broj_komada_opreme,
    MIN(o.datum_nabave) AS prva_isporuka,
    MAX(o.datum_nabave) AS zadnja_isporuka
FROM dobavljac d
LEFT JOIN oprema o ON o.dobavljac_id = d.id
GROUP BY d.id, d.naziv;
```

**Svrha view-a:**
- Sažima osnovnu sliku dobavljača:
  - koliko komada opreme ima,
  - od kada traje suradnja (prva isporuka),
  - kada je zadnja nabava (zadnja isporuka).
- Korisno za “dashboard” ili brzi pregled dobavljača bez detaljnih stanja.

---

### 4.3 VIEW: `v_neispravna_oprema`

```sql
CREATE OR REPLACE VIEW v_neispravna_oprema AS
SELECT
    o.id AS oprema_id,
    o.naziv,
    o.stanje,
    CONCAT(p.oznaka, ' - ', p.lokacija) AS prostorija,
    d.naziv AS dobavljac,
    od.datum AS zadnje_odrzavanje,
    z.ime  AS zadnji_serviser_ime,
    z.prezime AS zadnji_serviser_prezime
FROM oprema o
JOIN prostorija p ON o.prostorija_id = p.id
JOIN dobavljac d ON o.dobavljac_id = d.id
LEFT JOIN odrzavanje od ON od.id = (
    SELECT od2.id
    FROM odrzavanje od2
    WHERE od2.oprema_id = o.id
    ORDER BY od2.datum DESC, od2.id DESC
    LIMIT 1
)
LEFT JOIN zaposlenik z ON z.id = od.zaposlenik_id
WHERE o.stanje IN ('neispravno', 'u servisu', 'otpisano');
```

**Svrha view-a:**
- View izdvaja samo opremu koja nije u normalnom stanju.
- Daje odmah kontekst:
  - gdje je oprema (prostorija),
  - od koga je došla (dobavljač),
  - kada je zadnji put dirana (zadnje održavanje),
  - tko je zadnji radio na njoj (ime i prezime servisera).

**Zašto je query ovakav (subquery za zadnje održavanje):**
- `LEFT JOIN odrzavanje` s podupitom bira **točno jedan** zapis održavanja – onaj najnoviji (zadnji datum, a ako su isti datumi, najveći id).
- Time se izbjegne da se oprema pojavi više puta (jednom za svako održavanje).

**Praktična uporaba:**
- lista “kvarovi i servisi” za osoblje,
- praćenje odgovornosti (tko je zadnji servisirao),
- brža komunikacija s dobavljačem ili servisom.

---

## 5. Funkcije

### 5.1 Funkcija: `fn_zadnje_odrzavanje(oprema_id)`

```sql
CREATE FUNCTION fn_zadnje_odrzavanje (p_oprema_id INT)
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE v_datum DATE;

    SELECT MAX(datum)
    INTO v_datum
    FROM odrzavanje
    WHERE oprema_id = p_oprema_id;

    RETURN v_datum;
END;
```

**Svrha funkcije:**
- Vraća zadnji datum održavanja za određenu opremu.
- Ako oprema nikada nije servisirana, vraća `NULL`.
- Koristi se kao “building block” u drugim upitima/procedurama da se ne ponavlja logika.

**Zašto je korisna:**
- u procedurama i izvještajima samo pozoveš `fn_zadnje_odrzavanje(o.id)` umjesto pisanja `SELECT MAX(datum)...` svaki put,
- smanjuje greške i ubrzava izradu upita u projektu.

---

### 5.2 Funkcija: `fn_dani_od_zadnjeg_odrzavanja(oprema_id)`

```sql
CREATE FUNCTION fn_dani_od_zadnjeg_odrzavanja (p_oprema_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_zadnje DATE;
    DECLARE v_nabava DATE;
    DECLARE v_rezultat INT;

    SELECT datum_nabave
    INTO v_nabava
    FROM oprema
    WHERE id = p_oprema_id;

    SET v_zadnje = fn_zadnje_odrzavanje(p_oprema_id);

    SET v_rezultat = DATEDIFF(CURDATE(), COALESCE(v_zadnje, v_nabava));

    RETURN v_rezultat;
END;
```

**Svrha funkcije:**
- Računa “koliko je dana prošlo” od zadnje servisne aktivnosti.
- Ako nema održavanja, računa se od `datum_nabave` (jer se ipak želi dobiti neka starost).
- Vraća cijeli broj (INT) koji se može direktno sortirati ili koristiti u uvjetima.

**Tipični scenariji:**
- prikaz u izvještajima (“dana bez servisa”),
- logika za upozorenja (npr. ako > 365 dana, preporuči servis),
- rangiranje opreme po prioritetu servisa.

---

## 6. Procedure

Napomena: Parametar stanja u procedurama je `VARCHAR(20)` radi kompatibilnosti, a vrijednosti se provjeravaju u proceduri.

### 6.1 Procedura: `sp_evidentiraj_odrzavanje`

```sql
CREATE PROCEDURE sp_evidentiraj_odrzavanje (
    IN p_oprema_id INT,
    IN p_zaposlenik_id INT,
    IN p_opis VARCHAR(300),
    IN p_novo_stanje VARCHAR(20)
)
BEGIN
    IF p_novo_stanje IS NOT NULL
       AND p_novo_stanje NOT IN ('ispravno','neispravno','u servisu','otpisano') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Neispravno stanje. Dozvoljeno: ispravno, neispravno, u servisu, otpisano.';
    END IF;

    INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
    VALUES (p_oprema_id, p_zaposlenik_id, CURDATE(), p_opis);

    IF p_novo_stanje IS NOT NULL THEN
        UPDATE oprema
        SET stanje = p_novo_stanje
        WHERE id = p_oprema_id;
    END IF;
END;
```

**Svrha procedure:**
- Procedura služi da se unos održavanja radi na kontroliran način:
  1) upiše se novi zapis u `odrzavanje` (tko, što, kada),
  2) po potrebi se odmah promijeni stanje opreme (npr. nakon popravka postavi se `ispravno`, ili ako je kvar pronađen postavi se `neispravno`).

**Zašto je korisno da je ovo procedura:**
- U jednom pozivu napraviš dvije logičke radnje (dnevnik + stanje).
- Smanjuje se mogućnost da netko upiše održavanje, a zaboravi ažurirati stanje (ili obrnuto).
- Omogućuje provjeru da `p_novo_stanje` bude jedna od dozvoljenih vrijednosti.

**Kako se tipično koristi:**
- kad serviser završi posao i želi evidentirati što je napravljeno,
- kad se oprema šalje u servis i želiš promijeniti stanje u `u servisu` uz zapis objašnjenja.

---

### 6.2 Procedura: `sp_izvjestaj_oprema_po_dobavljacu`

```sql
CREATE PROCEDURE sp_izvjestaj_oprema_po_dobavljacu (
    IN p_dobavljac_id INT
)
BEGIN
    SELECT
        o.id AS oprema_id,
        o.naziv AS naziv_opreme,
        o.stanje,
        o.datum_nabave,
        CONCAT(p.oznaka, ' - ', p.lokacija) AS prostorija,
        fn_zadnje_odrzavanje(o.id) AS zadnje_odrzavanje,
        fn_dani_od_zadnjeg_odrzavanja(o.id) AS dana_od_zadnjeg
    FROM oprema o
    JOIN prostorija p ON p.id = o.prostorija_id
    WHERE o.dobavljac_id = p_dobavljac_id
    ORDER BY o.datum_nabave;
END;
```

**Svrha procedure:**
- Vraća detaljan izvještaj za jednog dobavljača.
- Dobiva se popis opreme tog dobavljača zajedno s:
  - trenutnim stanjem,
  - prostorijom gdje se nalazi,
  - zadnjim održavanjem,
  - brojem dana od zadnjeg održavanja.

**Zašto je korisno:**
- kad želiš provjeriti kvalitetu opreme dobavljača,
- kad pripremaš reklamaciju ili servisni upit dobavljaču,
- kad trebaš analizirati starost i servisnu povijest opreme po dobavljaču.

---

### 6.3 Procedura: `sp_azuriraj_opremu`

```sql
CREATE PROCEDURE sp_azuriraj_opremu (
    IN p_oprema_id INT,
    IN p_naziv VARCHAR(150),
    IN p_prostorija_id INT,
    IN p_dobavljac_id INT,
    IN p_stanje VARCHAR(20)
)
BEGIN
    IF p_stanje IS NOT NULL
       AND p_stanje NOT IN ('ispravno','neispravno','u servisu','otpisano') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Neispravno stanje. Dozvoljeno: ispravno, neispravno, u servisu, otpisano.';
    END IF;

    UPDATE oprema
    SET
        naziv = COALESCE(p_naziv, naziv),
        prostorija_id = COALESCE(p_prostorija_id, prostorija_id),
        dobavljac_id = COALESCE(p_dobavljac_id, dobavljac_id),
        stanje = COALESCE(p_stanje, stanje)
    WHERE id = p_oprema_id;
END;
```

**Svrha procedure:**
- Služi za uređivanje (update) podataka o opremi bez potrebe da se uvijek šalju svi podaci.
- `COALESCE` znači: “ako je parametar NULL, ostavi staru vrijednost”.

**Primjeri zašto je korisno:**
- promjena prostorije (oprema je premještena),
- promjena dobavljača (ako je pogrešno uneseno),
- promjena naziva (standardizacija naziva),
- promjena stanja (npr. ručno postavljanje na `otpisano`).

**Prednost u odnosu na obični UPDATE:**
- korisnik/projekt može pozvati proceduru i poslati samo ono što želi promijeniti,
- manja šansa da se slučajno prepiše neki podatak.

---

### 6.4 Procedura: `sp_obrisi_odrzavanje`

```sql
CREATE PROCEDURE sp_obrisi_odrzavanje (
    IN p_odrzavanje_id INT
)
BEGIN
    DELETE FROM odrzavanje
    WHERE id = p_odrzavanje_id;
END;
```

**Svrha procedure:**
- Briše jedan zapis održavanja po ID-u.
- Koristi se oprezno jer brisanje uklanja dio povijesti (audit), ali u projektima se zna koristiti kad je unos bio pogrešan.

**Tipična uporaba:**
- greškom upisan datum ili opis pa se želi ponovno unijeti ispravno,
- duplicirani zapis održavanja.

---

## 7. Zaključak

Ovim modulom dobiven je sustav za praćenje opreme i održavanja s pregledima, view-ovima, funkcijama i procedurama koji pomažu u upravljanju servisima i analizi dobavljača.

Najvažniji doprinos modula:
- operativni uvid u “što je gdje i u kakvom je stanju”,
- servisna povijest (tko/kada/što),
- analitika dobavljača,
- standardizirani izvještaji kroz view-ove i funkcije,
- sigurniji unos kroz procedure.
