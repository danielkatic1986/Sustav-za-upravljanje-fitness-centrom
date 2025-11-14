/*
U ovom dokumentu definiramo shemu baze podataka

TODO: autentifikacija i autorizacija, dodati korisnika koji ima pristup nekim tablicama
*/

/*
=================================================
			      DANIEL KATIĆ
=================================================
*/

DROP DATABASE IF EXISTS fitness_centar;
CREATE DATABASE fitness_centar;
USE fitness_centar;

/*
  Relacija: mjesto
  Opis: popis mjesta
*/

CREATE TABLE mjesto (
    id INT AUTO_INCREMENT,
    naziv VARCHAR(100) NOT NULL,
    postanski_broj CHAR(5) NOT NULL,
    drzava VARCHAR(100) DEFAULT 'Hrvatska',
    CONSTRAINT pk_mjesto PRIMARY KEY(id),
    CONSTRAINT uq_mjesto_naziv_postanski UNIQUE(naziv, postanski_broj)
);

/*
	Relacija: clan
    Opis: osnovni podaci o članovima fitness centra.
    Veze: povezan s clanarina, placanje, rezervacija, trening_clan
    
    - aktivan = FALSE mogu postaviti ako je članarina istekla
		- TODO: automatizirati triggerom
*/
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

/*
	Relacija: tip_clanarine
	Opis: definira vrste članarina (npr. mjesečna, godišnja, premium..).
    Veze: 1:N s clanarina
	
	Primjer:
	id			naziv		trajanje_mjeseci	cijena	opis
	1			Mjesečna	1					40.00	Osnovni pristup svim dvoranama
	2			Godišnja	12					400.00	Popust 2 mjeseca gratis
	3			Premium		12					600.00	Uključuje osobnog trenera
*/

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

/*
	Relacija: statistika_potrosnje
    Opis: statistika potrošnje svakog člana po tromjesečju
    Veze: 1:N, jedan član ima N statističkih zapisa
*/
CREATE TABLE statistika_potrosnje (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_clan INT NOT NULL,
  ukupno_u_periodu DECIMAL(10,2) NOT NULL DEFAULT 0,
  godina YEAR NOT NULL,
  kvartal INT NOT NULL,
  
  CONSTRAINT fk_statistika_potrosnje_clan
  FOREIGN KEY (id_clan) REFERENCES clan(id)
  ON UPDATE CASCADE,
  
  CONSTRAINT uq_statistika_potrosnje_id_godina_kvartal
  UNIQUE(id_clan, godina, kvartal)
);