# Sustav za upravljanje fitness centrom (Tim-1)

**Članovi:**
- Daniel Katić, voditelj + programer
- Lana Kohut, osoba za komunikaciju + programer
- Anja Svećarovski, programer
- Maja Kovačević, programer
- Mikel Milohanić, dokumentacija + programer
- Vladan Krivokapić, QA tester + programer

# Tablice

**Projekt se sastoji od sljedećih tablica:**
- clan, clanarina, tip_clanarine, status_clanarine, placanje, racun, popust, zaposlenik, trener, trener_program, program, trening, trening_clan, raspored, rezervacija, prostorija, oprema, odrzavanje, dobavljac

**Svaki član samostalno izrađuje svoj dio baze podataka.**
To uključuje svoj dio dokumentacije, tablice, ER dijagram, procedure, funkcije, pogled, okidače, te podatke za unos u bazu podataka.


# Odgovornosti

| Ime i prezime                    | Uloga                         | Odgovornost                                                      | Tablice                                                                                                                          |
| -------------------------------- | ----------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| **Daniel Katić [Voditelj]**            | Voditelj projekta + programer | **Članovi i članarine** — vođenje članova, statusi, tipovi članarina, isteci | Tablice (`clan`, `clanarina`, `tip_clanarine`, `status_clanarine`)|
| **Lana Kohut [Osoba za komunikaciju]** | Komunikacija + programer  | **Plaćanja i financije** — praćenje uplata, računa i popusta                 | Tablice (`placanje`, `racun`, `popust`)                        |
| **Anja Svećarovski**                         | Programer                     | **Treneri i zaposlenici** — evidencija osoblja i trenera                     | Tablice (`zaposlenik`, `trener`, `trener_program`)   |
| **Maja Kovačević**                        | Programer                     | **Programi i treninzi** — planiranje grupnih i individualnih treninga        | Tablice (`program`, `trening`, `trening_clan`)                          |
| **Mikel Milohanić**                        | Dokumentacija + programer         | **Raspored i rezervacije** — zakazivanje termina i prostorija                | Tablice (`termin treninga`, `rezervacija`, `prostorija`) |
| **Vladan Krivokapić**                       | QA tester + Programer                     | **Oprema i održavanje** — vođenje evidencije opreme i kvarova                | Tablice (`oprema`, `odrzavanje`, `dobavljac`)                      |


# Veze između tablica

## Daniel - članovi i članarine

| Veza                             | Vrsta | Objašnjenje                                                    |
| -------------------------------- | ----- | -------------------------------------------------------------- |
| `clan` – `clanarina`             | 1:N   | Jedan član može imati više članarina (npr. mjesečne).          |
| `clanarina` – `tip_clanarine`    | N:1   | Svaka članarina je određene vrste (npr. standard, premium).    |
| `clanarina` – `status_clanarine` | N:1   | Svaka članarina ima svoj status (aktivna, istekla, zamrznuta). |
| `clan` – `placanje` *(Lana)*     | 1:N   | Član može imati više uplata.                                   |
| `clan` – `trening_clan` *(Maja)* | 1:N   | Jedan član može sudjelovati u više treninga.                   |
| `clan` – `rezervacija` *(Mikel)* | 1:N   | Član može imati više rezervacija termina.                      |

## Lana - plaćanja i financije

| Veza                              | Vrsta       | Objašnjenje                                      |
| --------------------------------- | ----------- | ------------------------------------------------ |
| `placanje` – `clan` *(Daniel)*    | N:1         | Plaćanje pripada određenom članu.                |
| `placanje` – `racun`              | 1:1 ili 1:N | Svako plaćanje ima svoj račun (ovisno o modelu). |
| `racun` – `popust`                | N:1         | Na račun se može primijeniti određeni popust.    |
| `popust` – `clanarina` *(Daniel)* | 1:N         | Popust se može vezati uz vrstu članarine.        |

## Anja - treneri i zaposlenici

| Veza                                   | Vrsta | Objašnjenje                                              |
| -------------------------------------- | ----- | -------------------------------------------------------- |
| `trener` – `zaposlenik`                | 1:1   | Trener je ujedno i zaposlenik.                           |
| `trener` – `trener_program`            | 1:N   | Jedan trener može voditi više programa.                  |
| `trener_program` – `program` *(Maja)*  | N:1   | Program ima jednog odgovornog trenera.                   |
| `zaposlenik` – `odrzavanje` *(Vladan)* | 1:N   | Zaposlenik (npr. tehničar) može obaviti više održavanja. |
| `trener` – `raspored` *(Mikel)*        | 1:N   | Trener ima više termina u rasporedu.                     |


## Maja - programi i treninzi

| Veza                               | Vrsta | Objašnjenje                                  |
| ---------------------------------- | ----- | -------------------------------------------- |
| `program` – `trening`              | 1:N   | Program (npr. CrossFit) ima više treninga.   |
| `trening` – `trening_clan`         | 1:N   | Trening može imati više članova.             |
| `trening_clan` – `clan` *(Daniel)* | N:1   | Svaki unos u tablici veže člana na trening.  |
| `trening` – `raspored` *(Mikel)*   | 1:N   | Svaki trening ima svoje termine u rasporedu. |
| `program` – `prostorija` *(Mikel)* | N:1   | Program se odvija u određenoj prostoriji.    |

## Mikel - raspored i rezervacije

| Veza                               | Vrsta | Objašnjenje                                            |
| ---------------------------------- | ----- | ------------------------------------------------------ |
| `termin_treninga` – `trening` *(Maja)*    | N:1   | Svaki zapis u rasporedu pripada određenom treningu.    |
| `termin_treninga` – `prostorija`          | N:1   | Termin se održava u određenoj prostoriji.              |
| `rezervacija` – `raspored`         | N:1   | Rezervacija se odnosi na određeni termin iz rasporeda. |
| `rezervacija` – `clan` *(Daniel)*  | N:1   | Rezervaciju radi određeni član.                        |
| `prostorija` – `oprema` *(Vladan)* | 1:N   | Prostorija sadrži više komada opreme.                  |

## Vladan - oprema i održavanje

| Veza                                 | Vrsta | Objašnjenje                                       |
| ------------------------------------ | ----- | ------------------------------------------------- |
| `dobavljac` – `oprema`               | 1:N   | Jedan dobavljač isporučuje više komada opreme.    |
| `oprema` – `odrzavanje`              | 1:N   | Svaka sprava može imati više zapisa o održavanju. |
| `oprema` – `prostorija` *(Mikel)*    | N:1   | Sprava se nalazi u određenoj prostoriji.          |
| `odrzavanje` – `zaposlenik` *(Anja)* | N:1   | Održavanje izvodi određeni zaposlenik.            |


## Kratki sažetak relacija

| Povezani moduli       | Vrsta veze | Primjer                                       |
| --------------------- | ---------- | --------------------------------------------- |
| Daniel ↔️ Lana        | 1:N        | `clan` – `placanje`                           |
| Daniel ↔️ Maja        | M:N        | `clan` – `trening` (preko `trening_clan`)     |
| Daniel ↔️ Mikel       | 1:N        | `clan` – `rezervacija`                        |
| Maja ↔️ Anja          | M:N        | `program` – `trener` (preko `trener_program`) |
| Mikel ↔️ Vladan       | 1:N        | `prostorija` – `oprema`                       |
| Anja ↔️ Vladan        | 1:N        | `zaposlenik` – `odrzavanje`                   |
| Vladan ↔️ (unutarnje) | 1:N        | `dobavljac` – `oprema`                        |

