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
- **procedura** – kontrolirani unos/izmjene (npr. evidentiraj održavanje, ažuriraj opremu),
- **eventa** – periodične automatizirane provjere (scheduler),
- **transakcija** – grupiranje više promjena u jednu logičku cjelinu (COMMIT/ROLLBACK).

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
- Omogućuje da svaka sprava ima identitet, naziv, lokaciju, dobavljača, datum nabave i stanje.
- `datum_nabave` je bitan kao “rezervni datum” za izračune kad oprema nema niti jedan zapis održavanja.

**Zašto je `stanje` bitno:**
- `ispravno` – normalno stanje (oprema radi i može se koristiti).
- `neispravno` – oprema je pokvarena i ne smije se koristiti.
- `u servisu` – oprema je poslana na servis / čeka servis / u postupku.
- `otpisano` – oprema se više ne koristi (zastarjela, neisplativa za popravak).

**Veze (FK) i njihov smisao:**
- `prostorija_id → prostorija(id)`: osigurava da oprema uvijek ima validnu prostoriju (nema “fantomskih” lokacija).
- `dobavljac_id → dobavljac(id)`: osigurava da se oprema veže uz postojećeg dobavljača i da su statistike po dobavljaču pouzdane.

**Indeksi:**
- Index na `prostorija_id`: ubrzava upite tipa “prikaži svu opremu u prostoriji” i JOIN na `prostorija`.
- Index na `dobavljac_id`: ubrzava upite tipa “prikaži svu opremu dobavljača” i JOIN na `dobavljac`.

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
- Čuva podatke o dobavljačima opreme radi praćenja opreme po dobavljaču, analitike kvalitete isporuke i kontaktiranja u slučaju reklamacije/servisa.

**Zašto `UNIQUE` na `naziv` i `oib`:**
- `oib` sprječava unos iste tvrtke više puta (jedinstveni identifikator).
- `naziv` sprječava dupliciranje dobavljača kroz naziv (npr. isti dobavljač pod istim imenom dva puta).

**CHECK za OIB (format):**
- Provjera `^[0-9]{11}$` osigurava da OIB ima točno 11 znamenki (bez slova i razmaka).

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
- U pregledima i view-ovima prostorija se prikazuje kao `CONCAT(oznaka, ' - ', lokacija)` jer je to najčitljivije za korisnika.

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
- Ovo je “servisni dnevnik” za opremu (povijest intervencija).
- Na temelju ove tablice se računaju broj održavanja, zadnji datum održavanja i “koliko dana bez servisa”.

**Zašto se veže na zaposlenika:**
- Omogućuje odgovornost i provjeru tko je zadnji radio na opremi (korisno kod reklamacija i interne kontrole).

**Indeksi:**
- Index na `oprema_id`: ubrzava dohvat održavanja po opremi i agregacije (COUNT/MAX).
- Index na `zaposlenik_id`: ubrzava upite po zaposleniku (npr. izvještaj tko je koliko održavanja radio).

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
| id_mjesto | INT       | FK → mjesto(id), NOT NULL | Mjesto. |
| telefon | VARCHAR(20) | (može biti NULL)    | Kontakt telefon. |
| email  | VARCHAR(100) | (može biti NULL)    | Email adresa. |
| datum_zaposlenja | DATE | NOT NULL          | Datum zaposlenja. |
| datum_prestanka | DATE | DEFAULT NULL       | Datum prestanka rada (ako postoji). |
| status_zaposlenika | ENUM('aktivan','neaktivan') | NOT NULL | Status zaposlenika. |
| placa  | DECIMAL(10,2) | CHECK (placa >= 0), DEFAULT 0 | Plaća zaposlenika. |
| id_radno_mjesto | INT | FK → radno_mjesto(id), NOT NULL | Radno mjesto. |
| id_podruznica | INT  | FK → podruznica(id), NOT NULL | Podružnica. |

**Svrha tablice:**
- Tablica sadrži podatke o zaposlenicima sustava.
- U ovom modulu se koristi preko veze `odrzavanje.zaposlenik_id` kako bi se znalo tko je evidentirao/izvršio održavanje.
- U problematičnim slučajevima omogućuje brz odgovor na pitanje “tko je zadnji servisirao opremu”.

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
- Glavni pregled koji spaja sve bitno za opremu na jednom mjestu: oprema, dobavljač, prostorija i servisna statistika.
- Koristi se za brzi operativni uvid i određivanje prioriteta servisa (sortirano po “najduže bez servisa”).

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
- Analitika dobavljača: koliko opreme dolazi od kojeg dobavljača i u kakvom je stanju ta oprema.
- Pomaže usporediti dobavljače i uočiti eventualno “problematične” isporuke (puno kvarova ili servisa).

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
- Izdvaja opremu koja je u problematičnom stanju (neispravno/u servisu) i “stoji” predugo bez intervencije.
- Koristi se kao lista prioriteta za rješavanje kvarova ili odluku o otpisu.

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
- “Spremanjeni izvještaj” koji standardizira prikaz opreme s osnovnim servisnim informacijama.
- Koristi se kao baza za jednostavne SELECT upite i filtriranja (npr. samo oprema u servisu).

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
- Sažima osnovnu sliku dobavljača: broj komada opreme i raspon nabava (prva/zadnja isporuka).
- Pogodno za dashboard i brzi pregled dobavljača bez detalja o stanjima.

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
- Daje listu problematične opreme (neispravno/u servisu/otpisano) zajedno s kontekstom: prostorija, dobavljač i zadnji serviser.
- Subquery osigurava da se za svaku opremu uzme točno jedan (najnoviji) zapis održavanja.

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
- Ako oprema nikada nije servisirana, funkcija vraća `NULL`.
- Koristi se kao osnovni “komad logike” u procedurama i upitima.

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
- Računa koliko je dana prošlo od zadnjeg održavanja.
- Ako nema održavanja, računa od datuma nabave.
- Korisno za rangiranje opreme po prioritetu servisa ili za upozorenja (npr. > 365 dana).

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
- Kontrolirani unos održavanja (zapis u dnevnik) i opcionalna promjena stanja opreme u istom pozivu.
- Smanjuje šansu da se napravi samo jedna polovica posla (npr. upiše održavanje, ali se ne promijeni stanje).

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
- Vraća detaljan izvještaj za jednog dobavljača: popis opreme, lokacija, stanje i servisne informacije.
- Koristi se za analizu dobavljača i pripremu reklamacija ili nabave.

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
- Ažurira podatke o opremi bez obaveze slanja svih vrijednosti (NULL znači “ne mijenjaj”).
- Korisno za premještaj opreme, ispravke dobavljača ili ručno ažuriranje statusa.

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
- Koristi se kad je zapis pogrešno unesen ili dupliciran (oprezno jer briše dio povijesti).

---

## 7. Events

Eventi u MySQL-u služe kao rasporednik (scheduler) koji automatski pokreće određene SQL radnje u zadanim intervalima. U ovom modulu eventi se koriste za periodične provjere opreme i automatizirano označavanje problema.

### 7.1 EVENT: `ev_oprema_predugo_u_servisu`

```sql
CREATE EVENT IF NOT EXISTS ev_oprema_predugo_u_servisu
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY)
DO
BEGIN
    UPDATE oprema o
    LEFT JOIN (
        SELECT oprema_id, MAX(datum) AS zadnje_odrzavanje
        FROM odrzavanje
        GROUP BY oprema_id
    ) od ON od.oprema_id = o.id
    SET o.stanje = 'neispravno'
    WHERE o.stanje = 'u servisu'
      AND DATEDIFF(
            CURDATE(),
            COALESCE(od.zadnje_odrzavanje, o.datum_nabave)
          ) > 180;
END;
```

**Svrha eventa:**
- Svaki dan provjerava opremu koja je u stanju `u servisu`.
- Ako je oprema bez održavanja duže od 180 dana, automatski se prebacuje na `neispravno`.
- Ako oprema nema održavanja, kao referenca se koristi `datum_nabave`.

---

### 7.2 EVENT: `ev_oprema_stara_bez_servisa`

```sql
CREATE EVENT IF NOT EXISTS ev_oprema_stara_bez_servisa
ON SCHEDULE EVERY 1 WEEK
STARTS (CURRENT_DATE + INTERVAL 7 DAY)
DO
BEGIN
    SELECT
        o.id AS oprema_id,
        o.naziv,
        o.stanje,
        DATEDIFF(
            CURDATE(),
            COALESCE(
                (SELECT MAX(od.datum)
                 FROM odrzavanje od
                 WHERE od.oprema_id = o.id),
                o.datum_nabave
            )
        ) AS dana_bez_servisa
    FROM oprema o
    WHERE o.stanje = 'ispravno'
    HAVING dana_bez_servisa > 365
    ORDER BY dana_bez_servisa DESC;
END;
```

**Svrha eventa:**
- Jednom tjedno pronalazi opremu koja je `ispravno`, ali nije servisirana duže od 365 dana.
- Event ne mijenja podatke, nego služi kao periodična provjera (lista za preventivni servis).

---

## 8. Transakcije

Transakcije služe za grupiranje više SQL naredbi u jednu logičku cjelinu. Ako se radi više promjena odjednom, transakcija sprječava da baza ostane u “polovičnom” stanju (npr. upisano održavanje, ali stanje opreme nije promijenjeno).

### 8.1 Transakcija: Evidentiranje održavanja + promjena stanja opreme

```sql
START TRANSACTION;

INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
VALUES (2, 5, CURDATE(), 'Unos održavanja kroz transakciju + promjena stanja.');

UPDATE oprema
SET stanje = 'ispravno'
WHERE id = 2;

COMMIT;
```

**Svrha transakcije:**
- Održavanje i promjena stanja se izvrše zajedno (ili se sve poništi).
- Korisno kad serviser završi posao i odmah vraća opremu u upotrebu.

---

### 8.2 Transakcija: Premještaj opreme u drugu prostoriju + zapis održavanja

```sql
START TRANSACTION;

UPDATE oprema
SET prostorija_id = 1
WHERE id = 3;

INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
VALUES (3, 4, CURDATE(), 'Premještaj opreme nakon pregleda/servisa.');

COMMIT;
```

**Svrha transakcije:**
- Premještaj opreme i servisni zapis ostaju povezani kao jedan događaj.
- Korisno kod reorganizacije teretane ili povrata opreme iz servisa u novu lokaciju.

---

### 8.3 Transakcija: Primjer ROLLBACK-a (simulacija greške)

```sql
START TRANSACTION;

UPDATE oprema
SET stanje = 'u servisu'
WHERE id = 6;

INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
VALUES (6, 5, CURDATE(), 'Zapis koji se neće spremiti jer radimo rollback.');

ROLLBACK;
```

**Svrha transakcije:**
- Pokazuje kako poništiti sve promjene ako se tijekom unosa primijeti greška ili se odustane od postupka.

---

## 9. Zaključak

Ovim modulom dobiven je sustav za praćenje opreme i održavanja koji pokriva:
- operativni uvid u opremu (što je gdje i u kakvom je stanju),
- servisnu povijest (tko/kada/što),
- analitiku dobavljača,
- standardizirane izvještaje kroz view-ove,
- ponovljive izračune kroz funkcije,
- kontrolirane izmjene kroz procedure,
- periodične provjere kroz evente,
- sigurnije izvođenje složenijih promjena kroz transakcije.

Kombinacija ovih objekata čini modul upotrebljivim i za administrativni dio (menadžment i analitika) i za operativni dio (serviseri i osoblje teretane).
