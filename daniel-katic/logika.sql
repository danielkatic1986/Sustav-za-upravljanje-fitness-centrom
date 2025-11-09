/*
    Definicija logike

    TODO: procedura koja koristi cursor
    TODO: dodati još koji trigger
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
ORDER BY Broj_članova DESC; 

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
    POGLED: ukupne_potrosnje_clanova
    - Pregled članova i koliko su ukupno potrošili na članarine,
      koristi se sa funkcijom ukupna_potrosnja_clana(cl.oib).
*/

CREATE VIEW ukupne_potrosnje_clanova AS
SELECT 
    cl.id,
    cl.ime,
    cl.prezime,
    ukupna_potrosnja_clana(cl.oib) AS ukupno_potroseno
FROM clan cl
ORDER BY ukupno_potroseno DESC;


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
    FUNKCIJA: ukupna_potrosnja_clana(oib_clana)
    - Dobijemo koliko EUR-a je određeni član potrošio na članarine u centru.
      To nam može koristiti u marketingu, ili na primjer da nekako nagradimo
      one članove koji troše više od određene cifre.
    - Kao demonstraciju funkcije stvorio sam ukupne_potrosnje_clanova pogled
      gdje pomoću pogleda možemo vidjeti ukupnu potrošnju svakog člana na
      članarine.
*/

DELIMITER //
CREATE FUNCTION ukupna_potrosnja_clana(a_oib CHAR(11))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE m_ukupna_potrosnja DECIMAL(10,2) DEFAULT 0;
    SELECT SUM(tc.cijena) INTO m_ukupna_potrosnja
	FROM tip_clanarine tc
	JOIN clanarina c ON c.id_tip = tc.id
	JOIN clan cl ON c.id_clan = cl.id
	WHERE cl.oib = a_oib
	GROUP BY cl.id;
    
    IF m_ukupna_potrosnja > 0 THEN
		RETURN m_ukupna_potrosnja;
	ELSE 
		RETURN 0;
	END IF;
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
    - Imam i event 'event_azuriraj_status_clanarina' gdje će se ovo izvršavati 
      jednom dnevno, što je i realno za poslovnu aplikaciju.
*/

DELIMITER //

CREATE PROCEDURE azuriraj_status_clanarina()
BEGIN
    DECLARE id_aktivna INT;
    DECLARE id_istekla INT;
    DECLARE id_zamrznuta INT;

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
    DECLARE a_mjesec INT DEFAULT 1;
    DECLARE broj_akt INT;

    -- Privremena tablica za rezultate
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_aktivni (
        mjesec INT,
        broj_aktivnih INT
    );

    -- Isprazni tablicu ako već postoji
    TRUNCATE TABLE temp_aktivni;

    -- Petlja kroz mjesece
    WHILE a_mjesec <= 12 DO
        SET broj_akt = broj_aktivnih_clanova(a_mjesec, a_godina);

        INSERT INTO temp_aktivni (mjesec, broj_aktivnih)
        VALUES (a_mjesec, broj_akt);

        SET a_mjesec = a_mjesec + 1;
    END WHILE;

    -- Vrati rezultat
    SELECT * FROM temp_aktivni;

    -- Očisti tablicu na kraju
    DROP TEMPORARY TABLE IF EXISTS temp_aktivni;
END //
DELIMITER ;


/* 
    ================================
                Triggeri
    ================================
*/

/*
    TRIGGER: datum_uclanjenja
    Opis: automatsko postavljanje datuma učlanjenja ukoliko nije unesen
*/
DELIMITER //

CREATE TRIGGER datum_uclanjenja
BEFORE INSERT ON clan
FOR EACH ROW
BEGIN
    IF NEW.datum_uclanjenja IS NULL THEN
        SET NEW.datum_uclanjenja = CURDATE();
    END IF;
END//

DELIMITER ;

/* 
    ================================
                EVENTI
    ================================
*/

/*
    EVENT: event_azuriraj_status_clanarina
    - Svaki dan ažurira statuse članarina
*/

CREATE EVENT IF NOT EXISTS event_azuriraj_status_clanarina
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
  CALL azuriraj_status_clanarina();