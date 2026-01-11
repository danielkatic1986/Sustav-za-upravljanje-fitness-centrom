-- Kreiranje korisnika za flask app
CREATE USER 'flask_user'@'localhost'
IDENTIFIED BY 'flask_lozinka';

-- Osnovna prava nad bazom
GRANT
    SELECT,
    INSERT,
    UPDATE,
    DELETE
ON fitness_centar.*
TO 'flask_user'@'localhost';

-- Dozvola za korištenje procedura
GRANT EXECUTE
ON fitness_centar.*
TO 'flask_user'@'localhost';

FLUSH PRIVILEGES;