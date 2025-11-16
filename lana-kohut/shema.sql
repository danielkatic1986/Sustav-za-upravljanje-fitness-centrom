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

CREATE TABLE placanje (
id 	INT AUTO_INCREMENT PRIMARY KEY,
id_clan INT ,
id_racun INT,
opis_placanja VARCHAR(100),
status_placanja VARCHAR(50),
FOREIGN KEY (id_clan) REFERENCES clan (id),
FOREIGN KEY (id_racun) REFERENCES racun (id)
);






CREATE TABLE racun (
id INT AUTO_INCREMENT PRIMARY KEY,
broj_racuna INT,
id_popusta INT,
nacin_placanja VARCHAR(50),
datum_izdavanja DATE,
vrijeme_izdavanja TIME,
iznos_prije_popusta INT,
popust_check VARCHAR(1),
ukupan_iznos INT,
FOREIGN KEY (id_popusta) REFERENCES popust (id),
CHECK (popust_check IN ("D", "N"))

);

CREATE TABLE popust (
id INT AUTO_INCREMENT PRIMARY KEY,
naziv_popusta VARCHAR(50),
iznos_popusta INT
);


