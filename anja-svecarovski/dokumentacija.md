# VEZE ENTITETA PREMA ER DIJAGRAMU

| Veza | Vrsta | Objašnjenje |
|------|-------|-------------|
| trener — trener_program | 1:N | Jedan trener može voditi više programa. |
| trener_program — program (Maja) | N:1 | Program ima jednog odgovornog trenera. |
| zaposlenik — odrzavanje (Vladan) | 1:N | Zaposlenik (npr. tehničar) može obaviti više održavanja. |
| trener — raspored (Mikel) | 1:N | Trener ima više termina u rasporedu. |
| zaposlenik - radno_mjesto | 1:N | Jedno radno mjesto može imati više zaposlenika, ali svaki zaposlenik pripada samo jednom radnom mjestu.|
| odjel - radno_mjesto | 1:N | Jedan odjel može imati više radnih mjesta, ali svako radno mjesto pripada samo jednom odjelu.|
| podruznica - zaposlenik | 1:N | Jedna podruznica može imati više zaposlenih, ali svaki zaposlenik pripada samo jednoj podruznici.|
| mjesto - podružnica| 1:N | Jedno mjesto može imati više podružnica, ali svaka podružnica pripada samo jednom mjestu.|

# SHEME RELACIJSKOG MODELA

- odjel (id, naziv, aktivno, opis, broj_zaposlenika)
- radno_mjesto (id, naziv, aktivno, opis, id_odjel)
- podruznica (id, naziv, adresa, id_mjesto)
- zaposlenik (id, ime, prezime, oib, datum_rodenja, spol, adresa, grad, telefon, email, datum_zaposlenja, datum_prestanka, status_zaposlenika, placa, id_radno_mjesto, id_podruznica)
- trener_program (id, trener_id, program_id)

# EER DIJAGRAM (MySQL Workbench)

# SQL TABLICE

## Tablica odjel

### Svrha
Tablica odjel korisi se za evidenciju različitih odjela unutar fitness centra. Odjeli predstavljaju
funkcionalne jedinice, poput fitness, wellness, odrzavanje, administracija, recepcija, marketing, prodaja, uprava, racunovodstvo i omogućuju organizaciji da prati broj zaposlenika i upravlja njihovim resursima.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog odjela. Automatski se generira i koristi za razlikovanje odjela |
| `naziv` | VARCHAR(50) | NOT NULL UNIQUE | | Naziv odjela, obavezno polje jer omogućuje identifikaciju odjela. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Zbog ograničenja UNIQUE znači da ne mogu postojati dva odjela s istim nazivom. |
| `aktivno` | BOOLEAN | DEFAULT TRUE | | Označava je li odjel trenutno aktivan, zadana vrijednost je True |
| `opis` | TEXT  | | | Do 65.535 znakova za opis pojednih odjela, unos opisa nije obavezan i ne očekuje se da bude jedinstven. |
| `broj_zaposlenika` | INT | CHECK (broj_zaposlenika >= 0) DEFAULT 0 | | Broj zaposlenika unutar odjela. Ovo polje ima zadanu vrijednost 0 i mora biti nenegativno. Koristi se za praćenje ljudskih resursa u odjelu. |

## Tablica radno_mjesto

### Svrha
Predstavlja razlicita radna mjesta unutar svakog odjela fitness centra, poput 'trener', 'tehničar', 'recepcioner', 'administracija'.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog ranog mjesta. Automatski se generira i koristi za razlikovanje ranog mjesta. |
| `naziv` | VARCHAR(50) | NOT NULL UNIQUE | | Naziv radnog mjesta, obavezno polje jer omogućuje identifikaciju radnog mjesta. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Zbog ograničenja UNIQUE znači da ne mogu postojati dva radna mjesta s istim nazivom. |
| `aktivno` | BOOLEAN | DEFAULT TRUE | | Označava je li radno mjesto trenutno aktivno, zadana vrijednost je True |
| `opis` | TEXT  | | | Do 65.535 znakova za opis pojednih radnih mjesta, unos opisa nije obavezan i ne očekuje se da bude jedinstven. |
| `id_odjel` | INT | NOT NULL | FOREIGN KEY REFERENCES odjel(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obavezno polje. |

## Tablica poslovnica

### Svrha
Normalizacija bazu, tako da se adrese i lokacije fitness centara ne dupliciraju po članovima ili zaposlenicima, već da postoje posebne tablice za podružnice i mjesta.
Više podružnica može biti u istom gradu – zato je veza na mjesto korisna, jer grad, poštanski broj i država ne moraju biti duplicirani.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog odjela. Automatski se generira i koristi za razlikovanje odjela |
| `naziv` | VARCHAR(100) | NOT NULL | | Naziv podružnice, obavezno polje jer omogućuje identifikaciju odjela. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `adresa` | VARCHAR(100) | NOT NULL | | Adresa podružnice, obavezno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `id_mjesto` | INT | NOT NULL | FOREIGN KEY REFERENCES mjesto(id) | Strani ključ koji osigurava očuvanje referencijalnog integriteta među povezanim tablicama, obavezno polje. |

## Tablica zaposlenik

### Svrha
Tablica zaposlenik pohranjuje podatke o zaposlenicima fitness centra. Svaki zaposlenik je povezan s određenim radnim mjestom i odjelom, a podaci poput datuma zaposlenja i statusa omogućuju praćenje radne snage.

### Atributi
| Atribut | Tip | Ograničenje | Ključ | Opis |
|---------|-----|-------------|-------| ------|
| `id` | INT AUTO_INCREMENT | | PRIMARY KEY | Jedinstveni identifikator svakog ranog mjesta. Automatski se generira i koristi za razlikovanje ranog mjesta. |
| `ime` | VARCHAR(50) | NOT NULL | | Ime zaposlenika, obavezno polje za identifikaciju. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `prezime` | VARCHAR(50) | NOT NULL | | Adresa zaposlenika, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `oib` | CHAR(11) | NOT NULL UNIQUE | | OIB zaposlenika, obavezno polje za identifikaciju. Zbog ograničenja UNIQUE znači da ne mogu postojati dva zaposlenika s istim OIBom. |
| `datum_rodjenja` | DATE | | | Datum rođenja, opcionalno polje.|
| `spol` | ENUM('M', 'Ž', 'Drugo') | | | Spol zaposlenika, opcionalno polje, unaprijed definirane opcije. |
| `adresa` | VARCHAR(100) | NULL | | Adresa zaposlenika, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `grad` | VARCHAR(50) | NULL | | Grad povezan sa adresom zaposlenika, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `telefon` | VARCHAR(20) | NULL | | Kontakt broj zaposlenika, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `email` | VARCHAR(100) | NULL | | Email adresa zaposlenika za komunikaciju unutar organizacije, opcionalno polje. Tipa je VARCHAR iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `datum_zaposlenja` | DATE | NOT NULL | DEFAULT NOW()| Datum kada je zaposlenik počeo raditi. Ovo je obavezno polje za praćenje radnog staža. Ukoliko nije definirano, postavlja se datum kada je uneseno.|
| `datum_prestanka` | DATE | | DEFAULT NULL| Datum kada je zaposlenik prestao raditi. Ukoliko nije definirano, postavlja se vrijednost NULL.|
| `status_zaposlenika` | ENUM('aktivan', 'neaktivan') | NOT NULL | | Status zaposlenika koji pokazuje je li zaposlenik trenutno aktivan ili neaktivan. |
| `placa` | DECIMAL(10,2) | DEFAULT 0 CHECK (placa >= 0) | | Plaća zaposlenika, ukoliko nije definirano, postavlja se vrijednost NULL. Pri unosu ili updateu se provjerava dal i je unesena plaća veća ili jednaka 0.|
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

# UPITI

# POGLEDI

# FUNKCIJE

# PROCEDURE

# OKIDAČI

# AUTENTIFIKACIJA I AUTORIZACIJA

# TRANSAKCIJE
