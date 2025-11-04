DELIMITER !%
CREATE TRIGGER racunanje_kraja_treninga
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
                ELSE
					SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'Nije moguće unijeti termin treninga: nepostojeći trening_id.';
				END IF;
			END; !%
DELIMITER ;