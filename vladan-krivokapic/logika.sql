/*________________________
  PREGLEDI
  ________________________               */


/* 1. Pregled sve opreme s dobavljačem, prostorijom, 
      brojem održavanja i datumom zadnjeg održavanja */
SELECT 
    o.id AS oprema_id,
    o.naziv AS naziv_opreme,
    o.stanje,
    d.naziv AS dobavljac,
    p.naziv AS prostorija,
    COUNT(od.id) AS broj_odrzavanja,
    MAX(od.datum) AS zadnje_odrzavanje,
    DATEDIFF(CURDATE(), COALESCE(MAX(od.datum), o.datum_nabave)) AS dana_od_zadnjeg_odrzavanja
FROM oprema o
JOIN dobavljac d ON o.dobavljac_id = d.id
JOIN prostorija p ON o.prostorija_id = p.id
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
GROUP BY 
    o.id, o.naziv, o.stanje, d.naziv, p.naziv, o.datum_nabave
ORDER BY dana_od_zadnjeg_odrzavanja DESC;


/* 2. Statistika po dobavljačima:
      koliko opreme, koliko ispravne / neispravne / u servisu / otpisane */
SELECT 
    d.id,
    d.naziv AS dobavljac,
    COUNT(o.id) AS ukupno_komada,
    SUM(o.stanje = 'ispravno')   AS broj_ispravnih,
    SUM(o.stanje = 'neispravno') AS broj_neispravnih,
    SUM(o.stanje = 'u servisu')  AS broj_u_servisu,
    SUM(o.stanje = 'otpisano')   AS broj_otpisanih,
    MIN(o.datum_nabave) AS najstarija_nabava,
    MAX(o.datum_nabave) AS najnovija_nabava
FROM dobavljac d
LEFT JOIN oprema o ON o.dobavljac_id = d.id
GROUP BY d.id, d.naziv
ORDER BY ukupno_komada DESC;

/* 3. Oprema koja je neispravna ili u servisu predugo bez održavanja 
      (npr. više od 180 dana) */
SELECT 
    o.id AS oprema_id,
    o.naziv,
    o.stanje,
    COALESCE(MAX(od.datum), o.datum_nabave) AS zadnji_servis_ili_nabava,
    DATEDIFF(CURDATE(), COALESCE(MAX(od.datum), o.datum_nabave)) AS dana_bez_servisa
FROM oprema o
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
WHERE o.stanje IN ('neispravno', 'u servisu')
GROUP BY 
    o.id, o.naziv, o.stanje, o.datum_nabave
HAVING dana_bez_servisa > 180
ORDER BY dana_bez_servisa DESC;

/*________________________________________________________________________
  POGLEDI
  ________________________________________________________________________               */
/* VIEW 1: v_oprema_zadnje_odrzavanje
   – sve informacije o opremi + zadnji datum održavanja + broj održavanja */
CREATE OR REPLACE VIEW v_oprema_zadnje_odrzavanje AS
SELECT 
    o.id AS oprema_id,
    o.naziv AS naziv_opreme,
    o.stanje,
    o.datum_nabave,
    d.naziv AS dobavljac,
    p.naziv AS prostorija,
    COUNT(od.id) AS broj_odrzavanja,
    MAX(od.datum) AS zadnje_odrzavanje
FROM oprema o
JOIN dobavljac d ON o.dobavljac_id = d.id
JOIN prostorija p ON o.prostorija_id = p.id
LEFT JOIN odrzavanje od ON od.oprema_id = o.id
GROUP BY 
    o.id, o.naziv, o.stanje, o.datum_nabave, d.naziv, p.naziv;

/* VIEW 2: v_dobavljac_statistika
   – agregirani podaci po dobavljaču (broj opreme, maksimalni datum nabave itd.) */
CREATE OR REPLACE VIEW v_dobavljac_statistika AS
SELECT 
    d.id AS dobavljac_id,
    d.naziv,
    COUNT(o.id) AS broj_komada_opreme,
    MIN(o.datum_nabave) AS prva_isporuka,
    MAX(o.datum_nabave) AS zadnja_isporuka
FROM dobavljac d
LEFT JOIN oprema o ON o.dobavljac_id = d.id
GROUP BY d.id, d.naziv;

/* VIEW 3: v_neispravna_oprema
   – samo oprema koja nije ispravna, uz zadnje održavanje i zadnjeg zaposlenika */
CREATE OR REPLACE VIEW v_neispravna_oprema AS
SELECT 
    o.id AS oprema_id,
    o.naziv,
    o.stanje,
    p.naziv AS prostorija,
    d.naziv AS dobavljac,
    od.datum AS zadnje_odrzavanje,
    z.ime  AS zadnji_serviser_ime,
    z.prezime AS zadnji_serviser_prezime
FROM oprema o
JOIN prostorija p ON o.prostorija_id = p.id
JOIN dobavljac d ON o.dobavljac_id = d.id
LEFT JOIN odrzavanje od ON od.id = (
    SELECT od2.id
    FROM odrzavanje od2
    WHERE od2.oprema_id = o.id
    ORDER BY od2.datum DESC, od2.id DESC
    LIMIT 1
)
LEFT JOIN zaposlenik z ON z.id = od.zaposlenik_id
WHERE o.stanje IN ('neispravno', 'u servisu', 'otpisano');

DELIMITER //


/*___________________________________________________________
  FUNCKIJE
  ___________________________________________________________               */
      
/* FUNKCIJA 1: fn_zadnje_odrzavanje(oprema_id)
   – vraća zadnji datum održavanja, ili NULL ako nije održavano */
CREATE FUNCTION fn_zadnje_odrzavanje (p_oprema_id INT)
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE v_datum DATE;

    SELECT MAX(datum)
    INTO v_datum
    FROM odrzavanje
    WHERE oprema_id = p_oprema_id;

    RETURN v_datum;
END;
//
DELIMITER ;

DELIMITER //

/* FUNKCIJA 2: fn_dani_od_zadnjeg_odrzavanja(oprema_id)
   – broj dana od zadnjeg održavanja (ako nema, računa od nabave) */
CREATE FUNCTION fn_dani_od_zadnjeg_odrzavanja (p_oprema_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_zadnje DATE;
    DECLARE v_nabava DATE;
    DECLARE v_rezultat INT;

    SELECT datum_nabave
    INTO v_nabava
    FROM oprema
    WHERE id = p_oprema_id;

    SET v_zadnje = fn_zadnje_odrzavanje(p_oprema_id);

    SET v_rezultat = DATEDIFF(
        CURDATE(),
        COALESCE(v_zadnje, v_nabava)
    );

    RETURN v_rezultat;
END;
//
DELIMITER ;

DELIMITER //

 /*_______________________________________________________
  PROCEDURE
  ________________________________________________________               */

      
/* PROCEDURA 1: sp_evidentiraj_odrzavanje
   – ubacuje novi zapis u odrzavanje
   – opcionalno odmah mijenja stanje opreme (default 'ispravno') */
CREATE PROCEDURE sp_evidentiraj_odrzavanje (
    IN p_oprema_id INT,
    IN p_zaposlenik_id INT,
    IN p_opis VARCHAR(300),
    IN p_novo_stanje ENUM('ispravno','neispravno','u servisu','otpisano')
)
BEGIN
    INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
    VALUES (p_oprema_id, p_zaposlenik_id, CURDATE(), p_opis);

    /* ako je proslijeđeno novo stanje, promijeni ga */
    IF p_novo_stanje IS NOT NULL THEN
        UPDATE oprema
        SET stanje = p_novo_stanje
        WHERE id = p_oprema_id;
    END IF;
END;
//
DELIMITER ;

DELIMITER //

/* PROCEDURA 2: sp_izvjestaj_oprema_po_dobavljacu
   – vraća detaljan popis opreme i njen status za jednog dobavljača */
CREATE PROCEDURE sp_izvjestaj_oprema_po_dobavljacu (
    IN p_dobavljac_id INT
)
BEGIN
    SELECT 
        o.id AS oprema_id,
        o.naziv AS naziv_opreme,
        o.stanje,
        o.datum_nabave,
        p.naziv AS prostorija,
        fn_zadnje_odrzavanje(o.id) AS zadnje_odrzavanje,
        fn_dani_od_zadnjeg_odrzavanja(o.id) AS dana_od_zadnjeg
    FROM oprema o
    JOIN prostorija p ON p.id = o.prostorija_id
    WHERE o.dobavljac_id = p_dobavljac_id
    ORDER BY o.datum_nabave;
END;
//
DELIMITER ;

DELIMITER //


/* PROCEDURA 3: sp_azuriraj_opremu
   – omogućuje izmjenu podataka o postojećoj opremi
   – opcionalno ažurira naziv, prostoriju, dobavljača i stanje opreme
   – ako je neki parametar NULL, odgovarajući podatak se ne mijenja     */

DELIMITER //

CREATE PROCEDURE sp_azuriraj_opremu (
    IN p_oprema_id INT,
    IN p_naziv VARCHAR(150),
    IN p_prostorija_id INT,
    IN p_dobavljac_id INT,
    IN p_stanje ENUM('ispravno','neispravno','u servisu','otpisano')
)
BEGIN
    UPDATE oprema
    SET
        naziv = COALESCE(p_naziv, naziv),
        prostorija_id = COALESCE(p_prostorija_id, prostorija_id),
        dobavljac_id = COALESCE(p_dobavljac_id, dobavljac_id),
        stanje = COALESCE(p_stanje, stanje)
    WHERE id = p_oprema_id;
END;
//

CREATE PROCEDURE sp_obrisi_odrzavanje (
    IN p_odrzavanje_id INT
)
BEGIN
    DELETE FROM odrzavanje
    WHERE id = p_odrzavanje_id;
END;
//

DELIMITER ;



/*________________________________________________________
  TRIGGERI
  ________________________________________________________               */

      
/* TRIGGER 1: prije INSERT u odrzavanje
   – zabrani unos ako je datum manji od datuma nabave opreme */
CREATE TRIGGER trg_odrzavanje_bi_datum_kontrola
BEFORE INSERT ON odrzavanje
FOR EACH ROW
BEGIN
    DECLARE v_nabava DATE;

    SELECT datum_nabave
    INTO v_nabava
    FROM oprema
    WHERE id = NEW.oprema_id;

    IF NEW.datum < v_nabava THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Datum odrzavanja ne smije biti prije datuma nabave opreme.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //

/* TRIGGER 2: nakon INSERT u odrzavanje
   – ako opis sadrži ključne riječi (popravak / zamjena),
     automatski postavi stanje opreme na 'ispravno'
     (pretpostavka: odrađen popravak) */
CREATE TRIGGER trg_odrzavanje_ai_auto_ispravno
AFTER INSERT ON odrzavanje
FOR EACH ROW
BEGIN
    IF NEW.opis LIKE '%popravak%' 
       OR NEW.opis LIKE '%zamjena%' 
       OR NEW.opis LIKE '%servis%' THEN
        UPDATE oprema
        SET stanje = 'ispravno'
        WHERE id = NEW.oprema_id
          AND stanje IN ('neispravno', 'u servisu');
    END IF;
END;
//
DELIMITER ;


