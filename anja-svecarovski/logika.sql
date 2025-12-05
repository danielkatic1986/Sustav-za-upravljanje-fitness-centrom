# SLOŽENI UPITI

# Broj zaposlenika po odjelu (uz info o aktivnosti odjela)

SELECT o.naziv AS odjel, o.aktivno, COUNT(z.id) AS broj_zaposlenika
    FROM odjel o
    LEFT JOIN radno_mjesto rm ON rm.id_odjel = o.id
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY o.id
    ORDER BY broj_zaposlenika DESC;

## Broj zaposlenika po radnom mjestu

SELECT rm.naziv AS radno_mjesto, COUNT(z.id) AS broj_zaposlenika
    FROM radno_mjesto rm
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY rm.id
    ORDER BY broj_zaposlenika DESC;

## Zaposlenici kojima ugovor uskoro istječe (30 dana)

SELECT z.ime, z.prezime, z.datum_prestanka, DATEDIFF(z.datum_prestanka, CURDATE()) AS dana_do_isteka
    FROM zaposlenik z
    WHERE z.datum_prestanka IS NOT NULL
    AND DATEDIFF(z.datum_prestanka, CURDATE()) BETWEEN 0 AND 30
    ORDER BY z.datum_prestanka;


## Broj zaposlenika po spolu i odjelu

SELECT o.naziv AS odjel, SUM(CASE WHEN z.spol = 'M' THEN 1 ELSE 0 END) AS musko, SUM(CASE WHEN z.spol = 'Ž' THEN 1 ELSE 0 END) AS zensko
    FROM odjel o
    LEFT JOIN radno_mjesto rm ON rm.id_odjel = o.id
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY o.id;

## Prosječna dob zaposlenika po odjelu

SELECT o.naziv AS odjel, ROUND(AVG(TIMESTAMPDIFF(YEAR, z.datum_rodenja, CURDATE())), 1) AS prosjecna_dob
    FROM odjel o
    LEFT JOIN radno_mjesto rm ON rm.id_odjel = o.id
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY o.id;

# POGLEDI

## Neaktivni zaposlenici

CREATE VIEW view_neaktivni_zaposlenici AS
	SELECT id, ime, prezime, datum_zaposlenja, datum_prestanka, status_zaposlenika,
    CONCAT(
		FLOOR(DATEDIFF(datum_prestanka, datum_zaposlenja)/365.25), ' godina, ',
		FLOOR((DATEDIFF(datum_prestanka, datum_zaposlenja) - FLOOR(DATEDIFF(datum_prestanka, datum_zaposlenja)/365.25)*365.25)/30.44), ' mjeseci'
        ) AS ukupno_zaposlen
    FROM zaposlenik
    WHERE status_zaposlenika = 'neaktivan';

SELECT *
FROM view_neaktivni_zaposlenici;

## Aktivni zaposlenici koji rade kao treneri

CREATE VIEW view_zaposlenici_treneri AS
	SELECT z.id, z.ime, z.prezime, rm.naziv AS 'Radno mjesto', p.naziv AS 'Podruznica'
    FROM zaposlenik z
		INNER JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
        INNER JOIN podruznica p ON z.id_podruznica = p.id
    WHERE status_zaposlenika = 'aktivan'
    AND z.id_radno_mjesto = 1;

SELECT *
FROM view_zaposlenici_treneri;

## Podaci o zaposlenicima s radnim mjestom, odjelom i statusom

CREATE VIEW view_zaposlenici_radno_mjesto_odjel AS
	SELECT z.id, z.ime, z.prezime, z.oib, z.datum_rodenja, z.spol, z.datum_zaposlenja, z.datum_prestanka, z.status_zaposlenika, z.placa, rm.naziv AS 'Radno mjesto', o.naziv AS 'Odjel', p.naziv AS 'Podruznica'
    FROM zaposlenik z
		INNER JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
        INNER JOIN podruznica p ON z.id_podruznica = p.id
        INNER JOIN odjel o ON rm.id_odjel = o.id;

SELECT *
FROM view_zaposlenici_radno_mjesto_odjel;

# FUNKCIJE

## Broj zaposlenih u određenom odjelu

DELIMITER //
CREATE FUNCTION broj_zaposlenih_odjel(p_id_odjel INT) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE rezultat INT;
    SELECT COUNT(z.id) INTO rezultat
        FROM zaposlenik z
        JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
        WHERE rm.id_odjel = p_id_odjel;
	RETURN rezultat;
END //
DELIMITER ;

SELECT broj_zaposlenih_odjel(1) FROM DUAL;

## Broj zaposlenika na određenom radnom mjestu

DELIMITER //
CREATE FUNCTION broj_na_radnom_mjestu(p_id_radno_mjesto INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE rezultat INT;
    SELECT COUNT(*) INTO rezultat
        FROM zaposlenik
        WHERE id_radno_mjesto = p_id_radno_mjesto;
    RETURN rezultat;
END //
DELIMITER ;

SELECT broj_na_radnom_mjestu(1) FROM DUAL;

## Prosječna plaću u odjelu

DELIMITER //
CREATE FUNCTION prosjecna_placa_odjela(p_odjel_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE rezultat DECIMAL(10,2);
        SELECT AVG(z.placa) INTO rezultat
        FROM zaposlenik z
        JOIN radno_mjesto rm ON rm.id = z.id_radno_mjesto
        WHERE rm.id_odjel = p_odjel_id;
    RETURN rezultat;
END //
DELIMITER ;

SELECT prosjecna_placa_odjela(1) FROM DUAL;

## Puni naziv zaposlenika

DELIMITER //
CREATE FUNCTION puno_ime(p_zaposlenik_id INT)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE ime_prezime VARCHAR(200);
    SELECT CONCAT(ime, ' ', prezime) INTO ime_prezime
    FROM zaposlenik
    WHERE id = p_zaposlenik_id;

    RETURN ime_prezime;
END //
DELIMITER ;

SELECT puno_ime(1) FROM DUAL;

## Starost zaposlenika

DELIMITER //
CREATE FUNCTION starost_zaposlenika(p_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE godine INT;
    SELECT TIMESTAMPDIFF(YEAR, datum_rodenja, CURDATE()) INTO godine
        FROM zaposlenik
        WHERE id = p_id;
    RETURN godine;
END //
DELIMITER ;

SELECT starost_zaposlenika(1);

# PROCEDURE

## Azuriranje radnog mjesta zaposlenika

DELIMITER //
CREATE PROCEDURE azuriraj_radno_mjesto (IN p_zaposlenik_id INT, IN p_novo_radno_mjesto INT)
BEGIN
    UPDATE zaposlenik
    SET id_radno_mjesto = p_novo_radno_mjesto
    WHERE id = p_zaposlenik_id;
END //
DELIMITER ;

CALL azuriraj_radno_mjesto(1,2);

## Azuriranje statusa zaposlenika aktivan i neaktivan

DELIMITER //
CREATE PROCEDURE azuriraj_status (IN p_zaposlenik_id INT, IN p_status VARCHAR(20))
BEGIN
    UPDATE zaposlenik
    SET status_zaposlenika = p_status
    WHERE id = p_zaposlenik_id;
END //
DELIMITER ;

CALL azuriraj_status(1, 'Neaktivan');

## Azuriranje broj zaposlenika u odjelu

DELIMITER //
CREATE PROCEDURE azuriraj_broj_zaposlenika_odjela (IN p_odjel_id INT)
BEGIN
    DECLARE ukupno INT;

    SELECT COUNT(z.id) INTO ukupno
        FROM zaposlenik z
        JOIN radno_mjesto rm ON rm.id = z.id_radno_mjesto
        WHERE rm.id_odjel = p_odjel_id;

    UPDATE odjel
    SET broj_zaposlenika = ukupno
    WHERE id = p_odjel_id;
END //
DELIMITER ;

CALL azuriraj_broj_zaposlenika_odjela (1);

## Premještanje zaposlenika u drugu podružnicu

DELIMITER //
CREATE PROCEDURE premjesti_podruznica (IN p_zaposlenik_id INT, IN p_nova_podruznica INT)
BEGIN
    UPDATE zaposlenik
    SET id_podruznica = p_nova_podruznica
    WHERE id = p_zaposlenik_id;
END //
DELIMITER ;

CALL premjesti_podruznica(1,9);

## Promjena plaće zaposlenika

DELIMITER //
CREATE PROCEDURE promijeni_placu (IN p_zaposlenik_id INT, IN p_nova_placa DECIMAL(10,2))
BEGIN
    UPDATE zaposlenik
    SET placa = p_nova_placa
    WHERE id = p_zaposlenik_id;
END //
DELIMITER ;

CALL promijeni_placu(1, 8000.00);

# OKIDAČI

## Automatsko azuriranje statusa nakon unosa datuma prestanka zaposlenja

DELIMITER //
CREATE TRIGGER bu_status_prestanak_zaposlenik
BEFORE UPDATE ON zaposlenik
FOR EACH ROW
BEGIN
    IF NEW.datum_prestanka IS NOT NULL THEN
        SET NEW.status_zaposlenika = 'neaktivan';
    END IF;
END //
DELIMITER ;

UPDATE zaposlenik SET datum_prestanka = STR_TO_DATE('05.12.2025.', '%d.%m.%Y.') WHERE id = 2;

## Automatsko postavljanje statusa na aktivan prilikom kreiranja novog zaposlenika

DELIMITER //
CREATE TRIGGER bi_status_zaposlenik
BEFORE INSERT ON zaposlenik
FOR EACH ROW
BEGIN
    IF NEW.status_zaposlenika IS NULL THEN
        SET NEW.status_zaposlenika = 'aktivan';
    END IF;
END //
DELIMITER ;

INSERT INTO zaposlenik 
(ime, prezime, oib, datum_rodenja, spol, adresa, id_mjesto, telefon, email, datum_zaposlenja, datum_prestanka, placa, id_radno_mjesto, id_podruznica) 
VALUES
('Anja', 'Anić', '1703988365046', STR_TO_DATE('17.03.1988.', '%d.%m.%Y.'), 'Ž', 'Splitska 12, Zagreb', 1, '0981925899', 'anja.anic@gmail.com', STR_TO_DATE('05.12.2025.', '%d.%m.%Y.'), NULL, 1500.00, 1, 1);

SELECT * FROM zaposlenik WHERE id = 101;

## Azuriranje broja zaposlenika u odjelu - dodavanje novog zaposlenog

DELIMITER //
CREATE TRIGGER ai_povecaj_broj_zaposlenik
AFTER INSERT ON zaposlenik
FOR EACH ROW
BEGIN
    UPDATE odjel d
    JOIN radno_mjesto rm ON rm.id_odjel = d.id
    SET d.broj_zaposlenika = d.broj_zaposlenika + 1
    WHERE rm.id = NEW.id_radno_mjesto;
END //
DELIMITER ;

INSERT INTO zaposlenik 
(ime, prezime, oib, datum_rodenja, spol, adresa, id_mjesto, telefon, email, datum_zaposlenja, datum_prestanka, placa, id_radno_mjesto, id_podruznica) 
VALUES
('Mima', 'Mojmić', '1050488365046', STR_TO_DATE('05.04.1988.', '%d.%m.%Y.'), 'Ž', 'Splitska 12, Pula', 1, '091788987', 'mima.mojmic@gmail.com', STR_TO_DATE('05.12.2025.', '%d.%m.%Y.'), NULL, 1600.00, 1, 1);

SELECT * FROM odjel ;
SELECT * FROM zaposlenik;

## Azuriranje broja zaposlenika u odjelu - brisanje zaposlenika

DELIMITER //
CREATE TRIGGER ad_smanji_broj_zaposlenik
AFTER DELETE ON zaposlenik
FOR EACH ROW
BEGIN
    UPDATE odjel d
    JOIN radno_mjesto rm ON rm.id_odjel = d.id
    SET d.broj_zaposlenika = d.broj_zaposlenika - 1
    WHERE rm.id = OLD.id_radno_mjesto;
END //
DELIMITER ;

DELETE FROM zaposlenik WHERE id = 102;
SELECT * FROM odjel;