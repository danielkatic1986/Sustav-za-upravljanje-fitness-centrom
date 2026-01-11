-- Modul: program / trening / trening_clan (+ rezervacija, termin_treninga)
-- Sadrži: 2 VIEW-a + 3 PROCEDURE (1 glavna + 2 mini), transakcije i SIGNAL poruke.

SET NAMES utf8mb4;

-- ============================================================
-- VIEW 1: Popunjenost termina
-- ============================================================

CREATE VIEW v_popunjenost_termina AS
SELECT
    tt.id AS termin_id,
    p.naziv AS naziv_programa,
    t.id AS trening_id,
    tt.vrijeme_pocetka,
    tt.vrijeme_zavrsetka,
    COUNT(tc.id) AS broj_prisutnih
FROM termin_treninga tt
JOIN trening t
    ON tt.trening_id = t.id
JOIN program p
    ON t.program_id = p.id
LEFT JOIN trening_clan tc
    ON tc.termin_treninga_id = tt.id
   AND tc.status_prisustva = 'PRISUTAN'
GROUP BY
    tt.id,
    p.naziv,
    t.id,
    tt.vrijeme_pocetka,
    tt.vrijeme_zavrsetka;

-- ============================================================
-- VIEW 2: Aktivnost člana (PRISUTAN / IZOSTANAK / OPRAVDANO)
-- ============================================================

CREATE VIEW v_aktivnost_clana AS
SELECT
    c.id AS clan_id,
    c.ime,
    c.prezime,
    SUM(CASE WHEN tc.status_prisustva = 'PRISUTAN' THEN 1 ELSE 0 END) AS broj_prisutnih,
    SUM(CASE WHEN tc.status_prisustva = 'IZOSTANAK' THEN 1 ELSE 0 END) AS broj_izostanaka,
    SUM(CASE WHEN tc.status_prisustva = 'OPRAVDANO' THEN 1 ELSE 0 END) AS broj_opravdanih,
    COUNT(tc.id) AS ukupno_evidencija
FROM clan c
LEFT JOIN trening_clan tc
    ON tc.clan_id = c.id
GROUP BY
    c.id, c.ime, c.prezime;

-- ============================================================
-- PROCEDURE: p_checkin_clana - samo uz rezervaciju
-- ============================================================

DELIMITER $$

CREATE PROCEDURE p_checkin_clana(
    IN p_termin_treninga_id INT,
    IN p_clan_id INT,
    IN p_napomena VARCHAR(255)
)
BEGIN
    DECLARE v_rezervacija_count INT DEFAULT 0;
    DECLARE v_evidencija_count INT DEFAULT 0;

    START TRANSACTION;

    -- 1) Mora postojati rezervacija
    SELECT COUNT(*)
      INTO v_rezervacija_count
    FROM rezervacija r
    WHERE r.termin_treninga_id = p_termin_treninga_id
      AND r.clan_id = p_clan_id;

    IF v_rezervacija_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check-in nije moguć: član nema rezervaciju za odabrani termin.';
    END IF;

    -- 2) Ne smije već postojati evidencija (UNIQUE termin+clan)
    SELECT COUNT(*)
      INTO v_evidencija_count
    FROM trening_clan tc
    WHERE tc.termin_treninga_id = p_termin_treninga_id
      AND tc.clan_id = p_clan_id;

    IF v_evidencija_count > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Check-in nije moguć: evidencija za ovog člana i termin već postoji.';
    END IF;

    -- 3) Upis evidencije dolaska
    INSERT INTO trening_clan (
        termin_treninga_id,
        clan_id,
        status_prisustva,
        vrijeme_checkina,
        napomena
    ) VALUES (
        p_termin_treninga_id,
        p_clan_id,
        'PRISUTAN',
        NOW(),
        p_napomena
    );

    COMMIT;
END$$

-- ============================================================
-- PROCEDURE: p_otkazi_rezervaciju
-- ============================================================

CREATE PROCEDURE p_otkazi_rezervaciju(
    IN p_termin_treninga_id INT,
    IN p_clan_id INT
)
BEGIN
    DECLARE v_rezervacija_count INT DEFAULT 0;

    START TRANSACTION;

    SELECT COUNT(*)
      INTO v_rezervacija_count
    FROM rezervacija r
    WHERE r.termin_treninga_id = p_termin_treninga_id
      AND r.clan_id = p_clan_id;

    IF v_rezervacija_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Otkaz nije moguć: rezervacija ne postoji.';
    END IF;

    DELETE FROM rezervacija
    WHERE termin_treninga_id = p_termin_treninga_id
      AND clan_id = p_clan_id;

    COMMIT;
END$$

-- ============================================================
-- PROCEDURE: p_oznaci_izostanak - upis izostanka (uz rezervaciju)
-- ============================================================

CREATE PROCEDURE p_oznaci_izostanak(
    IN p_termin_treninga_id INT,
    IN p_clan_id INT,
    IN p_napomena VARCHAR(255)
)
BEGIN
    DECLARE v_rezervacija_count INT DEFAULT 0;
    DECLARE v_evidencija_count INT DEFAULT 0;

    START TRANSACTION;

    -- mora postojati rezervacija
    SELECT COUNT(*)
      INTO v_rezervacija_count
    FROM rezervacija r
    WHERE r.termin_treninga_id = p_termin_treninga_id
      AND r.clan_id = p_clan_id;

    IF v_rezervacija_count = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Izostanak nije moguć: član nema rezervaciju za odabrani termin.';
    END IF;

    -- ne smije već postojati evidencija
    SELECT COUNT(*)
      INTO v_evidencija_count
    FROM trening_clan tc
    WHERE tc.termin_treninga_id = p_termin_treninga_id
      AND tc.clan_id = p_clan_id;

    IF v_evidencija_count > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Izostanak nije moguć: evidencija već postoji.';
    END IF;

    INSERT INTO trening_clan (
        termin_treninga_id,
        clan_id,
        status_prisustva,
        vrijeme_checkina,
        napomena
    ) VALUES (
        p_termin_treninga_id,
        p_clan_id,
        'IZOSTANAK',
        NULL,
        p_napomena
    );

    COMMIT;
END$$

DELIMITER ;
