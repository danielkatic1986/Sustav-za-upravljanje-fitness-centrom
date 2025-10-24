## TABLICA tip_prostorije

Tablica ***tip\_prostorije*** služi za evidentiranje tipova prostorija koje se nalaze u fitness centru. Sastoji se od atributa `id`, `naziv` i `opis`.

Atribut `id` je tipa **INTEGER** te nam predstavlja **PRIMARY KEY** iz razloga jer jedinstveno određuje svaki redak (n-torku) naše tablice koristeći jedinstvene cjelobrojne vrijednosti, također korištenjem ključne riječi **AUTO INCREMENT** omogućuje se automatsko generiranje nove vrijednosti primarnog ključa prilikom svakog novog unosa u tablicu.

Atribut `naziv` je tipa **VARCHAR** iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Prilikom definiranja tipa **VARCHAR** potrebno je unijeti dozvoljenu gornju granicu unosa pa je tako za navedeni atribut postavljena gornja granica od **50** znakova. Također postavljeno je ograničenje **NOT NULL** koje ne dozvoljava izostavljanje vrijednosti za atribut nad kojim je definirano, bilo prilikom novog unosa ili prilikom izmjene postojećih n-torki. Osim ograničenja **NOT NULL** postavljeno je i ograničenje **UNIQUE** iz razloga jer ne želimo da nam se u tablici isti tip ponavlja. Zbog ograničenja **UNIQUE** možemo reći da je atribut `naziv` kandidat ključ ove tablice.

Atribut `opis` je tipa **TEXT** i kao takav ima ograničenje od 65,535 znakova što bi trebalo biti dovoljno za opis pojednih prostorija, atribut nema ograničenja jer unos opisa nije obavezan i ne očekuje se da bude jedinstven.


## TABLICA prostorija

Tablica ***prostorija*** služi za evidenciju prostorija u fitness centru. Sastoji se od atributa `id`, `oznaka`, `kapacitet` i `lokacija`.

Atribut `id` je tipa **INTEGER** te nam predstavlja **PRIMARY KEY** iz razloga jer jedinstveno određuje svaki redak (n-torku) naše tablice koristeći jedinstvene cjelobrojne vrijednosti, također korištenjem ključne riječi **AUTO INCREMENT** omogućuje se automatsko generiranje nove vrijednosti primarnog ključa prilikom svakog novog unosa u tablicu.

Atributi `oznaka` i `lokacija` su tipa **VARCHAR** iz razloga jer duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Prilikom definiranja tipa **VARCHAR** potrebno je unijeti dozvoljenu gornju granicu unosa pa je tako za navedene atribute postavljena gornja granica od **20** znakova. Također nad navedenim atributima postavljeno je i ograničenje **NOT NULL** koje ne dozvoljava izostavljanje vrijednosti za atribut nad kojim je definirano, bilo prilikom novog unosa ili prilikom izmjene postojećih n-torki. Nad atributom `oznaka` također je postavljeno i ograničenje **UNIQUE** pošto će svaka prostorija imati svoju jedinstvenu oznaku po kojoj će ih se razlikovati. Zbog ograničenja **UNIQUE** možemo reći da je atribut `oznaka` kandidat ključ ove tablice.

Atributi `kapacitet` i `tip_prostorije_id` su tipa **INTEGER** te kao takvi dozvoljavaju unos isključivo cijelobrojnih vrijednosti. Atribut `kapacitet` predstavlja najveći dozvoljeni broj članova koji se mogu istovremeno nalaziti u prostoriji te mu je kao takvom dodjeljeno ograničenje **NOT NULL** jer je to informacija koja mora biti definirana za svaku prostoriju zbog sigurnosti svih sudionika i ograničavanja rezervacija. Atribut `tip_prostorije_id` predstavlja strani ključ koji referencira atribut `id` tablice `tip_prostorije` te mu je kao takvom dodjeljeno ograničenje **FOREIGN KEY** koje osigurava očuvanje referencijalnog integriteta među povezanim tablicama, a također je nad njime postavljeno i ograničenje **NOT NULL** jer svaka prostorija mora imati evidentirano kojeg je tipa kako bi se znalo za koje je vrste treninga pogodna.


## TABLICA termin_treninga

Tablica ***termin_treninga*** služi za evidenciju termina pojedinog treninga. Sastoji se od atributa `id`, `trening_id`, `prostorija_id`, `trener_id`, `vrijeme_pocetka`, `vrijeme_zavrsetka`, `napomena` i `otkazan`.

Atribut `id` je tipa **INTEGER** te nam predstavlja **PRIMARY KEY** iz razloga jer jedinstveno određuje svaki redak (n-torku) naše tablice koristeći jedinstvene cjelobrojne vrijednosti, također korištenjem ključne riječi **AUTO INCREMENT** omogućuje se automatsko generiranje nove vrijednosti primarnog ključa prilikom svakog novog unosa u tablicu.

Atributi `trening_id`, `prostorija_id` i `trener_id` su tipa **INTEGER** te kao takvi dozvoljavaju samo unos cijelobrojnih vrijednosti. Navedenim atributima dodjeljeno je ograničenje **FOREIGN KEY** koje osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Pa tako atribut `trening_id` referencira atribut `id` tablice `trening` te je nad njime postavljeno ograničenje **NOT NULL** jer svaki termin treninga mora imati evidentiran trening koji se izvodi u tom terminu. Nadalje, atribut `prostorija_id` referencira atribut `id` tablice `prostorija` te je nad njime postavljeno ograničenje **NOT NULL** jer svaki termin treninga mora imati evidentiranu prostoriju u kojoj se isti izvodi. Atribut `trener_id` referencira atribut `id` tablice `zaposlenik` te je nad njime postavljeno ograničenje **NOT NULL** jer svaki termin treninga mora imati evidentiranog trenera koji će voditi trening.

Atributi `vrijeme_pocetka` i `vrijeme_zavrsetka` su tipa **DATETIME** te nam kao takvi dozvoljavaju unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, a sam tip podatka nam omogućuje lakšu manipulaciju tim podacima toko daljnjeg rada. Nad navedenim atributima postavljeno je ograničenje **NOT NULL** koje ne dozvoljava izostavljanje vrijednosti za atribut nad kojim je definirano, bilo prilikom novog unosa ili prilikom izmjene postojećih n-torki.

Atribut `napomena` je tipa **TEXT** i kao takav ima ograničenje od 65,535 znakova što bi trebalo biti dovoljno za unos i ponekih duljih komentara ako za to bude bilo potrebe. Korištenjem ključne riječi **DEFAULT** omogućujemo upis zadane vrijednosti za navedeni atribut ukoliko je ista izostavljena prilikom unosa.

Atribut `otkazan` je tipa **BOOLEAN** te kao takav dozvoljava unos logičkih vrijednosti true i false korištenjem brojčanih vrijednosti 0 i 1. Navedeni atribut omogućava evidenciju otkazanih termina treninga te korištenjem ključne riječi **DEFAULT** postavljamo zadanu vrijednost atributa koja je u ovom slučaju 0, a ukoliko dođe do otkazivanja termina treninga vrijednost atributa se mijenja na 1.


## TABLICA rezervacija

Tablica ***rezervacija*** služi za rezervaciju termina treninga. Sastoji se od atributa `id`, `clan_id`, `termin_treninga_id`, `vrijeme_rezervacije` i `nacin_rezervacije`.

Atribut `id` je tipa **INTEGER** te nam predstavlja **PRIMARY KEY** iz razloga jer jedinstveno određuje svaki redak (n-torku) naše tablice koristeći jedinstvene cjelobrojne vrijednosti, također korištenjem ključne riječi **AUTO INCREMENT** omogućuje se automatsko generiranje nove vrijednosti primarnog ključa prilikom svakog novog unosa u tablicu.

Atributi `clan_id` i `termin_treninga_id` su tipa **INTEGER** te kao takvi dozvoljavaju samo unos cijelobrojnih vrijednosti. Navedenim atributima dodjeljeno je ograničenje **FOREIGN KEY** koje osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Atribut `clan_id` referencira atribut `id` tablice `clan` te je nad njime postavljeno ograničenje **NOT NULL** jer svaka rezervacija treninga mora imati evidentiranog člana koji ju je zakazao. Nadalje, atribut `termin_treninga_id` referencira atribut `id` tablice `termin_treninga` te je nad njime postavljeno ograničenje **NOT NULL** jer svaka rezervacija mora imati evidentiran termin na koji se ista odnosi. Nad referencama atributa `clan_id` i `termin_treninga_id` također je definirano i referencijalno pravilo **ON DELETE CASCADE** koje pri brisanju člana iz tablice `clan` ili pri brisanju termina treninga iz tablice `termin_treninga` briše sve rezervacije povezane s tim clanom/terminom u tablici ***rezervacija*** pošto nam rezervacija ne koristi ako za istu nemamo evidentiranog člana koji ju je podnio ili termin na koji se ona odnosi.

Atribut `vrijeme_rezervacije` je tipa **DATETIME** te nam kao takav dozvoljava unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, a sam tip podatka nam omogućuje lakšu manipulaciju tim podacima toko daljnjeg rada. Nad navedenim atributom postavljeno je ograničenje **NOT NULL** koje ne dozvoljava izostavljanje vrijednosti za atribut nad kojim je definirano.

Atribut `nacin_rezervacije` je tipa **ENUM** koji nam omogućuje unos unaprijed definiranih vrijednosti, u ovom slučaju te vrijednosti su: 'Online' i 'Recepcija'. Nad atributom status_narudzbe postavljeno je ograničenje **NOT NULL**.