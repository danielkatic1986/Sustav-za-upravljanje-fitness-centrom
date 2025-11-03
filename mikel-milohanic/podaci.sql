INSERT INTO tip_prostorije (naziv, opis) VALUES
('Kardio', 'Opremljena s trakama, orbitrecima i biciklima za razvoj izdržljivosti.'),
('Teretana', 'Opremljena utezima i spravama za snagu, pogodna za powerlifting i bodybuilding.'),
('Funkcionalna', 'Pogodna za CrossFit, TRX i treninge visokog intenziteta.'),
('Aerobik/ples', 'Prilagođena za aerobik, zumbu i ostale programe s glazbom.'),
('Mind&Body', 'Sesije usmjerene na držanje, disanje i kontrolu pokreta npr. yoga, pilates, meditacija.'),
('Mobilnost i istezanje', 'Zona pogodna za istezanje i mobilnost.'),
('Borilačka', 'Boks, kickboxing, tatami zone i ring.'),
('Bazen', 'Zatvoreni bazen i prostor za aqua aerobik.'),
('Višenamjenska', 'Rekreacijska dvorana za različite sportove i radionice.'),
('Outdoor', 'Vanjski prostor za trening na otvorenom.'),
('Bodyweight', 'Zona namijenjena kalistenici, street workoutu i gimnastičkim vježbama.'),
('Sportska dvorana', 'Dvorana prilagođena za sportske aktivnosti poput košarke, badmintona ili nogometa.'),
('Penjačka', 'Prostorija opremljena umjetnom stijenom i sigurnosnom opremom za trening penjanja i razvoja snage gornjeg dijela tijela.');

INSERT INTO prostorija (oznaka, lokacija, kapacitet, tip_prostorije_id, podruznica_id) VALUES
('K-1', 'Prizemlje, lijevi blok', 20, 1, 1),
('K-2', 'Prizemlje, lijevi blok', 30, 1, 1),
('T-1', 'Suteren', 100, 2, 1),
('F-1', '1. kat', 20, 3, 1),
('A-1', 'Prizemlje, desni blok', 30, 4, 1),
('A-2', 'Prizemlje, desni blok', 30, 4, 1),
('MB-1', '1. kat, desni blok', 20, 5, 1),
('MI-1', '1. kat, desni blok', 20, 6, 1),
('BO-1', '1. kat', 30, 7, 1),
('BAZ-1', 'Suteren', 20, 8, 1),
('BAZ-2', 'Suteren', 30, 8, 1),
('V-1', '1. kat, lijevi blok', 20, 9, 1),
('V-2', '1. kat, lijevi blok', 20, 9, 1),
('O-1', 'Vani', 50, 10, 1),
('BW-1', '1. kat', 30, 11, 1),
('SD-1', 'Prizemlje', 30, 12, 1),
('P-1', 'Prizemlje', 20, 13, 1),

('K-1', 'Prizemlje, desni blok', 20, 1, 2),
('K-2', 'Prizemlje, desni blok', 20, 1, 2),
('T-1', '1. kat, lijevi blok', 80, 2, 2),
('F-1', '1. kat', 30, 3, 2),
('A-1', 'Prizemlje', 40, 4, 2),
('MB-1', '1. kat, desni blok', 20, 5, 2),
('MI-1', '1. kat, desni blok', 20, 6, 2),
('BO-1', '1. kat', 40, 7, 2),
('BAZ-1', 'Prizemlje', 40, 8, 2),
('V-1', '1. kat', 30, 9, 2),
('O-1', 'Vani', 70, 10, 2),
('BW-1', '1. kat, desni blok', 30, 11, 2),
('SD-1', 'Prizemlje, lijevi blok', 30, 12, 2),
('P-1', 'Prizemlje, lijevi blok', 20, 13, 2),

('K-1', '1. kat', 30, 1, 3),
('K-2', '1. kat', 30, 1, 3),
('T-1', 'Prizemlje', 60, 2, 3),
('F-1', '2. kat', 20, 3, 3),
('A-1', '1. kat', 30, 4, 3),
('MB-1', '2. kat', 15, 5, 3),
('MI-1', '2. kat', 15, 6, 3),
('BO-1', '2. kat', 20, 7, 3),
('BAZ-1', 'Suteren', 35, 8, 3),
('V-1', '2. kat', 30, 9, 3),
('O-1', 'Vani', 40, 10, 3),
('BW-1', '1. kat', 30, 11, 3),
('SD-1', 'Prizemlje', 30, 12, 3),
('P-1', 'Prizemlje', 30, 13, 3),

('K-1', 'Prizemlje, desni blok', 50, 1, 4),
('T-1', 'Prizemlje, desni blok', 50, 2, 4),
('F-1', 'Prizemlje', 30, 3, 4),
('A-1', 'Prizemlje, desni blok', 30, 4, 4),
('MB-1', 'Prizemlje', 25, 5, 4),
('MI-1', 'Prizemlje', 25, 6, 4),
('BO-1', 'Prizemlje, lijevi blok', 50, 7, 4),
('BAZ-1', 'Prizemlje', 50, 8, 4),
('V-1', 'Prizemlje, lijevi blok', 30, 9, 4),
('O-1', 'Vani', 60, 10, 4),
('BW-1', 'Prizemlje, desni blok', 35, 11, 4),
('SD-1', 'Prizemlje, lijevi blok', 30, 12, 4),
('P-1', 'Prizemlje, lijevi blok', 30, 13, 4),

('K-1', 'Prizemlje', 30, 1, 5),
('T-1', 'Prizemlje', 50, 2, 5),
('F-1', '1. kat', 20, 3, 5),
('A-1', '1. kat', 20, 4, 5),
('MB-1', '1. kat', 15, 5, 5),
('MI-1', '1. kat', 15, 6, 5),
('BO-1', '1. kat', 20, 7, 5),
('BAZ-1', 'Prizemlje', 30, 8, 5),
('V-1', '1. kat', 20, 9, 5),
('SD-1', 'Prizemlje', 30, 12, 5),

('K-1', 'Prizemlje, lijevi blok', 30, 1, 6),
('T-1', 'Prizemlje', 50, 2, 6),
('F-1', 'Prizemlje, desni blok', 20, 3, 6),
('A-1', 'Prizemlje, lijevi blok', 30, 4, 6),
('BAZ-1', 'Prizemlje', 30, 8, 6),
('V-1', 'Prizemlje, desni blok', 20, 9, 6),
('O-1', 'Vani', 30, 10, 6),
('BW-1', 'Prizemlje, desni blok', 20, 11, 6),
('SD-1', 'Prizemlje, lijevi blok', 30, 12, 6),
('P-1', 'Prizemlje, desni blok', 20, 13, 6),

('K-1', 'Prizemlje', 20, 1, 7),
('T-1', 'Prizemlje', 50, 2, 7),
('F-1', '1. kat', 20, 3, 7),
('A-1', '1. kat', 20, 4, 7),
('MI-1', '1. kat', 15, 6, 7),
('BAZ-1', 'Prizemlje', 30, 8, 7),
('V-1', '1. kat', 20, 9, 7),
('O-1', 'Vani', 30, 10, 7),
('SD-1', 'Prizemlje', 30, 12, 7),
('P-1', '1. kat', 15, 13, 7),

('K-1', 'Prizemlje', 30, 1, 8),
('T-1', 'Prizemlje', 50, 2, 8),
('F-1', '1. kat', 20, 3, 8),
('A-1', '1. kat', 20, 4, 8),
('MI-1', '1. kat', 15, 6, 8),
('BAZ-1', 'Prizemlje', 30, 8, 8),
('V-1', '1. kat', 20, 9, 8),
('O-1', 'Vani', 30, 10, 8),
('BW-1', '1. kat', 15, 11, 8),
('SD-1', 'Prizemlje', 30, 12, 8),

('K-1', 'Prizemlje, lijevi blok', 30, 1, 9),
('T-1', 'Prizemlje', 60, 2, 9),
('F-1', '1. kat', 20, 3, 9),
('A-1', 'Prizemlje, lijevi blok', 30, 4, 9),
('MB-1', '1. kat, desni blok', 20, 5, 9),
('MI-1', '1. kat, desni blok', 20, 6, 9),
('BO-1', '1. kat', 30, 7, 9),
('BAZ-1', 'Prizemlje, desni blok', 50, 8, 9),
('V-1', '1. kat, lijevi blok', 30, 9, 9),
('BW-1', '1. kat', 20, 11, 9),
('SD-1', 'Prizemlje, desni blok', 30, 12, 9),
('P-1', 'Prizemlje', 20, 13, 9),

('K-1', 'Prizemlje', 30, 1, 10),
('T-1', 'Suteren', 60, 2, 10),
('F-1', 'Prizemlje', 30, 3, 10),
('A-1', 'Prizemlje', 30, 4, 10),
('BO-1', 'Prizemlje', 20, 7, 10),
('BAZ-1', 'Suteren', 35, 8, 10),
('V-1', 'Prizemlje', 30, 9, 10),
('O-1', 'Vani', 30, 10, 10),
('SD-1', 'Suteren', 30, 12, 10);

INSERT INTO termin_treninga (trening_id, prostorija_id, trener_id, vrijeme_pocetka, vrijeme_zavrsetka, napomena) VALUES
(3, 7, 3, STR_TO_DATE('01.10.2025. 18:00:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 1
(5, 93, 35, STR_TO_DATE('01.10.2025. 18:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 2
(3, 93, 15, STR_TO_DATE('01.10.2025. 19:30:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 3
(3, 63, 11, STR_TO_DATE('02.10.2025. 18:00:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 4
(2, 48, 30, STR_TO_DATE('02.10.2025. 19:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 5
(1, 4, 24, STR_TO_DATE('03.10.2025. 15:30:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 6
(5, 74, 33, STR_TO_DATE('03.10.2025. 18:00:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 7
(3, 93, 36, STR_TO_DATE('03.10.2025. 18:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 8
(2, 113, trener_karlovac, STR_TO_DATE('04.10.2025. 17:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 9
(2, 4, 22, STR_TO_DATE('04.10.2025. 18:00:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 10
(6, 18, 25, STR_TO_DATE('04.10.2025. 18:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 11
(1, 101, 37, STR_TO_DATE('05.10.2025. 18:10:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 12
(4, 4, 2, STR_TO_DATE('05.10.2025. 16:00:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 13
(6, 46, 30, STR_TO_DATE('06.10.2025. 18:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 14
(1, 81, 20, STR_TO_DATE('07.10.2025. 18:10:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 15
(4, 35, 7, STR_TO_DATE('07.10.2025. 18:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 16
(3, 7, 1, STR_TO_DATE('08.10.2025. 18:10:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 17
(3, 85, 41, STR_TO_DATE('08.10.2025. 18:15:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 18
(2, 21, 4, STR_TO_DATE('09.10.2025. 16:30:00', '%d.%m.%Y. %H:%i:%s'), NULL), -- 19
(5, 37, 28, STR_TO_DATE('09.10.2025. 18:15:00', '%d.%m.%Y. %H:%i:%s'), NULL); -- 20

INSERT INTO rezervacija (clan_id, termin_treninga_id, vrijeme_rezervacije, nacin_rezervacije) VALUES
(1, 1, STR_TO_DATE('27.09.2025. 11:13:07', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(2, 1, STR_TO_DATE('24.09.2025. 09:21:11', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(3, 2, STR_TO_DATE('23.09.2025. 20:09:16', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(4, 3, STR_TO_DATE('25.09.2025. 20:00:19', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(5, 4, STR_TO_DATE('28.09.2025. 12:54:56', '%d.%m.%Y. %H:%i:%s'), 'Recepcija'),
(6, 5, STR_TO_DATE('01.10.2025. 17:51:22', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(7, 6, STR_TO_DATE('30.09.2025. 15:48:44', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(8, 7, STR_TO_DATE('29.09.2025. 11:03:33', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(9, 8, STR_TO_DATE('01.10.2025. 16:54:40', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(10, 9, STR_TO_DATE('28.09.2025. 18:42:07', '%d.%m.%Y. %H:%i:%s'), 'Recepcija'),
(11, 10, STR_TO_DATE('01.10.2025. 14:28:02', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(12, 11, STR_TO_DATE('02.10.2025. 10:56:38', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(13, 12, STR_TO_DATE('30.09.2025. 09:52:36', '%d.%m.%Y. %H:%i:%s'), 'Recepcija'),
(14, 13, STR_TO_DATE('03.10.2025. 21:48:13', '%d.%m.%Y. %H:%i:%s'), 'Recepcija'),
(15, 14, STR_TO_DATE('01.10.2025. 08:34:42', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(16, 15, STR_TO_DATE('04.10.2025. 20:55:38', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(17, 16, STR_TO_DATE('02.10.2025. 16:03:03', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(18, 17, STR_TO_DATE('01.10.2025. 16:38:42', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(19, 18, STR_TO_DATE('03.10.2025. 19:49:00', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(20, 19, STR_TO_DATE('06.10.2025. 19:59:31', '%d.%m.%Y. %H:%i:%s'), 'Online'),
(21, 20, STR_TO_DATE('02.10.2025. 10:16:08', '%d.%m.%Y. %H:%i:%s'), 'Online');