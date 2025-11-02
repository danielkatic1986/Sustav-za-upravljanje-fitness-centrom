CREATE TABLE IF NOT EXISTS program (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  naziv      VARCHAR(80)  NOT NULL,
  opis       TEXT,
  intenzitet ENUM('LOW','MEDIUM','HIGH') NOT NULL DEFAULT 'MEDIUM',
  UNIQUE (naziv)
) ENGINE=InnoDB;


CREATE TABLE IF NOT EXISTS trening (
  id                     INT AUTO_INCREMENT PRIMARY KEY,
  program_id             INT NOT NULL,
  razina                 ENUM('BEGINNER','INTERMEDIATE','ADVANCED') NOT NULL DEFAULT 'BEGINNER',
  planirano_trajanje_min SMALLINT UNSIGNED NOT NULL DEFAULT 60,
  max_polaznika          SMALLINT UNSIGNED NOT NULL DEFAULT 20,
  aktivan                TINYINT(1) NOT NULL DEFAULT 1,
  CONSTRAINT fk_trening_program
    FOREIGN KEY (program_id) REFERENCES program(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX (program_id)
) ENGINE=InnoDB;



CREATE TABLE IF NOT EXISTS trening_clan (
  id                 INT AUTO_INCREMENT PRIMARY KEY,
  termin_treninga_id INT NOT NULL,
  clan_id            INT NOT NULL,
  status_prisustva   ENUM('PRISUTAN','IZOSTANAK','OPRAVDANO') NOT NULL DEFAULT 'PRISUTAN',
  vrijeme_checkina   DATETIME NULL,
  napomena           VARCHAR(255),
  CONSTRAINT uq_trening_clan UNIQUE (termin_treninga_id, clan_id),
  CONSTRAINT fk_tc_termin
    FOREIGN KEY (termin_treninga_id) REFERENCES termin_treninga(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_tc_clan
    FOREIGN KEY (clan_id) REFERENCES clan(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  INDEX (clan_id)
) ENGINE=InnoDB;
