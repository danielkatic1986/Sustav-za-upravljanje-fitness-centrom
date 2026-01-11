/*
=================================================
                VLADAN KRIVOKAPIĆ
=================================================
*/

/* 
  Baza podataka: fitness_centar
  Opis: osnovne tablice za upravljanje opremom i dobavljačima
*/

/* ============================================================
   FITNESS_CENTAR – DIO: DOBAVLJAC, OPREMA, ODRZAVANJE
   Autor: Vladan Krivokapić
   
   (veze na tablice: zaposlenik, prostorija)
   ============================================================ */


USE fitness_centar;

/* ================================================
   DOBAVLJAC
   ================================================ */
CREATE TABLE IF NOT EXISTS dobavljac (
    id INT AUTO_INCREMENT,
    naziv VARCHAR(150) NOT NULL,
    oib CHAR(11) NOT NULL,
    kontakt VARCHAR(150) NOT NULL,
    adresa VARCHAR(200) NOT NULL,

    CONSTRAINT pk_dobavljac PRIMARY KEY (id),
    CONSTRAINT uq_dobavljac_oib UNIQUE (oib),
    CONSTRAINT uq_dobavljac_naziv UNIQUE (naziv),
    CONSTRAINT ck_dobavljac_oib_format CHECK (oib REGEXP '^[0-9]{11}$')
);

/* ================================================
   OPREMA
   FK: prostorija(id), dobavljac(id)
   ================================================ */
CREATE TABLE IF NOT EXISTS oprema (
    id INT AUTO_INCREMENT,
    naziv VARCHAR(150) NOT NULL,
    prostorija_id INT NOT NULL,
    dobavljac_id INT NOT NULL,
    datum_nabave DATE NOT NULL,
    stanje ENUM('ispravno','neispravno','u servisu','otpisano')
           NOT NULL DEFAULT 'ispravno',

    CONSTRAINT pk_oprema PRIMARY KEY (id),

    CONSTRAINT fk_oprema_prostorija
        FOREIGN KEY (prostorija_id)
        REFERENCES prostorija (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_oprema_dobavljac
        FOREIGN KEY (dobavljac_id)
        REFERENCES dobavljac (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE INDEX idx_oprema_prostorija ON oprema (prostorija_id);
CREATE INDEX idx_oprema_dobavljac ON oprema (dobavljac_id);

/* ================================================
   ODRZAVANJE
   FK: oprema(id), zaposlenik(id)
   ================================================ */
CREATE TABLE IF NOT EXISTS odrzavanje (
    id INT AUTO_INCREMENT,
    oprema_id INT NOT NULL,
    zaposlenik_id INT NOT NULL,
    datum DATE NOT NULL,
    opis VARCHAR(300) NOT NULL,

    CONSTRAINT pk_odrzavanje PRIMARY KEY (id),

    CONSTRAINT fk_odrzavanje_oprema
        FOREIGN KEY (oprema_id)
        REFERENCES oprema (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_odrzavanje_zaposlenik
        FOREIGN KEY (zaposlenik_id)
        REFERENCES zaposlenik (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE INDEX idx_odrzavanje_oprema ON odrzavanje (oprema_id);
CREATE INDEX idx_odrzavanje_zaposlenik ON odrzavanje (zaposlenik_id);

