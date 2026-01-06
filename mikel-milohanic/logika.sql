DELIMITER //
-- -------- --
-- Funkcije --
-- -------- --

-- Funkcija koja provjerava preklapanje termina za trenere i rezervacija za članove
DROP FUNCTION IF EXISTS fn_slobodan_termin //
CREATE FUNCTION fn_slobodan_termin(p_id_osoba INTEGER, p_uloga ENUM('c', 't'), p_vrijeme_pocetka TIMESTAMP, p_vrijeme_zavrsetka TIMESTAMP) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	DECLARE v_rez BOOLEAN;
    
    IF p_uloga = 'c' THEN
		SELECT NOT EXISTS (
			SELECT 1
			FROM   rezervacija r
			JOIN   termin_treninga tt ON r.termin_treninga_id = tt.id
			WHERE  r.clan_id = p_id_osoba
            AND    tt.vrijeme_pocetka > CURRENT_TIMESTAMP()
			AND    p_vrijeme_pocetka <= tt.vrijeme_zavrsetka
			AND    p_vrijeme_zavrsetka >= tt.vrijeme_pocetka
		) INTO v_rez;
	ELSE
		SELECT NOT EXISTS (
			SELECT 1
			FROM   termin_treninga tt
			WHERE  tt.trener_id = p_id_osoba
            AND    tt.vrijeme_pocetka > CURRENT_TIMESTAMP()
			AND    p_vrijeme_pocetka <= tt.vrijeme_zavrsetka
			AND    p_vrijeme_zavrsetka >= tt.vrijeme_pocetka
		) INTO v_rez;
	END IF;
    
    RETURN v_rez;
END //

-- Funkcija koja vraća prvi slobodni termin unutar tjedan dana za pet dana od sada
DROP FUNCTION IF EXISTS fn_prvi_slobodan_termin //
CREATE FUNCTION fn_prvi_slobodan_termin(p_trener_id INTEGER, p_trening_id INTEGER) RETURNS TIMESTAMP
DETERMINISTIC
BEGIN
	DECLARE v_rubno_vrijeme TIMESTAMP DEFAULT CURRENT_DATE() + INTERVAL 5 DAY + INTERVAL 8 HOUR;
    DECLARE v_rez TIMESTAMP DEFAULT NULL;
	DECLARE v_vrijeme_pocetka, v_vrijeme_zavrsetka TIMESTAMP;
    DECLARE v_trajanje_treninga_min INTEGER;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
		SELECT vrijeme_pocetka,
			   vrijeme_zavrsetka
		FROM   termin_treninga
		WHERE  trener_id = p_trener_id
		AND    vrijeme_pocetka BETWEEN v_rubno_vrijeme
								   AND v_rubno_vrijeme + INTERVAL 7 DAY;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	IF NOT EXISTS (
		SELECT 1
		FROM   zaposlenik
		WHERE  id = p_trener_id
		AND    id_radno_mjesto = 1
		AND    status_zaposlenika = 'aktivan') THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Došlo je do greške: uneseni \'id\' trenera ne postoji ili više nije aktivan.';
	ELSE
        SELECT planirano_trajanje_min
        INTO   v_trajanje_treninga_min
        FROM   trening
        WHERE  id = p_trening_id;
		
        OPEN cur;
		petlja: LOOP
			FETCH cur INTO v_vrijeme_pocetka, v_vrijeme_zavrsetka;
			
			IF (v_rez <> NULL) OR done THEN
				LEAVE petlja;
			END IF;
			
			IF TIMESTAMPDIFF(MINUTE, v_rubno_vrijeme, v_vrijeme_pocetka) >= v_trajanje_treninga_min + 30 THEN
				IF v_rubno_vrijeme + INTERVAL (v_trajanje_treninga_min + 30) MINUTE > DATE(v_rubno_vrijeme) + INTERVAL 22 HOUR THEN
					SET v_rubno_vrijeme = DATE(v_rubno_vrijeme) + INTERVAL 1 DAY + INTERVAL 8 HOUR;
				ELSE
					SET v_rez = v_rubno_vrijeme + INTERVAL 15 MINUTE;
				END IF;
			ELSE
				SET v_rubno_vrijeme = v_vrijeme_zavrsetka;
			END IF;
		END LOOP petlja;
		CLOSE cur;
	END IF;
	
    RETURN v_rez;
END //

-- Funkcija koja za danu podružnicu vraća postotak prošlih termina koji nisu imali niti jednu rezervaciju
DROP FUNCTION IF EXISTS fn_termina_bez_rezervacije //
CREATE FUNCTION fn_termina_bez_rezervacije(p_podruznica_id INTEGER) RETURNS VARCHAR(4)
DETERMINISTIC
BEGIN
	DECLARE v_ukupno_termina, v_ukupno_bez_rezervacije INTEGER;
    
    DROP TEMPORARY TABLE IF EXISTS prosli_termini;
    CREATE TEMPORARY TABLE prosli_termini (
        broj_rezervacija INTEGER
	);
    
    INSERT INTO prosli_termini
		SELECT tt.rezervirano
		FROM   termin_treninga tt
		JOIN   prostorija p ON tt.prostorija_id = p.id
		WHERE  p.podruznica_id = p_podruznica_id
		AND    vrijeme_zavrsetka < CURRENT_TIMESTAMP();
    
    SELECT COUNT(*)
    INTO   v_ukupno_termina
    FROM   prosli_termini;
    
    IF NOT v_ukupno_termina THEN
		RETURN '0%';
	END IF;
    
    SELECT COUNT(*)
    INTO   v_ukupno_bez_rezervacije
    FROM   prosli_termini 
    WHERE  broj_rezervacija = 0;
    
    RETURN CONCAT(ROUND(v_ukupno_bez_rezervacije/v_ukupno_termina*100, 0), '%');
END //
SELECT naziv, fn_termina_bez_rezervacije(id) AS postotak_treninga_bez_rezervacija FROM podruznica // 

-- --------- --
-- Procedure --
-- --------- --

-- Procedura koja raspodjeljuje nadolazeće termine treninga nekog trenera
DROP PROCEDURE IF EXISTS sp_raspodijeli_termine //
CREATE PROCEDURE sp_raspodijeli_termine(IN p_trener_id INTEGER)
BEGIN
    DECLARE v_trener_id, v_podruznica_id, v_termin_treninga_id INTEGER;
    DECLARE v_vrijeme_pocetka_termina, v_vrijeme_zavrsetka_termina TIMESTAMP;
    DECLARE v_autocommit BOOLEAN;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
		SELECT id,
			   vrijeme_pocetka,
               vrijeme_zavrsetka
        FROM   termin_treninga
        WHERE  trener_id = p_trener_id
        AND    vrijeme_pocetka > CURRENT_TIMESTAMP();
	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET done = TRUE;
    DECLARE EXIT HANDLER FOR 1644 
		SELECT 'Došlo je do greške: ne postoji trener s unesenim \'id\'-jem.' AS PORUKA_GRESKE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
            SET AUTOCOMMIT = v_autocommit;
            SELECT 'Došlo je do greške: procedura \'raspodijeli_termine\' je prisilno zaustavljena, a sve promjene su poništene.' AS PORUKA_GRESKE;
		END;
    
    SET v_autocommit = @@autocommit;
    
	IF NOT EXISTS (
		SELECT 1
		FROM   zaposlenik
		WHERE  id = p_trener_id
		AND    id_radno_mjesto = 1) THEN
			SIGNAL SQLSTATE '45001';
	END IF;
    
    SELECT id_podruznica
    INTO   v_podruznica_id
    FROM   zaposlenik
    WHERE  id = p_trener_id;
    
	DROP TEMPORARY TABLE IF EXISTS termini_trenera;
	CREATE TEMPORARY TABLE termini_trenera (
		trener_id INTEGER,
        broj_termina INTEGER,
        
        PRIMARY KEY (trener_id)
	);
    
    INSERT INTO termini_trenera
		SELECT     	t.id, COUNT(tt.id)
        FROM	   	termin_treninga tt
        RIGHT JOIN (SELECT id
					FROM   zaposlenik
                    WHERE  id <> p_trener_id
                    AND    id_radno_mjesto = 1
                    AND    id_podruznica = v_podruznica_id
                    AND    status_zaposlenika = 'aktivan') AS t ON tt.trener_id = t.id
		WHERE 		vrijeme_pocetka > CURRENT_TIMESTAMP()
		GROUP BY   	t.id;
	
    OPEN cur;
    SET AUTOCOMMIT = OFF;
	petlja: LOOP
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
		START TRANSACTION;
		FETCH cur INTO v_termin_treninga_id, v_vrijeme_pocetka_termina, v_vrijeme_zavrsetka_termina;
        
        IF done THEN
			LEAVE petlja;
		END IF;
        
        SELECT	 trener_id
        INTO	 v_trener_id
        FROM	 termini_trenera
        WHERE	 trener_id NOT IN  (SELECT DISTINCT trener_id
									FROM   termin_treninga
									WHERE  v_vrijeme_pocetka_termina <= vrijeme_zavrsetka
									AND    v_vrijeme_zavrsetka_termina >= vrijeme_pocetka)
		ORDER BY broj_termina ASC
        LIMIT    1;
        
        IF v_trener_id IS NULL THEN
			UPDATE termin_treninga
            SET    otkazan = TRUE
            WHERE  termin_treninga.id = v_termin_treninga_id;
		ELSE
			UPDATE termin_treninga
            SET    trener_id = v_trener_id
            WHERE  termin_treninga.id = v_termin_treninga_id;
            
            UPDATE termini_trenera
            SET    broj_termina = broj_termina + 1
            WHERE  trener_id = v_trener_id;
		END IF;
		COMMIT;
    END LOOP petlja;
    SET AUTOCOMMIT = v_autocommit;
    CLOSE cur;
END //

-- Procedura koja traži nektivne trenere s zakazin terminima i raspodjeljuje njihove termine
DROP PROCEDURE IF EXISTS sp_provjeri_trenere //
CREATE PROCEDURE sp_provjeri_trenere()
BEGIN
	DECLARE v_trener_id INTEGER;
    DECLARE done BOOLEAN DEFAULT FALSE;
	DECLARE cur CURSOR FOR
		SELECT   DISTINCT n.id
		FROM     (SELECT id
				  FROM   zaposlenik
				  WHERE  id_radno_mjesto = 1
				  AND    status_zaposlenika = 'neaktivan') AS n
		JOIN	 (SELECT id, trener_id
				  FROM   termin_treninga
				  WHERE  vrijeme_pocetka > CURRENT_TIMESTAMP()) AS tt
				  ON n.id = tt.trener_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	OPEN cur;
	petlja: LOOP
		FETCH cur INTO v_trener_id;
        
        IF done THEN
			LEAVE petlja;
		END IF;
        
        CALL sp_raspodijeli_termine(v_trener_id);
        
    END LOOP petlja;
    CLOSE cur;
END //

-- Procedura koja bilježi promjene nad količinom rezervacija na danom terminu
DROP PROCEDURE IF EXISTS sp_evidencija_rezervacija_termina //
CREATE PROCEDURE sp_evidencija_rezervacija_termina(IN p_termin_treninga_id INTEGER, IN p_promjena INTEGER)
BEGIN
	DECLARE v_trenutno_rezervacija, v_max_kapacitet INTEGER;
    
    SELECT	 tt.rezervirano,
			 p.kapacitet
	INTO	 v_trenutno_rezervacija,
			 v_max_kapacitet
    FROM	 (SELECT *
			  FROM termin_treninga
			  WHERE id = p_termin_treninga_id) AS tt
    JOIN	 prostorija p ON tt.prostorija_id = p.id;
    
    
    IF v_trenutno_rezervacija + p_promjena > v_max_kapacitet THEN
		SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'Nije moguće unijeti novu rezervaciju: kapacitet termina je popunjen.';
	ELSE
		UPDATE termin_treninga
		SET    rezervirano = v_trenutno_rezervacija + p_promjena
		WHERE  id = p_termin_treninga_id;
	END IF;
END//

-- Zamjena prostorija dvaju termina treninga
DROP PROCEDURE IF EXISTS sp_zamjeni_prostorije //
CREATE PROCEDURE sp_zamjeni_prostorije(IN p_termin_1 INTEGER, IN p_termin_2 INTEGER)
BEGIN
	DECLARE v_prostorija_1, v_prostorija_2 INTEGER;
    DECLARE v_autocommit BOOLEAN;
	DECLARE EXIT HANDLER FOR 3572 
		SELECT 'Došlo je do greške: redak se ne može zaključati jer je zaključan od strane neke druge transakcije.' AS PORUKA_GRESKE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
            SET AUTOCOMMIT = v_autocommit;
            SELECT 'Došlo je do greške: procedura \'zamjeni_prostorije\' je prisilno zaustavljena, a sve promjene su poništene.' AS PORUKA_GRESKE;
		END;    
	
    SET v_autocommit = @@autocommit;
    SET AUTOCOMMIT = OFF;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;
    
    SELECT prostorija_id
    INTO   v_prostorija_1
    FROM   termin_treninga
    WHERE  id = p_termin_1
    FOR UPDATE NOWAIT;
    
    SELECT prostorija_id
    INTO   v_prostorija_2
    FROM   termin_treninga
    WHERE  id = p_termin_2
    FOR UPDATE NOWAIT;
    
    UPDATE termin_treninga
    SET    prostorija_id = v_prostorija_2
    WHERE  id = p_termin_1;
    
    UPDATE termin_treninga
    SET    prostorija_id = v_prostorija_1
    WHERE  id = p_termin_2;
    
    COMMIT;
    SET AUTOCOMMIT = v_autocommit;
END //

-- ---------------- --
-- Triggeri/okidači --
-- ---------------- --

-- Okidač koji prilikom unosa termina treninga računa vrijeme završetka ovisno o treningu
DROP TRIGGER IF EXISTS bi_termin_treninga //
CREATE TRIGGER bi_termin_treninga
BEFORE INSERT ON termin_treninga
FOR EACH ROW
BEGIN
	DECLARE v_trajanje_treninga INTEGER;
	
	SELECT planirano_trajanje_min
		INTO v_trajanje_treninga
		FROM trening
		WHERE trening.id = NEW.trening_id;
	
	IF v_trajanje_treninga IS NULL THEN
		SIGNAL SQLSTATE '45003'
		SET MESSAGE_TEXT = 'Nije moguće unijeti termin treninga: nepostojeći trening.';
	END IF;
    
	SET NEW.vrijeme_zavrsetka = NEW.vrijeme_pocetka + INTERVAL v_trajanje_treninga MINUTE;
    
	IF NOT fn_slobodan_termin(NEW.trener_id, 't', NEW.vrijeme_pocetka, NEW.vrijeme_zavrsetka) THEN
		SIGNAL SQLSTATE '45004'
		SET MESSAGE_TEXT = 'Nije moguće unijeti termin treninga: postoji zakazan trening koji se preklapa s unesenim terminom.';
	END IF;
    
	SET NEW.otkazan = COALESCE(NEW.otkazan, FALSE);
END //

-- Okidač koji provjerava preklapanje rezervacije i povećava popunjenost termina
DROP TRIGGER IF EXISTS bi_rezervacija //
CREATE TRIGGER bi_rezervacija
BEFORE INSERT ON rezervacija
FOR EACH ROW
BEGIN
	DECLARE v_vrijeme_pocetka, v_vrijeme_zavrsetka TIMESTAMP;
    
    SELECT vrijeme_pocetka,
		   vrijeme_zavrsetka
	INTO   v_vrijeme_pocetka,
		   v_vrijeme_zavrsetka
	FROM   termin_treninga
    WHERE  id = NEW.termin_treninga_id;
    
	IF NOT fn_slobodan_termin(NEW.clan_id, 'c', v_vrijeme_pocetka, v_vrijeme_zavrsetka) THEN
		SIGNAL SQLSTATE '45005'
		SET MESSAGE_TEXT = 'Nije moguće unijeti rezervaciju termina treninga: preklapanje s postojećom rezervacijom.';
	ELSE
		CALL sp_evidencija_rezervacija_termina(NEW.termin_treninga_id, 1);
	END IF;
END //

-- Okidač koji smanjuje popunjenost termina treninga kada se otkaže rezervacija
DROP TRIGGER IF EXISTS ad_rezervacija //
CREATE TRIGGER ad_rezervacija
AFTER DELETE ON rezervacija
FOR EACH ROW
BEGIN
	CALL sp_evidencija_rezervacija_termina(OLD.termin_treninga_id, -1);
END //

-- Okidač koji ne dozvoljava da se kapacitet prostorije postavi na manje od najvećeg
-- broja rezervacija za tu prostoriju na nekom od nadolazećih termina
-- te kroz grašku javlja koliko ima takvih termina
DROP TRIGGER IF EXISTS bu_prostorija //
CREATE TRIGGER bu_prostorija
BEFORE UPDATE ON prostorija
FOR EACH ROW
BEGIN
	IF NEW.kapacitet < OLD.kapacitet
		AND EXISTS (
			SELECT  1
			FROM    termin_treninga
			WHERE   prostorija_id = NEW.id
			AND		vrijeme_pocetka > CURRENT_TIMESTAMP()
			AND     rezervirano > NEW.kapacitet
		) THEN
		SIGNAL SQLSTATE '45006'
		SET MESSAGE_TEXT = 'Greška prilikom promijene kapaciteta prostorije: postoje nadolazeći termini s više rezervacija od novo unesenog kapaciteta.';
	END IF;
END //

DELIMITER ;

-- ------- --
-- Pogledi --
-- ------- --

-- Pregled odrađenih treninga po poslovnicama u proteklih mjesec dana , sortirano silazno
CREATE VIEW vw_proteklih_mjesec_treninga_po_podruznicama AS
SELECT 	 po.naziv, COUNT(*) AS odradeno_treninga
FROM 	 termin_treninga tt
JOIN 	 prostorija pr ON tt.prostorija_id = pr.id
JOIN 	 podruznica po ON pr.podruznica_id = po.id
WHERE 	 otkazan IS FALSE
AND 	 vrijeme_pocetka >= CURRENT_TIMESTAMP() - INTERVAL 1 MONTH
AND 	 vrijeme_zavrsetka < CURRENT_TIMESTAMP()
GROUP BY po.id
ORDER BY odradeno_treninga DESC;

-- 10 trenera s najviše otkazanih termina
CREATE VIEW vw_treneri_s_najvise_otkazivanja AS
SELECT 	  z.id,
		  z.ime,
          z.prezime,
		  COUNT(*) AS broj_otkazanih
FROM 	  (SELECT *
		   FROM   zaposlenik
           WHERE  id_radno_mjesto = 1
           AND    status_zaposlenika = 'aktivan') AS z
LEFT JOIN (SELECT *
		   FROM   termin_treninga
           WHERE  otkazan IS TRUE) AS ot ON z.id = ot.trener_id
GROUP BY  z.id
ORDER BY  broj_otkazanih DESC
LIMIT 	  10;

-- Centri koji nude sve tipove prostorija
CREATE VIEW vw_podruznice_s_svim_sadrzajima AS
SELECT	 po.naziv,
		 po.adresa,
         m.postanski_broj
FROM	 prostorija pr
JOIN	 podruznica po ON pr.podruznica_id = po.id
JOIN	 mjesto m ON po.id_mjesto = m.id
GROUP BY po.id
HAVING	 COUNT(DISTINCT tip_prostorije_id) = (SELECT COUNT(*) FROM tip_prostorije);

-- Pregled broja rezervacija po treningu za nadolazećih mjesec dana
CREATE VIEW vw_nadolazece_rezervacije_po_treningu AS
SELECT	  prg.naziv AS tip_programa,
          tr.razina AS razina_treninga,
          CONCAT(z.ime, ' ', z.prezime) AS trener,
          prs.oznaka AS prostorija,
          prs.podruznica_id AS podruznica,
          tt.vrijeme_pocetka,
          tt.vrijeme_zavrsetka,
          tt.napomena,
          COUNT(*) AS broj_rezervacija
FROM 	  termin_treninga tt
LEFT JOIN rezervacija r ON tt.id = r.termin_treninga_id
JOIN 	  trening tr ON tt.trening_id = tr.id
JOIN 	  program prg ON tr.program_id = prg.id
JOIN 	  zaposlenik z ON tt.trener_id = z.id
JOIN	  prostorija prs ON tt.prostorija_id = prs.id
WHERE 	  tt.vrijeme_pocetka BETWEEN CURRENT_TIMESTAMP() AND CURRENT_TIMESTAMP() + INTERVAL 1 MONTH
AND 	  tt.otkazan IS FALSE
GROUP BY  tt.id;

-- Pregled broja etaža po podružnicama
CREATE VIEW vw_etaze_po_podruznicama AS
SELECT 	 po.naziv,
		 po.adresa,
		 COUNT(DISTINCT IF(lokacija LIKE '%,%', LEFT(lokacija, LOCATE(',', lokacija) - 1), lokacija)) AS broj_etaza
FROM   	 prostorija pr
JOIN   	 podruznica po on pr.podruznica_id = po.id
WHERE 	 lokacija <> 'Vani'
GROUP BY po.id;

-- ----- --
-- Upiti --
-- ----- --

-- Ukupan kapacitet svih prostorija po podružnicama
SELECT p.id,
	   p.naziv,
       p.adresa,
       uk.ukupan_kapacitet
FROM   podruznica p
JOIN   (SELECT   podruznica_id,
				 SUM(kapacitet) AS ukupan_kapacitet
		FROM 	 prostorija
		GROUP BY podruznica_id) AS uk ON p.id = uk.podruznica_id;

-- Udio načina rezervacije u postocima
SELECT	 nacin_rezervacije,
		 CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM rezervacija)*100, 1), ' %') AS udio
FROM	 rezervacija
GROUP BY nacin_rezervacije;

-- Prosjek rezervacija mjesečno na razini svih podružnica
SELECT CAST(AVG(br.broj_rezervacija) AS UNSIGNED) AS prosjek_rezervacija_mjesecno
FROM   (SELECT 	 COUNT(*) AS broj_rezervacija
		FROM 	 rezervacija
		GROUP BY DATE_FORMAT(DATE(vrijeme_rezervacije), '%m.%Y.')) AS br;

--  Ukupan broj nadolazećih rezervacija i prosječan broj dana koliko unaprijed članovi rezerviraju termine treninga, po podružnicama
SELECT   po.naziv AS podruznica,
		 COUNT(r.id) AS broj_rezervacija,
         ROUND(AVG(DATEDIFF(tt.vrijeme_pocetka, r.vrijeme_rezervacije)), 0) AS prosjek_dana_rezervacije_prije_treninga
FROM 	 rezervacija r
JOIN 	 termin_treninga tt ON r.termin_treninga_id = tt.id
JOIN 	 prostorija pr ON tt.prostorija_id = pr.id
JOIN 	 podruznica po ON pr.podruznica_id = po.id
WHERE	 tt.vrijeme_pocetka > CURRENT_TIMESTAMP()
GROUP BY po.id;

-- Broj trenera prema broju treninga za treninge u narednih mjesec dana 
SELECT   COUNT(*) AS broj_trenera, broj_treninga
FROM     (SELECT trener_id, COUNT(*) AS broj_treninga
		  FROM termin_treninga
		  WHERE vrijeme_pocetka BETWEEN CURRENT_TIMESTAMP() AND CURRENT_TIMESTAMP() + INTERVAL 1 MONTH
		  GROUP BY trener_id) AS btt
GROUP BY broj_treninga
ORDER BY broj_treninga DESC;

-- ------------------------------ --
-- Autentifikacija i autorizacija --
-- ------------------------------ --

-- Korisnik - administrator
CREATE ROLE 'admin_ovlasti';
GRANT ALL PRIVILEGES ON fitness_centar.* TO 'admin_ovlasti';
CREATE USER 'AdminMiro' IDENTIFIED BY 'miro';
GRANT 'admin_ovlasti' TO 'AdminMiro';

-- Korisnik - trener
CREATE ROLE 'ovlasti_trenera';
GRANT SELECT, INSERT, UPDATE, DELETE ON fitness_centar.termin_treninga TO 'ovlasti_trenera';
GRANT SELECT, DELETE ON fitness_centar.rezervacija TO 'ovlasti_trenera';
CREATE USER 'TrenerIvo' IDENTIFIED BY 'ivo';
GRANT 'ovlasti_trenera' TO 'TrenerIvo';

-- Korisnik - član
CREATE ROLE 'ovlasti_clana';
GRANT SELECT ON fitness_centar.termin_treninga TO 'ovlasti_clana';
GRANT SELECT, INSERT ON fitness_centar.rezervacija TO 'ovlasti_clana';
CREATE USER 'ClanPero' IDENTIFIED BY 'pero';
GRANT 'ovlasti_clana' TO 'ClanPero';

-- ------ --
-- Eventi --
-- ------ --

-- Event koji svaki dan u 1 sat iza ponoći provjerava neaktivne trenere s zakazanim terminima
DROP EVENT IF EXISTS dnevna_provjera_trenera;
CREATE EVENT dnevna_provjera_trenera
	ON SCHEDULE
		EVERY 1 DAY
		STARTS IF(
					CURRENT_TIMESTAMP() < CURRENT_DATE() + INTERVAL 1 HOUR,
					CURRENT_DATE() + INTERVAL 1 HOUR,
					CURRENT_DATE() + INTERVAL 1 DAY + INTERVAL 1 HOUR
				)
    DO
		CALL sp_provjeri_trenere();
