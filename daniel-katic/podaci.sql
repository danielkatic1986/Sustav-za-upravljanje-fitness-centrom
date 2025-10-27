/*
=================================================
			      DANIEL KATIĆ
=================================================
*/

/*
    Relacija: mjesto, gradovi/mjesta u hr
*/ 

INSERT INTO mjesto (naziv, postanski_broj, drzava) VALUES
('Zagreb', '10000', 'Hrvatska'),
('Split', '21000', 'Hrvatska'),
('Rijeka', '51000', 'Hrvatska'),
('Osijek', '31000', 'Hrvatska'),
('Zadar', '23000', 'Hrvatska'),
('Varaždin', '42000', 'Hrvatska'),
('Karlovac', '47000', 'Hrvatska'),
('Pula', '52100', 'Hrvatska'),
('Šibenik', '22000', 'Hrvatska'),
('Slavonski Brod', '35000', 'Hrvatska'),
('Sisak', '44000', 'Hrvatska'),
('Dubrovnik', '20000', 'Hrvatska'),
('Koprivnica', '48000', 'Hrvatska'),
('Vinkovci', '32100', 'Hrvatska'),
('Čakovec', '40000', 'Hrvatska'),
('Bjelovar', '43000', 'Hrvatska'),
('Virovitica', '33000', 'Hrvatska'),
('Požega', '34000', 'Hrvatska'),
('Gospić', '53000', 'Hrvatska'),
('Krapina', '49000', 'Hrvatska'),
('Petrinja', '44250', 'Hrvatska'),
('Kutina', '44320', 'Hrvatska'),
('Metković', '20350', 'Hrvatska'),
('Sinj', '21230', 'Hrvatska'),
('Vukovar', '32000', 'Hrvatska'),
('Makarska', '21300', 'Hrvatska'),
('Knin', '22300', 'Hrvatska'),
('Nova Gradiška', '35400', 'Hrvatska'),
('Rovinj', '52210', 'Hrvatska'),
('Umag', '52470', 'Hrvatska'),
('Đakovo', '31400', 'Hrvatska'),
('Poreč', '52440', 'Hrvatska'),
('Trogir', '21220', 'Hrvatska'),
('Našice', '31500', 'Hrvatska'),
('Crikvenica', '51260', 'Hrvatska'),
('Ivanić-Grad', '10310', 'Hrvatska'),
('Dugo Selo', '10370', 'Hrvatska'),
('Velika Gorica', '10410', 'Hrvatska'),
('Zaprešić', '10290', 'Hrvatska'),
('Solin', '21210', 'Hrvatska'),
('Kaštela', '21216', 'Hrvatska'),
('Samobor', '10430', 'Hrvatska'),
('Omiš', '21310', 'Hrvatska'),
('Karlobag', '53288', 'Hrvatska'),
('Pag', '23250', 'Hrvatska'),
('Rab', '51280', 'Hrvatska'),
('Opatija', '51410', 'Hrvatska'),
('Ogulin', '47300', 'Hrvatska'),
('Delnice', '51300', 'Hrvatska'),
('Buzet', '52420', 'Hrvatska'),
('Labin', '52220', 'Hrvatska'),
('Korčula', '20260', 'Hrvatska'),
('Blato', '20271', 'Hrvatska'),
('Makole', '42230', 'Hrvatska'),
('Ludbreg', '42230', 'Hrvatska'),
('Donji Miholjac', '31540', 'Hrvatska'),
('Slatina', '33520', 'Hrvatska'),
('Garešnica', '43280', 'Hrvatska'),
('Križevci', '48260', 'Hrvatska'),
('Benkovac', '23420', 'Hrvatska');

/*
	Relacija: clan, 50 članova
*/

INSERT INTO clan (ime, prezime, oib, spol, datum_rodenja, id_mjesto, adresa, email, telefon, datum_uclanjenja, datum_posljednje_aktivnosti, aktivan) VALUES
('Ivan', 'Novak', '35324263512', 'M', STR_TO_DATE('04.12.1992.', '%d.%m.%Y.'), 11, 'Bosutska 108', 'ivan.novak0@gmail.com', '0954404186', STR_TO_DATE('09.10.2024.', '%d.%m.%Y.'), STR_TO_DATE('24.03.2028.', '%d.%m.%Y.'), TRUE),
('Iva', 'Kralj', '15770403523', 'Ž', STR_TO_DATE('08.07.1991.', '%d.%m.%Y.'), 9, 'Ilica 34', 'iva.kralj1@gmail.com', '0992486703', STR_TO_DATE('20.07.2024.', '%d.%m.%Y.'), STR_TO_DATE('01.12.2025.', '%d.%m.%Y.'), TRUE),
('Paula', 'Vidović', '88322272924', 'Ž', STR_TO_DATE('05.05.1990.', '%d.%m.%Y.'), 9, 'Primorska 94', 'paula.vidovic2@gmail.com', '0923146682', STR_TO_DATE('01.07.2021.', '%d.%m.%Y.'), STR_TO_DATE('18.03.2022.', '%d.%m.%Y.'), TRUE),
('Paula', 'Marković', '97673836138', 'Ž', STR_TO_DATE('28.03.1996.', '%d.%m.%Y.'), 5, 'Bosutska 14', 'paula.markovic3@gmail.com', '0925232408', STR_TO_DATE('04.05.2021.', '%d.%m.%Y.'), STR_TO_DATE('02.08.2023.', '%d.%m.%Y.'), TRUE),
('Marija', 'Marić', '60713802361', 'Ž', STR_TO_DATE('08.10.2001.', '%d.%m.%Y.'), 14, 'Palmotićeva 9', 'marija.maric4@gmail.com', '0952222234', STR_TO_DATE('01.06.2025.', '%d.%m.%Y.'), STR_TO_DATE('24.06.2026.', '%d.%m.%Y.'), FALSE),
('Paula', 'Grgić', '67011365900', 'Ž', STR_TO_DATE('02.11.1998.', '%d.%m.%Y.'), 39, 'Maksimirska 42', 'paula.grgic5@gmail.com', '0951127129', STR_TO_DATE('29.12.2024.', '%d.%m.%Y.'), STR_TO_DATE('01.04.2028.', '%d.%m.%Y.'), TRUE),
('Ivan', 'Radić', '52112684609', 'M', STR_TO_DATE('01.04.1989.', '%d.%m.%Y.'), 17, 'Maksimirska 82', 'ivan.radic6@gmail.com', '0910266459', STR_TO_DATE('03.12.2023.', '%d.%m.%Y.'), STR_TO_DATE('04.01.2028.', '%d.%m.%Y.'), TRUE),
('Lucija', 'Božić', '53893776007', 'Ž', STR_TO_DATE('01.12.2005.', '%d.%m.%Y.'), 9, 'Ilica 119', 'lucija.bozic7@gmail.com', '0952570466', STR_TO_DATE('21.04.2022.', '%d.%m.%Y.'), STR_TO_DATE('01.08.2023.', '%d.%m.%Y.'), FALSE),
('Marko', 'Kralj', '96506066339', 'M', STR_TO_DATE('20.06.1996.', '%d.%m.%Y.'), 7, 'Maksimirska 78', 'marko.kralj8@gmail.com', '0991322825', STR_TO_DATE('02.12.2023.', '%d.%m.%Y.'), STR_TO_DATE('04.08.2024.', '%d.%m.%Y.'), FALSE),
('Luka', 'Živković', '89730860511', 'M', STR_TO_DATE('21.03.2000.', '%d.%m.%Y.'), 16, 'Zagrebačka 18', 'luka.zivkovic9@gmail.com', '0918589525', STR_TO_DATE('27.10.2024.', '%d.%m.%Y.'), STR_TO_DATE('26.11.2026.', '%d.%m.%Y.'), TRUE),
('Marko', 'Grgić', '92758343013', 'M', STR_TO_DATE('15.12.1988.', '%d.%m.%Y.'), 43, 'Radnička 45', 'marko.grgic10@gmail.com', '0910551206', STR_TO_DATE('16.10.2024.', '%d.%m.%Y.'), STR_TO_DATE('13.10.2027.', '%d.%m.%Y.'), TRUE),
('Paula', 'Vidović', '44191722150', 'Ž', STR_TO_DATE('28.03.1995.', '%d.%m.%Y.'), 53, 'Kumičićeva 83', 'paula.vidovic11@gmail.com', '0913571326', STR_TO_DATE('04.02.2023.', '%d.%m.%Y.'), STR_TO_DATE('02.11.2026.', '%d.%m.%Y.'), FALSE),
('Marko', 'Lončar', '24320098376', 'M', STR_TO_DATE('03.06.1985.', '%d.%m.%Y.'), 58, 'Radnička 89', 'marko.loncar12@gmail.com', '0912813371', STR_TO_DATE('25.11.2021.', '%d.%m.%Y.'), STR_TO_DATE('06.07.2024.', '%d.%m.%Y.'), FALSE),
('Sara', 'Novak', '67170477680', 'Ž', STR_TO_DATE('27.12.2001.', '%d.%m.%Y.'), 25, 'Zagrebačka 89', 'sara.novak13@gmail.com', '0978579952', STR_TO_DATE('27.12.2025.', '%d.%m.%Y.'), STR_TO_DATE('19.07.2027.', '%d.%m.%Y.'), TRUE),
('Nikola', 'Perić', '76556351205', 'M', STR_TO_DATE('03.01.2003.', '%d.%m.%Y.'), 30, 'Bosutska 27', 'nikola.peric14@gmail.com', '0913738789', STR_TO_DATE('10.02.2022.', '%d.%m.%Y.'), STR_TO_DATE('02.02.2025.', '%d.%m.%Y.'), FALSE),
('Iva', 'Novak', '10550813651', 'Ž', STR_TO_DATE('04.04.1997.', '%d.%m.%Y.'), 35, 'Kumičićeva 88', 'iva.novak15@gmail.com', '0993038641', STR_TO_DATE('01.01.2021.', '%d.%m.%Y.'), STR_TO_DATE('30.05.2021.', '%d.%m.%Y.'), TRUE),
('Ana', 'Grgić', '76332277870', 'Ž', STR_TO_DATE('09.11.1986.', '%d.%m.%Y.'), 22, 'Savska 60', 'ana.grgic16@gmail.com', '0974608614', STR_TO_DATE('22.11.2023.', '%d.%m.%Y.'), STR_TO_DATE('26.04.2027.', '%d.%m.%Y.'), TRUE),
('Tena', 'Horvat', '02168711712', 'Ž', STR_TO_DATE('22.10.1996.', '%d.%m.%Y.'), 8, 'Vukovarska 38', 'tena.horvat17@gmail.com', '0913755674', STR_TO_DATE('12.08.2021.', '%d.%m.%Y.'), STR_TO_DATE('03.02.2023.', '%d.%m.%Y.'), TRUE),
('Marija', 'Novak', '86677691255', 'Ž', STR_TO_DATE('26.08.1999.', '%d.%m.%Y.'), 2, 'Savska 76', 'marija.novak18@gmail.com', '0976289532', STR_TO_DATE('05.06.2024.', '%d.%m.%Y.'), STR_TO_DATE('20.09.2026.', '%d.%m.%Y.'), TRUE),
('Nika', 'Kralj', '48041410212', 'Ž', STR_TO_DATE('11.03.1985.', '%d.%m.%Y.'), 49, 'Kumičićeva 81', 'nika.kralj19@gmail.com', '0973351441', STR_TO_DATE('24.09.2022.', '%d.%m.%Y.'), STR_TO_DATE('03.01.2023.', '%d.%m.%Y.'), TRUE),
('Ema', 'Marković', '54716790316', 'Ž', STR_TO_DATE('31.08.1994.', '%d.%m.%Y.'), 3, 'Vukovarska 64', 'ema.markovic20@gmail.com', '0928709255', STR_TO_DATE('18.12.2023.', '%d.%m.%Y.'), STR_TO_DATE('06.01.2025.', '%d.%m.%Y.'), TRUE),
('Nika', 'Radić', '54123022863', 'Ž', STR_TO_DATE('07.08.2003.', '%d.%m.%Y.'), 44, 'Primorska 54', 'nika.radic21@gmail.com', '0952337244', STR_TO_DATE('27.08.2021.', '%d.%m.%Y.'), STR_TO_DATE('04.04.2024.', '%d.%m.%Y.'), FALSE),
('Paula', 'Horvat', '72721617961', 'Ž', STR_TO_DATE('08.09.1985.', '%d.%m.%Y.'), 8, 'Primorska 49', 'paula.horvat22@gmail.com', '0950679840', STR_TO_DATE('07.06.2020.', '%d.%m.%Y.'), STR_TO_DATE('18.08.2023.', '%d.%m.%Y.'), TRUE),
('Luka', 'Kovač', '63117899035', 'M', STR_TO_DATE('01.11.2005.', '%d.%m.%Y.'), 24, 'Kumičićeva 5', 'luka.kovac23@gmail.com', '0955844243', STR_TO_DATE('18.02.2021.', '%d.%m.%Y.'), STR_TO_DATE('13.01.2022.', '%d.%m.%Y.'), TRUE),
('Paula', 'Grgić', '32210231000', 'Ž', STR_TO_DATE('12.04.2004.', '%d.%m.%Y.'), 22, 'Primorska 83', 'paula.grgic24@gmail.com', '0973665306', STR_TO_DATE('04.05.2023.', '%d.%m.%Y.'), STR_TO_DATE('17.05.2025.', '%d.%m.%Y.'), TRUE),
('Sara', 'Kovač', '95507414882', 'Ž', STR_TO_DATE('25.10.1996.', '%d.%m.%Y.'), 12, 'Maksimirska 23', 'sara.kovac25@gmail.com', '0912513314', STR_TO_DATE('17.12.2024.', '%d.%m.%Y.'), STR_TO_DATE('29.12.2027.', '%d.%m.%Y.'), FALSE),
('Nikola', 'Šarić', '49580510554', 'M', STR_TO_DATE('01.07.2002.', '%d.%m.%Y.'), 40, 'Maksimirska 23', 'nikola.saric26@gmail.com', '0918616617', STR_TO_DATE('09.05.2020.', '%d.%m.%Y.'), STR_TO_DATE('13.02.2022.', '%d.%m.%Y.'), TRUE),
('Filip', 'Matijević', '02531135408', 'M', STR_TO_DATE('25.01.1990.', '%d.%m.%Y.'), 45, 'Vukovarska 13', 'filip.matijevic27@gmail.com', '0956934159', STR_TO_DATE('10.03.2022.', '%d.%m.%Y.'), STR_TO_DATE('25.07.2024.', '%d.%m.%Y.'), TRUE),
('Marija', 'Vidović', '78546963814', 'Ž', STR_TO_DATE('21.10.1986.', '%d.%m.%Y.'), 1, 'Primorska 1', 'marija.vidovic28@gmail.com', '0992328084', STR_TO_DATE('24.05.2020.', '%d.%m.%Y.'), STR_TO_DATE('31.05.2023.', '%d.%m.%Y.'), TRUE),
('Nika', 'Babić', '32219450001', 'Ž', STR_TO_DATE('20.11.1991.', '%d.%m.%Y.'), 43, 'Kumičićeva 69', 'nika.babic29@gmail.com', '0918899910', STR_TO_DATE('03.01.2025.', '%d.%m.%Y.'), STR_TO_DATE('07.03.2027.', '%d.%m.%Y.'), FALSE),
('Ana', 'Knežević', '93511567190', 'Ž', STR_TO_DATE('03.08.1990.', '%d.%m.%Y.'), 41, 'Savska 9', 'ana.knezevic30@gmail.com', '0971691225', STR_TO_DATE('13.02.2022.', '%d.%m.%Y.'), STR_TO_DATE('26.06.2024.', '%d.%m.%Y.'), TRUE),
('Karlo', 'Lončar', '07827531373', 'M', STR_TO_DATE('21.08.1992.', '%d.%m.%Y.'), 47, 'Bosutska 107', 'karlo.loncar31@gmail.com', '0977540951', STR_TO_DATE('19.08.2025.', '%d.%m.%Y.'), STR_TO_DATE('23.09.2025.', '%d.%m.%Y.'), TRUE),
('Nikola', 'Grgić', '42525563024', 'M', STR_TO_DATE('27.05.1987.', '%d.%m.%Y.'), 50, 'Savska 53', 'nikola.grgic32@gmail.com', '0993990445', STR_TO_DATE('28.11.2025.', '%d.%m.%Y.'), STR_TO_DATE('21.04.2027.', '%d.%m.%Y.'), TRUE),
('Filip', 'Grgić', '11533648586', 'M', STR_TO_DATE('15.05.1986.', '%d.%m.%Y.'), 1, 'Radnička 109', 'filip.grgic33@gmail.com', '0994783392', STR_TO_DATE('20.09.2022.', '%d.%m.%Y.'), STR_TO_DATE('30.04.2024.', '%d.%m.%Y.'), FALSE),
('Filip', 'Matijević', '77968183003', 'M', STR_TO_DATE('17.11.1995.', '%d.%m.%Y.'), 4, 'Vukovarska 77', 'filip.matijevic34@gmail.com', '0993800312', STR_TO_DATE('06.02.2022.', '%d.%m.%Y.'), STR_TO_DATE('26.02.2023.', '%d.%m.%Y.'), TRUE),
('Iva', 'Božić', '46777129542', 'Ž', STR_TO_DATE('08.08.2003.', '%d.%m.%Y.'), 36, 'Ilica 45', 'iva.bozic35@gmail.com', '0995210592', STR_TO_DATE('17.03.2025.', '%d.%m.%Y.'), STR_TO_DATE('22.01.2029.', '%d.%m.%Y.'), TRUE),
('Karlo', 'Novak', '32664758555', 'M', STR_TO_DATE('02.09.1997.', '%d.%m.%Y.'), 54, 'Vukovarska 75', 'karlo.novak36@gmail.com', '0975011814', STR_TO_DATE('11.04.2021.', '%d.%m.%Y.'), STR_TO_DATE('16.09.2023.', '%d.%m.%Y.'), TRUE),
('Ema', 'Vidović', '08495536287', 'Ž', STR_TO_DATE('21.03.1986.', '%d.%m.%Y.'), 52, 'Ilica 67', 'ema.vidovic37@gmail.com', '0977665777', STR_TO_DATE('10.12.2023.', '%d.%m.%Y.'), STR_TO_DATE('23.04.2024.', '%d.%m.%Y.'), FALSE),
('Karlo', 'Knežević', '22714801111', 'M', STR_TO_DATE('28.10.2004.', '%d.%m.%Y.'), 44, 'Radnička 14', 'karlo.knezevic38@gmail.com', '0923530393', STR_TO_DATE('20.05.2022.', '%d.%m.%Y.'), STR_TO_DATE('28.07.2025.', '%d.%m.%Y.'), FALSE),
('Matej', 'Grgić', '82839234266', 'M', STR_TO_DATE('16.09.1985.', '%d.%m.%Y.'), 16, 'Bosutska 90', 'matej.grgic39@gmail.com', '0999776398', STR_TO_DATE('03.11.2023.', '%d.%m.%Y.'), STR_TO_DATE('21.09.2024.', '%d.%m.%Y.'), TRUE),
('Dario', 'Lovrić', '80941847312', 'M', STR_TO_DATE('06.10.1991.', '%d.%m.%Y.'), 41, 'Palmotićeva 48', 'dario.lovric40@gmail.com', '0994240620', STR_TO_DATE('16.03.2020.', '%d.%m.%Y.'), STR_TO_DATE('10.09.2021.', '%d.%m.%Y.'), TRUE),
('Lucija', 'Božić', '49906152507', 'Ž', STR_TO_DATE('05.02.1988.', '%d.%m.%Y.'), 48, 'Kumičićeva 10', 'lucija.bozic41@gmail.com', '0971927141', STR_TO_DATE('25.03.2022.', '%d.%m.%Y.'), STR_TO_DATE('07.01.2024.', '%d.%m.%Y.'), TRUE),
('Petar', 'Novak', '49051855302', 'M', STR_TO_DATE('04.04.1997.', '%d.%m.%Y.'), 34, 'Kumičićeva 67', 'petar.novak42@gmail.com', '0951310014', STR_TO_DATE('05.06.2020.', '%d.%m.%Y.'), STR_TO_DATE('13.05.2023.', '%d.%m.%Y.'), TRUE),
('Luka', 'Novak', '04173488055', 'M', STR_TO_DATE('08.12.1995.', '%d.%m.%Y.'), 31, 'Radnička 82', 'luka.novak43@gmail.com', '0952765599', STR_TO_DATE('17.04.2025.', '%d.%m.%Y.'), STR_TO_DATE('26.10.2025.', '%d.%m.%Y.'), TRUE),
('Maja', 'Kovač', '77110445953', 'Ž', STR_TO_DATE('29.10.1990.', '%d.%m.%Y.'), 45, 'Zagrebačka 41', 'maja.kovac44@gmail.com', '0924924757', STR_TO_DATE('26.11.2024.', '%d.%m.%Y.'), STR_TO_DATE('22.07.2026.', '%d.%m.%Y.'), TRUE),
('Marko', 'Novak', '96535656697', 'M', STR_TO_DATE('03.05.2004.', '%d.%m.%Y.'), 12, 'Radnička 18', 'marko.novak45@gmail.com', '0953962799', STR_TO_DATE('09.02.2025.', '%d.%m.%Y.'), STR_TO_DATE('26.10.2027.', '%d.%m.%Y.'), TRUE),
('Lucija', 'Radić', '67283886737', 'Ž', STR_TO_DATE('16.02.1997.', '%d.%m.%Y.'), 56, 'Vukovarska 113', 'lucija.radic46@gmail.com', '0952905389', STR_TO_DATE('22.02.2023.', '%d.%m.%Y.'), STR_TO_DATE('09.11.2025.', '%d.%m.%Y.'), TRUE),
('Marko', 'Tomić', '92714797220', 'M', STR_TO_DATE('09.12.2005.', '%d.%m.%Y.'), 4, 'Primorska 111', 'marko.tomic47@gmail.com', '0955764624', STR_TO_DATE('13.12.2020.', '%d.%m.%Y.'), STR_TO_DATE('21.03.2024.', '%d.%m.%Y.'), TRUE),
('Ana', 'Šarić', '68442862995', 'Ž', STR_TO_DATE('31.05.1994.', '%d.%m.%Y.'), 58, 'Radnička 95', 'ana.saric48@gmail.com', '0924647607', STR_TO_DATE('08.06.2022.', '%d.%m.%Y.'), STR_TO_DATE('23.02.2024.', '%d.%m.%Y.'), FALSE),
('Ivan', 'Kralj', '84267571635', 'M', STR_TO_DATE('28.03.1987.', '%d.%m.%Y.'), 5, 'Ilica 7', 'ivan.kralj49@gmail.com', '0978017850', STR_TO_DATE('11.01.2023.', '%d.%m.%Y.'), STR_TO_DATE('26.01.2026.', '%d.%m.%Y.'), FALSE);

/*
	Relacija: tip_clanarine
*/

INSERT INTO tip_clanarine (naziv, trajanje_mjeseci, cijena, opis) VALUES
	('Mjesec basic', 1, 40.00, 'neograničeno samostalno vrijeme treninga'),
	('Mjesec group', 1, 65.00, 'neograničeno samostalno vrijeme treninga, grupni treninzi'),
	('Mjesec personal', 1, 99.00, 'osobni trener, individualizirani programi'),
	('Godina basic', 12, 456.00, 'basic godišnje'),
	('Godina group', 12, 741.00, 'group godišnje'),
	('Godina personal', 12, 1128.00, 'osobni trener godišnje');

/*
	Relacija: status_clanarine
*/

INSERT INTO status_clanarine (naziv, opis) VALUES
	('aktivna', 'aktivna članarina'),
	('istekla', 'istekla članarina'),
	('zamrznuta', 'zamrznuta članarina');

/*
	Relacija: clanarina
    Opis: veza između člana, tipa i statusa članarine
    Veze: povezuje sve tri relacije (clan, tip_clanarine, status_clanarine)
*/

INSERT INTO clanarina (id_clan, id_tip, id_status, datum_pocetka, datum_zavrsetka) VALUES
-- Novi članovi, aktivne članarine (učlanjeni 2025-10)
(1, 2, 1, '2025-10-10', '2025-11-10'),
(2, 3, 1, '2025-10-01', '2025-11-01'),
(3, 1, 1, '2025-10-15', '2025-11-15'),

-- Članovi s ponavljanim mjesečnim članarinama
(4, 1, 2, '2025-05-01', '2025-05-31'),
(4, 1, 2, '2025-06-01', '2025-06-30'),
(4, 2, 1, '2025-07-01', '2025-08-01'),

(5, 3, 2, '2025-01-01', '2025-02-01'),
(5, 4, 1, '2025-02-02', '2026-02-02'),

-- Stari član, prelazak s basic na personal
(6, 1, 2, '2023-10-01', '2023-11-01'),
(6, 2, 2, '2023-11-02', '2023-12-02'),
(6, 3, 1, '2024-01-01', '2024-02-01'),
(6, 6, 1, '2025-01-01', '2026-01-01'),

-- Dugogodišnji član s godišnjim obnavljanjem
(7, 4, 2, '2021-01-01', '2022-01-01'),
(7, 4, 2, '2022-01-02', '2023-01-02'),
(7, 5, 2, '2023-01-03', '2024-01-03'),
(7, 6, 1, '2024-01-04', '2025-01-04'),

-- Član s "zamrznutom" članarinom
(8, 2, 3, '2025-08-01', '2025-09-01'),

-- Novi član, aktivan
(9, 1, 1, '2025-10-05', '2025-11-05'),

-- Redovni obnavljač mjesečne članarine
(10, 1, 2, '2024-09-01', '2024-09-30'),
(10, 2, 2, '2024-10-01', '2024-10-31'),
(10, 2, 1, '2025-09-01', '2025-10-01'),

-- Kombinacija group i personal
(11, 5, 2, '2023-02-01', '2024-02-01'),
(11, 6, 1, '2024-02-02', '2025-02-02'),

-- Par isteklih i jedna aktivna
(12, 1, 2, '2024-07-01', '2024-07-31'),
(12, 2, 2, '2024-08-01', '2024-08-31'),
(12, 3, 1, '2025-09-01', '2025-10-01'),

-- Član s godišnjom, sada zamrznutom
(13, 4, 3, '2025-03-01', '2026-03-01'),

-- Redovni korisnik od 2022.
(14, 1, 2, '2022-10-01', '2022-11-01'),
(14, 2, 2, '2023-01-01', '2023-02-01'),
(14, 5, 1, '2024-01-01', '2025-01-01'),

-- Dugogodišnji premium korisnik
(15, 6, 1, '2023-01-01', '2024-01-01'),
(15, 6, 1, '2024-01-02', '2025-01-02'),
(15, 6, 1, '2025-01-03', '2026-01-03'),

-- Novi član
(16, 2, 1, '2025-10-15', '2025-11-15'),

-- Član s više isteklih
(17, 1, 2, '2024-03-01', '2024-03-31'),
(17, 2, 2, '2024-04-01', '2024-05-01'),
(17, 3, 1, '2025-01-01', '2025-02-01'),

-- Stari član s više godišnjih
(18, 4, 2, '2022-01-01', '2023-01-01'),
(18, 4, 2, '2023-01-02', '2024-01-02'),
(18, 5, 1, '2024-01-03', '2025-01-03'),

-- Zamrznuta zbog bolesti
(19, 2, 3, '2025-09-01', '2025-10-01'),

-- Itd., nastavak za ostale članove (20–50)
(20, 3, 1, '2025-08-15', '2025-09-15'),
(21, 5, 1, '2025-01-01', '2026-01-01'),
(22, 1, 2, '2023-03-01', '2023-03-31'),
(22, 2, 2, '2023-04-01', '2023-04-30'),
(22, 3, 1, '2025-05-01', '2025-06-01'),
(23, 4, 1, '2024-09-01', '2025-09-01'),
(24, 2, 2, '2024-04-01', '2024-05-01'),
(25, 1, 1, '2025-10-01', '2025-11-01'),
(26, 3, 2, '2024-05-01', '2024-06-01'),
(26, 5, 1, '2025-01-01', '2026-01-01'),
(27, 4, 2, '2023-07-01', '2024-07-01'),
(27, 5, 1, '2024-07-02', '2025-07-02'),
(28, 6, 3, '2025-02-01', '2026-02-01'),
(29, 5, 1, '2025-03-01', '2026-03-01'),
(30, 1, 2, '2024-01-01', '2024-01-31'),
(30, 2, 2, '2024-02-01', '2024-03-01'),
(30, 3, 1, '2025-05-01', '2025-06-01'),
(31, 1, 1, '2025-10-10', '2025-11-10'),
(32, 2, 1, '2025-09-01', '2025-10-01'),
(33, 3, 2, '2023-02-01', '2023-03-01'),
(33, 4, 1, '2024-02-01', '2025-02-01'),
(34, 5, 1, '2025-04-01', '2026-04-01'),
(35, 6, 1, '2025-01-01', '2026-01-01'),
(36, 2, 2, '2023-06-01', '2023-07-01'),
(36, 3, 2, '2024-06-01', '2024-07-01'),
(36, 5, 1, '2025-06-01', '2026-06-01'),
(37, 1, 2, '2024-03-01', '2024-04-01'),
(37, 2, 1, '2025-09-01', '2025-10-01'),
(38, 3, 1, '2025-10-01', '2025-11-01'),
(39, 4, 1, '2025-05-01', '2026-05-01'),
(40, 5, 3, '2025-03-01', '2026-03-01'),
(41, 6, 1, '2025-02-01', '2026-02-01'),
(42, 1, 2, '2023-07-01', '2023-08-01'),
(42, 2, 2, '2023-08-02', '2023-09-02'),
(42, 3, 1, '2025-09-01', '2025-10-01'),
(43, 4, 1, '2025-01-01', '2026-01-01'),
(44, 5, 1, '2025-04-01', '2026-04-01'),
(45, 6, 1, '2025-06-01', '2026-06-01'),
(46, 2, 2, '2024-02-01', '2024-03-01'),
(46, 3, 1, '2025-03-01', '2025-04-01'),
(47, 4, 1, '2025-07-01', '2026-07-01'),
(48, 5, 3, '2025-08-01', '2026-08-01'),
(49, 6, 1, '2025-09-01', '2026-09-01'),
(50, 1, 2, '2024-05-01', '2024-06-01'),
(50, 2, 2, '2024-07-01', '2024-08-01'),
(50, 3, 1, '2025-09-01', '2025-10-01');