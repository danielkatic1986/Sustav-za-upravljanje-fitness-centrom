# SLOŽENI UPITI

# Broj zaposlenika po odjelu

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


## Prosječna dob zaposlenika po odjelu

SELECT o.naziv AS odjel, ROUND(AVG(TIMESTAMPDIFF(YEAR, z.datum_rodenja, CURDATE())), 1) AS prosjecna_dob
    FROM odjel o
    LEFT JOIN radno_mjesto rm ON rm.id_odjel = o.id
    LEFT JOIN zaposlenik z ON z.id_radno_mjesto = rm.id
    GROUP BY o.id;

# POGLEDI

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

## Zaposlenici koji danas slave rođendan ili imaju godišnjicu zaposlenja

CREATE VIEW danasnji_dogadjaji AS
	SELECT z.id AS zaposlenik_id, CONCAT(z.ime, ' ', z.prezime) AS puno_ime, z.datum_rodenja, z.datum_zaposlenja, rm.naziv AS radno_mjesto, o.naziv AS odjel,
    CASE 
        WHEN DAY(z.datum_rodenja) = DAY(CURDATE()) 
         AND MONTH(z.datum_rodenja) = MONTH(CURDATE())
        THEN 'Rodjendan'
        ELSE NULL
    END AS danas_rodjendan,
    CASE 
        WHEN DAY(z.datum_zaposlenja) = DAY(CURDATE())
         AND MONTH(z.datum_zaposlenja) = MONTH(CURDATE())
        THEN 'Dan zaposlenja'
        ELSE NULL
    END AS danas_zaposlen
FROM zaposlenik z
JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
JOIN odjel o ON rm.id_odjel = o.id
WHERE 
    (DAY(z.datum_rodenja) = DAY(CURDATE()) AND MONTH(z.datum_rodenja) = MONTH(CURDATE()))
    OR
    (DAY(z.datum_zaposlenja) = DAY(CURDATE()) AND MONTH(z.datum_zaposlenja) = MONTH(CURDATE()));

SELECT *
FROM danasnji_dogadjaji;

# FUNKCIJE

## Broj zaposlenih po spolu u odjelu

DELIMITER //
CREATE FUNCTION broj_zaposlenih_spol(p_id_odjel INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE br_zene INT DEFAULT 0;
    DECLARE br_muskarci INT DEFAULT 0;
    DECLARE ukupno INT DEFAULT 0;
    DECLARE odjel_ime VARCHAR(50);

    SELECT COUNT(CASE WHEN z.spol = 'Ž' THEN 1 END),
           COUNT(CASE WHEN z.spol = 'M' THEN 1 END)
        INTO br_zene, br_muskarci
        FROM zaposlenik z
        JOIN radno_mjesto rm ON z.id_radno_mjesto = rm.id
        WHERE rm.id_odjel = p_id_odjel;
    SET ukupno = br_zene + br_muskarci;
    SELECT naziv INTO odjel_ime
        FROM odjel
        WHERE id = p_id_odjel;
        
	RETURN CONCAT('Postotak zaposlenika po spolu u odjelu: ',odjel_ime,' -> ','Žene: ', ROUND((br_zene/ukupno)*100,2),'%', ', Muškarci: ', ROUND((br_muskarci/ukupno)*100,2),'%');
END //
DELIMITER ;

SELECT broj_zaposlenih_spol(1) FROM DUAL;

## Prosječna plaća u odjelu po spolu

DELIMITER //
CREATE FUNCTION prosjecna_placa_odjela_po_spolu(p_id_odjel INT) RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE rezultat_zene DECIMAL(10,2);
    DECLARE rezultat_muski DECIMAL(10,2);
    DECLARE odjel_ime VARCHAR(50);

    SELECT AVG(CASE WHEN z.spol = 'Ž' THEN z.placa END),
           AVG(CASE WHEN z.spol = 'M' THEN z.placa END)
        INTO rezultat_zene, rezultat_muski
        FROM zaposlenik z
        JOIN radno_mjesto rm ON rm.id = z.id_radno_mjesto
        WHERE rm.id_odjel = p_id_odjel;
    SELECT naziv INTO odjel_ime
        FROM odjel
        WHERE id = p_id_odjel;

    RETURN CONCAT('Prosječna plaća u odjelu: ', odjel_ime, ' -> Žene: ', ROUND(rezultat_zene,2),' EUR', ', Muškarci: ', ROUND(rezultat_muski,2),' EUR');
END //
DELIMITER ;

SELECT prosjecna_placa_odjela_po_spolu(1) FROM DUAL;

## Današnji dogadjaji - overview

DELIMITER //
CREATE FUNCTION danasnji_dogadjaji_zaposlenika() RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN
    DECLARE br_rodjendan INT;
    DECLARE br_godisnjica INT;

    SELECT COUNT(*) INTO br_rodjendan
        FROM zaposlenik
        WHERE DAY(datum_rodenja) = DAY(CURDATE())
        AND MONTH(datum_rodenja) = MONTH(CURDATE());

    SELECT COUNT(*) INTO br_godisnjica
        FROM zaposlenik
        WHERE DAY(datum_zaposlenja) = DAY(CURDATE())
        AND MONTH(datum_zaposlenja) = MONTH(CURDATE());

    RETURN CONCAT('Danas rođendan slavi ', br_rodjendan,' zaposlenika, a godišnjicu zaposlenja slavi ',br_godisnjica, ' zaposlenika.');
END //
DELIMITER ;

SELECT danasnji_dogadjaji_zaposlenika() FROM DUAL;

# PROCEDURE

## Azuriranje radnog mjesta zaposlenika i broj zaposlenika u odjelu

DELIMITER //
CREATE PROCEDURE azuriraj_radno_mjesto (IN p_zaposlenik_id INT, IN p_novo_radno_mjesto INT)
BEGIN
    DECLARE stari_odjel INT;
    DECLARE novi_odjel INT;

    SELECT rm.id_odjel
    INTO stari_odjel
    FROM zaposlenik z
    JOIN radno_mjesto rm ON rm.id = z.id_radno_mjesto
    WHERE z.id = p_zaposlenik_id;

    SELECT id_odjel
    INTO novi_odjel
    FROM radno_mjesto
    WHERE id = p_novo_radno_mjesto;

    IF stari_odjel <> novi_odjel THEN
        UPDATE odjel
        SET broj_zaposlenika = broj_zaposlenika - 1
        WHERE id = stari_odjel;

        UPDATE odjel
        SET broj_zaposlenika = broj_zaposlenika + 1
        WHERE id = novi_odjel;
    END IF;
    
    UPDATE zaposlenik
    SET id_radno_mjesto = p_novo_radno_mjesto
    WHERE id = p_zaposlenik_id;
END //
DELIMITER ;

CALL azuriraj_radno_mjesto(1,4);

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
