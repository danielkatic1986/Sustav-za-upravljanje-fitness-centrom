/*
U ovom dokumentu definiramo shemu baze podataka
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
    adresa VARCHAR(150) NOT NULL,
    grad VARCHAR(100) NOT NULL,
    postanski_broj CHAR(5) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefon VARCHAR(20) NOT NULL,
    datum_uclanjenja DATE NOT NULL,
    datum_posljednje_aktivnosti DATE,
    aktivan BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT pk_clan PRIMARY KEY (id),
    CONSTRAINT uq_clan_oib UNIQUE(oib),
    CONSTRAINT uq_clan_email UNIQUE(email)
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
    cijena DECIMAL(8, 2) NOT NULL,
    opis VARCHAR(255),
    
    CONSTRAINT pk_tip_clanarine 
		PRIMARY KEY(id)
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
		FOREIGN KEY (id_clan) REFERENCES clan(id),
    
    CONSTRAINT fk_clanarina_tip_clanarine 
		FOREIGN KEY (id_tip) REFERENCES tip_clanarine(id),
    
    CONSTRAINT fk_clanarina_status_clanarine 
		FOREIGN KEY (id_status) REFERENCES status_clanarine(id)
);