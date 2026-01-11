/*
=================================================
                VLADAN KRIVOKAPIĆ
=================================================
*/

/*
  Baza podataka: fitness_centar
  Opis: pregledi (SELECT), VIEW-ovi, funkcije, procedure i eventi
*/

USE fitness_centar;

/* ============================================================
   3. PREGLEDI (SELECT)
   ============================================================ */

/* ------------------------------------------------------------
   3.1 Pogled: Pregled sve opreme s dobavljačem i prostorijom
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
   3.2 Pogled: Statistika opreme po dobavljačima
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
   3.3 Pogled: Oprema neispravna ili u servisu predugo bez održavanja
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
   4. VIEW-OVI (POGLEDI U BAZI)
   ============================================================ */

/* ------------------------------------------------------------
   4.1 VIEW: v_oprema_zadnje_odrzavanje
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
   4.2 VIEW: v_dobavljac_statistika
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
   4.3 VIEW: v_neispravna_oprema
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
   5. FUNKCIJE
   ============================================================ */

DELIMITER //

/* ------------------------------------------------------------
   5.1 FUNKCIJA: fn_zadnje_odrzavanje(oprema_id)
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
   5.2 FUNKCIJA: fn_dani_od_zadnjeg_odrzavanja(oprema_id)
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


/* ============================================================
   6. PROCEDURE
   ============================================================ */

/* ------------------------------------------------------------
   6.1 PROCEDURA: sp_evidentiraj_odrzavanje
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
   6.2 PROCEDURA: sp_izvjestaj_oprema_po_dobavljacu
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
   6.3 PROCEDURA: sp_azuriraj_opremu
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
   6.4 PROCEDURA: sp_obrisi_odrzavanje
   ------------------------------------------------------------ */
CREATE PROCEDURE sp_obrisi_odrzavanje (
    IN p_odrzavanje_id INT
)
BEGIN
    DELETE FROM odrzavanje
    WHERE id = p_odrzavanje_id;
END//


/* ============================================================
   7. EVENTS
   ============================================================ */

/* -------------------------------------------------
   7.1 EVENT: ev_oprema_predugo_u_servisu
   ------------------------------------------------- */
CREATE EVENT IF NOT EXISTS ev_oprema_predugo_u_servisu
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY)
DO
BEGIN
    UPDATE oprema o
    LEFT JOIN (
        SELECT oprema_id, MAX(datum) AS zadnje_odrzavanje
        FROM odrzavanje
        GROUP BY oprema_id
    ) od ON od.oprema_id = o.id
    SET o.stanje = 'neispravno'
    WHERE o.stanje = 'u servisu'
      AND DATEDIFF(
            CURDATE(),
            COALESCE(od.zadnje_odrzavanje, o.datum_nabave)
          ) > 180;
END//


/* -------------------------------------------------
   7.2 EVENT: ev_oprema_stara_bez_servisa
   ------------------------------------------------- */
CREATE EVENT IF NOT EXISTS ev_oprema_stara_bez_servisa
ON SCHEDULE EVERY 1 WEEK
STARTS (CURRENT_DATE + INTERVAL 7 DAY)
DO
BEGIN
    SELECT
        o.id AS oprema_id,
        o.naziv,
        o.stanje,
        DATEDIFF(
            CURDATE(),
            COALESCE(
                (SELECT MAX(od.datum)
                 FROM odrzavanje od
                 WHERE od.oprema_id = o.id),
                o.datum_nabave
            )
        ) AS dana_bez_servisa
    FROM oprema o
    WHERE o.stanje = 'ispravno'
    HAVING dana_bez_servisa > 365
    ORDER BY dana_bez_servisa DESC;
END//

DELIMITER ;

/* ============================================================
   8. TRANSAKCIJE
   ============================================================ */

/* ------------------------------------------------------------
   8.1 Transakcija: Evidentiranje održavanja + promjena stanja opreme
   ------------------------------------------------------------ */
START TRANSACTION;

INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
VALUES (2, 5, CURDATE(), 'Unos održavanja kroz transakciju + promjena stanja.');

UPDATE oprema
SET stanje = 'ispravno'
WHERE id = 2;

COMMIT;


/* ------------------------------------------------------------
   8.2 Transakcija: Premještaj opreme u drugu prostoriju + zapis održavanja
   ------------------------------------------------------------ */
START TRANSACTION;

UPDATE oprema
SET prostorija_id = 1
WHERE id = 3;

INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
VALUES (3, 4, CURDATE(), 'Premještaj opreme nakon pregleda/servisa.');

COMMIT;


/* ------------------------------------------------------------
   8.3 Transakcija: Primjer ROLLBACK-a (simulacija greške)
   ------------------------------------------------------------ */
START TRANSACTION;

UPDATE oprema
SET stanje = 'u servisu'
WHERE id = 6;

INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
VALUES (6, 5, CURDATE(), 'Zapis koji se neće spremiti jer radimo rollback.');

ROLLBACK;







