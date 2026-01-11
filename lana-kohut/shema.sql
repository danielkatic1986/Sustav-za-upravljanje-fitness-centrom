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
    iznos_prije_popusta INT NOT NULL,
    popust_check CHAR(1) NOT NULL,
    ukupan_iznos INT NOT NULL,

    CONSTRAINT pk_racun PRIMARY KEY (id),
    CONSTRAINT fk_racun_popust
        FOREIGN KEY (id_popusta)
        REFERENCES popust(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_popust CHECK (popust_check IN ('D', 'N'))
);

-- PLACANJE
CREATE TABLE placanje (
    id INT AUTO_INCREMENT,
    id_clan INT NOT NULL,
    id_racun INT NOT NULL,
    opis_placanja VARCHAR(100),
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


