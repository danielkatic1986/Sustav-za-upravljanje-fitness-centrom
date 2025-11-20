DROP DATABASE IF EXISTS fitness_centar;
CREATE DATABASE fitness_centar;
USE fitness_centar;

CREATE TABLE tip_prostorije (
	id INTEGER AUTO_INCREMENT,
    naziv VARCHAR(50) NOT NULL,
	opis TEXT,
    
    CONSTRAINT uq_tip_prostorije_naziv UNIQUE (naziv),
    
    CONSTRAINT pk_tip_prostorije PRIMARY KEY (id)
);

CREATE TABLE prostorija (
	id INTEGER AUTO_INCREMENT,
    oznaka VARCHAR(10) NOT NULL,
    lokacija VARCHAR(50) NOT NULL,
    kapacitet INTEGER NOT NULL,
    tip_prostorije_id INTEGER NOT NULL,
	podruznica_id INTEGER NOT NULL,
    
    CONSTRAINT ck_prostorija_kapacitet CHECK (kapacitet > 0),
    
    CONSTRAINT pk_prostorija PRIMARY KEY (id),
    
    CONSTRAINT fk_prostorija_tip_prostorije
		FOREIGN KEY (tip_prostorije_id)
        REFERENCES tip_prostorije (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
	CONSTRAINT fk_prostorija_podruznica
		FOREIGN KEY (podruznica_id)
        REFERENCES podruznica (id) 
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE termin_treninga (
	id INTEGER AUTO_INCREMENT,
    trening_id INTEGER NOT NULL,
    prostorija_id INTEGER NOT NULL,
    trener_id INTEGER NOT NULL,
    vrijeme_pocetka TIMESTAMP NOT NULL,
    vrijeme_zavrsetka TIMESTAMP NOT NULL,
    napomena TEXT,
    otkazan BOOLEAN NOT NULL DEFAULT FALSE,
    
    CONSTRAINT ck_termin_treninga_vrijeme_pocetka_vrijeme_zavrsetka
		CHECK (vrijeme_zavrsetka > vrijeme_pocetka ),
    
    CONSTRAINT pk_termin_treninga PRIMARY KEY (id),
    
    CONSTRAINT fk_termin_treninga_trening
		FOREIGN KEY (trening_id)
        REFERENCES trening (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_termin_treninga_prostorija
		FOREIGN KEY (prostorija_id)
        REFERENCES prostorija (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_termin_treninga_zaposlenik
		FOREIGN KEY (trener_id)
        REFERENCES zaposlenik (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE rezervacija (
	id INTEGER AUTO_INCREMENT,
    clan_id INTEGER NOT NULL,
    termin_treninga_id INTEGER NOT NULL,
    vrijeme_rezervacije TIMESTAMP NOT NULL,
    nacin_rezervacije ENUM("Online", "Recepcija") NOT NULL,
    
    CONSTRAINT uq_rezervacija_clan_id_termin_treninga_id UNIQUE (clan_id, termin_treninga_id),
    
    CONSTRAINT pk_rezervacija PRIMARY KEY (id),
    
    CONSTRAINT fk_rezervacija_clan
		FOREIGN KEY (clan_id)
        REFERENCES clan (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_rezervacija_termin_treninga
		FOREIGN KEY (termin_treninga_id)
        REFERENCES termin_treninga (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
