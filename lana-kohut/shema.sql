DROP DATABASE IF EXISTS fitness_centar;
CREATE DATABASE fitness_centar;
USE fitness_centar;

-- tablice na koje se vežem
CREATE TABLE clan (
  id INT AUTO_INCREMENT,
  ime VARCHAR(50) NOT NULL,
  prezime VARCHAR(50) NOT NULL,
  oib CHAR(11) NOT NULL,
  spol ENUM('M', 'Ž', 'Drugo'),
  datum_rodenja DATE,
  id_mjesto INT NOT NULL,
  adresa VARCHAR(150) NOT NULL,
  email VARCHAR(100) NOT NULL,
  telefon VARCHAR(20) NOT NULL,
  datum_uclanjenja DATE NOT NULL,
  datum_posljednje_aktivnosti DATE,
  aktivan BOOLEAN DEFAULT TRUE,
  
  CONSTRAINT pk_clan PRIMARY KEY (id),
  CONSTRAINT uq_clan_oib UNIQUE(oib),
  CONSTRAINT uq_clan_email UNIQUE(email),
  CONSTRAINT uq_clan_telefon UNIQUE(telefon),
  CONSTRAINT fk_clan_mjesto FOREIGN KEY (id_mjesto)
    REFERENCES mjesto(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
CREATE TABLE mjesto (
    id INT AUTO_INCREMENT,
    naziv VARCHAR(100) NOT NULL,
    postanski_broj CHAR(5) NOT NULL,
    drzava VARCHAR(100) DEFAULT 'Hrvatska',
    CONSTRAINT pk_mjesto PRIMARY KEY(id),
    CONSTRAINT uq_mjesto_naziv_postanski UNIQUE(naziv, postanski_broj)
);

CREATE TABLE tip_clanarine (
  id INT AUTO_INCREMENT,
  naziv VARCHAR(50) NOT NULL,
  trajanje_mjeseci INT NOT NULL,
  cijena DECIMAL(10, 2) NOT NULL,
  opis VARCHAR(255),
  
  CONSTRAINT pk_tip_clanarine 
  PRIMARY KEY(id),

  CONSTRAINT ck_tip_clanarine_trajanje_mjeseci
  CHECK (trajanje_mjeseci > 0),

  CONSTRAINT ck_tip_clanarine_cijena
  CHECK (cijena > 0)
);

/*
	Relacija: status_clanarine
    Opis: omogućava praćenje statusa svake članarine
    Veza: 1:N s clanarina
    
    Primjer:
    id		naziv		opis
    1		Aktivna		Članarina je važeća
    2		Istekla		Rok članarine je prošao
    3		Zamrznuta	Privremeno pauzirana
*/

CREATE TABLE status_clanarine (
  id INT AUTO_INCREMENT,
  naziv VARCHAR(50) NOT NULL,
  opis VARCHAR(255),
  
  CONSTRAINT pk_status_clanarine 
  PRIMARY KEY(id)
);

/*
	Relacija: clanarina
    Opis: veza između člana, tipa i statusa članarine
    Veze: povezuje sve tri relacije (clan, tip_clanarine, status_clanarine)
*/

CREATE TABLE clanarina (
  id INT AUTO_INCREMENT,
  id_clan INT NOT NULL,
  id_tip INT NOT NULL,
  id_status INT NOT NULL,
  datum_pocetka DATE NOT NULL,
  datum_zavrsetka DATE NOT NULL,
  
  CONSTRAINT pk_clanarina 
  PRIMARY KEY(id),
  
  CONSTRAINT fk_clanarina_clan 
  FOREIGN KEY (id_clan) REFERENCES clan(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  
  CONSTRAINT fk_clanarina_tip_clanarine 
  FOREIGN KEY (id_tip) REFERENCES tip_clanarine(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
  
  CONSTRAINT fk_clanarina_status_clanarine 
  FOREIGN KEY (id_status) REFERENCES status_clanarine(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE,

  CONSTRAINT ck_clanarina_datumi
  CHECK (datum_zavrsetka > datum_pocetka)
);

-- moje tablice

-- POPUST
CREATE TABLE popust (
    id INT AUTO_INCREMENT,
    naziv_popusta VARCHAR(50) NOT NULL,
    iznos_popusta INT NOT NULL,

    CONSTRAINT pk_popust PRIMARY KEY (id)
);

-- RACUN
CREATE TABLE racun (
    id INT AUTO_INCREMENT,
    broj_racuna INT NOT NULL,
    id_popusta INT,
    nacin_placanja VARCHAR(50) NOT NULL,
    datum_izdavanja DATE NOT NULL,
    vrijeme_izdavanja TIME NOT NULL,
    iznos_prije_popusta DECIMAL(10,2) NOT NULL,
    popust_check CHAR(1) NOT NULL,
    ukupan_iznos DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_racun PRIMARY KEY (id),

    CONSTRAINT fk_racun_popust
        FOREIGN KEY (id_popusta)
        REFERENCES popust(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,

    CONSTRAINT chk_popust
        CHECK (popust_check IN ('D', 'N'))
);

-- RACUN STAVKA:
CREATE TABLE racun_stavka (
    id INT AUTO_INCREMENT,
    id_racun INT NOT NULL,
    id_tip_clanarine INT NULL,
    id_artikl INT NULL,
    kolicina INT NOT NULL DEFAULT 1,
    cijena_jedinicna DECIMAL(10,2) NOT NULL,
    ukupna_cijena DECIMAL(10,2) NOT NULL,

    CONSTRAINT pk_racun_stavka PRIMARY KEY (id),

    CONSTRAINT fk_racun_stavka_racun
        FOREIGN KEY (id_racun)
        REFERENCES racun(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_racun_stavka_tip_clanarine
        FOREIGN KEY (id_tip_clanarine)
        REFERENCES tip_clanarine(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_racun_stavka_artikl
        FOREIGN KEY (id_artikl)
        REFERENCES artikl(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    
    CONSTRAINT ck_racun_stavka_proizvod
        CHECK (
            (id_tip_clanarine IS NOT NULL AND id_artikl IS NULL)
         OR (id_tip_clanarine IS NULL AND id_artikl IS NOT NULL)
        ),

    CONSTRAINT ck_racun_stavka_kolicina
        CHECK (kolicina > 0)
);



-- PLACANJE
CREATE TABLE placanje (
    id INT AUTO_INCREMENT,
    id_clan INT NOT NULL,
    id_racun INT NOT NULL,
    status_placanja VARCHAR(50),
    

    CONSTRAINT pk_placanje PRIMARY KEY (id),
    CONSTRAINT fk_placanje_clan
        FOREIGN KEY (id_clan)
        REFERENCES clan(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_placanje_racun
        FOREIGN KEY (id_racun)
        REFERENCES racun(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- IZVRŠENA PLAĆANJA
CREATE TABLE izvrsena_placanja (
	id INT AUTO_INCREMENT,
    id_placanje INT NOT NULL,
    id_clanarine INT NOT NULL,
    status_tf BOOL,
    
    CONSTRAINT pk_izvrsena_placanja PRIMARY KEY(id),
    CONSTRAINT fk_izvrsena_placanja_placanje
        FOREIGN KEY (id_placanje)
        REFERENCES placanje(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_izvrsena_placanja_tip_clanarine
        FOREIGN KEY (id_clanarine)
        REFERENCES clanarina(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ARTIKLI
CREATE TABLE artikl (
	id INT AUTO_INCREMENT,
    barkod INT NOT NULL,
    tip VARCHAR(50) NOT NULL,
    cijena DECIMAL(10,2) NOT NULL
);


