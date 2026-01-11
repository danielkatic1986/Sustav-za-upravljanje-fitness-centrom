## Modul: Programi, treninzi i evidencija prisustva
**Autor:** Maja Kovačević

### Opis modula
Ovaj modul pokriva programe i treninge te evidenciju prisustva članova na terminima treninga.  
Kroz poglede i procedure omogućeno je praćenje popunjenosti termina i aktivnosti članova, uz jasna poslovna pravila.

---

## Tablice

### Tablica: program
| Atribut | Tip | Ograničenje | Ključ | Opis |
|------|----|------------|------|------|
| id | INT | AUTO_INCREMENT | PRIMARY KEY | jedinstveni identifikator programa |
| naziv | VARCHAR(100) | NOT NULL | | naziv programa treninga |
| opis | VARCHAR(255) | | | kratki opis programa |

### Tablica: trening
| Atribut | Tip | Ograničenje | Ključ | Opis |
|------|----|------------|------|------|
| id | INT | AUTO_INCREMENT | PRIMARY KEY | jedinstveni identifikator treninga |
| program_id | INT | NOT NULL | FOREIGN KEY | referenca na program kojem trening pripada |
| naziv | VARCHAR(100) | NOT NULL | | naziv treninga |
| opis | VARCHAR(255) | | | kratki opis treninga |
| trajanje_min | INT | NOT NULL | | trajanje treninga u minutama |

### Tablica: trening_clan
| Atribut | Tip | Ograničenje | Ključ | Opis |
|------|----|------------|------|------|
| id | INT | AUTO_INCREMENT | PRIMARY KEY | jedinstveni identifikator evidencije prisustva |
| termin_treninga_id | INT | NOT NULL | FOREIGN KEY | referenca na termin treninga |
| clan_id | INT | NOT NULL | FOREIGN KEY | referenca na člana |
| status_prisustva | ENUM | NOT NULL | | status prisustva: PRISUTAN / IZOSTANAK / OPRAVDANO |
| vrijeme_checkina | DATETIME | | | vrijeme check-ina (ako je član prisutan) |
| napomena | VARCHAR(255) | | | dodatna napomena uz evidenciju |

---

## Pogledi (VIEW)

### vw_popunjenost_termina
Pogled prikazuje broj prisutnih članova po terminu treninga.  
Broji se samo status **PRISUTAN**, a termin se prikazuje i ako trenutno nema evidentiranih dolazaka (LEFT JOIN).

### vw_aktivnost_clana
Pogled prikazuje aktivnost članova kroz broj dolazaka, izostanaka i opravdanih izostanaka.  
Korisno za uvid u angažman članova kroz vrijeme.

---

## Procedure

### p_checkin_clana
Procedura evidentira dolazak člana na termin treninga.  
Check-in je moguć samo ako postoji rezervacija za taj termin, a upis se radi unutar transakcije radi očuvanja konzistentnosti podataka.

### p_otkazi_rezervaciju
Procedura otkazuje postojeću rezervaciju za termin treninga.  
Ako rezervacija ne postoji, procedura vraća grešku.

### p_oznaci_izostanak
Procedura evidentira izostanak člana s termina treninga (status **IZOSTANAK**).  
Izostanak se može upisati samo ako postoji rezervacija i ako evidencija još nije upisana.

---

## Poslovna pravila
- Evidencija dolaska/izostanka moguća je samo uz postojeću rezervaciju.
- Za jednog člana i jedan termin može postojati samo jedna evidencija prisustva (UNIQUE termin_treninga_id + clan_id).
- U slučaju kršenja pravila procedura prekida rad i poništava promjene (ROLLBACK + SIGNAL).
