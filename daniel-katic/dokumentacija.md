# 🧩 Daniel Katić, dokumentacija – članovi i članarine

## 1. Opis modula
Ovaj modul pokriva **vođenje članova i članarina fitness centra**.  
Svrha je omogućiti praćenje statusa članova, vrsta članarina i njihovog trajanja.

### Funkcionalnosti:
- Evidencija osobnih podataka članova  
- Definiranje tipova članarina (mjesečna, godišnja, premium...)  
- Praćenje statusa svake članarine (aktivna, istekla, zamrznuta)  
- Povezivanje članova s njihovim članarinama  
- Priprema podataka za obračun plaćanja i automatsku deaktivaciju članova  

---

## 2. Relacije i veze

### 2.1 `clan`
**Opis:** osnovni podaci o članovima fitness centra.  
**Veze:**  
- 1:N s `clanarina`  
- 1:N s `placanje` *(izvan ovog modula)*  
- 1:N s `rezervacija` *(izvan ovog modula)*  
- 1:N s `trening_clan` *(izvan ovog modula)*  

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator člana |
| `ime` | VARCHAR(50) |  | Ime člana |
| `prezime` | VARCHAR(50) |  | Prezime člana |
| `datum_rodenja` | DATE |  | Datum rođenja |
| `email` | VARCHAR(100) | UQ | Kontakt e-mail |
| `telefon` | VARCHAR(20) |  | Broj telefona |
| `datum_uclanjenja` | DATE |  | Datum kada je član upisan |
| `aktivan` | BOOLEAN |  | Označava je li član trenutno aktivan |

> **Napomena:** Polje `aktivan` planirano je automatizirati **triggerom** koji deaktivira člana kad istekne članarina.

---

### 2.2 `tip_clanarine`
**Opis:** definira vrste članarina dostupne u fitness centru.  
**Veza:** 1:N s `clanarina`.

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator tipa |
| `naziv` | VARCHAR(50) |  | Naziv članarine |
| `trajanje_mjeseci` | INT |  | Trajanje članarine u mjesecima |
| `cijena` | DECIMAL(8,2) |  | Cijena u eurima |
| `opis` | VARCHAR(255) |  | Dodatne informacije o tipu |

**Primjeri podataka:**

| id | naziv | trajanje_mjeseci | cijena | opis |
|----|--------|------------------|--------|------|
| 1 | Mjesečna | 1 | 40.00 | Osnovni pristup svim dvoranama |
| 2 | Godišnja | 12 | 400.00 | Popust 2 mjeseca gratis |
| 3 | Premium | 12 | 600.00 | Uključuje osobnog trenera |

---

### 2.3 `status_clanarine`
**Opis:** omogućava praćenje trenutnog statusa članarine.  
**Veza:** 1:N s `clanarina`.

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Identifikator statusa |
| `naziv` | VARCHAR(50) |  | Naziv statusa (Aktivna, Istekla, Zamrznuta...) |
| `opis` | VARCHAR(255) |  | Kratki opis značenja statusa |

**Primjeri:**

| id | naziv | opis |
|----|--------|------|
| 1 | Aktivna | Članarina je važeća |
| 2 | Istekla | Rok članarine je prošao |
| 3 | Zamrznuta | Privremeno pauzirana |

---

### 2.4 `clanarina`
**Opis:** veza između člana, tipa i statusa članarine.  
**Veze:**  
- N:1 prema `clan`  
- N:1 prema `tip_clanarine`  
- N:1 prema `status_clanarine`

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Identifikator članarine |
| `id_clan` | INT | FK | Poveznica na člana |
| `id_tip` | INT | FK | Poveznica na tip članarine |
| `id_status` | INT | FK | Poveznica na status članarine |
| `datum_pocetka` | DATE |  | Datum početka članarine |
| `datum_zavrsetka` | DATE |  | Datum završetka članarine |

---

## 3. Logičke veze (ER shema – opisno)
- **clan (1)** — *(N)* **clanarina**  
- **tip_clanarine (1)** — *(N)* **clanarina**  
- **status_clanarine (1)** — *(N)* **clanarina**

Ovim odnosima moguće je pratiti svaku članarinu pojedinog člana, njezin tip i trenutačni status.
