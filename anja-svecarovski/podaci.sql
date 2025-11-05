/*
 U ovom dokumentu unosimo podatke u tablice
*/

INSERT INTO odjel (naziv, aktivno, opis) VALUES
('Fitness', 1, 'Odgovoran za vođenje individualnih i grupnih treninga.'),
('Wellness', 1, 'Fokus na zdravlje, oporavak i prevenciju ozljeda.'),
('Održavanje', 1, 'Brine o opremi, prostorijama i sigurnosti.'),
('Administracija', 1, 'Upravljanje poslovanjem, ljudskim resursima i dokumentacijom.'),
('Recepcija', 1, 'Prva kontaktna točka za članove.'),
('Marketing i prodaja', 1, 'Promocija i prodaja članarina i programa.'),
('Uprava / Menadžment', 1, 'Donosi odluke o poslovanju i strategiji centra.'),
('Financije', 1, 'Upravljanje financijama i obračun plaća.')

INSERT INTO radno_mjesto (naziv, aktivno, opis, id_odjel) VALUES
('Trener', 1, 'Vode individualne i grupne treninge.', 1),
('Instruktor', 1, 'Pomažu u izvođenju treninga i vježbi.', 1),
('Asistent trenera', 1, 'Pružaju podršku trenerima u radu s članovima.', 1),
('Fizioterapeut', 1, 'Pružaju fizioterapijske tretmane članovima.', 2),
('Maser', 1, 'Izvode masaže za oporavak i relaksaciju.', 2),
('Wellness terapeut', 1, 'Organiziraju wellness programe i terapije.', 2),
('Tehničar', 1, 'Održavaju tehničku opremu centra.', 3),
('Domar', 1, 'Brinu o prostorijama i infrastrukturi.', 3),
('Čistač', 1, 'Održavaju čistoću prostora.', 3),
('Voditelj održavanja', 1, 'Koordiniraju sve aktivnosti održavanja.', 3),
('Administrator', 1, 'Upravljaju administrativnim zadacima centra.', 4),
('Tajnik', 1, 'Pomažu u dokumentaciji i koordinaciji.', 4),
('HR stručnjak', 1, 'Brinu o ljudskim resursima i zapošljavanju.', 4),
('Recepcioner', 1, 'Prva kontaktna točka za članove.', 5),
('Služba za korisnike', 1, 'Pomažu članovima s informacijama i upitima.', 5),
('Marketing menadžer', 1, 'Planiraju i vode marketinške kampanje.', 6),
('Prodajni savjetnik', 1, 'Savjetuju članove i prodaju programe.', 6),
('Dizajner', 1, 'Kreiraju vizualne materijale i promotivne sadržaje.', 6),
('Direktor', 1, 'Donosi strateške odluke centra.', 7),
('Voditelj odjela', 1, 'Koordiniraju rad pojedinih odjela.', 7),
('Menadžer', 1, 'Upravljaju operativnim aktivnostima i projektima.', 7),
('Računovođa', 1, 'Prate financijske transakcije i izvještaje.', 8),
('Blagajnik', 1, 'Obavljaju novčane transakcije i administraciju blagajne.', 8);

INSERT INTO podruznica (naziv, adresa, id_mjesto) VALUES
('Fitness Centar Arena Zagreb', 'Avenija Dubrovnik 15, Novi Zagreb', 1),
('Fitness Centar Marjan Split', 'Put Firula 2, Split', 2),
('Fitness Centar Korzo Rijeka', 'Korzo 28, Rijeka', 3),
('Fitness Centar Tvrđa Osijek', 'Vukovarska 31, Osijek', 4),
('Fitness Centar Zadar Poluotok', 'Obala kralja Tomislava 8, Zadar', 5),
('Fitness Centar Varaždin Plaza', 'Ulica Ivana Kukuljevića 12, Varaždin', 6),
('Fitness Centar Pula Veruda', 'Rizzijeva 45, Pula', 8),
('Fitness Centar Šibenik Dalmare', 'Ulica Velimira Škorpika 23, Šibenik', 9),
('Fitness Centar Dubrovnik Lapad', 'Masarykov put 5, Dubrovnik', 12),
('Fitness Centar Karlovac City', 'Radićeva 13, Karlovac', 7);

INSERT INTO zaposlenik 
(ime, prezime, oib, datum_rodenja, spol, adresa, id_mjesto, telefon, email, datum_zaposlenja, datum_prestanka, status_zaposlenika, placa, id_radno_mjesto, id_podruznica) 
VALUES
-- Treneri (40, 5 neaktivnih)
('Ivan', 'Horvat', '12345678901', STR_TO_DATE('15.03.1985.', '%d.%m.%Y.'), 'M', 'Ulica sportaša 12, Zagreb', 1, '0912345678', 'ivan.horvat@gmail.com', STR_TO_DATE('01.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 1),
('Marija', 'Kovač', '23456789012', STR_TO_DATE('22.07.1990.', '%d.%m.%Y.'), 'Ž', 'Trg bana Jelačića 5, Zagreb', 1, '0987654321', 'marija.kovac@gmail.com', STR_TO_DATE('15.03.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1550.00, 1, 1),
('Marko', 'Babić', '34567890123', STR_TO_DATE('09.11.1988.', '%d.%m.%Y.'), 'M', 'Ilica 45, Zagreb', 1, '0911122233', 'marko.babic@gmail.com', STR_TO_DATE('10.05.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 1),
('Ana', 'Novak', '45678901234', STR_TO_DATE('30.06.1992.', '%d.%m.%Y.'), 'Ž', 'Zagrebačka 7, Split', 2, '0912233445', 'ana.novak@gmail.com', STR_TO_DATE('20.01.2022.', '%d.%m.%Y.'), NULL, 'aktivan', 1480.00, 1, 2),
('Petar', 'Šimić', '56789012345', STR_TO_DATE('12.12.1984.', '%d.%m.%Y.'), 'M', 'Obala 3, Split', 2, '0983344556', 'petar.simic@gmail.com', STR_TO_DATE('05.06.2018.', '%d.%m.%Y.'), STR_TO_DATE('05.06.2019.', '%d.%m.%Y.'), 'neaktivan', 1500.00, 1, 2),
('Lucija', 'Grgić', '67890123456', STR_TO_DATE('07.04.1987.', '%d.%m.%Y.'), 'Ž', 'Korzo 12, Rijeka', 3, '0914455667', 'lucija.grgic@gmail.com', STR_TO_DATE('12.09.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1530.00, 1, 3),
('Tomislav', 'Perić', '78901234567', STR_TO_DATE('25.01.1983.', '%d.%m.%Y.'), 'M', 'Riva 4, Rijeka', 3, '0985566778', 'tomislav.peric@gmail.com', STR_TO_DATE('01.11.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1490.00, 1, 3),
('Ivana', 'Marić', '89012345678', STR_TO_DATE('18.08.1991.', '%d.%m.%Y.'), 'Ž', 'Vukovarska 20, Osijek', 4, '0916677889', 'ivana.maric@gmail.com', STR_TO_DATE('03.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 4),
('Luka', 'Kralj', '90123456789', STR_TO_DATE('05.05.1986.', '%d.%m.%Y.'), 'M', 'Europska avenija 8, Osijek', 4, '0987788990', 'luka.kralj@gmail.com', STR_TO_DATE('10.07.2018.', '%d.%m.%Y.'), STR_TO_DATE('10.07.2019.', '%d.%m.%Y.'), 'neaktivan', 1500.00, 1, 4),
('Maja', 'Župan', '11234567890', STR_TO_DATE('14.09.1993.', '%d.%m.%Y.'), 'Ž', 'Obala kralja Tomislava 2, Zadar', 5, '0918899001', 'maja.zupan@gmail.com', STR_TO_DATE('12.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 5),
('Davor', 'Barić', '12234567891', STR_TO_DATE('21.03.1985.', '%d.%m.%Y.'), 'M', 'Obala 5, Zadar', 5, '0989900112', 'davor.baric@gmail.com', STR_TO_DATE('01.08.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 5),
('Petra', 'Novosel', '13234567892', STR_TO_DATE('29.07.1988.', '%d.%m.%Y.'), 'Ž', 'Trg Slobode 10, Varaždin', 6, '0910011223', 'petra.novosel@gmail.com', STR_TO_DATE('15.01.2022.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 6),
('Damir', 'Vidović', '14234567893', STR_TO_DATE('10.11.1982.', '%d.%m.%Y.'), 'M', 'Ulica kralja Tomislava 3, Varaždin', 6, '0981122334', 'damir.vidovic@gmail.com', STR_TO_DATE('20.05.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 6),
('Kristina', 'Božić', '15234567894', STR_TO_DATE('02.02.1990.', '%d.%m.%Y.'), 'Ž', 'Via Lungomare 6, Pula', 8, '0912233445', 'kristina.bozic@gmail.com', STR_TO_DATE('05.09.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1490.00, 1, 7),
('Ivan', 'Matić', '16234567895', STR_TO_DATE('23.06.1987.', '%d.%m.%Y.'), 'M', 'Rizzijeva 12, Pula', 8, '0983344556', 'ivan.matic@gmail.com', STR_TO_DATE('12.12.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 7),
('Tihana', 'Ćosić', '17234567896', STR_TO_DATE('30.08.1991.', '%d.%m.%Y.'), 'Ž', 'Ulica kralja Zvonimira 8, Šibenik', 9, '0914455667', 'tihana.cosic@gmail.com', STR_TO_DATE('01.02.2018.', '%d.%m.%Y.'), STR_TO_DATE('01.02.2019.', '%d.%m.%Y.'), 'neaktivan', 1500.00, 1, 8),
('Filip', 'Knežević', '18234567897', STR_TO_DATE('12.12.1983.', '%d.%m.%Y.'), 'M', 'Ulica Jakova Gotovca 3, Šibenik', 9, '0985566778', 'filip.knezevic@gmail.com', STR_TO_DATE('10.03.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 8),
('Sandra', 'Radić', '19234567898', STR_TO_DATE('04.04.1989.', '%d.%m.%Y.'), 'Ž', 'Masarykov put 7, Dubrovnik', 12, '0916677889', 'sandra.radic@gmail.com', STR_TO_DATE('20.06.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 9),
('Dino', 'Lovrić', '20234567899', STR_TO_DATE('17.09.1986.', '%d.%m.%Y.'), 'M', 'Lapadska obala 15, Dubrovnik', 12, '0987788990', 'dino.lovric@gmail.com', STR_TO_DATE('05.01.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1530.00, 1, 9),
('Ivana', 'Tadić', '21234567890', STR_TO_DATE('11.01.1992.', '%d.%m.%Y.'), 'Ž', 'Ulica Hrvatskih branitelja 4, Karlovac', 7, '0918899001', 'ivana.tadic@gmail.com', STR_TO_DATE('12.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 10),
('Mario', 'Bulić', '22234567891', STR_TO_DATE('29.05.1985.', '%d.%m.%Y.'), 'M', 'Trg kralja Tomislava 6, Karlovac', 7, '0989900112', 'mario.bulic@gmail.com', STR_TO_DATE('01.08.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 10),
('Nikola', 'Šarić', '23234567892', STR_TO_DATE('10.02.1986.', '%d.%m.%Y.'), 'M', 'Ulica sportaša 14, Zagreb', 1, '0911234567', 'nikola.saric@gmail.com', STR_TO_DATE('10.06.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 1),
('Ana', 'Perković', '24234567893', STR_TO_DATE('25.12.1990.', '%d.%m.%Y.'), 'Ž', 'Trg bana Jelačića 8, Zagreb', 1, '0982345678', 'ana.perkovic@gmail.com', STR_TO_DATE('01.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 1),
('Tomislav', 'Vuković', '25234567894', STR_TO_DATE('03.07.1985.', '%d.%m.%Y.'), 'M', 'Ilica 50, Zagreb', 1, '0913456789', 'tomislav.vukovic@gmail.com', STR_TO_DATE('20.05.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 1),
('Lucija', 'Jurić', '26234567895', STR_TO_DATE('17.09.1988.', '%d.%m.%Y.'), 'Ž', 'Ulica kralja Tomislava 7, Split', 2, '0984567890', 'lucija.juric@gmail.com', STR_TO_DATE('15.04.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 2),
('Dario', 'Knežević', '27234567896', STR_TO_DATE('12.03.1987.', '%d.%m.%Y.'), 'M', 'Obala 7, Split', 2, '0915678901', 'dario.knezevic@gmail.com', STR_TO_DATE('01.01.2019.', '%d.%m.%Y.'), STR_TO_DATE('01.01.2020.', '%d.%m.%Y.'), 'neaktivan', 1500.00, 1, 2),
('Maja', 'Grubišić', '28234567897', STR_TO_DATE('30.06.1992.', '%d.%m.%Y.'), 'Ž', 'Korzo 15, Rijeka', 3, '0986789012', 'maja.grubisic@gmail.com', STR_TO_DATE('10.09.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 3),
('Ivan', 'Šimić', '29234567898', STR_TO_DATE('05.11.1984.', '%d.%m.%Y.'), 'M', 'Riva 12, Rijeka', 3, '0917890123', 'ivan.simic@gmail.com', STR_TO_DATE('20.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 3),
('Tihana', 'Božić', '30234567899', STR_TO_DATE('21.04.1991.', '%d.%m.%Y.'), 'Ž', 'Ulica Trga 5, Osijek', 4, '0988901234', 'tihana.bozic@gmail.com', STR_TO_DATE('15.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 4),
('Dino', 'Kovačević', '31234567890', STR_TO_DATE('18.08.1986.', '%d.%m.%Y.'), 'M', 'Europska avenija 15, Osijek', 4, '0919012345', 'dino.kovacevic@gmail.com', STR_TO_DATE('01.06.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 4),
('Petra', 'Barić', '32234567891', STR_TO_DATE('10.01.1993.', '%d.%m.%Y.'), 'Ž', 'Obala kralja Tomislava 8, Zadar', 5, '0980123456', 'petra.baric@gmail.com', STR_TO_DATE('10.09.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 5),
('Marko', 'Tadić', '33234567892', STR_TO_DATE('22.05.1989.', '%d.%m.%Y.'), 'M', 'Obala 10, Zadar', 5, '0911234567', 'marko.tadic@gmail.com', STR_TO_DATE('01.01.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 5),
('Ivana', 'Bulić', '34234567893', STR_TO_DATE('09.09.1987.', '%d.%m.%Y.'), 'Ž', 'Trg Slobode 5, Varaždin', 6, '0982345678', 'ivana.bulic@gmail.com', STR_TO_DATE('15.04.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 6),
('Luka', 'Matić', '35234567894', STR_TO_DATE('30.12.1985.', '%d.%m.%Y.'), 'M', 'Ulica kralja Tomislava 12, Varaždin', 6, '0913456789', 'luka.matic@gmail.com', STR_TO_DATE('20.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 6),
('Kristina', 'Marić', '36234567895', STR_TO_DATE('14.02.1990.', '%d.%m.%Y.'), 'Ž', 'Via Lungomare 12, Pula', 8, '0984567890', 'kristina.maric@gmail.com', STR_TO_DATE('01.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 7),
('Davor', 'Radić', '37234567896', STR_TO_DATE('27.07.1986.', '%d.%m.%Y.'), 'M', 'Rizzijeva 14, Pula', 8, '0915678901', 'davor.radic@gmail.com', STR_TO_DATE('15.04.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 7),
('Maja', 'Novosel', '38234567897', STR_TO_DATE('11.11.1991.', '%d.%m.%Y.'), 'Ž', 'Ulica kralja Zvonimira 10, Šibenik', 9, '0986789012', 'maja.novosel@gmail.com', STR_TO_DATE('20.05.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 8),
('Filip', 'Barić', '39234567898', STR_TO_DATE('03.03.1988.', '%d.%m.%Y.'), 'M', 'Ulica Jakova Gotovca 6, Šibenik', 9, '0917890123', 'filip.baric@gmail.com', STR_TO_DATE('01.06.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 8),
('Sandra', 'Knežević', '40234567899', STR_TO_DATE('19.05.1989.', '%d.%m.%Y.'), 'Ž', 'Masarykov put 10, Dubrovnik', 12, '0988901234', 'sandra.knezevic@gmail.com', STR_TO_DATE('15.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1520.00, 1, 9),
('Dino', 'Horvat', '41234567890', STR_TO_DATE('28.08.1987.', '%d.%m.%Y.'), 'M', 'Lapadska obala 20, Dubrovnik', 12, '0919012345', 'dino.horvat@gmail.com', STR_TO_DATE('01.01.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 1, 9),
('Ivana', 'Šimić', '42234567891', STR_TO_DATE('06.06.1992.', '%d.%m.%Y.'), 'Ž', 'Ulica Hrvatskih branitelja 6, Karlovac', 7, '0980123456', 'ivana.simic@gmail.com', STR_TO_DATE('10.09.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1510.00, 1, 10),
('Mario', 'Grgić', '43234567892', STR_TO_DATE('15.10.1985.', '%d.%m.%Y.'), 'M', 'Trg kralja Tomislava 10, Karlovac', 7, '0911234567', 'mario.grgic@gmail.com', STR_TO_DATE('01.06.2019.', '%d.%m.%Y.'), STR_TO_DATE('01.06.2020.', '%d.%m.%Y.'), 'neaktivan', 1500.00, 1, 10);

-- Instruktori (10, po 1 u svakoj podružnici)
('Luka', 'Šarić', '44234567893', STR_TO_DATE('05.03.1991.', '%d.%m.%Y.'), 'M', 'Ulica sportaša 1, Zagreb', 1, '0911112233', 'luka.saric@gmail.com', STR_TO_DATE('01.01.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 1),
('Matea', 'Delić', '45234567894', STR_TO_DATE('12.08.1987.', '%d.%m.%Y.'), 'Ž', 'Trg bana Jelačića 10, Split', 2, '0982223344', 'matea.delic@gmail.com', STR_TO_DATE('05.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 2),
('Ivan', 'Kovač', '46234567895', STR_TO_DATE('20.06.1985.', '%d.%m.%Y.'), 'M', 'Korzo 15, Rijeka', 3, '0913334455', 'ivan.kovac@gmail.com', STR_TO_DATE('10.03.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 3),
('Ana', 'Perković', '47234567896', STR_TO_DATE('15.02.1990.', '%d.%m.%Y.'), 'Ž', 'Ulica Trga 7, Osijek', 4, '0984445566', 'ana.perkovic@gmail.com', STR_TO_DATE('12.06.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 4),
('Marko', 'Horvat', '48234567897', STR_TO_DATE('07.11.1988.', '%d.%m.%Y.'), 'M', 'Obala 10, Zadar', 5, '0915556677', 'marko.horvat@gmail.com', STR_TO_DATE('20.01.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 5),
('Lucija', 'Radić', '49234567898', STR_TO_DATE('28.04.1992.', '%d.%m.%Y.'), 'Ž', 'Trg Slobode 12, Varaždin', 6, '0986667788', 'lucija.radic@gmail.com', STR_TO_DATE('01.09.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 6),
('Dino', 'Barić', '50234567899', STR_TO_DATE('09.09.1986.', '%d.%m.%Y.'), 'M', 'Via Lungomare 3, Pula', 8, '0917778899', 'dino.baric@gmail.com', STR_TO_DATE('15.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 7),
('Tihana', 'Novosel', '51234567890', STR_TO_DATE('23.12.1991.', '%d.%m.%Y.'), 'Ž', 'Ulica kralja Zvonimira 8, Šibenik', 9, '0988889900', 'tihana.novosel@gmail.com', STR_TO_DATE('01.03.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 8),
('Filip', 'Knežević', '52234567891', STR_TO_DATE('30.06.1989.', '%d.%m.%Y.'), 'M', 'Masarykov put 7, Dubrovnik', 12, '0919990011', 'filip.knezevic@gmail.com', STR_TO_DATE('10.06.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 9),
('Maja', 'Božić', '53234567892', STR_TO_DATE('18.05.1990.', '%d.%m.%Y.'), 'Ž', 'Trg kralja Tomislava 5, Karlovac', 7, '0980001122', 'maja.bozic@gmail.com', STR_TO_DATE('01.02.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1200.00, 2, 10);

-- Asistenti trenera (10, po 1 u svakoj podružnici)
('Petar', 'Vuković', '54234567893', STR_TO_DATE('15.01.1992.', '%d.%m.%Y.'), 'M', 'Ulica sportaša 2, Zagreb', 1, '0911112234', 'petar.vukovic@gmail.com', STR_TO_DATE('01.03.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 1),
('Ivana', 'Kovač', '55234567894', STR_TO_DATE('20.06.1989.', '%d.%m.%Y.'), 'Ž', 'Trg bana Jelačića 12, Split', 2, '0982223345', 'ivana.kovac@gmail.com', STR_TO_DATE('15.05.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 2),
('Luka', 'Perković', '56234567895', STR_TO_DATE('05.03.1987.', '%d.%m.%Y.'), 'M', 'Korzo 18, Rijeka', 3, '0913334456', 'luka.perkovic@gmail.com', STR_TO_DATE('10.06.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 3),
('Maja', 'Horvat', '57234567896', STR_TO_DATE('12.12.1990.', '%d.%m.%Y.'), 'Ž', 'Ulica Trga 9, Osijek', 4, '0984445567', 'maja.horvat@gmail.com', STR_TO_DATE('01.09.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 4),
('Filip', 'Šimić', '58234567897', STR_TO_DATE('22.07.1985.', '%d.%m.%Y.'), 'M', 'Obala 14, Zadar', 5, '0915556678', 'filip.simic@gmail.com', STR_TO_DATE('15.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 5),
('Ana', 'Barić', '59234567898', STR_TO_DATE('30.06.1992.', '%d.%m.%Y.'), 'Ž', 'Trg Slobode 15, Varaždin', 6, '0986667789', 'ana.baric@gmail.com', STR_TO_DATE('01.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 6),
('Dino', 'Novosel', '60234567899', STR_TO_DATE('05.11.1986.', '%d.%m.%Y.'), 'M', 'Via Lungomare 8, Pula', 8, '0917778890', 'dino.novosel@gmail.com', STR_TO_DATE('10.06.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 7),
('Tihana', 'Knežević', '61234567890', STR_TO_DATE('15.09.1991.', '%d.%m.%Y.'), 'Ž', 'Ulica kralja Zvonimira 12, Šibenik', 9, '0988889901', 'tihana.knezevic@gmail.com', STR_TO_DATE('01.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 8),
('Marko', 'Radić', '62234567891', STR_TO_DATE('18.05.1988.', '%d.%m.%Y.'), 'M', 'Masarykov put 12, Dubrovnik', 12, '0919990012', 'marko.radic@gmail.com', STR_TO_DATE('10.03.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 9),
('Lucija', 'Božić', '63234567892', STR_TO_DATE('28.08.1990.', '%d.%m.%Y.'), 'Ž', 'Trg kralja Tomislava 8, Karlovac', 7, '0980001123', 'lucija.bozic@gmail.com', STR_TO_DATE('01.04.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1000.00, 3, 10);

-- Ostali radnici fitness centra
('Maja', 'Kralj', '64234567893', STR_TO_DATE('05.05.1987.', '%d.%m.%Y.'), 'Ž', 'Ulica Zdravlja 1, Zagreb', 1, '0911112235', 'maja.kralj@gmail.com', STR_TO_DATE('01.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 4, 1),
('Ivan', 'Šimić', '65234567894', STR_TO_DATE('12.08.1985.', '%d.%m.%Y.'), 'M', 'Trg zdravlja 5, Split', 2, '0982223346', 'ivan.simic@gmail.com', STR_TO_DATE('15.03.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 4, 2),
('Petra', 'Barić', '66234567895', STR_TO_DATE('20.06.1988.', '%d.%m.%Y.'), 'Ž', 'Ulica Masaže 3, Rijeka', 3, '0913334457', 'petra.baric@gmail.com', STR_TO_DATE('10.06.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1700.00, 5, 3),
('Dino', 'Horvat', '67234567896', STR_TO_DATE('05.03.1990.', '%d.%m.%Y.'), 'M', 'Korzo 7, Osijek', 4, '0984445568', 'dino.horvat@gmail.com', STR_TO_DATE('01.09.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1700.00, 5, 4),
('Lucija', 'Radić', '68234567897', STR_TO_DATE('12.12.1992.', '%d.%m.%Y.'), 'Ž', 'Trg Wellnessa 9, Zadar', 5, '0915556679', 'lucija.radic@gmail.com', STR_TO_DATE('15.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1750.00, 6, 5),
('Filip', 'Kovač', '69234567898', STR_TO_DATE('22.07.1986.', '%d.%m.%Y.'), 'M', 'Obala Wellness 11, Varaždin', 6, '0986667790', 'filip.kovac@gmail.com', STR_TO_DATE('01.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1750.00, 6, 6),
('Ivan', 'Marić', '70234567899', STR_TO_DATE('05.11.1985.', '%d.%m.%Y.'), 'M', 'Tehnička 12, Pula', 8, '0917778891', 'ivan.maric@gmail.com', STR_TO_DATE('10.06.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1600.00, 7, 7),
('Tihana', 'Novosel', '71234567890', STR_TO_DATE('15.09.1989.', '%d.%m.%Y.'), 'Ž', 'Ulica Tehničara 3, Šibenik', 9, '0988889902', 'tihana.novosel@gmail.com', STR_TO_DATE('01.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1600.00, 7, 8),
('Marko', 'Barić', '72234567891', STR_TO_DATE('18.05.1987.', '%d.%m.%Y.'), 'M', 'Domarska 4, Dubrovnik', 12, '0919990013', 'marko.baric@gmail.com', STR_TO_DATE('10.03.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1400.00, 8, 9),
('Ana', 'Božić', '73234567892', STR_TO_DATE('28.08.1990.', '%d.%m.%Y.'), 'Ž', 'Trg Domara 5, Karlovac', 7, '0980001124', 'ana.bozic@gmail.com', STR_TO_DATE('01.04.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1400.00, 8, 10),
('Ivan', 'Horvat', '74234567893', STR_TO_DATE('05.05.1989.', '%d.%m.%Y.'), 'M', 'Ulica Čistoće 6, Zagreb', 1, '0911112236', 'ivan.horvat@gmail.com', STR_TO_DATE('01.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1300.00, 9, 1),
('Maja', 'Kovač', '75234567894', STR_TO_DATE('12.08.1991.', '%d.%m.%Y.'), 'Ž', 'Trg Čistoće 7, Split', 2, '0982223347', 'maja.kovac@gmail.com', STR_TO_DATE('15.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1300.00, 9, 2),
('Dino', 'Perković', '76234567895', STR_TO_DATE('20.06.1985.', '%d.%m.%Y.'), 'M', 'Ulica Održavanja 1, Rijeka', 3, '0913334458', 'dino.perkovic@gmail.com', STR_TO_DATE('10.06.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 10, 3),
('Lucija', 'Horvat', '77234567896', STR_TO_DATE('05.03.1990.', '%d.%m.%Y.'), 'Ž', 'Trg Održavanja 3, Osijek', 4, '0984445569', 'lucija.horvat@gmail.com', STR_TO_DATE('01.09.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 10, 4),
('Filip', 'Radić', '78234567897', STR_TO_DATE('12.12.1988.', '%d.%m.%Y.'), 'M', 'Administrativna 5, Zadar', 5, '0915556680', 'filip.radic@gmail.com', STR_TO_DATE('15.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 11, 5),
('Ana', 'Barić', '79234567898', STR_TO_DATE('22.07.1991.', '%d.%m.%Y.'), 'Ž', 'Administrativna 7, Varaždin', 6, '0986667791', 'ana.baric@gmail.com', STR_TO_DATE('01.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 11, 6),
('Ivan', 'Novosel', '80234567899', STR_TO_DATE('05.11.1987.', '%d.%m.%Y.'), 'M', 'Trg Tajnika 9, Pula', 8, '0917778892', 'ivan.novosel@gmail.com', STR_TO_DATE('10.06.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 12, 7),
('Maja', 'Knežević', '81234567890', STR_TO_DATE('15.09.1989.', '%d.%m.%Y.'), 'Ž', 'Ulica Tajnika 2, Šibenik', 9, '0988889903', 'maja.knezevic@gmail.com', STR_TO_DATE('01.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 12, 8),
('Marko', 'Barić', '82234567891', STR_TO_DATE('18.05.1986.', '%d.%m.%Y.'), 'M', 'Trg HR 4, Dubrovnik', 12, '0919990014', 'marko.baric@gmail.com', STR_TO_DATE('10.03.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 13, 9),
('Lucija', 'Božić', '83234567892', STR_TO_DATE('28.08.1990.', '%d.%m.%Y.'), 'Ž', 'HR Ulica 6, Karlovac', 7, '0980001125', 'lucija.bozic@gmail.com', STR_TO_DATE('01.04.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 13, 10),
('Ivan', 'Horvat', '84234567893', STR_TO_DATE('05.05.1988.', '%d.%m.%Y.'), 'M', 'Recepcija 1, Zagreb', 1, '0911112237', 'ivan.horvat@gmail.com', STR_TO_DATE('01.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 14, 1),
('Maja', 'Kovač', '85234567894', STR_TO_DATE('12.08.1992.', '%d.%m.%Y.'), 'Ž', 'Recepcija 2, Split', 2, '0982223348', 'maja.kovac@gmail.com', STR_TO_DATE('15.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 14, 2),
('Dino', 'Perković', '86234567895', STR_TO_DATE('20.06.1986.', '%d.%m.%Y.'), 'M', 'Korzo 1, Rijeka', 3, '0913334459', 'dino.perkovic@gmail.com', STR_TO_DATE('10.06.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 15, 3),
('Lucija', 'Horvat', '87234567896', STR_TO_DATE('05.03.1991.', '%d.%m.%Y.'), 'Ž', 'Trg 3, Osijek', 4, '0984445570', 'lucija.horvat@gmail.com', STR_TO_DATE('01.09.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1500.00, 15, 4),
('Filip', 'Radić', '88234567897', STR_TO_DATE('12.12.1989.', '%d.%m.%Y.'), 'M', 'Ulica Marketing 5, Zadar', 5, '0915556681', 'filip.radic@gmail.com', STR_TO_DATE('15.02.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 2200.00, 16, 5),
('Ana', 'Barić', '89234567898', STR_TO_DATE('22.07.1991.', '%d.%m.%Y.'), 'Ž', 'Trg Marketing 7, Varaždin', 6, '0986667792', 'ana.baric@gmail.com', STR_TO_DATE('01.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 2200.00, 16, 6),
('Ivan', 'Novosel', '90234567899', STR_TO_DATE('05.11.1988.', '%d.%m.%Y.'), 'M', 'Prodaja 9, Pula', 8, '0917778893', 'ivan.novosel@gmail.com', STR_TO_DATE('10.06.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 17, 7),
('Maja', 'Knežević', '91234567890', STR_TO_DATE('15.09.1990.', '%d.%m.%Y.'), 'Ž', 'Prodaja 2, Šibenik', 9, '0988889904', 'maja.knezevic@gmail.com', STR_TO_DATE('01.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 1800.00, 17, 8),
('Marko', 'Barić', '92234567891', STR_TO_DATE('18.05.1987.', '%d.%m.%Y.'), 'M', 'Dizajn 4, Dubrovnik', 12, '0919990015', 'marko.baric@gmail.com', STR_TO_DATE('10.03.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 18, 9),
('Lucija', 'Božić', '93234567892', STR_TO_DATE('28.08.1991.', '%d.%m.%Y.'), 'Ž', 'Dizajn 6, Karlovac', 7, '0980001126', 'lucija.bozic@gmail.com', STR_TO_DATE('01.04.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 18, 10),
('Ivan', 'Horvat', '94234567893', STR_TO_DATE('05.05.1985.', '%d.%m.%Y.'), 'M', 'Direktor 1, Zagreb', 1, '0911112238', 'ivan.horvat@gmail.com', STR_TO_DATE('01.02.2018.', '%d.%m.%Y.'), NULL, 'aktivan', 3000.00, 19, 1),
('Maja', 'Kovač', '95234567894', STR_TO_DATE('12.08.1988.', '%d.%m.%Y.'), 'Ž', 'Direktor 2, Split', 2, '0982223349', 'maja.kovac@gmail.com', STR_TO_DATE('15.03.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 3000.00, 19, 2),
('Dino', 'Perković', '96234567895', STR_TO_DATE('20.06.1986.', '%d.%m.%Y.'), 'M', 'Trg Odjela 1, Rijeka', 3, '0913334460', 'dino.perkovic@gmail.com', STR_TO_DATE('10.06.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 2500.00, 20, 3),
('Lucija', 'Horvat', '97234567896', STR_TO_DATE('05.03.1990.', '%d.%m.%Y.'), 'Ž', 'Ulica Odjela 3, Osijek', 4, '0984445571', 'lucija.horvat@gmail.com', STR_TO_DATE('01.09.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 2500.00, 20, 4),
('Filip', 'Radić', '98234567897', STR_TO_DATE('12.12.1989.', '%d.%m.%Y.'), 'M', 'Menadžer 5, Zadar', 5, '0915556682', 'filip.radic@gmail.com', STR_TO_DATE('15.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 2800.00, 21, 5),
('Ana', 'Barić', '99234567898', STR_TO_DATE('22.07.1991.', '%d.%m.%Y.'), 'Ž', 'Menadžer 7, Varaždin', 6, '0986667793', 'ana.baric@gmail.com', STR_TO_DATE('01.03.2021.', '%d.%m.%Y.'), NULL, 'aktivan', 2800.00, 21, 6),
('Ivan', 'Novosel', '100234567899', STR_TO_DATE('05.11.1988.', '%d.%m.%Y.'), 'M', 'Računovodstvo 9, Pula', 8, '0917778894', 'ivan.novosel@gmail.com', STR_TO_DATE('10.06.2019.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 22, 7),
('Maja', 'Knežević', '101234567890', STR_TO_DATE('15.09.1990.', '%d.%m.%Y.'), 'Ž', 'Blagajna 2, Šibenik', 9, '0988889905', 'maja.knezevic@gmail.com', STR_TO_DATE('01.02.2020.', '%d.%m.%Y.'), NULL, 'aktivan', 2000.00, 23, 8);

INSERT INTO trener_program (trener_id, program_id)
VALUES
-- Treneri podružnica 1
(1, 1), (1, 2), (1, 3),
(2, 2), (2, 4), 
(3, 1), (3, 3), (3, 5),
(4, 2), (4, 6),
-- Treneri podružnica 2
(5, 7), (5, 8), (5, 9),
(6, 8), (6, 10), 
(7, 7), (7, 9),
-- Treneri podružnica 3
(8, 11), (8, 12), (8, 13),
(9, 11), (9, 12),
-- Treneri podružnica 4
(10, 14), (10, 15),
(11, 14), (11, 16),
-- Treneri podružnica 5
(12, 17), (12, 18), (12, 19),
(13, 18), (13, 20),
-- Treneri podružnica 6
(14, 21), (14, 22),
(15, 21), (15, 23),
-- Treneri podružnica 7
(16, 24), (16, 25),
(17, 24), (17, 26),
-- Treneri podružnica 8
(18, 27), (18, 28), (18, 29),
(19, 28), (19, 30),
-- Treneri podružnica 9
(20, 31), (20, 32),
(21, 31), (21, 33),
-- Treneri podružnica 10
(22, 34), (22, 35), (22, 36),
(23, 35), (23, 37),
-- Ostali treneri (raspoređeni među podružnicama)
(24, 38), (24, 39),
(25, 38), (25, 40),
(26, 41), (26, 42),
(27, 41), (27, 43),
(28, 44), (28, 45),
(29, 44), (29, 46),
(30, 47), (30, 48),
(31, 47), (31, 49),
(32, 50), (32, 51),
(33, 50), (33, 52),
(34, 53), (34, 54),
(35, 53), (35, 55);
