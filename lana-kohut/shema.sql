DROP DATABASE IF EXISTS fitness_centar;
CREATE DATABASE fitness_centar;
USE fitness_centar;

CREATE TABLE placanje (
id 	INT AUTO_INCREMENT PRIMARY KEY,
id_clan INT ,
id_racun INT,
opis_placanja VARCHAR(100),
status_placanja VARCHAR(50),
FOREIGN KEY (id_clan) REFERENCES clan (id),
FOREIGN KEY (id_racun) REFERENCES racun (id)
);

CREATE TABLE racun (
id INT AUTO_INCREMENT PRIMARY KEY,
id_popusta INT,
nacin_placanja VARCHAR(50),
datum_izdavanja DATE,
vrijeme_izdavanja TIMESTAMP,
iznos INT,
popust_check VARCHAR(1),
ukupan_iznos INT,
FOREIGN KEY (id_popusta) REFERENCES popust (id)

);

CREATE TABLE popust (
id INT AUTO_INCREMENT PRIMARY KEY,
naziv_popusta VARCHAR(50),
iznos_popusta INT
);
