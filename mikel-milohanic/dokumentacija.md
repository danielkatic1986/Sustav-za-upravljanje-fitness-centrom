# TABLICE

## TABLICA tip_prostorije

- tablica ***tip\_prostorije*** služi za evidentiranje tipova prostorija koje se nalaze u fitness centru
- sastoji se od atributa `id`, `naziv` i `opis`.

| Atribut | Tip | Ograničenja |  Opis |
|---------|-----|-------------|-------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `tip` | VARCHAR(50) | NOT_NULL UNIQUE | Sadrži naziv tipa prostorije stoga je tip podatka VARCHAR pošto duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Zbog ograničenja UNIQUE možemo reći da je ovaj atribut kandidat ključ ove tablice. |
| `opis` | TEXT || Sadrži opis prostorije stoga tip podatka TEXT koji podržava unos do 65535 znakova, a nad istim nisu postavljena nikakva ograničenja iz razloga jer unos atributa nije obavezan i ne očekuje se da bude jedinstven. |

## TABLICA prostorija

- tablica ***prostorija*** služi za evidenciju prostorija u fitness centru
- sastoji se od atributa `id`, `oznaka`, `lokacija`, `kapacitet`, `tip_prostorije_id` i `podruznica_id`.

| Atribut | Tip | Ograničenja | Opis |
|---------|-----|-------------|------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `oznaka` | VARCHAR(20) | NOT_NULL UNIQUE | Sadrži oznaku prostorije stoga je tip podatka VARCHAR pošto duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Zbog ograničenja UNIQUE možemo reći da je ovaj atribut kandidat ključ ove tablice. |
| `lokacija` | VARCHAR(20) | NOT_NULL | Sadrži lokaciju prostorije unutar centra stoga je tip podatka VARCHAR pošto duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `kapacitet` | INTEGER | NOT_NULL | Sadrži najveći dozvoljeni broj članova koji se mogu istovremeno nalaziti u prostoriji stoga je tip podatka INTEGER. Atribut mora biti definiran za svaku prostoriju zbog sigurnosti svih sudionika i ograničavanja broja rezervacija. |
| `tip_prostorije_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***tip_prostorije*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto moramo imati evidentirano čemu je prostorija namijenjena. |
| `podruznica_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***podruznica*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto moramo imati evidentirano u kojoj podružnici se prostorija nalazi. Nad ograničenjem stranog ključa također je definirano i referencijalno pravilo ON DELETE CASCADE koje osigurava da se prilikom brisanja primarnog ključa unutar tablice ***podruznica*** obišu i svi retci kojima je vrijednost ovog atributa jednaka vrijednosti obrisanog primarnog ključa referencirane tablice pošto nam nema smisla imati evidentiranu prostoriju za podružnicu koja ne postoji. |

## TABLICA termin_treninga

- tablica ***termin_treninga*** služi za evidenciju termina pojedinog treninga
- sastoji se od atributa `id`, `trening_id`, `prostorija_id`, `trener_id`, `vrijeme_pocetka`, `vrijeme_zavrsetka`, `napomena` i `otkazan`.

| Atribut | Tip | Ograničenja | Opis |
|---------|-----|-------------|------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `trening_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***trening*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaki termin treninga mora imati evidentiran trening koji se izvodi u tom terminu. |
| `prostorija_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***prostorija*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaki termin treninga mora imati evidentiranu prostoriju u kojoj se isti izvodi. |
| `trener_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***trener*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaki termin treninga mora imati evidentiranog trenera koji će voditi trening. |
| `vrijeme_pocetka` | TIMESTAMP | NOT_NULL | Sadrži vrijeme početka termina treninga stoga je tip podatka TIMESTAMP koji dozvoljava unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, te omogućuje lakšu manipulaciju tim podacima tokom daljnjeg rada. Unos je obavezan pošto svaki termin treninga mora imati evidentirano vrijeme početka izvođenja. |
| `vrijeme_zavrsetka` | TIMESTAMP | NOT_NULL | Sadrži vrijeme završetka termina treninga stoga je tip podatka TIMESTAMP koji dozvoljava unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, te omogućuje lakšu manipulaciju tim podacima tokom daljnjeg rada. Unos je obavezan pošto svaki termin treninga mora imati evidentirano vrijeme završetka izvođenja. |
| `napomena` | TEXT | DEFAULT | Sadrži napomenu za pojedini termin treninga stoga je tip podatka TEXT koji podržava unos do 65535 znakova, a ukoliko se prilikom unosa ne unese vrijednost za ovaj atribut isti će biti postavljen na vrijednost *"Nema napomena."* definiranu ograničenjem DEFAULT. |
| `otkazan` | BOOLEAN | NOT_NULL DEFAULT | Sadrži informaciju je li pojedini termin treninga naposljetku otkazan stoga je tip podatka BOOLEAN. Atribut mora biti definiran za svaki termin radi lakše evidencije održanih i otkazanih termina, a ukoliko se prilikom unosa ne unese vrijednost za ovaj atribut isti će biti postavljen na vrijednost '0' definiranu ograničenjem DEFAULT.  |

## TABLICA rezervacija

- tablica ***rezervacija*** služi za rezervaciju termina treninga
- sastoji se od atributa `id`, `clan_id`, `termin_treninga_id`, `vrijeme_rezervacije` i `nacin_rezervacije`

| Atribut | Tip | Ograničenja | Opis |
|---------|-----|-------------|------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `clan_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***clan*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaka rezervacija treninga mora imati evidentiranog člana koji ju je zakazao. Nad ograničenjem stranog ključa također je definirano i referencijalno pravilo ON DELETE CASCADE koje osigurava da se prilikom brisanja primarnog ključa unutar tablice ***clan*** obišu i svi retci kojima je vrijednost ovog atributa jednaka vrijednosti obrisanog primarnog ključa referencirane tablice pošto nam rezervacija ne koristi ako za istu nemamo evidentiranog člana koji ju je podnio. |
| `termin_treninga_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***termin_treninga*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaka rezervacija mora imati evidentiran termin na koji se ista odnosi. Nad ograničenjem stranog ključa također je definirano i referencijalno pravilo ON DELETE CASCADE koje osigurava da se prilikom brisanja primarnog ključa unutar tablice ***termin_treninga*** obišu i svi retci kojima je vrijednost ovog atributa jednaka vrijednosti obrisanog primarnog ključa referencirane tablice pošto nam rezervacija ne koristi ako za istu nemamo evidentiran termin na koji se ona odnosi. |
| `vrijeme_rezervacije` | TIMESTAMP | NOT_NULL | Sadrži vrijeme podnošenja rezervacije stoga je tip podatka TIMESTAMP koji dozvoljava unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, te omogućuje lakšu manipulaciju tim podacima tokom daljnjeg rada. Unos je obavezan pošto želimo voditi evidenciju kad je tko napravio rezervaciju za slučaj da dođe do nekakvih problema. |
| `nacin_rezervacije` | ENUM | NOT_NULL | Sadrži vrijednost koja opisuje način na koji je podnijeta rezervacija stoga je tip podatka ENUM koji nam omogućuje unos unaprijed definiranih vrijednosti, u ovom slučaju te vrijednosti su: *"Online"* i *"Recepcija"*. Unos je obavezan pošto želimo voditi evidenciju na koji način naši korisnici vrše rezervacije. |
