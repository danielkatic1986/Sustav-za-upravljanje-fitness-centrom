/*
=================================================
                VLADAN KRIVOKAPIĆ
=================================================
*/

/*
  Baza podataka: fitness_centar
  Opis: pregledi (SELECT), VIEW-ovi, funkcije i procedure
*/

USE fitness_centar;

/* ============================================================
   1. PREGLEDI (SELECT)
   ============================================================ */

/* ------------------------------------------------------------
   1.1 Pogled: Pregled sve opreme s dobavljačem i prostorijom
       - prikazuje: opremu, stanje, dobavljača, prostoriju
       - računa: broj održavanja, zadnje održavanje, dane od zadnjeg
   ------------------------------------------------------------ */
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


/* ------------------------------------------------------------
   1.2 Pogled: Statistika opreme po dobavljačima
       - prikazuje: ukupno komada po dobavljaču
       - računa: broj ispravnih / neispravnih / u servisu / otpisanih
       - prikazuje: najstariju i najnoviju nabavu
   ------------------------------------------------------------ */
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


/* ------------------------------------------------------------
   1.3 Pogled: Oprema neispravna ili u servisu predugo bez održavanja
       - filtrira: stanje ('neispravno', 'u servisu')
       - uvjet: više od 180 dana bez servisa/održavanja
   ------------------------------------------------------------ */
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


/* ============================================================
   2. VIEW-OVI (POGLEDI U BAZI)
   ============================================================ */

/* ------------------------------------------------------------
   2.1 VIEW: v_oprema_zadnje_odrzavanje
       - prikazuje: opremu + dobavljača + prostoriju
       - računa: broj održavanja i zadnje održavanje po opremi
   ------------------------------------------------------------ */
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


/* ------------------------------------------------------------
   2.2 VIEW: v_dobavljac_statistika
       - prikazuje: broj komada opreme po dobavljaču
       - računa: prvu i zadnju isporuku (MIN/MAX datum nabave)
   ------------------------------------------------------------ */
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


/* ------------------------------------------------------------
   2.3 VIEW: v_neispravna_oprema
       - prikazuje: samo opremu koja nije ispravna
       - dodaje: zadnje održavanje i podatke o serviseru
   ------------------------------------------------------------ */
CREATE OR REPLACE VIEW v_neispravna_oprema AS
SELECT
    o.id AS oprema_id,
    o.naziv,
    o.stanje,
    p.naziv AS prostorija,
    d.naziv AS dobavljac,
    od.datum AS zadnje_odrzavanje,
    z.ime AS zadnji_serviser_ime,
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


/* ============================================================
   3. FUNKCIJE I PROCEDURE
   ============================================================ */

DELIMITER //

/* ------------------------------------------------------------
   3.1 FUNKCIJA: fn_zadnje_odrzavanje(oprema_id)
       - vraća: zadnji datum održavanja za opremu
       - ako nema održavanja: vraća NULL
   ------------------------------------------------------------ */
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
END//


/* ------------------------------------------------------------
   3.2 FUNKCIJA: fn_dani_od_zadnjeg_odrzavanja(oprema_id)
       - vraća: broj dana od zadnjeg održavanja
       - ako nema održavanja: računa od datuma nabave
   ------------------------------------------------------------ */
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

    SET v_rezultat = DATEDIFF(CURDATE(), COALESCE(v_zadnje, v_nabava));

    RETURN v_rezultat;
END//


/* ------------------------------------------------------------
   3.3 PROCEDURA: sp_evidentiraj_odrzavanje
       - dodaje: novi zapis u tablicu odrzavanje
       - opcionalno: ažurira stanje opreme (ako je poslano)
   ------------------------------------------------------------ */
CREATE PROCEDURE sp_evidentiraj_odrzavanje (
    IN p_oprema_id INT,
    IN p_zaposlenik_id INT,
    IN p_opis VARCHAR(300),
    IN p_novo_stanje VARCHAR(20)
)
BEGIN
    IF p_novo_stanje IS NOT NULL
       AND p_novo_stanje NOT IN ('ispravno','neispravno','u servisu','otpisano') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Neispravno stanje. Dozvoljeno: ispravno, neispravno, u servisu, otpisano.';
    END IF;

    INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
    VALUES (p_oprema_id, p_zaposlenik_id, CURDATE(), p_opis);

    IF p_novo_stanje IS NOT NULL THEN
        UPDATE oprema
        SET stanje = p_novo_stanje
        WHERE id = p_oprema_id;
    END IF;
END//


/* ------------------------------------------------------------
   3.4 PROCEDURA: sp_izvjestaj_oprema_po_dobavljacu
       - prikazuje: svu opremu za jednog dobavljača
       - uključuje: prostoriju, zadnje održavanje i broj dana od zadnjeg
   ------------------------------------------------------------ */
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
END//


/* ------------------------------------------------------------
   3.5 PROCEDURA: sp_azuriraj_opremu
       - ažurira: podatke o opremi
       - COALESCE: ako je parametar NULL, podatak se ne mijenja
   ------------------------------------------------------------ */
CREATE PROCEDURE sp_azuriraj_opremu (
    IN p_oprema_id INT,
    IN p_naziv VARCHAR(150),
    IN p_prostorija_id INT,
    IN p_dobavljac_id INT,
    IN p_stanje VARCHAR(20)
)
BEGIN
    IF p_stanje IS NOT NULL
       AND p_stanje NOT IN ('ispravno','neispravno','u servisu','otpisano') THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Neispravno stanje. Dozvoljeno: ispravno, neispravno, u servisu, otpisano.';
    END IF;

    UPDATE oprema
    SET
        naziv = COALESCE(p_naziv, naziv),
        prostorija_id = COALESCE(p_prostorija_id, prostorija_id),
        dobavljac_id = COALESCE(p_dobavljac_id, dobavljac_id),
        stanje = COALESCE(p_stanje, stanje)
    WHERE id = p_oprema_id;
END//


/* ------------------------------------------------------------
   3.6 PROCEDURA: sp_obrisi_odrzavanje
       - briše: zapis održavanja po ID-u
   ------------------------------------------------------------ */
CREATE PROCEDURE sp_obrisi_odrzavanje (
    IN p_odrzavanje_id INT
)
BEGIN
    DELETE FROM odrzavanje
    WHERE id = p_odrzavanje_id;
END//

DELIMITER ;

DELIMITER ;


