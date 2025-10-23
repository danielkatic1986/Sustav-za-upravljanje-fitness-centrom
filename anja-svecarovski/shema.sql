/*
U ovom dokumentu definiramo shemu baze podataka
*/

DROP DATABASE IF EXISTS fitness_centar;
CREATE DATABASE fitness_centar;
USE fitness_centar;

CREATE TABLE zaposlenik (
  id INT AUTO_INCREMENT PRIMARY KEY, # primarni kljuc, iznos se automatski sam povecava
  ime VARCHAR(50) NOT NULL, 
  prezime VARCHAR(50) NOT NULL, 
  oib CHAR(11) UNIQUE,
  datum_rodenja DATE,
  spol ENUM('muski', 'zenski', 'ostalo') DEFAULT NULL,
  adresa VARCHAR(100),
  grad VARCHAR(50),
  telefon VARCHAR(20),
  email VARCHAR(100),
  datum_zaposlenja DATE NOT NULL,
  datum_prestanka DATE DEFAULT NULL,
  status_zaposlenika ENUM('aktivan', 'neaktivan') NOT NULL, 
	radno_mjesto_id VARCHAR(50) NOT NULL,
  vrsta_ugovora ENUM('stalni', 'honorarni', 'studentski', 'sezonski') DEFAULT 'stalni',
  placa DECIMAL(10,2) DEFAULT NULL,
  FOREIGN KEY (radno_mjesto_id ) REFERENCES radno_mjesto(id)
);

CREATE TABLE radno_mjesto (
	id INT AUTO_INCREMENT PRIMARY KEY, # primarni kljuc, iznos se automatski sam povecava
  naziv VARCHAR(50) NOT NULL,
  opis TEXT,
  odjel_id VARCHAR(50) NOT NULL,
  aktivno BOOLEAN DEFAULT 1,
  FOREIGN KEY (odjel_id) REFERENCES odjel(id)
);

CREATE TABLE odjel (
	id INT AUTO_INCREMENT PRIMARY KEY, # primarni kljuc, iznos se automatski sam povecava
  naziv VARCHAR(100) NOT NULL,
  aktivno BOOLEAN DEFAULT 1,
  broj_zaposlenika INT CHECK (broj_zaposlenika >= 0) DEFAULT 0
);

CREATE TABLE trener_program (
	id INT AUTO_INCREMENT PRIMARY KEY, # primarni kljuc, iznos se automatski sam povecava
  trener_id VARCHAR(50) NOT NULL,
  program_id VARCHAR(50) NOT NULL,
  FOREIGN KEY (trener_id) REFERENCES zaposlenik(id),
  FOREIGN KEY (program_id) REFERENCES odjel(id)
);
