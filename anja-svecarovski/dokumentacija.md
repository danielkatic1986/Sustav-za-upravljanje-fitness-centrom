# VEZE ENTITETA PREMA ER DIJAGRAMU

| Veza | Vrsta | Objašnjenje |
|------|-------|-------------|
| trener — trener_program | 1:N | Jedan trener može voditi više programa. |
| trener_program — program (Maja) | N:1 | Program ima jednog odgovornog trenera. |
| zaposlenik — odrzavanje (Vladan) | 1:N | Zaposlenik (npr. tehničar) može obaviti više održavanja. |
| trener — raspored (Mikel) | 1:N | Trener ima više termina u rasporedu. |
| zaposlenik - radno_mjesto | 1:N | Jedno radno mjesto može imati više zaposlenika, ali svaki zaposlenik pripada samo jednom radnom mjestu.|
| odjel - radno_mjesto | 1:N | Jedan odjel može imati više radnih mjesta, ali svako radno mjesto pripada samo jednom odjelu.|
| podruznica - zaposlenik | 1:N | Jedna podružnica može imati više zaposlenih, ali svaki zaposlenik pripada samo jednoj podruznici.|
| mjesto - podružnica| 1:N | Jedno mjesto može imati više podružnica, ali svaka podružnica pripada samo jednom mjestu.|
| mjesto - zaposlenik| 1:N | Jedno mjesto može imati više podružnica, ali svaka podružnica pripada samo jednom mjestu.|

# SHEME RELACIJSKOG MODELA

- odjel (id, naziv, aktivno, opis, broj_zaposlenika)
- radno_mjesto (id, naziv, aktivno, opis, id_odjel)
- podruznica (id, naziv, adresa, id_mjesto)
- zaposlenik (id, ime, prezime, oib, datum_rodenja, spol, adresa, id_mjesto, telefon, email, datum_zaposlenja, datum_prestanka, status_zaposlenika, placa, id_radno_mjesto, id_podruznica)
- trener_program (id, trener_id, program_id)

# EER DIJAGRAM (MySQL Workbench)

# SQL TABLICE

## Tablica odjel

### Svrha
Tablica odjel koristi se za evidenciju različitih odjela unutar fitness centra. Odjeli predstavljaju
funkcionalne jedinice, poput fitness, wellness, odrzavanje, administracija, recepcija, marketing, prodaja, uprava, racunovodstvo i omogućuju organizaciji da prati broj zaposlenika i upravlja njihovim resursima.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog odjela. Automatski se generira i koristi za razlikovanje odjela |
| `naziv` | VARCHAR(50) | NOT NULL UNIQUE | | Naziv odjela, obvezno polje jer omogućuje identifikaciju odjela. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Zbog ograničenja UNIQUE znači da ne mogu postojati dva odjela s istim nazivom. |
| `aktivno` | BOOLEAN | DEFAULT TRUE | | Označava je li odjel trenutno aktivan, zadana vrijednost je True |
| `opis` | TEXT  | | | Do 65.535 znakova za opis pojednih odjela, unos opisa nije obavezan i ne očekuje se da bude jedinstven. |
| `broj_zaposlenika` | INT | CHECK (broj_zaposlenika >= 0) DEFAULT 0 | | Broj zaposlenika unutar odjela. Ovo polje ima zadanu vrijednost 0 i mora biti nenegativno. Koristi se za praćenje ljudskih resursa u odjelu. |

## Tablica radno_mjesto

### Svrha
Predstavlja različita radna mjesta unutar svakog odjela fitness centra, poput 'trener', 'tehničar', 'recepcioner', 'administracija'.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog radnog mjesta. Automatski se generira i koristi za razlikovanje radnog mjesta. |
| `naziv` | VARCHAR(50) | NOT NULL UNIQUE | | Naziv radnog mjesta, obvezno polje jer omogućuje identifikaciju radnog mjesta. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Zbog ograničenja UNIQUE znači da ne mogu postojati dva radna mjesta s istim nazivom. |
| `aktivno` | BOOLEAN | DEFAULT TRUE | | Označava je li radno mjesto trenutno aktivno, zadana vrijednost je True |
| `opis` | TEXT  | | | Do 65.535 znakova za opis pojednih radnih mjesta, unos opisa nije obavezan i ne očekuje se da bude jedinstven. |
| `id_odjel` | INT | NOT NULL | FOREIGN KEY REFERENCES odjel(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obvezno polje. |

## Tablica poslovnica

### Svrha
Normalizacija bazu, tako da se adrese i lokacije fitness centara ne dupliciraju po članovima ili zaposlenicima, već da postoje posebne tablice za podružnice i mjesta.
Više podružnica može biti u istom gradu – zato je veza na mjesto korisna, jer grad, poštanski broj i država ne moraju biti duplicirani.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog odjela. Automatski se generira i koristi za razlikovanje odjela |
| `naziv` | VARCHAR(100) | NOT NULL | | Naziv podružnice, obvezno polje jer omogućuje identifikaciju odjela. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `adresa` | VARCHAR(100) | NOT NULL | | Adresa podružnice, obvezno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `id_mjesto` | INT | NOT NULL | FOREIGN KEY REFERENCES mjesto(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obvezno polje. |

## Tablica zaposlenik

### Svrha
Tablica zaposlenik pohranjuje podatke o zaposlenicima fitness centra. Svaki zaposlenik je povezan s određenim radnim mjestom i odjelom, a podaci poput datuma zaposlenja i statusa omogućuju praćenje radne snage.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog radnog mjesta. Automatski se generira i koristi za razlikovanje radnog mjesta. |
| `ime` | VARCHAR(50) | NOT NULL | | Ime zaposlenika, obvezno polje za identifikaciju. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `prezime` | VARCHAR(50) | NOT NULL | | Prezime zaposlenika, obvezno polje za identifikaciju. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `oib` | CHAR(13) | NOT NULL UNIQUE | | OIB zaposlenika, obvezno polje za identifikaciju. Zbog ograničenja UNIQUE znači da ne mogu postojati dva zaposlenika s istim OIBom. |
| `datum_rodenja` | DATE | | | Datum rođenja, opcionalno polje.|
| `spol` | ENUM('M', 'Ž', 'Drugo') | | | Spol zaposlenika, opcionalno polje, unaprijed definirane opcije. |
| `adresa` | VARCHAR(100) | NULL | | Adresa zaposlenika, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `id_mjesto` | INT | NOT NULL | FOREIGN KEY REFERENCES mjesto(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obvezno polje. |
| `telefon` | VARCHAR(20) | NULL | | Kontakt broj zaposlenika, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `email` | VARCHAR(100) | NULL | | Email adresa zaposlenika za komunikaciju unutar organizacije, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `datum_zaposlenja` | DATE | NOT NULL | DEFAULT NOW()| Datum kada je zaposlenik počeo raditi. Ovo je obvezno polje za praćenje radnog staža. Ukoliko nije definirano, postavlja se datum kada je uneseno.|
| `datum_prestanka` | DATE | | DEFAULT NULL| Datum kada je zaposlenik prestao raditi. Ukoliko nije definirano, postavlja se vrijednost NULL.|
| `status_zaposlenika` | ENUM('aktivan', 'neaktivan') | NOT NULL | | Status zaposlenika koji pokazuje je li zaposlenik trenutno aktivan ili neaktivan. |
| `placa` | DECIMAL(10,2) | DEFAULT 0 CHECK (placa >= 0) | | Plaća zaposlenika, zadana vrijednost je 0. Pri unosu ili updateu provjerava se da je plaća nenegativna.|
| `id_radno_mjesto` | INT | NOT NULL | FOREIGN KEY REFERENCES radno_mjesto(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obvezno polje. |
| `id_podruznica` | INT | NOT NULL | FOREIGN KEY REFERENCES podruznica(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obvezno polje. |

## Tablica trener_program

### Svrha
Više trenera može biti vezano uz jedan program, ali svaki zapis u trener_program tablici odnosi se na točno jedan program.
Drugim riječima — jedan program ima jednog glavnog trenera, ali trener može voditi više programa.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator, automatski se generira. |
| `id_trener` | INT | NOT NULL | FOREIGN KEY REFERENCES zaposlenik(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obvezno polje. |
| `id_program` | INT | NOT NULL | FOREIGN KEY REFERENCES program(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obvezno polje. |

# SLOŽENI UPITI

## Broj zaposlenika po odjelu

``` sql
SELECT o.naziv AS odjel, o.aktivno, COUNT(z.id) AS broj_zaposlenika
    FROM odjel o
    LEFT JOIN radno_mjesto rm ON rm.id_odjel = o.id
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY o.id
    ORDER BY broj_zaposlenika DESC;
```
Svrha/info: Ovaj upit daje pregled broja zaposlenika u svakom odjelu, uz informaciju je li odjel aktivan. Koristi se za analizu strukture organizacije i raspodjele radne snage.

Referentne tablice: `odjel`, `radno_mjesto`, `zaposlenik`

Objašnjenje: Upit koristi LEFT JOIN kako bi prikazao sve odjele, uključujući i one koji možda trenutno nemaju zaposlenike. Preko veze odjel → radno mjesto → zaposlenik broji se ukupan broj zaposlenika po odjelu. Rezultat se sortira silazno prema broju zaposlenika.

## Broj zaposlenika po radnom mjestu

``` sql
SELECT rm.naziv AS radno_mjesto, COUNT(z.id) AS broj_zaposlenika
    FROM radno_mjesto rm
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY rm.id
    ORDER BY broj_zaposlenika DESC;
```
Svrha/info: Upit prikazuje koliko zaposlenika radi na svakom radnom mjestu. Koristan je za praćenje popunjenosti pozicija i detekciju eventualnih radnih mjesta bez zaposlenika.

Referentne tablice: `radno_mjesto`, `zaposlenik`

Objašnjenje: LEFT JOIN osigurava da se prikažu i radna mjesta bez zaposlenika. COUNT(z.id) izračunava broj zaposlenika vezanih za svako radno mjesto. Rezultat se grupira po ID-u radnog mjesta i sortira prema broju zaposlenika.

## Zaposlenici kojima ugovor uskoro istječe (30 dana)

``` sql
SELECT z.ime, z.prezime, z.datum_prestanka, DATEDIFF(z.datum_prestanka, CURDATE()) AS dana_do_isteka
    FROM zaposlenik z
    WHERE z.datum_prestanka IS NOT NULL
    AND DATEDIFF(z.datum_prestanka, CURDATE()) BETWEEN 0 AND 30
    ORDER BY z.datum_prestanka;

```
Svrha/info: Upit identificira zaposlenike kojima datum prestanka radnog odnosa dolazi u sljedećih 30 dana. Koristi se za planiranje ljudskih resursa i pravodobno reagiranje na isteke ugovora.

Referentne tablice: `zaposlenik`

Objašnjenje: Filtriraju se zaposlenici čiji datum prestanka nije NULL. Funkcija DATEDIFF izračunava broj dana do isteka ugovora, a rezultat uključuje samo one između 0 i 30 dana. Podaci se sortiraju po datumu prestanka radi preglednosti.

## Prosječna dob zaposlenika po odjelu

``` sql
SELECT o.naziv AS odjel, ROUND(AVG(TIMESTAMPDIFF(YEAR, z.datum_rodenja, CURDATE())), 1) AS prosjecna_dob
    FROM odjel o
    LEFT JOIN radno_mjesto rm ON rm.id_odjel = o.id
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY o.id;

```
Svrha/info: Upit izračunava prosječnu dob zaposlenika u svakom odjelu. Koristi se za analizu dobne strukture, planiranje sukcesije i razumijevanje demografskih obrazaca.

Referentne tablice: `odjel`, r`adno_mjesto`, `zaposlenik`

Objašnjenje: Upit računa dob svakog zaposlenika pomoću TIMESTAMPDIFF(YEAR, datum_rodenja, CURDATE()) i zatim izračunava prosjek za svaki odjel. Korišten je LEFT JOIN kako bi se prikazali i odjeli bez zaposlenika (gdje će prosjek biti NULL). Rezultat je zaokružen na jednu decimalu.

# POGLEDI

## Aktivni zaposlenici koji rade kao treneri

``` sql
CREATE VIEW view_zaposlenici_treneri AS
	SELECT z.id, z.ime, z.prezime, rm.naziv AS 'Radno mjesto', p.naziv AS 'Podruznica'
    FROM zaposlenik z
		INNER JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
        INNER JOIN podruznica p ON z.id_podruznica = p.id
    WHERE status_zaposlenika = 'aktivan'
    AND z.id_radno_mjesto = 1;
```

Pogled naziv: `view_zaposlenici_treneri`

Svrha/info: prikaz informacija o zaposlenicima koji su trenutno zaposleni kao treneri

Referentne tablice: `zaposlenik`, `radno_mjesto`, `podruznica`

Objašnjenje:
- Ovaj je pogled osmišljen za prikaz informacija o zaposlenicima koji trenutno rade kao treneri.
- Funkcionalnost ovog pogleda temelji se na povezivanju podataka iz tablica zaposlenik i radno_mjesto, kako bi se osigurali podaci o zaposlenicima koji imaju radno mjesto trener.
- Povezivanje se vrši preko atributa radno_mjesto_id, čime se omogućava precizno filtriranje zaposlenika prema njihovom pripadništvu određenom ranom mjestu.
- Uvjet postavljen u WHERE klauzuli osigurava da se u pogledu prikazuju isključivo zaposlenici čiji je status označen kao aktivan i koji pripadaju radnom mjestu trenera.
- Korištenjem ovog pogleda izbjegava se potreba za ručnim povezivanjem i filtriranjem podataka iz više tablica, čime se štedi vrijeme i osigurava tačnost u analizi.

## Podaci o zaposlenicima s radnim mjestom, odjelom i statusom

``` sql
CREATE VIEW view_zaposlenici_radno_mjesto_odjel AS
	SELECT z.id, z.ime, z.prezime, z.oib, z.datum_rodenja, z.spol, z.datum_zaposlenja, z.datum_prestanka, z.status_zaposlenika, z.placa, rm.naziv AS 'Radno mjesto', o.naziv AS 'Odjel', p.naziv AS 'Podruznica'
    FROM zaposlenik z
		INNER JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
        INNER JOIN podruznica p ON z.id_podruznica = p.id
        INNER JOIN odjel o ON rm.id_odjel = o.id;
```

Pogled naziv: `view_zaposlenici_radno_mjesto_odjel`

Svrha/info: prikaz informacija o zaposlenicima zajedno s podacima o njihovom odjelu i statusu zaposlenja

Referentne tablice: `zaposlenik`, `radno_mjesto`, `odjel`

Objašnjenje:
- Ovaj pogled omogućava detaljan uvid u zaposlenike, njihov status zaposlenja i pripadnost određenim radnim mjestima i odjelima, te je korisno za analizu ljudskih resursa, praćenje organizacijske strukture i podršku upravljanju timovima.
- Funkcionalnost ovog pogleda temelji se na povezivanju podataka iz tablica zaposlenik, radno mjesto i odjel, kako bi se osigurali detalji o zaposlenicima, uključujući njihove osobne podatke, datum zaposlenja, status, naziv radnog mjesta te naziv odjela u kojem rade.
- Povezivanje s tablicom odjel vrši se preko atributa id_odjel koji smo povezali preko tablice radno_mjesto i id_radno_mjesto, čime se omogućava detaljan prikaz zaposlenika zajedno s
informacijama o njihovom radnom mjestu i njihovim odjelima.
- Rezultati u ovom pogledu nisu specifično sortirani, jer je primarni cilj prikazati kompletne informacije o zaposlenicima uz povezanost s radnim mjestom, odjelima i statusima.

## Zaposlenici koji danas slave rođendan ili imaju godišnjicu zaposlenja

``` sql
CREATE VIEW danasnji_dogadjaji AS
	SELECT z.id AS zaposlenik_id, CONCAT(z.ime, ' ', z.prezime) AS puno_ime, z.datum_rodenja, z.datum_zaposlenja, rm.naziv AS radno_mjesto, o.naziv AS odjel,
    CASE 
        WHEN DAY(z.datum_rodenja) = DAY(CURDATE()) 
         AND MONTH(z.datum_rodenja) = MONTH(CURDATE())
        THEN 'Rodjendan'
        ELSE NULL
    END AS danas_rodjendan,
    CASE 
        WHEN DAY(z.datum_zaposlenja) = DAY(CURDATE())
         AND MONTH(z.datum_zaposlenja) = MONTH(CURDATE())
        THEN 'Dan zaposlenja'
        ELSE NULL
    END AS danas_zaposlen
FROM zaposlenik z
JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
JOIN odjel o ON rm.id_odjel = o.id
WHERE 
    (DAY(z.datum_rodenja) = DAY(CURDATE()) AND MONTH(z.datum_rodenja) = MONTH(CURDATE()))
    OR
    (DAY(z.datum_zaposlenja) = DAY(CURDATE()) AND MONTH(z.datum_zaposlenja) = MONTH(CURDATE()));
```

Pogled naziv: `danasnji_dogadjaji`

Svrha/info: prikaz informacija o zaposlenicima koji danas imaju rođendan ili su zaposleni na današnji datum

Referentne tablice: `zaposlenik`, `radno_mjesto`, `odjel`

Objašnjenje:
- Ovaj je pogled osmišljen kako bi odjelu ljudskih resursa pružio jasan pregled zaposlenika koji danas slave rođendan ili datum zaposlenja
- U uvjetu WHERE pregledava se da li je datum i mjesec rođenja/zaposlenja jednak današnjem datumu i mjescu, i pokazati će ono što ispuni taj uvjet
- Korištenje ovog pogleda služi odjelu ljudskih resursa da znaju točno tko danas "nešto slavi" kako bi se ta informacija mogla prenijeti ostalima i podići povezanost zaposlenika tako što znaju više o kolegama.


# FUNKCIJE

## Broj zaposlenih po spolu u odjelu

``` sql
DELIMITER //
CREATE FUNCTION broj_zaposlenih_spol(p_id_odjel INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE br_zene INT DEFAULT 0;
    DECLARE br_muskarci INT DEFAULT 0;
    DECLARE ukupno INT DEFAULT 0;
    DECLARE odjel_ime VARCHAR(50);

    SELECT COUNT(CASE WHEN z.spol = 'Ž' THEN 1 END),
           COUNT(CASE WHEN z.spol = 'M' THEN 1 END)
        INTO br_zene, br_muskarci
        FROM zaposlenik z
        JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
        WHERE rm.id_odjel = p_id_odjel;
    SET ukupno = br_zene + br_muskarci;
    SELECT naziv INTO odjel_ime
        FROM odjel
        WHERE id = p_id_odjel;

	RETURN CONCAT('Postotak zaposlenika po spolu u odjelu: ',odjel_ime,' -> ','Žene: ', ROUND((br_zene/ukupno)*100,2),'%', ', Muškarci: ', ROUND((br_muskarci/ukupno)*100,2),'%');
END //
DELIMITER ;
```

Funkcija vraća ukupan postotak zaposlenika po spolu koji pripadaju određenom odjelu. Koristi se za analitiku i generiranje izvještaja.
Funkcija prima jedan parametar p_id_odjel koji predstavlja ID odjela za koji se želi odrediti postotak zaposlenika po spolu. Fukcija koristi dvije varijable br_zene i br_muskarci za brojanje zaposlenika po spolu za unesni odjel, te varijablu ukupno za izraćunavanje ukupnog broja zaposlenika.
Nakon izračuna brojeva zaposlenika po spolu, funkcija koristi ROUND() funkciju za zaokruživanje postotka zaposlenika po spolu na dva decimalna mjesta. Funkcija na kraju vraća rezultat u obliku stringa koji sadrži ime odjela, postotak ženskih zaposlenika i postotak muških zaposlenika.

## Prosječna plaća u odjelu po spolu

``` sql
DELIMITER //
CREATE FUNCTION prosjecna_placa_odjela_po_spolu(p_id_odjel INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE rezultat_zene DECIMAL(10,2);
    DECLARE rezultat_muski DECIMAL(10,2);
    DECLARE odjel_ime VARCHAR(50);

    SELECT AVG(CASE WHEN z.spol = 'Ž' THEN z.placa END),
           AVG(CASE WHEN z.spol = 'M' THEN z.placa END)
        INTO rezultat_zene, rezultat_muski
        FROM zaposlenik z
        JOIN radno_mjesto rm ON rm.id = z.id_radno_mjesto
        WHERE rm.id_odjel = p_id_odjel;
    SELECT naziv INTO odjel_ime
        FROM odjel
        WHERE id = p_id_odjel;

    RETURN CONCAT('Prosječna plaća u odjelu: ', odjel_ime, ' -> Žene: ', ROUND(rezultat_zene,2),' EUR', ', Muškarci: ', ROUND(rezultat_muski,2),' EUR');
END //
DELIMITER ;
```
Funkcija izračunava prosječnu plaću zaposlenika po spolu unutar odabranog odjela. Koristi se za financijske analize, usporedbu odjela te HR statistike.

Funkcija spaja zaposlenike i radna mjesta te filtrira radna mjesta prema odjelu. Uz pomoć agregatne funkcije AVG izračunava se prosječna plaća po spolu u tom odjelu. Nakon izračuna prosječne plaće zaposlenika po spolu, funkcija koristi ROUND() funkciju za zaokruživanje iznosa prosječne plaće zaposlenika po spolu na dva decimalna mjesta. Funkcija na kraju vraća rezultat u obliku stringa koji sadrži ime odjela, prosječnu plaću ženskih zaposlenika i prosječnu plaću muških zaposlenika.

## Današnji dogadjaji - overview

``` sql
DELIMITER //
CREATE FUNCTION danasnji_dogadjaji_zaposlenika() RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE br_rodjendan INT;
    DECLARE br_godisnjica INT;

    SELECT COUNT(*) INTO br_rodjendan
        FROM zaposlenik
        WHERE DAY(datum_rodenja) = DAY(CURDATE())
        AND MONTH(datum_rodenja) = MONTH(CURDATE());

    SELECT COUNT(*) INTO br_godisnjica
        FROM zaposlenik
        WHERE DAY(datum_zaposlenja) = DAY(CURDATE())
        AND MONTH(datum_zaposlenja) = MONTH(CURDATE());

    RETURN CONCAT('Danas rođendan slavi ', br_rodjendan,' zaposlenika, a godišnjicu zaposlenja slavi ',br_godisnjica, ' zaposlenika.');
END //
DELIMITER ;
```

Ova fukcija služi za generiranje sažetog dnevnog izvještaja odjelu ljudskih resursa o zaposlenicima koji na današnji dan slave rođendan ili godišnjicu zaposlenja, za dnevni bilten dešavanja u fitness centru.
Funkcija na kraju vraća rezultat u obliku stringa koji sadrži ime i prezime zaposlenika, starost i godine zaposlenja.
Detaljan popis zaposlenika koji slave rođendan ili godišnjicu zaposlenja dobiva se pomoću pogleda `Zaposlenici koji danas slave rođendan ili imaju godišnjicu zaposlenja`.

# PROCEDURE

## Azuriranje radnog mjesta zaposlenika i broj zaposlenika u odjelu

``` sql
DELIMITER //
CREATE PROCEDURE azuriraj_radno_mjesto (IN p_zaposlenik_id INT, IN p_novo_radno_mjesto INT)
BEGIN
    DECLARE stari_odjel INT;
    DECLARE novi_odjel INT;

    SELECT rm.id_odjel
    INTO stari_odjel
    FROM zaposlenik z
    JOIN radno_mjesto rm ON rm.id = z.id_radno_mjesto
    WHERE z.id = p_zaposlenik_id;

    SELECT id_odjel
    INTO novi_odjel
    FROM radno_mjesto
    WHERE id = p_novo_radno_mjesto;

    IF stari_odjel <> novi_odjel THEN
        UPDATE odjel
        SET broj_zaposlenika = broj_zaposlenika - 1
        WHERE id = stari_odjel;

        UPDATE odjel
        SET broj_zaposlenika = broj_zaposlenika + 1
        WHERE id = novi_odjel;
    END IF;
    
    UPDATE zaposlenik
    SET id_radno_mjesto = p_novo_radno_mjesto
    WHERE id = p_zaposlenik_id;
END //
DELIMITER ;
```

Procedura mijenja radno mjesto zaposlenika. Koristi se prilikom internih promjena pozicije, napredovanja, reorganizacije ili transfera.
Procedure prima ID zaposlenika i ID novog radnog mjesta. UPDATE naredbom mijenja vrijednost atributa id_radno_mjesto.

Također, procedura provjerava da li je novim radnim mjestom promijenjen i odjel, te postavlja novi zaposlenika u starom i novom odjelu. Pošto imamo okidače koji računaju kada imamo novog zaposlenika ili kada netko odlazi, ova procedura se koristi kada zaposlenik promijenom radnog mjesta promijeni i odjel u kojem je zaposlen, da bi držali broj_zaposlenih u tablici odjel ažurnim.

## Promjena plaće zaposlenika

``` sql
DELIMITER //
CREATE PROCEDURE promijeni_placu (IN p_zaposlenik_id INT, IN p_nova_placa DECIMAL(10,2))
BEGIN
    UPDATE zaposlenik
    SET placa = p_nova_placa
    WHERE id = p_zaposlenik_id;
END //
DELIMITER ;
```

Procedura ažurira plaću odabranog zaposlenika. Koristi se pri promjeni ugovora, povišicama, korekcijama ili obračunskim izmjenama.

Prima ID zaposlenika i novu visinu plaće. Jednostavnim UPDATE-om zamjenjuje staru vrijednost. Može se kombinirati s funkcijama koje računaju prosječnu plaću odjela.

# OKIDAČI

## Automatsko azuriranje statusa nakon unosa datuma prestanka zaposlenja

``` sql
DELIMITER //
CREATE TRIGGER bu_status_prestanak_zaposlenik
BEFORE UPDATE ON zaposlenik
FOR EACH ROW
BEGIN
    IF NEW.datum_prestanka IS NOT NULL THEN
        SET NEW.status_zaposlenika = 'neaktivan';
    END IF;
END //
DELIMITER ;
```

Svrha: Automatsko ažuriranje statusa zaposlenika nakon unosa datuma prestanka zaposlenja.

Ovaj okidač, nazvan bu_status_prestanak_zaposlenik, kreiran je kako bi nakon ažuriranja zapisa u tablici zaposlenik automatski promijenio status zaposlenika na 'neaktivan' kada je upisan datum prestanka zaposlenja. Funkcionalnost okidača temelji se na provjeri polja datum_prestanka u zapisu koji se ažurira.

Okidač se aktivira prije ažuriranja zapisa u tablici zaposlenik (BEFORE UPDATE). Ukoliko je polje datum_prestanka različito od NULL, okidač automatski postavlja atribut status_zaposlenika na 'neaktivan'. Na taj način, status zaposlenika se dosljedno ažurira svaki put kada se unese datum prestanka, čime se održava integritet podataka i smanjuje mogućnost ljudske pogreške.

Ovaj okidač omogućava automatsku kontrolu statusa zaposlenika i olakšava praćenje aktivnih i neaktivnih zaposlenika u organizaciji. Podaci generirani ovim okidačem mogu se koristiti za analitiku, izvještavanje i planiranje ljudskih resursa.

## Automatsko postavljanje statusa na aktivan prilikom kreiranja novog zaposlenika

``` sql
DELIMITER //
CREATE TRIGGER bi_status_zaposlenik
BEFORE INSERT ON zaposlenik
FOR EACH ROW
BEGIN
    IF NEW.status_zaposlenika IS NULL THEN
        SET NEW.status_zaposlenika = 'aktivan';
    END IF;
END //
DELIMITER ;
```

Svrha: Automatsko postavljanje statusa zaposlenika na 'aktivan' prilikom kreiranja novog zaposlenika.

Okidač bi_status_zaposlenik kreiran je kako bi svaki novi unos u tablici zaposlenik automatski dobio status 'aktivan', osim ako izričito nije definiran drugi status. Funkcionalnost okidača temelji se na provjeri polja status_zaposlenika u novom zapisu (NEW).

Okidač se aktivira prije unosa novog zapisa (BEFORE INSERT). Ako polje status_zaposlenika nije definirano, okidač postavlja njegovu vrijednost na 'aktivan'. Na taj način se sprječava pojava praznih ili neodređenih statusa zaposlenika i osigurava osnovna konzistentnost podataka o zaposlenicima.

Primjena ovog okidača olakšava administraciju i upravljanje zaposlenicima, jer garantira da svi novi zaposlenici automatski imaju valjani status, što je ključno za izvještavanje, analitiku i procesiranje podataka u sustavu.

## Azuriranje broja zaposlenika u odjelu - dodavanje novog zaposlenog

``` sql
DELIMITER //
CREATE TRIGGER ai_povecaj_broj_zaposlenik
AFTER INSERT ON zaposlenik
FOR EACH ROW
BEGIN
    UPDATE odjel d
    JOIN radno_mjesto rm ON rm.id_odjel = d.id
    SET d.broj_zaposlenika = d.broj_zaposlenika + 1
    WHERE rm.id = NEW.id_radno_mjesto;
END //
DELIMITER ;
```

Svrha: Automatsko ažuriranje broja zaposlenika u odjelu prilikom dodavanja novog zaposlenika.

Okidač ai_povecaj_broj_zaposlenik kreiran je kako bi nakon dodavanja novog zaposlenika u tablicu zaposlenik automatski ažurirao broj zaposlenika u odjelu kojem pripada novi zaposlenik. Funkcionalnost okidača temelji se na spajanju tablica radno_mjesto i odjel, gdje se odjel određuje prema id_radno_mjesto zaposlenika.

Okidač se aktivira nakon unosa zapisa (AFTER INSERT) i izvršava UPDATE naredbu nad tablicom odjel, povećavajući vrijednost polja broj_zaposlenika za odgovarajući odjel za jedan. Na taj način, broj zaposlenika u odjelu se automatski ažurira svaki put kada se unese novi zaposlenik, čime se osigurava točnost i aktualnost podataka.

Primjena ovog okidača olakšava administraciju ljudskih resursa, omogućava automatsko praćenje popunjenosti odjela te osigurava da izvještaji i statistike o broju zaposlenika uvijek budu ažurni.

## Azuriranje broja zaposlenika u odjelu - brisanje zaposlenika

``` sql
DELIMITER //
CREATE TRIGGER ad_smanji_broj_zaposlenik
AFTER DELETE ON zaposlenik
FOR EACH ROW
BEGIN
    UPDATE odjel d
    JOIN radno_mjesto rm ON rm.id_odjel = d.id
    SET d.broj_zaposlenika = d.broj_zaposlenika - 1
    WHERE rm.id = OLD.id_radno_mjesto;
END //
DELIMITER ;
```

Svrha: Automatsko ažuriranje broja zaposlenika u odjelu prilikom brisanja zaposlenika.

Okidač ad_smanji_broj_zaposlenik kreiran je kako bi nakon brisanja zapisa iz tablice zaposlenik automatski ažurirao broj zaposlenika u odjelu kojem je pripadao obrisani zaposlenik. Funkcionalnost okidača temelji se na spajanju tablica radno_mjesto i odjel, gdje se odjel određuje prema id_radno_mjesto zaposlenika koji se briše.

Okidač se aktivira nakon brisanja zapisa (AFTER DELETE) i izvršava UPDATE naredbu nad tablicom odjel, smanjujući vrijednost polja broj_zaposlenika za odgovarajući odjel za jedan. Na taj način, broj zaposlenika u odjelu se automatski ažurira svaki put kada zaposlenik bude obrisan iz sustava, čime se održava točnost podataka o broju zaposlenika po odjelima.

Ovaj okidač omogućava automatsku kontrolu i ažuriranje podataka, olakšava upravljanje ljudskim resursima te osigurava precizne informacije za analizu i izvještavanje o strukturi zaposlenika unutar organizacije.

# AUTENTIFIKACIJA I AUTORIZACIJA

# TRANSAKCIJE
