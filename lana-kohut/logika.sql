-- FUNKCIJE:
-- broj računa izdanih u odabranom mjesecu
-- daje brojčani rezultat koliko računa je izdano u mjesecu
-- služi za praćenje količine računa u određenim mjesecima što može utjecati na neke nove ponude ili opcije
-- za određene mjesece, ovisno da li je broj računa manji ili veći
DELIMITER $$

CREATE FUNCTION broj_racuna_u_mjesecu(p_godina INT, p_mjesec INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE broj_rac_mj INT;

  SELECT COUNT(*)
    INTO broj_rac_mj
  FROM racun r
  WHERE YEAR(r.datum_izdavanja) = p_godina
    AND MONTH(r.datum_izdavanja) = p_mjesec;

  RETURN broj_rac_mj;
END$$

DELIMITER ;

SELECT broj_racuna_u_mjesecu(2025,12) FROM DUAL;

-- broj računa izdanih u odabrano doba dana
-- daje brojčani rezultat koliko računa je izdano u određeno doba dana
-- služi za praćenje količine računa u određeno doba dana što može utjecati na neke nove poslovne odluke (npr posebne ponude za manje popularno doba dana)
DELIMITER $$

CREATE FUNCTION fn_broj_racuna_u_doba_dana(p_od TIME, p_do TIME)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE broj_rac_dan INT;

  SELECT COUNT(*)
    INTO broj_rac_dan
  FROM racun r
  WHERE r.vrijeme_izdavanja >= p_od
    AND r.vrijeme_izdavanja <= p_do;

  RETURN broj_rac_dan;
END$$

DELIMITER ;
SELECT fn_broj_racuna_u_doba_dana("08:00:00", "12:00:00") FROM DUAL;
-- broj računa plaćenih sa odabranom metodom plaćanja
-- daje brojčani rezultat koliko računa je plaćeno sa odabranom metodom plaćanja
-- služi za praćenje popularnih i manje popularnih metoda plaćanja, može poslužiti za neke posebne ponude sa partnerima (npr Visa, American,...)
DELIMITER $$

CREATE FUNCTION fn_broj_racuna_po_metodi(p_metoda VARCHAR(30))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE broj_rac_met INT;

  SELECT COUNT(*)
    INTO broj_rac_met
  FROM racun r
  WHERE LOWER(r.nacin_placanja) = LOWER(p_metoda);

  RETURN broj_rac_met;
END$$

DELIMITER ;
SELECT fn_broj_racuna_po_metodi ("Visa") FROM DUAL;
-- provjera člana (da li je već postojeći član ili novi član)
-- služi za provjeru u slučaju da član nije siguran da li se već učlanio ili ako su podaci koje dobivamo od člana krivi pa tražimo točne
-- po OIB-u:
DELIMITER $$


CREATE FUNCTION fn_clan_postoji_oib(p_oib VARCHAR(20))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE v_cnt INT;

  SELECT COUNT(*)
    INTO v_cnt
  FROM clan c
  WHERE c.oib = p_oib;

  RETURN IF(v_cnt > 0, 1, 0);
END$$

DELIMITER ;
SELECT fn_clan_postoji_oib ("96506066339") FROM DUAL;
SELECT fn_clan_postoji_oib ("46217366479") FROM DUAL;
-- po emailu:
DELIMITER $$

CREATE FUNCTION fn_clan_postoji_email(p_email VARCHAR(255))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE v_cnt INT;

  SELECT COUNT(*)
    INTO v_cnt
  FROM clan c
  WHERE LOWER(c.email) = LOWER(p_email);

  RETURN IF(v_cnt > 0, 1, 0);
END$$

DELIMITER ;
SELECT fn_clan_postoji_email("marija.maric4@gmail.com") FROM DUAL;

-- računanje ukupnog iznosa računa (bez ili sa popustom)
DELIMITER $$

CREATE FUNCTION fn_ukupan_iznos_racuna(p_id_racun INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
  DECLARE v_osnovica DECIMAL(10,2); 
  DECLARE v_postotak INT;
  DECLARE v_popust_check CHAR(1);
  DECLARE v_id_popusta INT;

  -- osnovica = suma stavki
  SELECT IFNULL(SUM(sr.kolicina * a.cijena), 0)
    INTO v_osnovica
  FROM stavka_racun sr
  JOIN artikl a ON a.id = sr.id_artikl
  WHERE sr.id_racun = p_id_racun;

  -- info o popustu s racuna
  SELECT r.popust_check, r.id_popusta
    INTO v_popust_check, v_id_popusta
  FROM racun r
  WHERE r.id = p_id_racun;

  -- ako nema popusta -> vrati osnovicu
  IF v_popust_check <> 'D' OR v_id_popusta IS NULL THEN
    RETURN ROUND(v_osnovica, 2);
  END IF;

  -- dohvati postotak popusta
  SELECT p.postotak
    INTO v_postotak
  FROM popust p
  WHERE p.id = v_id_popusta;

  RETURN ROUND(v_osnovica * (1 - (v_postotak / 100.0)), 2);
END$$

DELIMITER ;




-- POGLEDI:
-- svi izdani računi sa popustom
-- praćenje svih računa koji su uključivali popust
CREATE OR REPLACE VIEW vw_racuni_sa_popustom AS
SELECT r.*
FROM racun r
WHERE r.popust_check = 'D'
  AND r.id_popusta IS NOT NULL;
SELECT * FROM vw_racuni_sa_popustom;
-- u kojem mjestu imamo najviše prihoda?
-- praćenje najpopularnijih mjesta našeg poslovanja
CREATE OR REPLACE VIEW vw_prihod_po_mjestu AS
SELECT 
  m.id AS id_mjesto,
  m.naziv,
  m.postanski_broj,
  m.drzava,
  SUM(r.ukupan_iznos) AS ukupni_prihod
FROM placanje p
JOIN racun r  ON r.id = p.id_racun
JOIN clan c   ON c.id = p.id_clan
JOIN mjesto m ON m.id = c.id_mjesto
WHERE p.status_placanja = 'placeno'
GROUP BY m.id, m.naziv, m.postanski_broj, m.drzava;

SELECT * FROM vw_prihod_po_mjestu;
-- svi neplaćeni računi s popustom
CREATE OR REPLACE VIEW vw_neplaceni_racuni_sa_popustom AS
SELECT DISTINCT r.*
FROM racun r
JOIN placanje p ON p.id_racun = r.id
WHERE r.popust_check = 'D'
  AND r.id_popusta IS NOT NULL
  AND p.status_placanja <> 'placeno';

SELECT * FROM vw_neplaceni_racuni_sa_popustom;
-- članovi bez uplata
CREATE OR REPLACE VIEW vw_clanovi_bez_uplata AS
SELECT c.*
FROM clan c
LEFT JOIN placanje p ON p.id_clan = c.id
WHERE p.id IS NULL;

SELECT * FROM vw_clanovi_bez_uplata;
-- ukupni iznos plaćen po članu za određeni mjesec
CREATE OR REPLACE VIEW vw_placeno_po_clanu_po_mjesecu AS
SELECT
  c.id AS id_clan,
  c.ime,
  c.prezime,
  YEAR(r.datum_izdavanja) AS godina,
  MONTH(r.datum_izdavanja) AS mjesec,
  SUM(r.ukupan_iznos) AS ukupno_placeno
FROM placanje p
JOIN racun r ON r.id = p.id_racun
JOIN clan c  ON c.id = p.id_clan
WHERE p.status_placanja = 'placeno'
GROUP BY c.id, c.ime, c.prezime, YEAR(r.datum_izdavanja), MONTH(r.datum_izdavanja);

SELECT * FROM vw_placeno_po_clanu_po_mjesecu;

-- novi korisnici od 10-12. mjeseca i koliko su platili
CREATE OR REPLACE VIEW vw_novi_korisnici_10_12_i_placanja AS
SELECT
  c.id AS id_clan,
  c.ime,
  c.prezime,
  c.datum_uclanjenja,
  SUM(CASE WHEN p.status_placanja = 'placeno' THEN r.ukupan_iznos ELSE 0 END) AS ukupno_placeno
FROM clan c
LEFT JOIN placanje p ON p.id_clan = c.id
LEFT JOIN racun r ON r.id = p.id_racun
WHERE MONTH(c.datum_uclanjenja) IN (10,11,12)
GROUP BY c.id, c.ime, c.prezime, c.datum_uclanjenja;

SELECT * FROM vw_novi_korisnici_10_12_i_placanja;
-- mjesečni prihodi po načinu plaćanja
CREATE OR REPLACE VIEW vw_mjesecni_prihodi_po_nacinu_placanja AS
SELECT
  YEAR(r.datum_izdavanja) AS godina,
  MONTH(r.datum_izdavanja) AS mjesec,
  r.nacin_placanja,
  SUM(r.ukupan_iznos) AS prihod
FROM placanje p
JOIN racun r ON r.id = p.id_racun
WHERE p.status_placanja = 'placeno'
GROUP BY YEAR(r.datum_izdavanja), MONTH(r.datum_izdavanja), r.nacin_placanja;

SELECT * FROM vw_mjesecni_prihodi_po_nacinu_placanja;

-- top 10 članova po potrošnji
CREATE OR REPLACE VIEW vw_top_10_clanova_po_potrosnji AS
SELECT
  c.id AS id_clan,
  c.ime,
  c.prezime,
  SUM(r.ukupan_iznos) AS ukupna_potrosnja
FROM placanje p
JOIN racun r ON r.id = p.id_racun
JOIN clan c  ON c.id = p.id_clan
WHERE p.status_placanja = 'placeno'
GROUP BY c.id, c.ime, c.prezime
ORDER BY ukupna_potrosnja DESC
LIMIT 10;

SELECT * FROM vw_top_10_clanova_po_potrosnji;
-- članarina vs shop zarada
-- praćenje zarade od članarina vs od shopa (merch)
CREATE OR REPLACE VIEW vw_zarada_clanarina_vs_shop AS
SELECT
  SUM(CASE 
        WHEN p.opis_placanja IN ('mj_clanarina', 'god_clanarina') THEN r.ukupan_iznos
        ELSE 0
      END) AS zarada_clanarina,
  SUM(CASE 
        WHEN p.opis_placanja = 'shop' THEN r.ukupan_iznos
        ELSE 0
      END) AS zarada_shop
FROM placanje p
JOIN racun r ON r.id = p.id_racun
WHERE p.status_placanja = 'placeno';

SELECT * FROM vw_zarada_clanarina_vs_shop;

-- PROCEDURE:

-- promet za odabrani dan
DELIMITER $$

CREATE PROCEDURE sp_promet_za_dan(IN p_datum DATE)
BEGIN
  SELECT
    p_datum AS datum,
    COUNT(*) AS broj_placenih_racuna,
    SUM(r.ukupan_iznos) AS promet
  FROM placanje p
  JOIN racun r ON r.id = p.id_racun
  WHERE p.status_placanja = 'placeno'
    AND r.datum_izdavanja = p_datum;
END$$

DELIMITER ;

CALL sp_promet_za_dan("2025-12-10");
-- ažuriranje popusta
DELIMITER $$

CREATE PROCEDURE pr_azuriraj_popust(
  IN p_id_popusta INT,
  IN p_postotak INT,
  IN p_naziv VARCHAR(100),
  IN p_aktivan TINYINT
)
BEGIN
  UPDATE popust
  SET postotak = p_postotak,
      naziv = p_naziv,
      aktivan = p_aktivan
  WHERE id = p_id_popusta;
END$$

DELIMITER ;


-- kreiraj račun
DELIMITER $$

CREATE PROCEDURE pr_kreiraj_racun(
  IN p_broj_racuna BIGINT,
  IN p_id_popusta INT,
  IN p_nacin_placanja VARCHAR(30),
  IN p_datum DATE,
  IN p_vrijeme TIME,
  IN p_iznos_prije_popusta DECIMAL(10,2),
  IN p_popust_check CHAR(1),
  IN p_ukupan_iznos DECIMAL(10,2)
)
BEGIN
  INSERT INTO racun
    (id, broj_racuna, id_popusta, nacin_placanja, datum_izdavanja, vrijeme_izdavanja,
     iznos_prije_popusta, popust_check, ukupan_iznos)
  VALUES
    (NULL, p_broj_racuna, p_id_popusta, p_nacin_placanja, p_datum, p_vrijeme,
     p_iznos_prije_popusta, p_popust_check, p_ukupan_iznos);

  SELECT LAST_INSERT_ID() AS novi_id_racun;
END$$

DELIMITER ;

-- označi račun kao plaćen
DELIMITER $$

CREATE PROCEDURE pr_oznaci_racun_kao_placen(IN p_id_racun INT)
BEGIN
  UPDATE placanje
  SET status_placanja = 'placeno'
  WHERE id_racun = p_id_racun;
END$$

DELIMITER ;

-- povrat novca
DELIMITER $$



-- primijeni popust na račun
DELIMITER $$

CREATE PROCEDURE pr_primijeni_popust_na_racun(
  IN p_id_racun INT,
  IN p_id_popusta INT
)
BEGIN
  UPDATE racun
  SET id_popusta = p_id_popusta,
      popust_check = 'D'
  WHERE id = p_id_racun;

  UPDATE racun
  SET ukupan_iznos = fn_ukupan_iznos_racuna(p_id_racun)
  WHERE id = p_id_racun;
END$$

DELIMITER ;

-- izbriši popust sa računa
DELIMITER $$

CREATE PROCEDURE pr_ukloni_popust_sa_racuna(IN p_id_racun INT)
BEGIN
  UPDATE racun
  SET id_popusta = NULL,
      popust_check = 'N'
  WHERE id = p_id_racun;

  UPDATE racun
  SET ukupan_iznos = fn_ukupan_iznos_racuna(p_id_racun)
  WHERE id = p_id_racun;
END$$

DELIMITER ;

-- statistika popusta
DELIMITER $$

CREATE PROCEDURE pr_statistika_popusta(
  IN p_godina INT,
  IN p_mjesec INT
)
BEGIN
  SELECT
    r.id_popusta,
    COUNT(*) AS broj_racuna,
    SUM(r.iznos_prije_popusta) AS suma_prije,
    SUM(r.ukupan_iznos) AS suma_poslije,
    (SUM(r.iznos_prije_popusta) - SUM(r.ukupan_iznos)) AS ukupno_ustedjeno
  FROM racun r
  JOIN placanje p ON p.id_racun = r.id
  WHERE p.status_placanja = 'placeno'
    AND r.id_popusta IS NOT NULL
    AND YEAR(r.datum_izdavanja) = p_godina
    AND MONTH(r.datum_izdavanja) = p_mjesec
  GROUP BY r.id_popusta
  ORDER BY ukupno_ustedjeno DESC;
END$$

DELIMITER ;

CALL pr_statistika_popusta(2025,11);

-- OKIDAČI:
-- zabrana plaćanja za isti račun
DELIMITER $$

CREATE TRIGGER trg_placanje_jedan_po_racunu
BEFORE INSERT ON placanje
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM placanje p
    WHERE p.id_racun = NEW.id_racun
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Ne moze se evidentirati vise uplata za isti racun.';
  END IF;
END$$

DELIMITER ;

-- zabrana brisanja računa
DELIMITER $$

CREATE TRIGGER trg_racun_zabrana_brisanja
BEFORE DELETE ON racun
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Brisanje racuna nije dozvoljeno.';
END$$

DELIMITER ;

-- blokiranje člana kad ima previše neuplaćenih računa
DELIMITER $$

CREATE TRIGGER trg_clan_blokiraj_after_insert_placanje
AFTER INSERT ON placanje
FOR EACH ROW
BEGIN
  DECLARE v_broj INT;

  SELECT COUNT(*)
  INTO v_broj
  FROM placanje p
  WHERE p.id_clan = NEW.id_clan
    AND p.status_placanja IN ('nije_placeno', 'blokirano');

  IF v_broj > 3 THEN
    UPDATE clan
    SET aktivan = 0
    WHERE id = NEW.id_clan;
  END IF;
END$$

DELIMITER ;


-- trigger za dodavanje novog izvršenog plaćanja koji je vezan za članarinu
DELIMITER $$

CREATE TRIGGER tg_izvrseno_placanje_clanarina
AFTER INSERT ON placanje
FOR EACH ROW
BEGIN
    INSERT INTO izvrsena_placanja (id_placanje, id_clanarine, status_tf)
    SELECT
        NEW.id,
        c.id,
        CASE
            WHEN NEW.status_placanja = 'placeno' THEN TRUE
            ELSE FALSE
        END
    FROM racun_stavka rs
    JOIN clanarina c ON c.id_clan = NEW.id_clan
    WHERE rs.id_racun = NEW.id_racun
      AND rs.id_tip_clanarine IS NOT NULL;
END$$

DELIMITER ;

-- transakcije
DELIMITER $$

CREATE PROCEDURE pr_povrat_novca(
  IN p_id_clan INT,
  IN p_iznos DECIMAL(10,2),        -- positive input (we'll store negative)
  IN p_nacin_placanja VARCHAR(30),
  IN p_datum DATE,
  IN p_vrijeme TIME,
  IN p_broj_racuna BIGINT
)
BEGIN
  DECLARE v_id_racun INT;

  START TRANSACTION;

  INSERT INTO racun
    (broj_racuna, id_popusta, nacin_placanja, datum_izdavanja, vrijeme_izdavanja,
     iznos_prije_popusta, popust_check, ukupan_iznos)
  VALUES
    (NULL, p_broj_racuna, NULL, p_nacin_placanja, p_datum, p_vrijeme,
     -ABS(p_iznos), 'N', -ABS(p_iznos));

  INSERT INTO placanje (id_clan, id_racun, opis_placanja, status_placanja)
  VALUES (NULL, p_id_clan, v_id_racun, 'povrat_novca', 'placeno');

  COMMIT;

  SELECT v_id_racun AS refund_racun_id;
END$$

DELIMITER ;


