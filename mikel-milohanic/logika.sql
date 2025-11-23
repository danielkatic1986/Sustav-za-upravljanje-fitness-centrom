DELIMITER //
-- -------- --
-- Funkcije --
-- -------- --

-- Funkcija koja vraća broj etaža pojedine podružnice
DROP FUNCTION IF EXISTS broj_etaza //
CREATE FUNCTION broj_etaza(p_podruznica_id INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
	DECLARE broj_etaza INTEGER;
    
	IF p_id_podruznica NOT IN (SELECT id FROM podruznica) THEN
		SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Došlo je do greške: nepostojeći \'id\' podružnice.';
	ELSE
		SELECT COUNT(DISTINCT IF(lokacija LIKE '%,%', LEFT(lokacija, LOCATE(',', lokacija) - 1), lokacija))
		INTO   broj_etaza
        FROM   prostorija
		WHERE  lokacija <> 'Vani'
		AND    podruznica_id = p_podruznica_id;
	END IF;
    
    RETURN broj_etaza;
END //

-- Funkcija koja za danu podružnicu vraća postotak prošlih termina koji nisu imali niti jednu rezervaciju
DROP FUNCTION termina_bez_rezervacije //
CREATE FUNCTION termina_bez_rezervacije(p_podruznica_id INTEGER) RETURNS VARCHAR(4)
DETERMINISTIC
BEGIN
	DECLARE ukupno_termina, ukupno_bez_rezervacije INTEGER;
    
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
    
    SELECT COUNT(*) INTO ukupno_termina FROM prosli_termini;
    
    IF NOT ukupno_termina THEN
		RETURN '0%';
	END IF;
    
    SELECT COUNT(*) INTO ukupno_bez_rezervacije FROM prosli_termini WHERE broj_rezervacija = 0;
    
    RETURN CONCAT(ROUND(ukupno_bez_rezervacije/ukupno_termina*100, 0), '%');
END //

-- Prosjek održanih treninga mjesečno od početka evidencije do trenutnog datuma
DROP FUNCTION IF EXISTS prosjek_odrzanih_treninga_mjesecno //
CREATE FUNCTION prosjek_odrzanih_treninga_mjesecno() RETURNS DECIMAL(7, 2)
DETERMINISTIC
BEGIN
	RETURN (SELECT AVG(broj_termina)
			FROM   (SELECT COUNT(*) AS broj_termina
					FROM termin_treninga
					WHERE otkazan IS FALSE
					AND vrijeme_zavrsetka < CURRENT_TIMESTAMP()
					GROUP BY EXTRACT(YEAR FROM vrijeme_pocetka), EXTRACT(MONTH FROM vrijeme_pocetka)) AS bt);
END //

-- Funkcija koja vraća postotak popunjenosti termina
DROP FUNCTION IF EXISTS postotak_popunjenosti //
CREATE FUNCTION postotak_popunjenosti(p_termin_id INTEGER) RETURNS VARCHAR(4)
DETERMINISTIC
BEGIN
	DECLARE postotak VARCHAR(4);
    
    IF (SELECT id FROM termin_treninga WHERE id = p_termin_id) IS NULL THEN
		SIGNAL SQLSTATE '40000'
        SET MESSAGE_TEXT = 'Došlo je do greške: nepostojeći \'id\' termina treninga.';
	ELSE
		SELECT CONCAT(ROUND(tt.rezervirano/p.kapacitet*100, 0), '%')
		INTO   postotak
		FROM   termin_treninga tt
		JOIN   prostorija p ON tt.prostorija_id = p.id
		WHERE  tt.id = p_termin_id;
	END IF;
    
    RETURN postotak;
END//

-- --------- --
-- Procedure --
-- --------- --

-- Procedura koja kad se prekine radni odnos s određenim trenerom
-- raspodjeljuje njegove nadolazeće termine treninga na ostale aktivne trenere unutar iste poslovnice
-- pazeći pritom da se termin ne preklapa s drugim terminom nekog trenera
-- i dajući prioritet pri raspodjeli treneru koji ima najmanje zakazanih treninga.
-- U slućaju da za neki trening nema na raspolaganju trenera koji ga može odraditi u tom terminu, isti se otkazuje
DROP PROCEDURE IF EXISTS raspodijeli_termine //
CREATE PROCEDURE raspodijeli_termine(IN p_trener_id INTEGER, IN p_podruznica_id INTEGER)
BEGIN
    DECLARE tid, ttid INTEGER;
    DECLARE ttvp TIMESTAMP;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
		SELECT id, vrijeme_pocetka
        FROM   termin_treninga
        WHERE  trener_id = p_trener_id
        AND    vrijeme_pocetka > CURRENT_TIMESTAMP();
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	DROP TEMPORARY TABLE IF EXISTS termini_trenera;
	CREATE TEMPORARY TABLE termini_trenera (
		trener_id INTEGER,
        broj_termina INTEGER,
        
        INDEX idx_broj_termina (broj_termina)
	);
    
    INSERT INTO termini_trenera
		SELECT     t.id, COUNT(tt.id)
        FROM	   termin_treninga tt
        RIGHT JOIN (SELECT id
					FROM   zaposlenik
                    WHERE  id_radno_mjesto = 1
                    AND    id_podruznica = p_podruznica_id
                    AND    status_zaposlenika = 'aktivan') AS t ON tt.trener_id = t.id
		WHERE vrijeme_pocetka > CURRENT_TIMESTAMP()
		GROUP BY   t.id;
	
    OPEN cur;
	my_loop: LOOP
		FETCH cur INTO ttid, ttvp;
        
        IF done THEN
			LEAVE my_loop;
		END IF;
        
        SELECT	 ttr.trener_id
        INTO	 tid
        FROM	 termini_trenera ttr
        JOIN	 termin_treninga ttg ON ttr.trener_id = ttg.trener_id
        WHERE	 ttr.trener_id NOT IN (SELECT trener_id
									   FROM   termin_treninga
									   WHERE  ttvp BETWEEN vrijeme_pocetka AND vrijeme_zavrsetka)
		ORDER BY ttr.broj_termina ASC
        LIMIT    1;
        
        IF tid IS NULL THEN
			UPDATE termin_treninga
            SET    otkazan = TRUE
            WHERE  termin_treninga.id = ttid;
		ELSE
			UPDATE termin_treninga
            SET    trener_id = tid
            WHERE  termin_treninga.id = ttid;
            
            UPDATE termini_trenera
            SET    broj_termina = broj_termina + 1
            WHERE  trener_id = tid AND broj_termina > 0;
		END IF;
    END LOOP my_loop;
    CLOSE cur;
END//

-- Procedura koja bilježi promjene nad količinom rezervacija na nekom terminu
DROP PROCEDURE IF EXISTS evidencija_rezervacija_termina //
CREATE PROCEDURE evidencija_rezervacija_termina(IN p_termin_treninga_id INTEGER, IN p_promjena INTEGER)
BEGIN
	DECLARE trenutno_rezervacija, max_kapacitet INTEGER;
    
    SELECT	 COUNT(r.id),
			 p.kapacitet
	INTO	 trenutno_rezervacija,
			 max_kapacitet
    FROM	 (SELECT *
			  FROM termin_treninga
			  WHERE id = p_termin_treninga_id) AS tt
    JOIN	 prostorija p ON tt.prostorija_id = p.id
    JOIN	 rezervacija r ON tt.id = r.termin_treninga_id
    GROUP BY tt.id;
    
    
    IF trenutno_rezervacija + p_promjena > max_kapacitet THEN
		SIGNAL SQLSTATE '41000'
        SET MESSAGE_TEXT = 'Nije moguće unijeti novu rezervaciju: kapacitet termina je popunjen.';
	ELSE
		UPDATE termin_treninga
		SET    rezervirano = trenutno_rezervacija + p_promjena
		WHERE  id = p_termin_treninga_id;
	END IF;
END//

-- ---------------- --
-- Triggeri/okidači --
-- ---------------- --

-- Okidač koji prilikom unosa termina treninga računa vrijeme završetka treninga ovisno o treningu
DROP TRIGGER IF EXISTS bi_termin_treninga //
CREATE TRIGGER bi_termin_treninga
BEFORE INSERT ON termin_treninga
FOR EACH ROW
BEGIN
	DECLARE trajanje_treninga INTEGER;
	
	SELECT planirano_trajanje_min
		INTO trajanje_treninga
		FROM trening
		WHERE trening.id = NEW.trening_id;
	
	IF trajanje_treninga IS NOT NULL THEN
		SET NEW.vrijeme_zavrsetka = NEW.vrijeme_pocetka + INTERVAL trajanje_treninga MINUTE;
        SET NEW.otkazan = COALESCE(NEW.otkazan, FALSE);
	ELSE
		SIGNAL SQLSTATE '46000'
		SET MESSAGE_TEXT = 'Nije moguće unijeti termin treninga: nepostojeći trening.';
	END IF;
END //

-- Okidač za raspodijelu termina treninga prilikom promjene statusa trenera u 'neaktivan'
DROP TRIGGER IF EXISTS au_zaposlenik //
CREATE TRIGGER au_zaposlenik
AFTER UPDATE ON zaposlenik
FOR EACH ROW
BEGIN
	IF OLD.status_zaposlenika = 'aktivan' AND NEW.status_zaposlenika = 'neaktivan' THEN
		CALL raspodijeli_termine(NEW.id, OLD.id_podruznica);
	END IF;
END //

-- Okidač koji povećava popunjenost termina treninga kada se napravi rezervacija
DROP TRIGGER IF EXISTS bi_rezervacija //
CREATE TRIGGER bi_rezervacija
BEFORE INSERT ON rezervacija
FOR EACH ROW
BEGIN
	CALL evidencija_rezervacija_termina(NEW.termin_treninga_id, 1);
END //

-- Okidač koji smanjuje popunjenost termina treninga kada se napravi rezervacija
DROP TRIGGER IF EXISTS ad_rezervacija //
CREATE TRIGGER ad_rezervacija
AFTER DELETE ON rezervacija
FOR EACH ROW
BEGIN
	CALL evidencija_rezervacija_termina(OLD.termin_treninga_id, -1);
END //

-- Okidač koji ne dozvoljava da se kapacitet prostorije postavi na manje od najvećeg
-- broja rezervacija za tu prostoriju na nekom od nadolazećih termina
-- te kroz grašku javlja koliko ima takvih termina
DROP TRIGGER IF EXISTS bu_prostorija //
CREATE TRIGGER bu_prostorija
BEFORE UPDATE ON prostorija
FOR EACH ROW
BEGIN
	DECLARE broj_termina INTEGER;
	DECLARE msg TEXT;

	IF NEW.kapacitet < OLD.kapacitet THEN
		SELECT COUNT(*)
		INTO   broj_termina
		FROM   (SELECT   tt.id, COUNT(r.id) AS broj_rezervacija
				FROM     termin_treninga tt
				JOIN	 rezervacija r ON tt.id = r.termin_treninga_id
				WHERE    tt.prostorija_id = NEW.id
				AND		 tt.vrijeme_pocetka > CURRENT_TIMESTAMP()
				GROUP BY tt.id
				HAVING   broj_rezervacija > NEW.kapacitet) AS podupit;
		
		IF broj_termina THEN
			SET msg = CONCAT('Uneseni kapacitet je manji od broja rezevacija na ', broj_termina, ' nadolazećih termina treninga.');
			SIGNAL SQLSTATE '50000' SET MESSAGE_TEXT = msg;
		END IF;
	END IF;
END //

DELIMITER ;

-- ------- --
-- Pogledi --
-- ------- --

-- Pregled poslovnica s najviše odrađenih treninga u proteklih mjesec dana
CREATE VIEW protekli_mjesec_treninga_po_podruznicama AS
SELECT 	 po.naziv, COUNT(*) AS odradeno_treninga
FROM 	 termin_treninga tt
JOIN 	 prostorija pr ON tt.prostorija_id = pr.id
JOIN 	 podruznica po ON pr.podruznica_id = po.id
WHERE 	 otkazan IS FALSE
AND 	 vrijeme_pocetka BETWEEN CURRENT_TIMESTAMP() - INTERVAL 1 MONTH AND CURRENT_TIMESTAMP()
AND 	 vrijeme_zavrsetka < CURRENT_TIMESTAMP()
GROUP BY po.id, po.naziv
ORDER BY odradeno_treninga DESC;

-- 10 trenera s najviše otkazanih termina
CREATE VIEW treneri_s_najvise_otkazivanja AS
SELECT 	  z.id,
		  z.ime,
          z.prezime,
		  COUNT(*) AS broj_otkazanih
FROM 	  zaposlenik z
LEFT JOIN (SELECT *
		   FROM termin_treninga
           WHERE otkazan IS TRUE) AS ot ON z.id = ot.trener_id
WHERE 	  id_radno_mjesto = 1
AND 	  status_zaposlenika = 'aktivan'
GROUP BY  z.id
ORDER BY  broj_otkazanih DESC
LIMIT 	  10;

-- Centri koji nude sve tipove prostorija
CREATE VIEW podruznice_s_svim_sadrzajima AS
SELECT	 po.naziv,
		 po.adresa,
         m.postanski_broj
FROM	 prostorija pr
JOIN	 podruznica po ON pr.podruznica_id = po.id
JOIN	 mjesto m ON po.id_mjesto = m.id
GROUP BY po.id
HAVING	 COUNT(DISTINCT tip_prostorije_id) = (SELECT COUNT(*) FROM tip_prostorije);

-- Pregled broja rezervacija po treningu za nadolazećih mjesec dana
CREATE VIEW nadolazece_rezervacije_po_treningu AS
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
WHERE 	  vrijeme_pocetka BETWEEN CURRENT_TIMESTAMP() AND CURRENT_TIMESTAMP() + INTERVAL 1 MONTH
AND 	  otkazan IS FALSE
GROUP BY  tt.id;

-- ----- --
-- Upiti --
-- ----- --

-- Ukupan kapacitet svih prostorija po poslovnicama
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

-- Prosjek rezervacija mjesečno gledano na razini svih podružnica
SELECT ROUND(AVG(br.broj_rezervacija), 0) AS prosjek_rezervacija_mjesecno
FROM   (SELECT 	 COUNT(*) AS broj_rezervacija
		FROM 	 rezervacija
		GROUP BY DATE_FORMAT(DATE(vrijeme_rezervacije), '%m.%Y.')) AS br;

--  Ukupan broj rezervacija i prosječan broj dana koliko unaprijed članovi rezerviraju termine treninga, po podružnicama
SELECT   po.naziv AS podruznica,
		 COUNT(r.id) AS broj_rezervacija,
         ROUND(AVG(DATEDIFF(tt.vrijeme_pocetka, r.vrijeme_rezervacije)), 0) AS prosjek_dana_rezervacije_prije_treninga
FROM 	 rezervacija r
JOIN 	 termin_treninga tt ON r.termin_treninga_id = tt.id
JOIN 	 prostorija pr ON tt.prostorija_id = pr.id
JOIN 	 podruznica po ON pr.podruznica_id = po.id
GROUP BY po.id;

