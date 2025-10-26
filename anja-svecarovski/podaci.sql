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
