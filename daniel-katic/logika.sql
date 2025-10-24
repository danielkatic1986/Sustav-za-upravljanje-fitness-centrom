/*
    Definicija logike
*/

/*
    TRIGGER: datum_uclanjenja
    Opis: automatsko postavljanje datuma učlanjenja
*/
DELIMITER $$

CREATE TRIGGER datum_uclanjenja
BEFORE INSERT ON clan
FOR EACH ROW
BEGIN
    IF NEW.datum_uclanjenja IS NULL THEN
        SET NEW.datum_uclanjenja = CURDATE();
    END IF;
END$$

DELIMITER ;