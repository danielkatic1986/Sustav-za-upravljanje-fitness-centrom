-- PROGRAM
INSERT INTO program (naziv, opis, intenzitet) VALUES
('CrossFit', 'Visokointenzivni funkcionalni kružni treninzi', 'HIGH'),
('Yoga Flow', 'Mind & Body vježbe disanja i istezanja', 'LOW'),
('HIIT 30', 'Kratki intervalni treninzi od 30 minuta', 'HIGH'),
('Pilates Core', 'Fokus na stabilnost trupa i mobilnost', 'MEDIUM'),
('Cardio Blast', 'Kombinacija trčanja, bicikla i stepera', 'MEDIUM');

-- TRENING
INSERT INTO trening (program_id, razina, planirano_trajanje_min, max_polaznika, aktivan) VALUES
(1, 'INTERMEDIATE', 60, 15, 1),
(1, 'ADVANCED',     75, 12, 1),
(2, 'BEGINNER',     50, 18, 1),
(3, 'INTERMEDIATE', 30, 20, 1),
(4, 'BEGINNER',     55, 14, 1),
(5, 'INTERMEDIATE', 45, 20, 1);

-- TRENING_CLAN
INSERT INTO trening_clan (termin_treninga_id, clan_id, status_prisustva, vrijeme_checkina, napomena) VALUES
(1,  1,  'PRISUTAN',  '2025-10-01 18:02:00', NULL),
(1,  2,  'PRISUTAN',  '2025-10-01 18:04:00', NULL),
(2,  3,  'IZOSTANAK', NULL,                   'nije došao'),
(3,  4,  'PRISUTAN',  '2025-10-02 17:58:00', NULL),
(4,  5,  'PRISUTAN',  '2025-10-02 19:00:00', NULL),
(5,  6,  'OPRAVDANO', NULL,                   'bolest'),
(6,  7,  'PRISUTAN',  '2025-10-03 17:55:00', NULL),
(7,  8,  'PRISUTAN',  '2025-10-03 18:01:00', NULL),
(8,  9,  'IZOSTANAK', NULL,                   NULL),
(9,  10, 'PRISUTAN',  '2025-10-04 17:58:00', NULL),
(10, 11, 'PRISUTAN',  '2025-10-04 18:04:00', NULL),
(11, 12, 'PRISUTAN',  '2025-10-05 18:01:00', NULL),
(12, 13, 'IZOSTANAK', NULL,                   NULL),
(13, 14, 'PRISUTAN',  '2025-10-06 18:03:00', NULL),
(14, 15, 'PRISUTAN',  '2025-10-07 18:02:00', NULL),
(15, 16, 'PRISUTAN',  '2025-10-07 18:00:00', NULL),
(16, 17, 'PRISUTAN',  '2025-10-08 18:01:00', NULL),
(17, 18, 'PRISUTAN',  '2025-10-09 18:03:00', NULL),
(18, 19, 'IZOSTANAK', NULL,                   'kasno otkazao'),
(19, 20, 'PRISUTAN',  '2025-10-09 18:02:00', NULL),
(20, 21, 'PRISUTAN',  '2025-10-10 18:05:00', NULL);
