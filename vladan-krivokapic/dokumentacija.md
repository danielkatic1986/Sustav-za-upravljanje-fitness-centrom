# Dokumentacija – Modul opreme i održavanja

## 1. Opis modula

Modul opreme i održavanja služi za evidenciju i praćenje opreme unutar sustava. Omogućuje praćenje osnovnih podataka o opremi, njezina stanja, lokacije (prostorije), dobavljača te povijesti održavanja. Kroz modul se dobivaju operativni uvidi (npr. koja oprema najdulje nije servisirana), statistike po dobavljačima te informacije o zadnjim servisnim intervencijama i serviserima.

Modul je realiziran pomoću:
- pregleda (SELECT upita) za analitiku,
- pogleda (VIEW) kao standardiziranih izvještaja,
- funkcija za ponovljive izračune,
- procedura za kontrolirane poslovne radnje,
- triggera za automatizaciju i kontrolu unosa.

---

## 2. Opis tablica

U nastavku su tablice koje se koriste u ovom modulu.

### 2.1 Tablica: `oprema`

| Atribut       | Tip podataka                                        | Ključ / ograničenje                         | Opis |
|--------------|------------------------------------------------------|----------------------------------------------|------|
| id           | INT                                                  | PK                                           | Jedinstveni identifikator opreme. |
| naziv        | VARCHAR(…)                                           | NOT NULL                                     | Naziv opreme (sprava/uređaj). |
| stanje       | ENUM('ispravno','neispravno','u servisu','otpisano')  | NOT NULL                                     | Trenutno stanje opreme. |
| datum_nabave | DATE                                                 | NOT NULL                                     | Datum nabave opreme. |
| dobavljac_id | INT                                                  | FK → dobavljac(id), NOT NULL                 | Referenca na dobavljača opreme. |
| prostorija_id| INT                                                  | FK → prostorija(id), NOT NULL                | Referenca na prostoriju gdje se oprema nalazi. |

**Opis tablice:**  
Tablica predstavlja centralnu tablicu modula. Svaki zapis je jedan komad opreme. Atribut `stanje` koristi se u izvještajima i filtriranju (npr. neispravna oprema), dok se `datum_nabave` koristi kao referentni datum kada održavanje ne postoji. Veze na `dobavljac` i `prostorija` omogućuju kontekst (od koga je nabavljeno i gdje se nalazi).

---

### 2.2 Tablica: `dobavljac`

| Atribut | Tip podataka | Ključ / ograničenje | Opis |
|--------|--------------|---------------------|------|
| id     | INT          | PK                  | Jedinstveni identifikator dobavljača. |
| naziv  | VARCHAR(…)   | NOT NULL            | Naziv dobavljača. |

**Opis tablice:**  
Tablica sadrži popis dobavljača. Koristi se za statistike i izvještaje (količina opreme, raspodjela stanja, raspon nabava). Na tablicu se veže `oprema.dobavljac_id`.

---

### 2.3 Tablica: `prostorija`

| Atribut | Tip podataka | Ključ / ograničenje | Opis |
|--------|--------------|---------------------|------|
| id     | INT          | PK                  | Jedinstveni identifikator prostorije. |
| naziv  | VARCHAR(…)   | NOT NULL            | Naziv prostorije. |

**Opis tablice:**  
Tablica sadrži prostorije u kojima se oprema nalazi/koristi. U ovom modulu prostorija se koristi kao lokacija opreme i kao dio izvještaja. Na tablicu se veže `oprema.prostorija_id`.

---

### 2.4 Tablica: `odrzavanje`

| Atribut        | Tip podataka | Ključ / ograničenje                | Opis |
|---------------|--------------|------------------------------------|------|
| id            | INT          | PK                                 | Jedinstveni identifikator zapisa održavanja. |
| oprema_id     | INT          | FK → oprema(id), NOT NULL          | Oprema na koju se održavanje odnosi. |
| zaposlenik_id | INT          | FK → zaposlenik(id), NOT NULL      | Zaposlenik koji je izvršio održavanje. |
| datum         | DATE         | NOT NULL                            | Datum održavanja. |
| opis          | VARCHAR(300) | NOT NULL                            | Opis intervencije/servisa. |

**Opis tablice:**  
Tablica predstavlja dnevnik održavanja (povijest intervencija). Na temelju ove tablice računaju se broj održavanja i zadnje održavanje, te se u izvještajima prikazuje zadnji serviser. Triggeri nad ovom tablicom osiguravaju konzistentnost datuma i automatizaciju promjena stanja opreme.

---

### 2.5 Tablica: `zaposlenik`

| Atribut | Tip podataka | Ključ / ograničenje | Opis |
|--------|--------------|---------------------|------|
| id     | INT          | PK                  | Jedinstveni identifikator zaposlenika. |
| ime    | VARCHAR(…)   | NOT NULL            | Ime zaposlenika. |
| prezime| VARCHAR(…)   | NOT NULL            | Prezime zaposlenika. |

**Opis tablice:**  
Tablica sadrži osnovne podatke o zaposlenicima. U ovom modulu se koristi za dohvat imena i prezimena zadnjeg servisera kroz vezu `odrzavanje.zaposlenik_id`.

---

## 3. Pregledi (SELECT upiti)

### 3.1 Pregled sve opreme s dobavljačem, prostorijom, brojem održavanja i zadnjim održavanjem

```sql
SELECT 
    o.id AS oprema_id,
    o.naziv AS naziv_opreme,
    o.stanje,
    d.naziv AS dobavljac,
    p.naziv AS prostorija,
    COUNT(od.id) AS broj_odrzavanja,
    MAX(od.datum) AS zadnje_odrzavanje,
    DATEDIFF(CURDATE(), COALESCE(MAX(od.datum), o.datum_nabave)) AS dana_od_zadnjeg_odrzavanja
FROM oprema o
JOIN dobavljac d ON o.dobavljac_id = d.id
JOIN prostorija p ON o.prostorija_id = p.id
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
GROUP BY 
    o.id, o.naziv, o.stanje, d.naziv, p.naziv, o.datum_nabave
ORDER BY dana_od_zadnjeg_odrzavanja DESC;
```

**Svrha upita:**  
Upit služi za pregled sve opreme zajedno s lokacijom i dobavljačem, uz informaciju koliko puta je oprema servisirana i kada je zadnji put održavana. Koristan je za planiranje servisa i prioritetno rješavanje opreme koja najduže nije održavana.

**Opis upita:**  
Najprije se tablica `oprema` povezuje s tablicama `dobavljac` i `prostorija` koristeći `JOIN` kako bi se dobili čitljivi nazivi dobavljača i prostorije. Zatim se koristi `LEFT JOIN` nad tablicom `odrzavanje` da bi se uključila i oprema bez održavanja. Grupiranjem po opremi računaju se `COUNT(od.id)` kao broj održavanja i `MAX(od.datum)` kao zadnje održavanje. Broj dana od zadnjeg održavanja dobiva se funkcijom `DATEDIFF`, pri čemu `COALESCE` osigurava računanje od `datum_nabave` ako održavanje ne postoji. Rezultat se sortira silazno po broju dana bez održavanja.

---

### 3.2 Statistika po dobavljačima (količina i raspodjela po stanjima)

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
Upit služi za statistički uvid u opremu po dobavljačima. Može pomoći pri procjeni kvalitete dobavljača te donošenju odluka o budućim nabavama.

**Opis upita:**  
Upit kreće iz tablice `dobavljac` i `LEFT JOIN`-om uključuje opremu (tako da se prikažu i dobavljači bez opreme). Grupiranjem po dobavljaču računa se ukupan broj opreme `COUNT(o.id)`. Raspodjela po stanjima dobiva se pomoću `SUM(o.stanje = '...')`. Raspon nabave dobiva se pomoću `MIN` i `MAX` nad `datum_nabave`. Rezultat se sortira po ukupnoj količini opreme.

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
Upit služi za pronalazak opreme koja je neispravna ili u servisu te je dugo bez intervencije. Koristan je za listu “kritične opreme” i donošenje odluke o popravku ili otpisu.

**Opis upita:**  
Nakon filtriranja opreme po stanjima `neispravno` i `u servisu`, upit preko `LEFT JOIN` dohvaća održavanja. Grupiranjem se pronalazi zadnje održavanje `MAX(od.datum)`, a ako ne postoji koristi se `datum_nabave`. Funkcija `DATEDIFF` računa dane bez servisa, a `HAVING` filtrira samo one iznad 180 dana. Rezultat se sortira silazno po danima bez servisa.

---

## 4. Pogledi (VIEW)

### 4.1 VIEW: v_oprema_zadnje_odrzavanje

```sql
CREATE OR REPLACE VIEW v_oprema_zadnje_odrzavanje AS
SELECT 
    o.id AS oprema_id,
    o.naziv AS naziv_opreme,
    o.stanje,
    o.datum_nabave,
    d.naziv AS dobavljac,
    p.naziv AS prostorija,
    COUNT(od.id) AS broj_odrzavanja,
    MAX(od.datum) AS zadnje_odrzavanje
FROM oprema o
JOIN dobavljac d ON o.dobavljac_id = d.id
JOIN prostorija p ON o.prostorija_id = p.id
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
GROUP BY 
    o.id, o.naziv, o.stanje, o.datum_nabave, d.naziv, p.naziv;
```

**Svrha pogleda:**  
Pogled služi kao standardizirani izvor podataka o opremi s brojem i datumom zadnjeg održavanja, kako bi se isti podatci mogli lako koristiti u više izvještaja ili upita.

**Opis pogleda:**  
Pogled spaja `oprema` s `dobavljac` i `prostorija` radi čitljivih naziva, a `LEFT JOIN` na `odrzavanje` omogućuje uključivanje opreme bez održavanja. Grupiranjem se dobivaju `COUNT` kao broj održavanja i `MAX` kao datum zadnjeg održavanja.

---

### 4.2 VIEW: v_dobavljac_statistika

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

**Svrha pogleda:**  
Pogled daje sažetu statistiku opreme po dobavljaču i koristi se kada je potreban brz uvid u broj komada i raspon isporuka.

**Opis pogleda:**  
Kreće se iz tablice `dobavljac`, te se `LEFT JOIN`-om veže `oprema`. Grupiranjem po dobavljaču računaju se broj komada te prvi i zadnji datum nabave.

---

### 4.3 VIEW: v_neispravna_oprema

```sql
CREATE OR REPLACE VIEW v_neispravna_oprema AS
SELECT 
    o.id AS oprema_id,
    o.naziv,
    o.stanje,
    p.naziv AS prostorija,
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

**Svrha pogleda:**  
Pogled služi za operativni pregled problematične opreme i informacije o zadnjem održavanju i zadnjem serviseru.

**Opis pogleda:**  
Pogled filtrira opremu na stanja koja nisu normalna. Zadnje održavanje se dohvaća preko podupita koji bira najnoviji zapis održavanja po opremi (`ORDER BY datum DESC, id DESC LIMIT 1`), a zatim se preko `zaposlenik_id` dohvaćaju ime i prezime servisera.

---

## 5. Funkcije

### 5.1 Funkcija: fn_zadnje_odrzavanje(oprema_id)

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
Funkcija vraća datum zadnjeg održavanja određene opreme te se koristi u izvještajima i procedurama.

**Opis funkcije:**  
Funkcija prima `p_oprema_id` te pronalazi najveći datum održavanja u tablici `odrzavanje` za tu opremu. Ako nema održavanja, vraća `NULL`.

---

### 5.2 Funkcija: fn_dani_od_zadnjeg_odrzavanja(oprema_id)

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

    SET v_rezultat = DATEDIFF(
        CURDATE(),
        COALESCE(v_zadnje, v_nabava)
    );

    RETURN v_rezultat;
END;
```

**Svrha funkcije:**  
Funkcija računa koliko dana je prošlo od zadnjeg održavanja, a ako održavanja nema, od nabave opreme.

**Opis funkcije:**  
Najprije dohvaća datum nabave iz tablice `oprema`, zatim poziva funkciju `fn_zadnje_odrzavanje`. Referentni datum za računanje dana određuje se pomoću `COALESCE`, a rezultat se računa `DATEDIFF`-om.

---

## 6. Procedure

### 6.1 Procedura: sp_evidentiraj_odrzavanje

```sql
CREATE PROCEDURE sp_evidentiraj_odrzavanje (
    IN p_oprema_id INT,
    IN p_zaposlenik_id INT,
    IN p_opis VARCHAR(300),
    IN p_novo_stanje ENUM('ispravno','neispravno','u servisu','otpisano')
)
BEGIN
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
Procedura omogućuje kontrolirani unos održavanja i opcionalnu promjenu stanja opreme u istom pozivu.

**Opis procedure:**  
Prvo se dodaje zapis u `odrzavanje` s današnjim datumom, a zatim se (ako je parametar poslan) ažurira stanje opreme.

---

### 6.2 Procedura: sp_izvjestaj_oprema_po_dobavljacu

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
        p.naziv AS prostorija,
        fn_zadnje_odrzavanje(o.id) AS zadnje_odrzavanje,
        fn_dani_od_zadnjeg_odrzavanja(o.id) AS dana_od_zadnjeg
    FROM oprema o
    JOIN prostorija p ON p.id = o.prostorija_id
    WHERE o.dobavljac_id = p_dobavljac_id
    ORDER BY o.datum_nabave;
END;
```

**Svrha procedure:**  
Procedura vraća detaljan popis opreme za jednog dobavljača s podacima o održavanju.

**Opis procedure:**  
Filtrira opremu po dobavljaču, spaja s prostorijama, te koristi funkcije za dohvat zadnjeg održavanja i dana od zadnjeg.

---

### 6.3 Procedura: `sp_azuriraj_opremu`

```sql
DELIMITER //

CREATE PROCEDURE sp_azuriraj_opremu (
    IN p_oprema_id INT,
    IN p_naziv VARCHAR(150),
    IN p_prostorija_id INT,
    IN p_dobavljac_id INT,
    IN p_stanje ENUM('ispravno','neispravno','u servisu','otpisano')
)
BEGIN
    UPDATE oprema
    SET
        naziv = COALESCE(p_naziv, naziv),
        prostorija_id = COALESCE(p_prostorija_id, prostorija_id),
        dobavljac_id = COALESCE(p_dobavljac_id, dobavljac_id),
        stanje = COALESCE(p_stanje, stanje)
    WHERE id = p_oprema_id;
END;
//

DELIMITER ;
```

**Svrha procedure:**  
Procedura služi za izmjenu postojećih podataka o opremi u sustavu. Omogućuje ažuriranje naziva opreme, promjenu prostorije u kojoj se oprema nalazi, promjenu dobavljača te ažuriranje stanja opreme. Namijenjena je administrativnim ispravcima podataka, premještanju opreme između prostorija te promjenama stanja opreme nakon servisa, kvara ili otpisa.

**Opis procedure:**  
Procedura prima identifikator opreme (`p_oprema_id`) i parametre koji predstavljaju nove vrijednosti atributa opreme. Parametri za izmjenu su opcionalni, što znači da se za atribute koji se ne žele mijenjati može proslijediti vrijednost `NULL`.  
Unutar `UPDATE` naredbe koristi se funkcija `COALESCE` kako bi se zadržala postojeća vrijednost atributa u slučaju da nije proslijeđena nova vrijednost. Na ovaj način jedna procedura omogućuje fleksibilnu izmjenu više atributa opreme u jednom pozivu, bez potrebe za pisanjem više zasebnih `UPDATE` upita.

---



## 7. Triggeri

### 7.1 Trigger: trg_odrzavanje_bi_datum_kontrola

```sql
CREATE TRIGGER trg_odrzavanje_bi_datum_kontrola
BEFORE INSERT ON odrzavanje
FOR EACH ROW
BEGIN
    DECLARE v_nabava DATE;

    SELECT datum_nabave
    INTO v_nabava
    FROM oprema
    WHERE id = NEW.oprema_id;

    IF NEW.datum < v_nabava THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Datum odrzavanja ne smije biti prije datuma nabave opreme.';
    END IF;
END;
```

**Svrha triggera:**  
Onemogućuje unos održavanja s datumom prije datuma nabave opreme.

**Opis triggera:**  
Trigger se aktivira prije INSERT-a, dohvaća datum nabave i uspoređuje ga s `NEW.datum`. Ako je datum održavanja nelogičan, baca grešku.

---

### 7.2 Trigger: trg_odrzavanje_ai_auto_ispravno

```sql
CREATE TRIGGER trg_odrzavanje_ai_auto_ispravno
AFTER INSERT ON odrzavanje
FOR EACH ROW
BEGIN
    IF NEW.opis LIKE '%popravak%' 
       OR NEW.opis LIKE '%zamjena%' 
       OR NEW.opis LIKE '%servis%' THEN
        UPDATE oprema
        SET stanje = 'ispravno'
        WHERE id = NEW.oprema_id
          AND stanje IN ('neispravno', 'u servisu');
    END IF;
END;
```

**Svrha triggera:**  
Automatski postavlja opremu na stanje `ispravno` ako opis održavanja upućuje na popravak/servis.

**Opis triggera:**  
Nakon INSERT-a provjerava `NEW.opis` i, ako nađe ključne riječi, ažurira stanje opreme, ali samo ako je stanje bilo `neispravno` ili `u servisu`.

---

## 8. Zaključak

Ovim modulom dobiven je pregledan sustav za praćenje opreme i održavanja, s automatizacijom i kontrolama koje smanjuju mogućnost pogrešaka te olakšavaju servisne i upravljačke procese.
