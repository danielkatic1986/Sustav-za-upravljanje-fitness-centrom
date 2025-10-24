# 🏋️‍♀️ DOKUMENT ORGANIZACIJE

**Trenutni zadatak:**
- Svaki član napraviti svoj direktorij sa datotekama na Githubu, rok do nedjelje 26.10.2025.

---

## Tablice

**Projekt se sastoji od sljedećih tablica:**

`mjesto`, `clan`, `clanarina`, `tip_clanarine`, `status_clanarine`, `placanje`, `racun`, `popust`, `podruznica`, `zaposlenik`, `radno_mjesto`, `odjel`, `trener_program`, `program`, `trening`, `trening_clan`, `termin_treninga`, `rezervacija`, `prostorija`, `oprema`, `odrzavanje`, `dobavljac`

**Svaki član samostalno izrađuje svoj dio baze podataka.**  
To uključuje tablice, ER dijagram, procedure, funkcije, poglede, okidače te pripadajuće podatke za unos.

---

## Odgovornosti

| Ime i prezime | Uloga | Odgovornost | Tablice |
|----------------|-------|--------------|----------|
| **Daniel Katić [Voditelj]** | Voditelj projekta + programer | **Članovi i članarine** — vođenje članova, statusi, tipovi članarina, isteci | `mjesto`, `clan`, `clanarina`, `tip_clanarine`, `status_clanarine` |
| **Lana Kohut [Osoba za komunikaciju]** | Komunikacija + programer | **Plaćanja i financije** — praćenje uplata, računa i popusta | `placanje`, `racun`, `popust` |
| **Anja Svećarovski** | Programer | **Treneri i zaposlenici** — evidencija osoblja i trenera | `podruznica`, `zaposlenik`, `radno_mjesto`, `odjel`, `trener_program` |
| **Maja Kovačević** | Programer | **Programi i treninzi** — planiranje grupnih i individualnih treninga | `program`, `trening`, `trening_clan` |
| **Mikel Milohanić** | Dokumentacija + programer | **Raspored i rezervacije** — zakazivanje termina i prostorija | `termin_treninga`, `rezervacija`, `prostorija`, `tip_prostorije` |
| **Vladan Krivokapić** | QA tester + programer | **Oprema i održavanje** — vođenje evidencije opreme i kvarova | `oprema`, `odrzavanje`, `dobavljac` |
