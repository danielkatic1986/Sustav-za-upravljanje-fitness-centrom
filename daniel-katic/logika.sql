/*
    Definicija logike
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
    ================================
                Funkcije
    ================================
*/


/* 
    ================================
                Procedure
    ================================
*/

/*
    PROCEDURA: azuriraj_status_clanarina()
    - Ažurira status članarina.
    - Dodati ću event gdje će se ovo izvršavati jednom dnevno,
      što je i realno za poslovnu aplikaciju.
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
    TRIGGER: datum_uclanjenja
    Opis: automatsko postavljanje datuma učlanjenja
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