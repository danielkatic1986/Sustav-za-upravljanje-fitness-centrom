CREATE TABLE tip_prostorije (
	id INTEGER AUTO_INCREMENT,
    naziv VARCHAR(50) NOT NULL UNIQUE,
	opis TEXT,
    
    PRIMARY KEY (id)
);

CREATE TABLE prostorija (
	id INTEGER AUTO_INCREMENT,
    oznaka VARCHAR(20) NOT NULL UNIQUE,
    lokacija VARCHAR(20) NOT NULL, -- ovo možda izbaciti? (primjeri - prizemlje, 1./2./3. kat, lijevo/desno krilo itd.)
    kapacitet INTEGER NOT NULL,
    tip_prostorije_id INTEGER NOT NULL,
    
    PRIMARY KEY (id),
    FOREIGN KEY (tip_prostorije_id) REFERENCES tip_prostorije (id)
);

CREATE TABLE termin_treninga (
	id INTEGER AUTO_INCREMENT,
    trening_id INTEGER NOT NULL,
    prostorija_id INTEGER NOT NULL,
    trener_id INTEGER NOT NULL,
    vrijeme_pocetka DATETIME NOT NULL,
    vrijeme_zavrsetka DATETIME NOT NULL,
    napomena TEXT DEFAULT "Nema napomena.",
    otkazan BOOLEAN DEFAULT 0,  -- ovo možda izbaciti?
    
    PRIMARY KEY (id),
    FOREIGN KEY (trening_id) REFERENCES trening (id),
    FOREIGN KEY (prostorija_id) REFERENCES trening (id),
    FOREIGN KEY (trener_id) REFERENCES zaposlenik (id)
);

CREATE TABLE rezervacija (
	id INTEGER AUTO_INCREMENT,
    clan_id INTEGER NOT NULL,
    termin_treninga_id INTEGER NOT NULL,
    vrijeme_rezervacije DATETIME NOT NULL,
    nacin_rezervacije ENUM("Online", "Recepcija") NOT NULL,
    
    UNIQUE (clan_id, termin_treninga_id),
    
    PRIMARY KEY (id),
    FOREIGN KEY (clan_id) REFERENCES clan (id) ON DELETE CASCADE,
    FOREIGN KEY (termin_treninga_id) REFERENCES termin_treninga (id) ON DELETE CASCADE
);