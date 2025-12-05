/*
U ovom dokumentu definiramo shemu baze podataka
*/

DROP DATABASE IF EXISTS fitness_centar;
CREATE DATABASE fitness_centar;
USE fitness_centar;

CREATE TABLE odjel (
	id INT AUTO_INCREMENT, # iznos se automatski sam povecava
    naziv VARCHAR(50) NOT NULL, # naziv odjela, obavezno polje
    aktivno BOOLEAN DEFAULT TRUE, # status odjela, zadana vrijednost aktivno
    opis TEXT, # opis funkcija i odgovornosti odjela
    broj_zaposlenika INT DEFAULT 0, # broj zaposlenika u odjelu, zadana vrijednost 0

    CONSTRAINT odjel_pk PRIMARY KEY (id), # definicija primarnog kljuca
    CONSTRAINT odjel_naziv_uq UNIQUE (naziv), # definicija jedinstvenosti naziva odjela
    CONSTRAINT odjel_broj_zaposlenika_ck CHECK (broj_zaposlenika >= 0) # broj zaposlenika u odjelu, ne moze biti negativan
);

CREATE TABLE radno_mjesto (
	id INT AUTO_INCREMENT,  # iznos se automatski sam povecava
    naziv VARCHAR(50) NOT NULL, # naziv radnog mjesta
    aktivno BOOLEAN DEFAULT TRUE, # status radnog mjesta, zadana vrijednost aktivno
    opis TEXT, # opis radnih zadataka
    id_odjel INT NOT NULL, # strani kljuc koji povezuje radno mjesto s odjelom
    
    CONSTRAINT radno_mjesto_pk PRIMARY KEY (id), # definicija primarnog kljuca
    CONSTRAINT radno_mjesto_odjel_fk FOREIGN KEY (id_odjel) REFERENCES odjel(id), # definicija stranog kljuca
    CONSTRAINT radno_mjesto_naziv_uq UNIQUE (naziv) # definicija jedinstvenosti naziva radnog mjesta
);

CREATE TABLE podruznica (
    id INT AUTO_INCREMENT, # iznos se automatski sam povecava
    naziv VARCHAR(100) NOT NULL, # naziv podružnice, obavezno polje
    adresa VARCHAR(150) NOT NULL, # adresa podružnice, obavezno polje
    id_mjesto INT NOT NULL, # strani kljuc koji povezuje podružnicu s mjestom
    
    CONSTRAINT podruznica_pk PRIMARY KEY (id), # definicija primarnog kljuca
    CONSTRAINT podruznica_mjesto_fk FOREIGN KEY (id_mjesto) 
        REFERENCES mjesto(id) # definicija stranog kljuca
        ON DELETE RESTRICT # zabrana brisanja mjesta ako postoje povezane podružnice
        ON UPDATE CASCADE # automatska promjena id_mjesta u podružnici ako se promijeni id mjesta
);

CREATE TABLE zaposlenik (
	id INT AUTO_INCREMENT, # iznos se automatski sam povecava
    ime VARCHAR(50) NOT NULL, # ime zaposlenika, obavezno polje
    prezime VARCHAR(50) NOT NULL, # prezime zaposlenika, obavezno polje
    oib CHAR(13) NOT NULL, # osobni identifikacijski broj zaposlenika, obavezno polje
    datum_rodenja DATE, # datum rodenja zaposlenika
    spol ENUM('M', 'Ž', 'Drugo'), # spol zaposlenika, unaprijed definirane opcije
    adresa VARCHAR(100), # adresa stanovanja zaposlenika
    id_mjesto INT NOT NULL, # strani kljuc koji povezuje podružnicu s mjestom
    telefon VARCHAR(20), # kontakt telefon zaposlenika
    email VARCHAR(100), # email adresa zaposlenika
    datum_zaposlenja DATE NOT NULL, # datum zaposlenja, obavezno polje
    datum_prestanka DATE DEFAULT NULL, # datum prestanka radnog odnosa, moze biti NULL ako je zaposlenik aktivan
    status_zaposlenika ENUM('aktivan', 'neaktivan') NOT NULL, # status zaposlenika, obavezno polje, unaprijed definirane opcije
    placa DECIMAL(10,2) DEFAULT 0, # placa zaposlenika, zadana vrijednost 0

	id_radno_mjesto INT NOT NULL, # strani kljuc koji povezuje zaposlenika s radnim mjestom
    id_podruznica INT NOT NULL, # strani kljuc koji povezuje zaposlenika s podružnicom
   
    CONSTRAINT zaposlenik_pk PRIMARY KEY (id), # definicija primarnog kljuca
	CONSTRAINT podruznica_mj_fk FOREIGN KEY (id_mjesto) 
        REFERENCES mjesto(id) # definicija stranog kljuca
        ON DELETE RESTRICT # zabrana brisanja mjesta ako postoje povezane podružnice
        ON UPDATE CASCADE, # automatska promjena id_mjesta u podružnici ako se promijeni id mjesta
    CONSTRAINT zaposlenik_radno_mjesto_fk FOREIGN KEY (id_radno_mjesto) 
        REFERENCES radno_mjesto(id) # definicija stranog kljuca
        ON DELETE RESTRICT # zabrana brisanja radnog mjesta ako postoje povezani zaposlenici
        ON UPDATE CASCADE, # automatska promjena id_radno_mjesto u zaposleniku ako se promijeni id radnog mjesta
    CONSTRAINT zaposlenik_podruznica_fk FOREIGN KEY (id_podruznica) 
        REFERENCES podruznica(id) # definicija stranog kljuca
        ON DELETE RESTRICT # zabrana brisanja podružnice ako postoje povezani zaposlenici
        ON UPDATE CASCADE, # automatska promjena id_podruznica u zaposleniku ako se promijeni id podružnice
    CONSTRAINT zaposlenik_oib_uq UNIQUE (oib), # definicija jedinstvenosti OIB-a
    CONSTRAINT zaposlenik_placa_ck CHECK (placa >= 0) # provjera da placa nije negativna
);

CREATE TABLE trener_program (
	id INT AUTO_INCREMENT, # iznos se automatski sam povecava
    trener_id INT NOT NULL, # strani kljuc koji povezuje trenera sa zaposlenikom, obavezno polje
    program_id INT NOT NULL, # strani kljuc koji povezuje program sa odjelom, obavezno polje
    
    CONSTRAINT trener_program_pk PRIMARY KEY (id), # definicija primarnog kljuca
    CONSTRAINT trener_fk FOREIGN KEY (trener_id) REFERENCES zaposlenik(id), # definicija stranog kljuca za trenera
    CONSTRAINT program_fk FOREIGN KEY (program_id) REFERENCES program(id) # definicija stranog kljuca za program
);
