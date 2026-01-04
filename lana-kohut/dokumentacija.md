-- dokumentacija za moj dio projekta
# 🧩 Lana Kohut, dokumentacija – plaćanja, računi, popust

## 1. Opis modula
Ovaj modul pokriva **vođenje plaćanja, računa i popusta**.  
Svrha je omogućiti praćenje statusa plaćanja, iznosa računa, načine plaćanja te izrada različitih financijskih izvještaja.

### Funkcionalnosti:
- Evidencija računa i plaćanja  
- Definiranje tipova plaćanja (  
- Praćenje statusa svake članarine (aktivna, istekla, zamrznuta)  
- Povezivanje članova s njihovim članarinama  
- Priprema podataka za obračun plaćanja i automatsku deaktivaciju članova  

---

## 2. Relacije i veze

### 2.1 `placanje`
**Opis:**  Sadrži podatke o svakoj transakciji svakog člana te koji je opis i status plaćanja
**Veze:**  
- 1:1 s `racun`  
- N:1 s `clan` 

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator plaćanja |
| `id_clan` | INT | FK | Strani ključ, jedinstveni identifikator člana |
| `id_racun` | INT | FK | Strani ključ, jedinstveni identifikator računa |
| `opis_placanja` | VARCHAR(100) | | Opis svakog plaćanja|
| `status_placanja` | VARCHAR(50) | | Status svakog plaćanja |

---

### 2.2 `racun`
**Opis:** popis svih računa ikad kreiranih u centru te potrebnih detalja za svaki račun  
**Veza:** 
- 1:1 s `placanje`
- N:1 s `popust`

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator računa |
| `broj_racuna` | INT | | Broj računa |
| `id_popusta` | INT | FK | Jedinstveni identifikator popusta |
| `nacin_placanja` | VARCHAR(50) | | Tekstualni opis načina plaćanja |
| `datum_izdavanja` | DATE | | Datum izdavanja računa |
| `vrijeme_izdavanja` | TIME | | Vrijeme izdavanja računa |
| `iznos_prije_popusta` | INT | | Iznos računa prije dodanog popusta |
| `popust_check` | VARCHAR(1) | | Provjera da li račun ima popust ili ne |
| `ukupan_iznos` | INT | | Ukupan iznos računa |


---

### 2.3 `popust`
**Opis:** popis svih dostupnih popusta  
**Veza:** N:1 s `racun`.

| Atribut | Tip | Ključ | Opis |
|----------|-----|-------|------|
| `id` | INT | PK | Jedinstveni identifikator popusta |
| `naziv_popusta` | VARCHAR(50) |  | Naziv popusta |
| `iznos_popusta` | INT | | Iznos popusta |
