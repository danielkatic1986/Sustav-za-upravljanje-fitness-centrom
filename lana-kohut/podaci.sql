-- podaci za tablice
INSERT INTO placanje (id, id_racun, opis_placanja, status_placanja) VALUES
(54987, 100487596, 'mj_clanarina', 'placeno'),
(54988, 100487597, 'god_clanarina', 'blokirano'),
(54989, 100487598, 'povrat_novca', 'nije_placeno'),
(54990, 100487599, 'povrat_novca', 'nije_placeno'),
(54991, 100487600, 'god_clanarina', 'blokirano'),
(54992, 100487601, 'povrat_novca', 'blokirano'),
(54993, 100487602, 'mj_clanarina', 'placeno'),
(54994, 100487603, 'god_clanarina', 'nije_placeno'),
(54995, 100487604, 'povrat_novca', 'nije_placeno'),
(54996, 100487605, 'mj_clanarina', 'blokirano'),
(54997, 100487606, 'god_clanarina', 'placeno'),
(54998, 100487607, 'shop', 'placeno'),
(54999, 100487608, 'mj_clanarina', 'blokirano'),
(55000, 100487609, 'god_clanarina', 'nije_placeno'),
(55001, 100487610, 'shop', 'placeno'),
(55002, 100487611, 'mj_clanarina', 'nije_placeno'),
(55003, 100487612, 'god_clanarina', 'nije_placeno'),
(55004, 100487613, 'shop', 'blokirano'),
(55005, 100487614, 'mj_clanarina', 'nije_placeno'),
(55006, 100487615, 'god_clanarina', 'nije_placeno'),
(55007, 100487616, 'shop', 'placeno');


INSERT INTO racun 
(id, broj_racuna, id_popusta, nacin_placanja, datum_izdavanja, vrijeme_izdavanja, iznos_prije_popusta, popust_check, ukupan_iznos) 
VALUES
(100487596, 132786544, 7001, 'visa',       '2025-10-01', '08:12:35', 45,  'D', 40.5),
(100487597, 132786545, NULL, 'mastercard', '2025-10-02', '08:47:09', 600, 'N', 600),
(100487598, 132786546, NULL, 'diners',     '2025-10-03', '09:23:58', -45, 'D', -40.5),
(100487599, 132786547, 7001, 'gotovina',   '2025-10-04', '09:56:44', 55,  'D', 49.5),
(100487600, 132786548, NULL, 'gotovina',   '2025-10-05', '10:31:27', 600, 'N', 600),
(100487601, 132786549, 7001, 'visa',       '2025-10-12', '11:04:52', -45, 'N', -45),
(100487602, 132786550, NULL, 'visa',       '2025-10-13', '11:39:15', 65,  'N', 65),
(100487603, 132786551, NULL, 'mastercard', '2025-10-15', '12:22:08', 600, 'N', 600),
(100487604, 132786552, NULL, 'gotovina',   '2025-10-15', '13:10:36', -55, 'N', -55),
(100487605, 132786553, NULL, 'gotovina',   '2025-10-17', '13:54:41', 600, 'N', 600),
(100487606, 132786554, NULL, 'american',   '2025-10-18', '14:37:19', 600, 'N', 600),
(100487607, 132786555, NULL, 'visa',       '2025-10-18', '15:08:55', 45,  'D', 40.5),
(100487608, 132786556, NULL, 'gotovina',   '2025-10-19', '15:42:33', 80,  'N', 80),
(100487609, 132786557, NULL, 'diners',     '2025-10-20', '16:25:11', 150, 'N', 150),
(100487610, 132786558, 7002, 'diners',     '2025-10-21', '17:02:47', 55,  'D', 49.5),
(100487611, 132786560, 7002, 'mastercard', '2025-10-21', '18:24:13', 600, 'D', 480),
(100487612, 132786561, NULL, 'mastercard', '2025-10-22', '18:49:59', 250, 'N', 250),
(100487613, 132786562, NULL, 'gotovina',   '2025-10-24', '19:51:05', 65,  'N', 65),
(100487614, 132786563, NULL, 'gotovina',   '2025-10-27', '20:36:48', 600, 'N', 600),
(100487615, 132786564, NULL, 'gotovina',   '2025-10-29', '21:57:16', 345, 'N', 345);


INSERT INTO popust (id, naziv_popusta, iznos_popusta) VALUES
(7001, 'Popust za nove korisnike', 10),
(7002, 'Prijelaz sa mjesecne na godisnju clanarinu', 20),
(7003, 'Ljetni popust (3-mjesecna clanarina)', 50),
(7004, 'Božić', 50),
(7005, 'Rođendan centra', 15);
