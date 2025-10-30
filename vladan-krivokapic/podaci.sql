/* =================================================
   INSERT PODACI – DOBAVLJAC
   ================================================= */
INSERT INTO dobavljac (naziv, oib, kontakt, adresa)
VALUES
('FitZone d.o.o.',        '12345678901', 'info@fitzone.hr', 'Ulica sporta 5, Zagreb'),
('SportMax d.o.o.',       '23456789012', 'kontakt@sportmax.hr', 'Industrijska 12, Rijeka'),
('ProGym Equipments',     '34567890123', 'sales@progym.hr', 'Trg Trenera 8, Split'),
('ActiveLine d.o.o.',     '45678901234', 'info@activeline.hr', 'Bana Jelačića 17, Osijek'),
('MuscleTech Europe',     '56789012345', 'office@mt-europe.com', 'Savska cesta 23, Zagreb'),
('TitanFit Equipment',    '67890123456', 'support@titanfit.hr', 'Primorska 4, Pula'),
('PowerMotion d.o.o.',    '78901234567', 'info@powermotion.hr', 'Zagrebačka 56, Varaždin'),
('BodyForm Systems',      '89012345678', 'sales@bodyform.hr', 'Šetalište mira 22, Zadar'),
('IronForce Supply',      '90123456789', 'contact@ironforce.eu', 'Put sporta 9, Dubrovnik'),
('SportElite d.o.o.',     '01234567890', 'elite@sportelite.hr', 'Ulica fitnesa 10, Karlovac');

/* =================================================
   INSERT PODACI – OPREMA
   ================================================= */
INSERT INTO oprema (naziv, prostorija_id, dobavljac_id, datum_nabave, stanje)
VALUES
('Bench Press klupa',            1, 1, '2022-03-15', 'ispravno'),
('Traka za trčanje TechnoRun',   2, 2, '2021-11-20', 'ispravno'),
('Sobni bicikl X500',            2, 2, '2020-08-10', 'u servisu'),
('Set bučica 2-20kg',            3, 3, '2023-01-12', 'ispravno'),
('Kabel mašina dual pulley',     3, 4, '2022-09-02', 'ispravno'),
('Stepper Pro 2000',             2, 2, '2021-05-18', 'neispravno'),
('Lat mašina',                   3, 1, '2019-07-30', 'otpisano'),
('Leg press mašina',             3, 5, '2023-05-05', 'ispravno'),
('Kettlebell set 4-24kg',        4, 3, '2023-03-21', 'ispravno'),
('Elastične trake (set)',        4, 6, '2024-02-14', 'ispravno'),
('Traka za hodanje BasicWalk',   2, 2, '2020-01-05', 'neispravno'),
('Orbitrek Advance 300',         2, 5, '2023-10-10', 'ispravno'),
('Rower Concept 2',              2, 7, '2021-04-17', 'ispravno'),
('Smith mašina',                 3, 1, '2020-09-28', 'u servisu'),
('Vaga za mjerenje tjelesne mase', 4, 8, '2023-12-05', 'ispravno'),
('Multipress Pro 4000',          3, 9, '2022-06-09', 'ispravno'),
('TRX trake',                    4, 6, '2024-01-11', 'ispravno'),
('Eliptični trenažer CX900',     2, 10, '2022-10-20', 'u servisu'),
('Čučanj stalak HeavyDuty',      3, 5, '2021-12-30', 'ispravno'),
('Ručni utezi 1-10kg',           4, 3, '2023-02-16', 'ispravno'),
('Abdominalna klupa',            1, 7, '2021-03-22', 'neispravno'),
('Podloga za vježbanje (set)',   4, 8, '2024-04-02', 'ispravno'),
('Kavez za trening snage',       3, 9, '2023-09-14', 'ispravno'),
('Traka za sprint PowerRun',     2, 10, '2022-05-05', 'ispravno');

/* =================================================
   INSERT PODACI – ODRZAVANJE
   ================================================= */
INSERT INTO odrzavanje (oprema_id, zaposlenik_id, datum, opis)
VALUES
(2,  5, '2022-01-10', 'Zamjena pokretne trake i podmazivanje motora.'),
(3,  4, '2022-02-25', 'Popravak elektronike nakon kratkog spoja.'),
(6,  5, '2023-06-15', 'Provjera hidraulike, dijelovi naručeni.'),
(1,  2, '2023-08-01', 'Redovno godišnje održavanje i čišćenje.'),
(4,  3, '2024-01-05', 'Pregled zateznih vijaka i podmazivanje spojeva.'),
(7,  1, '2020-09-09', 'Zamjena sajle i boja konstrukcije.'),
(11, 4, '2024-05-20', 'Neispravna ploča napajanja, poslano na servis.'),
(8,  2, '2024-06-18', 'Podešavanje kliznih ležajeva i kontrola sigurnosti.'),
(9,  3, '2024-08-12', 'Zamjena jedne kugle u ručki kettlebella.'),
(10, 6, '2024-09-30', 'Provjera elastičnosti i stanje gume uredno.'),
(12, 3, '2023-12-01', 'Čišćenje senzora otpora i kalibracija.'),
(13, 2, '2024-02-14', 'Zamjena lanca i podmazivanje zglobova.'),
(14, 5, '2023-04-11', 'Popravak sajle, zamjena hvataljke.'),
(15, 4, '2024-03-23', 'Kalibracija senzora težine.'),
(16, 2, '2024-05-02', 'Zamjena amortizera i provjera sigurnosti.'),
(17, 1, '2024-06-10', 'TRX trake očišćene i testirane.'),
(18, 5, '2024-07-01', 'Provjera elektromotora i promjena gume.'),
(19, 3, '2024-08-19', 'Zatezanje spojeva i čišćenje konstrukcije.'),
(20, 6, '2024-09-09', 'Oštećena ručka zamijenjena novom.'),
(21, 2, '2024-09-25', 'Zamjena zglobnih vijaka.'),
(22, 4, '2024-10-05', 'Provjera podloge i čvrstoće okvira.'),
(23, 1, '2024-10-12', 'Zamjena remena za sprint i test funkcionalnosti.'),
(5,  3, '2024-10-18', 'Redovno održavanje i čišćenje konstrukcije.');

