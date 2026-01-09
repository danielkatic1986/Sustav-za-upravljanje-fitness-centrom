/*
    Definicija logike

    TODO: implementirati transakciju
*/

/* 
    ================================
            Napredni upiti
    ================================
*/

/*
    UPIT: Aktivne članarine po tipu.
    - Broj trenutno aktivnih članarina grupiran po tipu (s cijenom i trajanjem).
*/

SELECT
    t.naziv AS tip_clanarine,
    COUNT(c.id) AS broj_aktivnih,
    t.cijena,
    t.trajanje_mjeseci
FROM clanarina c
JOIN tip_clanarine t ON c.id_tip = t.id
JOIN status_clanarine s ON c.id_status = s.id
WHERE s.naziv = 'Aktivna'
GROUP BY t.id
ORDER BY broj_aktivnih DESC;

/*
    UPIT: Broj članova po mjestu.
    - Koliko članova dolazi iz svakog mjesta.
*/

SELECT
    m.naziv AS mjesto,
    COUNT(cl.id) AS broj_clanova
FROM clan cl
RIGHT JOIN mjesto m ON cl.id_mjesto = m.id
GROUP BY m.id
ORDER BY broj_clanova DESC;

/*
    UPIT: Članovi kojima članarina uskoro istječe.
    - Na primjer za 7 dana.
*/

SELECT 
    cl.ime, cl.prezime,
    c.datum_zavrsetka,
    DATEDIFF(c.datum_zavrsetka, CURDATE()) AS dana_do_isteka
FROM clanarina c
JOIN clan cl ON c.id_clan = cl.id
WHERE DATEDIFF(c.datum_zavrsetka, CURDATE()) BETWEEN 0 AND 7
    AND c.id_status = (SELECT id FROM status_clanarine WHERE naziv = 'Aktivna');

/*
    UPIT: Broj članarina po statusu
    - Koliko ih je aktivno, isteklo, zamrznuto, itd.
*/

SELECT 
    s.naziv AS status,
    COUNT(c.id) AS broj_clanarina
FROM clanarina c
JOIN status_clanarine s ON c.id_status = s.id
GROUP BY s.id;

/*
    UPIT: Novi članovi
    - Učlanjeni u zadnjih godinu dana.
*/

SELECT ime, prezime, datum_uclanjenja
FROM clan
WHERE datum_uclanjenja >= CURDATE() - INTERVAL 1 YEAR;


/* 
    ================================
                Pogledi
    ================================
*/

/*
    POGLED: aktivni_clanovi
    - Prikaz svih aktivnih članova, tip članarine, datum početka i završetka članarine.
*/

CREATE VIEW aktivni_clanovi AS
SELECT 
    cl.ime AS Ime, 
    cl.prezime AS Prezime, 
    cl.oib AS OIB, 
    m.naziv AS Mjesto,
    cl.adresa AS Adresa, 
    cl.email AS Email, 
    cl.telefon AS Telefon,
    tcl.naziv AS Tip_clanarine,
    c.datum_pocetka AS Pocetak, 
    c.datum_zavrsetka AS Zavrsetak
FROM clan cl
JOIN mjesto m ON m.id = cl.id_mjesto
JOIN clanarina c ON c.id_clan = cl.id
JOIN status_clanarine scl ON scl.id = c.id_status
JOIN tip_clanarine tcl ON tcl.id = c.id_tip
WHERE scl.naziv = 'aktivna';

/*
    POGLED: zadnje_istekle_clanarine
    - Članarine koje su istekle u zadnjih 30 dana.
    - Može biti korisno za mailing listu ponuda obnove članarine,
      ili kao marketing takvim članovima.
*/

CREATE VIEW zadnje_istekle_clanarine AS
SELECT 
    cl.ime AS Ime, 
    cl.prezime AS Prezime, 
    cl.oib AS OIB, 
    cl.email AS Email, 
    cl.telefon AS Telefon,
    tcl.naziv AS Tip_clanarine,
    c.datum_zavrsetka AS Zavrsetak
FROM clan cl
JOIN clanarina c ON c.id_clan = cl.id
JOIN status_clanarine scl ON scl.id = c.id_status
JOIN tip_clanarine tcl ON tcl.id = c.id_tip
WHERE c.datum_zavrsetka BETWEEN (CURDATE() - INTERVAL 30 DAY) AND CURDATE();

/*
    POGLED: clanovi_po_mjestu
    - Kombinira tablice clan i mjesto radi lakseg uvida u geografski raspored članova.
      Dozvoljava nam analizu u kojem mjestu smo popularni, gdje nismo, na taj način
      možemo poboljšati svoju uslugu.
*/

CREATE VIEW clanovi_po_mjestu AS
SELECT COUNT(cl.id) AS Broj_clanova, m.naziv AS Mjesto
FROM clan cl
JOIN mjesto m ON m.id = cl.id_mjesto
GROUP BY m.naziv
ORDER BY Broj_clanova DESC; 

/*
    POGLED: clanarine_po_spolu
    - Pregled aktivnih, isteklih i zamrznutih članarina po spolu.
      Također nam olakšava analizu i omogućuje nam unaprijeđenje 
      prodaje ovisno o podacima.
*/

CREATE VIEW clanarine_po_spolu AS
SELECT 
    cl.spol AS Spol,
    s.naziv AS Status_clanarine,
    COUNT(c.id) AS Broj_clanarina
FROM clan cl
JOIN clanarina c ON c.id_clan = cl.id
JOIN status_clanarine s ON s.id = c.id_status
GROUP BY cl.spol, s.naziv
ORDER BY cl.spol, s.naziv;


/* 
    ================================
                Funkcije
    ================================
*/

/*
    FUNKCIJA: preostalo_trajanje_clanarine(oib_clana)
    - Pregled trajanja članarine određenog člana, od danas do datuma isteka.
      Ukoliko je članarina istekla (negativna vrijednost) vraća -1, to je zato
      jer ako danas ističe članarina datediff će vratiti 0, što znači da 
      članarina vrijedi do kraja dana.
      Uzimam OIB jer je to logičnije, neće korisnik aplikacije pamtiti id članova,
      nego će ih identificirati po oibu-u.
*/

DELIMITER //
CREATE FUNCTION preostalo_trajanje_clanarine (a_oib_clan CHAR(11))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE br_dana INT DEFAULT 0;
    SELECT DATEDIFF(datum_zavrsetka, CURDATE()) INTO br_dana
		FROM clanarina c 
        JOIN clan cl ON cl.id = c.id_clan
        WHERE cl.oib = a_oib_clan
        ORDER BY c.id DESC
        LIMIT 1;
	IF br_dana >= 0 THEN
		RETURN br_dana;
	ELSE
		RETURN -1;
	END IF;
END //
DELIMITER ;

/*
    FUNKCIJA: potrosnja_clana_za_period(oib_clana)
    - Dobijemo koliko EUR-a je određeni član potrošio na članarine u centru za
      određeni period.
      To nam može koristiti u marketingu, ili na primjer da nekako nagradimo
      one članove koji troše više od određene cifre.
    - Kao demonstraciju funkcije stvorio sam proceduru.
    - Postoji mala mana ove funkcije, a to je da bi se godišnje članarine
      trebale preračunavati proporcionalno, na primjer po danima ili mjesecima.
      Pošto bi to značilo puno kompleksniju funkciju, ja sam napisao ovako,
      logika se eventualno može proširiti, ovo je više dokaz koncepta.
*/

DELIMITER //
CREATE FUNCTION potrosnja_clana_za_period(a_oib CHAR(11), a_pocetak DATE, a_kraj DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE m_ukupno DECIMAL(10,2);

    -- Zbroji sve članarine koje pripadaju zadanom periodu
    SELECT SUM(tc.cijena)
    INTO m_ukupno
    FROM tip_clanarine tc
    JOIN clanarina c ON c.id_tip = tc.id
    JOIN clan cl ON cl.id = c.id_clan
    WHERE cl.oib = a_oib
      AND c.datum_pocetka <= a_kraj
      AND c.datum_zavrsetka >= a_pocetak;

    IF m_ukupno IS NULL THEN
        RETURN 0;
    END IF;

    RETURN m_ukupno;
END //
DELIMITER ;

/*
    FUNCTION: broj_aktivnih_clanova(a_mjesec INT, a_godina INT)
    - Vraća broj članova koji su imali aktivnu članarinu u zadanom mjesecu i godini,
      to jest barem jedan dan između datum_pocetka i datum_zavrsetka koji pada u to
      razdoblje.
      Veoma korisno za marketing, također možemo vidjeti u kojim mjesecima/godinama
      imamo najviše aktivnih članova, možemo po tome organizirati popuste itd.
    - Ovu funkciju koristim u proceduri aktivni_po_godini(a_godina) gdje je moguće
      dohvatiti tablicu s brojem aktivnih članova po mjesecima za danu godinu.
*/

DELIMITER //
CREATE FUNCTION broj_aktivnih_clanova(a_mjesec INT, a_godina INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE m_broj_akt_cl INT DEFAULT 0; 
    DECLARE m_pocetak DATE;
    DECLARE m_kraj DATE;

    SET m_pocetak = STR_TO_DATE(CONCAT('01.', a_mjesec, '.', a_godina, '.'), '%d.%m.%Y.');
    SET m_kraj = LAST_DAY(m_pocetak); -- pretražio na internetu (da znam koji je zadnji dan u tom mj)
    
    SELECT COUNT(DISTINCT c.id) INTO m_broj_akt_cl 
    FROM clan c
	JOIN clanarina cl ON cl.id_clan = c.id
    JOIN status_clanarine s ON s.id = cl.id_status
	WHERE 
	cl.datum_pocetka <= m_kraj
	AND cl.datum_zavrsetka >= m_pocetak
    AND s.naziv = 'aktivna';
    
    RETURN m_broj_akt_cl;
END //
DELIMITER ;

/* 
    ================================
                Procedure
    ================================
*/

/*
    PROCEDURA: azuriraj_status_clanarina()
    - Ažurira status članarina.
    - Koristim transakciju.
    - Imam i event 'event_azuriraj_status_clanarina' gdje će se ovo izvršavati 
      jednom dnevno, što je i realno za poslovnu aplikaciju.
*/

DELIMITER //

CREATE PROCEDURE azuriraj_status_clanarina()
BEGIN
    DECLARE id_aktivna INT;
    DECLARE id_istekla INT;
    DECLARE id_zamrznuta INT;

    -- handler za rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Greška tijekom ažuriranja statusa članarina.';
    END;

    -- Automatski isključuje autocommit, rollback i commit ga vraćaju
    START TRANSACTION;

    -- dohvaćanje ID-ova statusa
    SELECT id INTO id_aktivna FROM status_clanarine WHERE naziv = 'aktivna' LIMIT 1;
    SELECT id INTO id_istekla FROM status_clanarine WHERE naziv = 'istekla' LIMIT 1;
    SELECT id INTO id_zamrznuta FROM status_clanarine WHERE naziv = 'zamrznuta' LIMIT 1;

    -- 1. Ažuriraj na "istekla" ako je završetak prošao
    UPDATE clanarina
    SET id_status = id_istekla
    WHERE datum_zavrsetka < CURDATE()
      AND id_status != id_istekla
      AND id_status != id_zamrznuta; -- ako je zamrznuta, ne diramo

    -- 2. Ažuriraj na "aktivna" ako je članarina trenutno važeća
    UPDATE clanarina
    SET id_status = id_aktivna
    WHERE datum_pocetka <= CURDATE()
      AND datum_zavrsetka >= CURDATE()
      AND id_status != id_aktivna
      AND id_status != id_zamrznuta; -- opet, zamrznutu ne mijenjamo
    
    COMMIT;
END //

DELIMITER ;

/*
    PROCEDURA: aktivni_po_godini(a_godina)
    - Vraća tablicu koja sadrži broj aktivnih članova po mjesecima u zadanoj godini.
      Koristim privremenu tablicu i while petlju za prolazak kroz mjesece i onda
      koristim funkciju broj_aktivnih_clanova(a_mjesec, a_godina) gdje funkcija
      vraća broj aktivnih članova za određeni mjesec.
    - Također jako korisno u marketingu, procedura se može i dalje proširiti ili
      se napisati druga na primjer neaktivni_po_godini ili zamrznuti_po_godini
      gdje bi isto mogli dobiti za neaktivne i zamrznute korisnike.
*/

DELIMITER //
CREATE PROCEDURE aktivni_po_godini(a_godina INT)
BEGIN
    DECLARE m_mjesec INT DEFAULT 1;
    DECLARE m_broj_akt INT;

    -- Privremena tablica za rezultate
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_aktivni (
        mjesec INT,
        broj_aktivnih INT
    );

    -- Isprazni tablicu ako već postoji
    TRUNCATE TABLE temp_aktivni;

    -- Petlja kroz mjesece
    WHILE m_mjesec <= 12 DO
        SET m_broj_akt = broj_aktivnih_clanova(m_mjesec, a_godina);

        INSERT INTO temp_aktivni (mjesec, broj_aktivnih)
        VALUES (m_mjesec, m_broj_akt);

        SET m_mjesec = m_mjesec + 1;
    END WHILE;

    -- Vrati rezultat
    SELECT * FROM temp_aktivni;

    -- Očisti tablicu na kraju
    DROP TEMPORARY TABLE IF EXISTS temp_aktivni;
END //
DELIMITER ;

/*
	PROCEDURA: statistika_potrosnje()
    - Ova procedura računa statistiku potrošnje pomoću cursora za svakog člana.
    - Procedura koristi ranije definiranu funkciju ukupna_potrosnja_clana.
    - Za statistiku stvoriti ću novu tablicu 
      statistika_potrosnje(id_clan, ukupno_u_periodu, godina, kvartal)
	- Također ažurirati ću tablicu pomoću eventa event_statistika_potrosnje
      svaka 3 mjeseca.
*/

DELIMITER //
CREATE PROCEDURE statistika_potrosnje()
BEGIN
    DECLARE m_mjesec INT;
    DECLARE m_godina YEAR;
    DECLARE m_kvartal INT;
    
    DECLARE m_pocetak DATE;
    DECLARE m_kraj DATE;
    
    DECLARE m_id_clan INT;
    DECLARE m_oib CHAR(11);
    DECLARE m_ukupno DECIMAL(10,2);
    
    DECLARE m_gotovo INT DEFAULT 0;
    
    -- Cursor za dohvat članova
    DECLARE cur CURSOR FOR
		SELECT id, oib FROM clan;
        
	-- Handler za kraj cursora
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET m_gotovo = 1;
    
    SET m_mjesec = MONTH(CURDATE());
    SET m_godina = YEAR(CURDATE());
    
    -- Izračun kvartala
    IF (m_mjesec >= 1 AND m_mjesec <= 3) THEN
		SET m_kvartal = 1;
	ELSEIF (m_mjesec >= 4 AND m_mjesec <= 6) THEN
		SET m_kvartal = 2;
	ELSEIF (m_mjesec >= 7 AND m_mjesec <= 9) THEN
		SET m_kvartal = 3;
	ELSEIF (m_mjesec >= 10 AND m_mjesec <= 12) THEN
		SET m_kvartal = 4;
	END IF;
    
    -- Izračun početka i kraja kvartala
    IF m_kvartal = 1 THEN
		SET m_pocetak = STR_TO_DATE(CONCAT('01.01.', m_godina), '%d.%m.%Y');
        SET m_kraj = STR_TO_DATE(CONCAT('31.03.', m_godina), '%d.%m.%Y');
	ELSEIF m_kvartal = 2 THEN
		SET m_pocetak = STR_TO_DATE(CONCAT('01.04.', m_godina), '%d.%m.%Y');
        SET m_kraj = STR_TO_DATE(CONCAT('30.06.', m_godina), '%d.%m.%Y');
	ELSEIF m_kvartal = 3 THEN
		SET m_pocetak = STR_TO_DATE(CONCAT('01.07.', m_godina), '%d.%m.%Y');
        SET m_kraj = STR_TO_DATE(CONCAT('30.09.', m_godina), '%d.%m.%Y');
	ELSEIF m_kvartal = 4 THEN
		SET m_pocetak = STR_TO_DATE(CONCAT('01.10.', m_godina), '%d.%m.%Y');
        SET m_kraj = STR_TO_DATE(CONCAT('31.12.', m_godina), '%d.%m.%Y');
	END IF;
    
    OPEN cur;
    
    petlja: LOOP
		FETCH cur INTO m_id_clan, m_oib;
        
        IF m_gotovo = 1 THEN
			LEAVE petlja;
		END IF;
        
        -- Izračun potrošnje
        SET m_ukupno = potrosnja_clana_za_period(m_oib, m_pocetak, m_kraj);
        
        -- Pokušaj upisa (zbog unique ne smije biti duplikata, ako se to desi onda update ukupno)
        INSERT INTO statistika_potrosnje (id_clan, ukupno_u_periodu, godina, kvartal)
		VALUES (m_id_clan, m_ukupno, m_godina, m_kvartal)
        ON DUPLICATE KEY UPDATE
			ukupno_u_periodu = m_ukupno;
    END LOOP;
    
    CLOSE cur;
    
END //
DELIMITER ;

/* 
    ================================
                Triggeri
    ================================
*/

/*
    TRIGGER: tg_datum_uclanjenja
    Opis: automatsko postavljanje datuma učlanjenja ukoliko nije unesen
*/
DELIMITER //

CREATE TRIGGER tg_datum_uclanjenja
BEFORE INSERT ON clan
FOR EACH ROW
BEGIN
    IF NEW.datum_uclanjenja IS NULL THEN
        SET NEW.datum_uclanjenja = CURDATE();
    END IF;
END//

DELIMITER ;

/*
	TRIGGER: tg_default_godina
    Opis: Ako korisnik ne definira godinu postavljamo ju na trenutnu, za tablicu
          statistika_potrosnje
*/

DELIMITER //
CREATE TRIGGER tg_default_godina
BEFORE INSERT ON statistika_potrosnje
FOR EACH ROW
BEGIN
    IF NEW.godina IS NULL THEN
        SET NEW.godina = YEAR(CURDATE());
    END IF;
END //

DELIMITER ;

DELIMITER //

/*
	TRIGGER: tg_deaktiviraj_clana
    Opis: Pokreće se svaki put kad se promjeni status članarine, na primjer
          event je prebaci u "istekla", prebroji se koliko član ima trenutno
          aktivnih članarina, ako je 0, član više nije aktivan.
*/

CREATE TRIGGER tg_deaktiviraj_clana
AFTER UPDATE ON clanarina
FOR EACH ROW
BEGIN
    DECLARE m_aktivnih INT;

    -- Broj aktivnih članarina za tog člana
    SELECT COUNT(*) INTO m_aktivnih
    FROM clanarina c
    JOIN status_clanarine s ON s.id = c.id_status
    WHERE c.id_clan = NEW.id_clan
      AND s.naziv = 'aktivna';

    -- Ako nema niti jedne aktivne – član više nije aktivan
    IF m_aktivnih = 0 THEN
        UPDATE clan
        SET aktivan = FALSE
        WHERE id = NEW.id_clan;
    END IF;

END //

DELIMITER ;

/*
	TRIGGER: tg_aktiviraj_clana
    Opis: Ako se unosi nova članarina, korisnik će automatski postati aktivan član.
*/

DELIMITER //

CREATE TRIGGER tg_aktiviraj_clana
AFTER INSERT ON clanarina
FOR EACH ROW
BEGIN
    DECLARE m_status_aktivna_id INT;

    -- Dohvati id statusa "aktivna"
    SELECT id INTO m_status_aktivna_id
    FROM status_clanarine
    WHERE naziv = 'aktivna'
    LIMIT 1;

    -- Ako je unesena članarina aktivna onda aktiviraj člana
    IF NEW.id_status = m_status_aktivna_id THEN
        UPDATE clan
        SET aktivan = TRUE
        WHERE id = NEW.id_clan;
    END IF;
END //

DELIMITER ;

/*
	TRIGGER: tg_aktiviraj_clana_update
    Opis: Ako se promijeni status člana na aktivan, on to postaje
*/

DELIMITER //

CREATE TRIGGER tg_aktiviraj_clana_update
AFTER UPDATE ON clanarina
FOR EACH ROW
BEGIN
    DECLARE m_status_aktivna_id INT;

    SELECT id INTO m_status_aktivna_id
    FROM status_clanarine
    WHERE naziv = 'aktivna'
    LIMIT 1;

    -- Ako je status postao aktivan, aktiviraj člana
    IF NEW.id_status = m_status_aktivna_id THEN
        UPDATE clan
        SET aktivan = TRUE
        WHERE id = NEW.id_clan;
    END IF;
END //

DELIMITER ;

/* 
    ================================
                EVENTI
    ================================
    
    - Pretpostavka je da je event scheduler uključen na serveru,
      ako nije treba ga uključiti.
*/

/*
    EVENT: event_azuriraj_status_clanarina
    - Svaki dan ažurira statuse članarina
*/

CREATE EVENT IF NOT EXISTS event_azuriraj_status_clanarina
ON SCHEDULE EVERY 1 DAY
STARTS NOW()
DO
  CALL azuriraj_status_clanarina();

/*
	EVENT: event_statistika_potrosnje
    - Pokreće proceduru statistika_potrosnje svaka 3 mjeseca.
*/

CREATE EVENT IF NOT EXISTS event_statistika_potrosnje
ON SCHEDULE EVERY 3 MONTH
STARTS '2025-01-01'
DO
  CALL statistika_potrosnje();

-- Pozovi proceduru kada se prvi put stvori baza..
CALL statistika_potrosnje();