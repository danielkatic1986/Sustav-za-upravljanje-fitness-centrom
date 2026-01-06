# SQL TABLICE

## TABLICA tip_prostorije

```sql
CREATE TABLE tip_prostorije (
	id INTEGER AUTO_INCREMENT,
    naziv VARCHAR(50) NOT NULL,
	opis TEXT,
    
    CONSTRAINT uq_tip_prostorije_naziv UNIQUE (naziv),
    
    CONSTRAINT pk_tip_prostorije PRIMARY KEY (id)
);
```

- tablica ***tip\_prostorije*** služi za evidentiranje tipova prostorija koje se nalaze u fitness centru
- sastoji se od atributa `id`, `naziv` i `opis`.

| Atribut | Tip | Ograničenja |  Opis |
|---------|-----|-------------|-------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `tip` | VARCHAR(50) | NOT_NULL UNIQUE | Sadrži naziv tipa prostorije stoga je tip podatka VARCHAR pošto duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. Zbog ograničenja UNIQUE možemo reći da je ovaj atribut kandidat ključ ove tablice. |
| `opis` | TEXT || Sadrži opis prostorije stoga tip podatka TEXT koji podržava unos do 65535 znakova, a nad istim nisu postavljena nikakva ograničenja iz razloga jer unos atributa nije obavezan i ne očekuje se da bude jedinstven. |

## TABLICA prostorija

```sql
CREATE TABLE prostorija (
	id INTEGER AUTO_INCREMENT,
    oznaka VARCHAR(10) NOT NULL,
    lokacija VARCHAR(50) NOT NULL,
    kapacitet INTEGER NOT NULL,
    tip_prostorije_id INTEGER NOT NULL,
	podruznica_id INTEGER NOT NULL,
    
    CONSTRAINT ck_prostorija_kapacitet CHECK (kapacitet > 0),
    
    CONSTRAINT pk_prostorija PRIMARY KEY (id),
    
    CONSTRAINT fk_prostorija_tip_prostorije
		FOREIGN KEY (tip_prostorije_id)
        REFERENCES tip_prostorije (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
	CONSTRAINT fk_prostorija_podruznica
		FOREIGN KEY (podruznica_id)
        REFERENCES podruznica (id) 
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

- tablica ***prostorija*** služi za evidenciju prostorija u fitness centru
- sastoji se od atributa `id`, `oznaka`, `lokacija`, `kapacitet`, `tip_prostorije_id` i `podruznica_id`.

| Atribut | Tip | Ograničenja | Opis |
|---------|-----|-------------|------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `oznaka` | VARCHAR(10) | NOT_NULL | Sadrži oznaku prostorije stoga je tip podatka VARCHAR pošto duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `lokacija` | VARCHAR(50) | NOT_NULL | Sadrži lokaciju prostorije unutar centra stoga je tip podatka VARCHAR pošto duljina unosa može varirati pa se alokacija memorije vrši dinamički ovisno o unosu. |
| `kapacitet` | INTEGER | NOT_NULL | Sadrži najveći dozvoljeni broj članova koji se mogu istovremeno nalaziti u prostoriji stoga je tip podatka INTEGER. Atribut mora biti definiran za svaku prostoriju zbog sigurnosti svih sudionika i ograničavanja broja rezervacija. |
| `tip_prostorije_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***tip_prostorije*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto moramo imati evidentirano čemu je prostorija namijenjena. |
| `podruznica_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***podruznica*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto moramo imati evidentirano u kojoj podružnici se prostorija nalazi. Nad ograničenjem stranog ključa također je definirano i referencijalno pravilo ON DELETE CASCADE koje osigurava da se prilikom brisanja primarnog ključa unutar tablice ***podruznica*** obišu i sve n-torke kojima je vrijednost ovog atributa jednaka vrijednosti obrisanog primarnog ključa referencirane tablice pošto nam nema smisla imati evidentiranu prostoriju za podružnicu koja ne postoji. |

## TABLICA termin_treninga

```sql
CREATE TABLE termin_treninga (
	id INTEGER AUTO_INCREMENT,
    trening_id INTEGER NOT NULL,
    prostorija_id INTEGER NOT NULL,
    trener_id INTEGER NOT NULL,
    vrijeme_pocetka TIMESTAMP NOT NULL,
    vrijeme_zavrsetka TIMESTAMP NOT NULL,
    napomena TEXT,
    otkazan BOOLEAN NOT NULL DEFAULT FALSE,
    rezervirano INTEGER NOT NULL DEFAULT 0,
    
    CONSTRAINT ck_termin_treninga_vrijeme_pocetka_vrijeme_zavrsetka
		CHECK (vrijeme_zavrsetka > vrijeme_pocetka ),
    
    CONSTRAINT pk_termin_treninga PRIMARY KEY (id),
    
    CONSTRAINT fk_termin_treninga_trening
		FOREIGN KEY (trening_id)
        REFERENCES trening (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_termin_treninga_prostorija
		FOREIGN KEY (prostorija_id)
        REFERENCES prostorija (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_termin_treninga_zaposlenik
		FOREIGN KEY (trener_id)
        REFERENCES zaposlenik (id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
	
    INDEX idx_termin_treninga_vrijeme_pocetka (vrijeme_pocetka)
);
```

- tablica ***termin_treninga*** služi za evidenciju termina pojedinog treninga
- sastoji se od atributa `id`, `trening_id`, `prostorija_id`, `trener_id`, `vrijeme_pocetka`, `vrijeme_zavrsetka`, `rezervirano`, `napomena` i `otkazan`.

| Atribut | Tip | Ograničenja | Opis |
|---------|-----|-------------|------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `trening_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***trening*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaki termin treninga mora imati evidentiran trening koji se izvodi u tom terminu. |
| `prostorija_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***prostorija*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaki termin treninga mora imati evidentiranu prostoriju u kojoj se isti izvodi. |
| `trener_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***trener*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaki termin treninga mora imati evidentiranog trenera koji će voditi trening. |
| `vrijeme_pocetka` | TIMESTAMP | NOT_NULL | Sadrži vrijeme početka termina treninga stoga je tip podatka TIMESTAMP koji dozvoljava unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, te omogućuje lakšu manipulaciju tim podacima tokom daljnjeg rada. Unos je obavezan pošto svaki termin treninga mora imati evidentirano vrijeme početka izvođenja. Nad ovim atributom je također definiran i INDEX koji utječe na brži i bolji dohvat podataka. |
| `vrijeme_zavrsetka` | TIMESTAMP | NOT_NULL | Sadrži vrijeme završetka termina treninga stoga je tip podatka TIMESTAMP koji dozvoljava unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, te omogućuje lakšu manipulaciju tim podacima tokom daljnjeg rada. Unos je obavezan pošto svaki termin treninga mora imati evidentirano vrijeme završetka izvođenja. |
| `napomena` | TEXT | | Sadrži napomenu za pojedini termin treninga stoga je tip podatka TEXT koji podržava unos do 65535 znakova, a unos nije obavezan. |
| `otkazan` | BOOLEAN | NOT_NULL DEFAULT | Sadrži informaciju je li pojedini termin treninga naposljetku otkazan stoga je tip podatka BOOLEAN. Atribut mora biti definiran za svaki termin radi lakše evidencije održanih i otkazanih termina, a ukoliko se prilikom unosa ne unese vrijednost za ovaj atribut isti će biti postavljen na vrijednost FALSE definiranu ograničenjem DEFAULT. |
| `rezervirano` | INTEGER | NOT_NULL DEFAULT | Sadrži informaciju o popunjenosti termina rezervacijama stoga je tip podatka INTEGER. Atribut mora biti definiran za svaki termin kako nebi bilo više rezervacija nego što je kapacitet prostorije, a ukoliko se prilikom unosa ne unese vrijednost za ovaj atribut isti će biti postavljen na vrijednost 0 definiranu ograničenjem DEFAULT. |

## TABLICA rezervacija

```sql
CREATE TABLE rezervacija (
	id INTEGER AUTO_INCREMENT,
    clan_id INTEGER NOT NULL,
    termin_treninga_id INTEGER NOT NULL,
    vrijeme_rezervacije TIMESTAMP NOT NULL,
    nacin_rezervacije ENUM("Online", "Recepcija") NOT NULL,
    
    CONSTRAINT uq_rezervacija_clan_id_termin_treninga_id UNIQUE (clan_id, termin_treninga_id),
    
    CONSTRAINT pk_rezervacija PRIMARY KEY (id),
    
    CONSTRAINT fk_rezervacija_clan
		FOREIGN KEY (clan_id)
        REFERENCES clan (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_rezervacija_termin_treninga
		FOREIGN KEY (termin_treninga_id)
        REFERENCES termin_treninga (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

- tablica ***rezervacija*** služi za rezervaciju termina treninga
- sastoji se od atributa `id`, `clan_id`, `termin_treninga_id`, `vrijeme_rezervacije` i `nacin_rezervacije`

| Atribut | Tip | Ograničenja | Opis |
|---------|-----|-------------|------|
| `id` | INTEGER | PRIMARY_KEY | Jedinstveno određuje svaki redak (n-torku) tablice koristeći jedinstvene cjelobrojne vrijednosti. Korištenjem svojstva AUTO INCREMENT osiguravamo da se vrijednost atributa automatski generira prilikom svakog novog unosa ukoliko ista nije definirana samim unosom. |
| `clan_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***clan*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaka rezervacija treninga mora imati evidentiranog člana koji ju je zakazao. Nad ograničenjem stranog ključa također je definirano i referencijalno pravilo ON DELETE CASCADE koje osigurava da se prilikom brisanja primarnog ključa unutar tablice ***clan*** obišu i sve n-torke kojima je vrijednost ovog atributa jednaka vrijednosti obrisanog primarnog ključa referencirane tablice pošto nam rezervacija ne koristi ako za istu nemamo evidentiranog člana koji ju je podnio. |
| `termin_treninga_id` | INTEGER | NOT_NULL FOREIGN_KEY | Sadrži vrijednost stranog ključa tablice ***termin_treninga*** te korištenjem ograničenja FOREIGN KEY osigurava očuvanje referencijalnog integriteta među povezanim tablicama. Unos je obavezan pošto svaka rezervacija mora imati evidentiran termin na koji se ista odnosi. Nad ograničenjem stranog ključa također je definirano i referencijalno pravilo ON DELETE CASCADE koje osigurava da se prilikom brisanja primarnog ključa unutar tablice ***termin_treninga*** obišu i sve n-torke kojima je vrijednost ovog atributa jednaka vrijednosti obrisanog primarnog ključa referencirane tablice pošto nam rezervacija ne koristi ako za istu nemamo evidentiran termin na koji se ona odnosi. |
| `vrijeme_rezervacije` | TIMESTAMP | NOT_NULL | Sadrži vrijeme podnošenja rezervacije stoga je tip podatka TIMESTAMP koji dozvoljava unos vremena u formatu u kojem se može zabilježiti datum, sate, minute i sekunde, te omogućuje lakšu manipulaciju tim podacima tokom daljnjeg rada. Unos je obavezan pošto želimo voditi evidenciju kad je tko napravio rezervaciju za slučaj da dođe do nekakvih problema. |
| `nacin_rezervacije` | ENUM | NOT_NULL | Sadrži vrijednost koja opisuje način na koji je podnijeta rezervacija stoga je tip podatka ENUM koji nam omogućuje unos unaprijed definiranih vrijednosti, u ovom slučaju te vrijednosti su: *"Online"* i *"Recepcija"*. Unos je obavezan pošto želimo voditi evidenciju na koji način naši korisnici vrše rezervacije. |

# UPITI

## Ukupan kapacitet svih prostorija po podružnicama

```sql
SELECT p.id,
	   p.naziv,
       p.adresa,
       uk.ukupan_kapacitet
FROM   podruznica p
JOIN   (SELECT   podruznica_id,
				 SUM(kapacitet) AS ukupan_kapacitet
		FROM 	 prostorija
		GROUP BY podruznica_id) AS uk ON p.id = uk.podruznica_id;
```

**Svrha upita:**<br/>
&emsp;Upit služi za pregled ukupnog kapaciteta svih prostorija po poslovnicama, a može biti koristan za uvid u "veličinu" pojedine podružnice ili za nekakva financijska predviđanja troškova i/ili prihoda ovisno o maksimalnom kapacitetu podružnice.

**Opis upita:**<br/>
&emsp;Najprije se iz tablice *prostorija* grupiraju sve prostorije po podružnicama koristeći naredbu GROUP BY nad atributom *podruznica_id*, te se u rezultirajuću izvedenu tablicu sprema se primarni ključ svake podružnice iz atributa *podruznica_id* i ukupan kapacitet svake podružnice pomoću atributa *ukupan_kapacitet* koji se dobiva koristeći agregacijsku funkciju SUM nad atributom *kapacitet* prilikom samog grupiranja. Zatim se koristeći naredbu JOIN vrši spajanje izvedene tablice *uk* sa tablicom *podruznica* koristeći atribut *id* tablice podruznica i atribut *podruznica_id* tablice *uk*, a sam upit na kraju vraća tablicu koja sadrži id, naziv i adresu svake poslovnice, te njezin ukupan kapacitet.

## Udio načina rezervacije u postocima

```sql
SELECT	 nacin_rezervacije,
		 CONCAT(ROUND(COUNT(*)/(SELECT COUNT(*) FROM rezervacija)*100, 1), ' %') AS udio
FROM	 rezervacija
GROUP BY nacin_rezervacije;
```

**Svrha upita:**<br/>
&emsp;Upit služi za uvid u udijele/količine načina na koje članovi vrše rezervacije, a može biti koristan za definiranje nekakvih poslovnih strategija koje ciljaju određenu skupinu članova ovisno o načinu plaćanja npr. nekakve pogodnosti ili popusti.

**Opis upita:**<br/>
&emsp;Koristeći naredbu GROUP BY nad atributom *nacin_rezervacije* najprije se grupiraju sve rezervacije unutar tablice *rezervacija* prema načinu na koji je izvršena pojedina rezervacija, a kao rezultat upit vraća tablicu koja sadrži atribut *nacin_rezervacije* koji sadrži sve načine na koje korisnici vrše rezervacije, te atribut "udio" koji predstavlja udio pojedinog načina rezervacije među svim izvršenim rezervacijama. Atribut *udio* dobiven je tako što se za svaki od načina rezervacije prebrojava broj pojavljivanja koristeći agregacijsku funkciju COUNT, dobiveni rezultat se potom dijeli sa ukupnim brojem zapisa u tablici rezervacija i množi sa 100 kako bi se dobio iznos u obliku postotka, na kraju se rezultat još zaokružuje na cijeli broj koristeći funciju ROUND te se pomoću funkcije CONCAT dodaje simbol postotka (%) iza samog broja.

## Prosjek rezervacija mjesečno na razini svih podružnica

```sql
SELECT CAST(AVG(br.broj_rezervacija) AS UNSIGNED) AS prosjek_rezervacija_mjesecno
FROM   (SELECT 	 COUNT(*) AS broj_rezervacija
		FROM 	 rezervacija
		GROUP BY DATE_FORMAT(DATE(vrijeme_rezervacije), '%m.%Y.')) AS br;
```

**Svrha upita:**<br/>
&emsp;Upit služi za pregled koliko rezervacija mjesečno ostvaruju sve podružnice zajedno, a može biti koristan kako bi se dobio uvid u broj redovnih članova te dojam o potrebi za povećanjem/smanjenjem kapaciteta, sadržaja ili radne snage ni razini cijelog poslovanja.

**Opis upita:**<br/>
&emsp;Najprije se koristeći naredbu GROUP BY grupiraju sve vrijednosti unutar tablice *rezervacija* po mjesecima i godinama i to na način da se naprije atribut *vrijeme_rezervacije* pretvara is tipa podatka TIMESTAMP u tip podatka DATE, a potom se dobiveni datum formatira u željeni format korištenjem funkcije DATE_FORMAT, te se na kraju grupira po dobivenom atributu. Prilikom grupiranja koristi se agragacijska funkcija COUNT kako bi se prebrojalo ukupno razervacija za svaki mjesec. Nad dobivenom izvedenom tablicom *br* se zatim koristi agragacijska funkcija AVG kako bi se dobio prosjek rezervacija po mjesecima. Na kraju se još nad rezultatom koristi i funkcija CAST unutar koje se definira tip podatka UNSIGNED te se na taj način rezultat pretvara u pozitivni cijeli broj prilikom čega mu se decimalni dio odbacuje. Upit vraća dobiveni rezultat unutar atributa pod nazivom *prosjek_rezervacija_mjesecno*.

## Ukupan broj nadolazećih rezervacija sa prosječnim brojem dana prijevremenog podnošenja rezervacije termina treninga, po podružnicama

```sql
SELECT   po.naziv AS podruznica,
		 COUNT(r.id) AS broj_rezervacija,
         ROUND(AVG(DATEDIFF(tt.vrijeme_pocetka, r.vrijeme_rezervacije)), 0) AS prosjek_dana_rezervacije_prije_treninga
FROM 	 rezervacija r
JOIN 	 termin_treninga tt ON r.termin_treninga_id = tt.id
JOIN 	 prostorija pr ON tt.prostorija_id = pr.id
JOIN 	 podruznica po ON pr.podruznica_id = po.id
WHERE	 tt.vrijeme_pocetka > CURRENT_TIMESTAMP()
GROUP BY po.id;
```

**Svrha upita:**<br/>
&emsp;Upit služi za pregled prosječnog broja rezervacija po podružnicama i daje informaciju koliko dana u prosjeku članovi te podružnice vrše rezervacije željenih termina. Može biti koristan za bolje planiranje kapaciteta i zakazivanja termina treninga unutar pojedinih podružnica.

**Opis upita:**<br/>
&emsp;Najprije se koristeći naredbu JOIN povezuju tablice *rezervacija* i *termin_treninga* putem primarnog ključa tablice *termin_treninga*, zatim se naredbom JOIN povezuje dobivenu tablicu sa tablicom *prostorija* putem primarnog ključa tablice *prostorija*, te se na kraju ponavlja isto i sa tablicom *podruznica*. Dobivenu tablicu se potom grupira korištenjem naredbe GROUP BY nad atributom *id* tablice *podruznica*, a kao rezultat upit vraća tablicu s atributima *podruznica*, *broj_rezervacija* i *prosjek_dana_rezervacije_prije_treninga*. Atribut *podruznica* sadržava nazive svih podružnica dok atribut *broj_rezervacija* sadržava ukupan broj nadolazećih rezervacija pri čemu je isti dobiven korištenjem agregacijske funkcije COUNT prilikom grupiranja. Atribut *prosjek_dana_rezervacije_prije_treninga* sadrži brojčane vrijednosti koje prikazuju koliko u prosjeku dana prije treninga članovi pojedine podružnice vrše rezervaciju termina, a dobiven je na način da se prilikom grupiranja najprije za svaku n-torku izračunava razlika u danima od vremena rezervacije do vremena početka treninga korištenjem funkcije DATEDIFF, potom se pomoću agregacijske funkcije AVG računa proječna vrijednost dana te se na kraju taj rezultat zaokružuje na cijelobrojnu vrijednost korištenjem funkcije ROUND sa parametrom 0.

## Broj trenera prema broju treninga za treninge u narednih mjesec dana

```sql
SELECT   COUNT(*) AS broj_trenera, broj_treninga
FROM     (SELECT trener_id, COUNT(*) AS broj_treninga
		  FROM termin_treninga
		  WHERE vrijeme_pocetka BETWEEN CURRENT_TIMESTAMP() AND CURRENT_TIMESTAMP() + INTERVAL 1 MONTH
		  GROUP BY trener_id) AS btt
GROUP BY broj_treninga
ORDER BY broj_treninga DESC;
```

**Svrha upita:**<br/>
&emsp;Upit služi za uvid u opterećenje trenera treninzima za nadolazeći period od mjesec dana na razini cijelog sustava fitness centara, a prikazuje koliki broj trenera koji u navedenom periodu imaju zakazan određeni broj treninga. Navedeni upit može biti koristan za uvid jesu li treneri preopterećeni ili možda nedovoljno angažirani te se na temelju toga mogu donijeti odluke o povećanju ili smanjenju radne snage, a također je moguće odrediti je li potrebno izvršiti preraspodjelu termina kako bi se postigla ravnomjernija opterećenost trenera.

**Opis upita:**<br/>
&emsp;Korištenjem podupita najprije se unutar tablice *termin_treninga* filtriraju sve n-torke pomoću operatora BETWEEN pri čemu se provjerava je li vrijednost atributa *vrijeme_pocetka* između trenutnog vremena i vremena za mjesec dana od sada. Filtrirane rezultate se potom grupira korištenjem naredbe GROUP BY nad atributom *trener_id*, a rezultat je izvedena tablica sa atributom *trener_id* i atributom *broj_treninga* koji je dobiven korištenjem agregacijske funkcije COUNT prilikom grupiranja. Izvedena tablica *btt* se potom grupira koristeći atribut *broj_treninga* pri čemu se pomoću agregacijske funkcije COUNT prebrojavaju treneri koji imaju isti broj zakazanih treninga u odabranom periodu, a dobiveni broj trenera sprema se u atribut *broj_trenera*. Na kraju se dobivena tablica sortira silazno korištenjem naredbe ORDER BY i ključne riječi DESC pri čemu upit vraća tablicu u kojoj se na vrhu nalazi broj trenera s najviše zakazanih termina, a na dnu s najmanje.

# POGLEDI

## Pregled odrađenih treninga po poslovnicama u proteklih mjesec dana, sortirano silazno

```sql
CREATE VIEW vw_proteklih_mjesec_treninga_po_podruznicama AS
SELECT 	 po.naziv, COUNT(*) AS odradeno_treninga
FROM 	 termin_treninga tt
JOIN 	 prostorija pr ON tt.prostorija_id = pr.id
JOIN 	 podruznica po ON pr.podruznica_id = po.id
WHERE 	 otkazan IS FALSE
AND 	 vrijeme_pocetka >= CURRENT_TIMESTAMP() - INTERVAL 1 MONTH
AND 	 vrijeme_zavrsetka < CURRENT_TIMESTAMP()
GROUP BY po.id
ORDER BY odradeno_treninga DESC;
```

**Svrha pogleda:**<br/>
&emsp;Pogled služi za pregled odrađenih treninga po poslovnicama u proteklih mjesec dana, a može biti koristan za uvid u rad pojedinih centara, planiranju nekakvih posebnih ponuda i popusta u centrima koji imaju puno aktivnih članova, ili pri podjeli nagrada najuspješnijim centrima i zaposlenicima.

**Opis pogleda:**<br/>
&emsp;Najprije se koristeći naredbu JOIN povezuju tablice *termin_treninga* i *prostorija* putem primarnog ključa tablice *prostorija*, a zatim se dobivenu tablicu također povezuje sa tablicom *podruznica* putem primarnog ključa tablice *podruznica*. Sljedeće se vrši filtriranje dobivene izvedene tablice na način da se izdvoji samo odrađene treninge unatrag mjesec dana, ne računajući one koji se možda trenutno izvode. Korištenjem naredbe GROUP BY rezultirajuća tablica se potom grupira prema atributu *id* tablice *podruznica* i kao rezultat vraća se atribut *naziv* za svaku od podružnica te atribut *odradeno_treninga* kojeg dobivamo korištenjem agregacijske funkcije COUNT prilikom grupiranja. Dobiveni rezultat se na kraju još sortira silazno prema atributu *odradeno_treninga* korištenjem naredbe ORDER BY i ključne riječi DESC, a definirani upit sprema se u pogled naziva *proteklih_mjesec_treninga_po_podruznicama*.

## 10 trenera s najviše otkazanih termina

```sql
CREATE VIEW vw_treneri_s_najvise_otkazivanja AS
SELECT 	  z.id,
		  z.ime,
          z.prezime,
		  COUNT(*) AS broj_otkazanih
FROM 	  (SELECT *
		   FROM   zaposlenik
           WHERE  id_radno_mjesto = 1
           AND    status_zaposlenika = 'aktivan') AS z
LEFT JOIN (SELECT *
		   FROM   termin_treninga
           WHERE  otkazan IS TRUE) AS ot ON z.id = ot.trener_id
GROUP BY  z.id
ORDER BY  broj_otkazanih DESC
LIMIT 	  10;
```

**Svrha pogleda:**<br/>
&emsp;Pogled služi za pregled trenera s najviše otkazanih termina treninga, a može biti koristan kako bi se pravovremeno primjetilo ako neki trener ima znatno više otkazanih termina od ostalih i reagiralo s ciljem rješavanja potencijalnih problema i zadržavanja kvalitetnih trenera, ili eliminiranje nekvalitetnih.

**Opis pogleda:**<br/>
&emsp;Korištenjem podupita najprije se iz tablice *zaposlenik* filtriraju svi aktivni treneri, a drugim podupitom se iz tablice *termin_treninga* filtriraju svi otkazani termini. Rezultirajuće tablice *z* i *ot* se potom povezuje putem primarnog ključa tablice *zaposlenik* prilikom čega se koristi naredba LEFT JOIN kako bi se zadržali svi zapisi iz lijeve tablice te se na taj način zadržava sve zaposlenike uključujući i one koji nisu imali otkazanih termina. Dobivenu tablicu se zatim grupira korištenjem naredbe GROUP BY nad atributom *id* tablice *z* pri čemu se kao rezultat dobiva tablicu s atributima *id*, *ime* i *prezime* koji predstavljaju id, ime i prezime zaposlenika, te atribut *broj_otkazanih* koji je dobiven primjenom agregacijske funkcije COUNT prilikom grupiranja, a prikazuje broj otkazanih treninga za svakog zaposlenika. Dobivene rezultate se na kraju još sortira silazno prema atributu *broj_otkazanih* korištenjem naredbe ORDER BY i ključne riječi DESC te se korištenjem naredbe LIMIT u krajnji rezultat uzima samo prvih 10 n-torki tablice. Definirani upit sprema se u pogled naziva *treneri_s_najvise_otkazivanja*.

## Centri koji nude sve tipove prostorija

```sql
CREATE VIEW vw_podruznice_s_svim_sadrzajima AS
SELECT	 po.naziv,
		 po.adresa,
         m.postanski_broj
FROM	 prostorija pr
JOIN	 podruznica po ON pr.podruznica_id = po.id
JOIN	 mjesto m ON po.id_mjesto = m.id
GROUP BY po.id
HAVING	 COUNT(DISTINCT tip_prostorije_id) = (SELECT COUNT(*) FROM tip_prostorije);
```

**Svrha pogleda:**<br/>
&emsp;Pogled služi za brzi pregled popisa centara koji nude sve tipove prostorija što ujedno znači da nude najviše sadržaja, to može biti korisno za uvid u najrazvijenije centre čime ujedno znamo i ostale centre na kojima se može poraditi da dođu do te razine, a također može biti korisno za smještaj neki profesionalnih fitness grupa i ekipa koje zahtijevaju više različitih sadržaja radi bolje kvalitete treniranja i održavanja forme.

**Opis pogleda:**<br/>
&emsp;Najprije se koristeći naredbu JOIN povezuju tablice *prostorija* i *podruznica* putem primarnog ključa tablice *podruznica*, a zatim se dobivenu tablicu također povezuje sa tablicom *mjesto* putem primarnog ključa tablice *mjesto*. Dobivenu tablicu se zatim grupira korištenjem naredbe GROUP BY nad atributom *id* tablice *podruznica* nakon čega se razultate filtrira korištenjem naredbe HAVING na način da se obzir uzima samo podružnice koje sadrže sve tipove prostorija. Navedeno se postiže tako što se korištenjem agragacijske funkcije COUNT i ključne riječi DISTINCT za svaku podružnicu prebrojava broj različitih vrijednosti unutar atributa *tip_prostorije_id*, a potom se provjerava je li dobiveni broj isti ukupnom broju zapisa unutar tablice *tip_prostorije* kojeg se također dobiva korištenjem funkcije COUNT. Kao krajnji rezultat dobiva se tablicu sa atributima *naziv*, *adresa* i *postanski_broj* unutar koje su zapisane sve podružnice koje nude sve tipove prostorija, a definirani upit sprema se u pogled naziva *podruznice_s_svim_sadrzajima*.

## Pregled broja rezervacija po treningu za nadolazećih mjesec dana

```sql
CREATE VIEW vw_nadolazece_rezervacije_po_treningu AS
SELECT	  prg.naziv AS tip_programa,
          tr.razina AS razina_treninga,
          CONCAT(z.ime, ' ', z.prezime) AS trener,
          prs.oznaka AS prostorija,
          prs.podruznica_id AS podruznica,
          tt.vrijeme_pocetka,
          tt.vrijeme_zavrsetka,
          tt.napomena,
          COUNT(*) AS broj_rezervacija
FROM 	  termin_treninga tt
LEFT JOIN rezervacija r ON tt.id = r.termin_treninga_id
JOIN 	  trening tr ON tt.trening_id = tr.id
JOIN 	  program prg ON tr.program_id = prg.id
JOIN 	  zaposlenik z ON tt.trener_id = z.id
JOIN	  prostorija prs ON tt.prostorija_id = prs.id
WHERE 	  tt.vrijeme_pocetka BETWEEN CURRENT_TIMESTAMP() AND CURRENT_TIMESTAMP() + INTERVAL 1 MONTH
AND 	  tt.otkazan IS FALSE
GROUP BY  tt.id;
```

**Svrha pogleda:**<br/>
&emsp;Pogled služi za pregled broja rezervacija po treningu za nadolazećih mjesec dana, a to može biti korisno za praćenje i analizu strukture članova i razvoja trendova, a to može pomoći u pravovremenoj organizaciji budućih treninga, prostorija, popusta i sličnog.

**Opis pogleda:**<br/>
&emsp;Najprije se koristeći naredbu LEFT JOIN povezuju tablice *termin_treninga* i *rezervacija* putem primarnog ključa tablice *termin_treninga* pri čemu se zadržavaju i termini treninga koji nemaju rezervacija. Zatim se koristeći naredbu JOIN povezuje dobivenu tablicu sa tablicom *trening* putem primarnog ključa tablice *trening*, potom se dobivenu tablicu povezuje sa tablicom *program* putem primarnog ključa tablice *program*, pa se dobivenu tablicu povezuje sa tablicom *zaposlenik* putem primarnog ključa tablice *zaposlenik*, i na kraju se dobivenu tablicu povezuje sa tablicom *prostorija* putem primarnog ključa tablice *prostorija*. Rezultirajuću tablicu svih spajanja se zatim filtrira korištenjem operatora BETWEEN pri čemu se provjerava je li vrijednost atributa *vrijeme_pocetka* između trenutnog vremena i vremena za mjesec dana od sada, a u obzir se uzimaju samo termini treninga koji nisu otkazani. Filtriranu tablicu se zatim grupira korištenjem naredbe GROUP BY nad atributom *id* tablice *termin_treninga* nakon čega se kao rezultat dobiva tablica s atributima *tip_programa*, *razina_treninga*, *trener*, *prostorija*, *podruznica*, *vrijeme_pocetka*, *vrijeme_zavrsetka*, *napomena* i *broj_rezervacija*. Valja napomenuti kako su većina tih atributa zapravo preimenovani atributi tablica koje su se spajale, atribut *trener* dobiven je spajanjem atributa *ime* i *prezime* tablice *zaposlenik* pomoću funkcije CONCAT za svaku n-torku, dok je atribut *broj_rezervacija* dobiven korištenjem agregacijske funkcije COUNT tj. prebrojavanjem rezervacija za svaki termin treninga prilikom grupiranja. Definirani upit sprema se u pogled naziva *nadolazece_rezervacije_po_treningu*.

## Pregled broja etaža po podružnicama

```sql
CREATE VIEW vw_etaze_po_podruznicama AS
SELECT 	 po.naziv,
		 po.adresa,
		 COUNT(DISTINCT IF(lokacija LIKE '%,%', LEFT(lokacija, LOCATE(',', lokacija) - 1), lokacija)) AS broj_etaza
FROM   	 prostorija pr
JOIN   	 podruznica po on pr.podruznica_id = po.id
WHERE 	 lokacija <> 'Vani'
GROUP BY po.id;
```

**Svrha pogleda:**<br/>
&emsp;Pogled služi za pregled broja etaža svake pojedine podružnice što može biti korisno pri predviđanju troškova održavanja pojedinog fitness centra ili za grubu procjenu veličine i kapaciteta nekog centra.

**Opis pogleda:**<br/>
&emsp;Najprije se koristeći naredbu JOIN povezuju tablice *prostorija* i *podruznica* putem primarnog ključa tablice *podruznica*, iz dobivene tablice se potom filtriraju sve n-torke kojima je vrijednost atributa *lokacija* različita od vrijednosti *'Vani'* (pošto se navedena vrijednost ne može smatrati kao etaža). Dobivenu tablicu se zatim grupira korištenjem naredbe GROUP BY nad atributom *id* tablice *podruznica* nakon čega se dobiva rezultirajuću tablicu koja se sastoji od atributa *naziv* i *adresa* tablice *podruznica*, te atributa *broj_etaza*. Atribut *broj_etaza* dobiva se tako da se prilikom grupiranja koristi IF funkcija kako bi se provjerila svaka vrijednost unutar atributa *lokacija* i ukoliko ne sadrži zarez tada se ju ostavlja takavom kakva je, ali ukoliko vrijednost sadrži zarez tada se vrijednost zamijenjuje s vrijednošću upisanom do zareza. Navedena vrijednost dobiva se na način da se korištenjem funkcije LOCATE dobiva pozicija tog zareza koja se potom umanjuje za 1 kako bi se dobila pozicija zadnjeg znaka prije zareza te se na kraju koristeći funkciju LEFT uzima sve znakove s lijeva na desno do zareza tj. do dobivene pozicije zadnjeg znaka prije zareza uključno s tim znakom. Na kraju se korištenjem agragacijske funkcije COUNT i ključne riječi DISTINCT prebrojava jedinstvene vrijednosti atributa *lokacija* za svaku od podružnica. Definirani upit sprema se u pogled naziva *etaze_po_podruznicama*.

# FUNKCIJE

## Funkcija koja provjerava preklapanje termina za trenere i rezervacija za članove

```sql
CREATE FUNCTION fn_slobodan_termin(p_id_osoba INTEGER, p_uloga ENUM('c', 't'), p_vrijeme_pocetka TIMESTAMP, p_vrijeme_zavrsetka TIMESTAMP) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
	DECLARE v_rez BOOLEAN;
    
    IF p_uloga = 'c' THEN
		SELECT NOT EXISTS (
			SELECT 1
			FROM   rezervacija r
			JOIN   termin_treninga tt ON r.termin_treninga_id = tt.id
			WHERE  r.clan_id = p_id_osoba
            AND    tt.vrijeme_pocetka > CURRENT_TIMESTAMP()
			AND    p_vrijeme_pocetka <= tt.vrijeme_zavrsetka
			AND    p_vrijeme_zavrsetka >= tt.vrijeme_pocetka
		) INTO v_rez;
	ELSE
		SELECT NOT EXISTS (
			SELECT 1
			FROM   termin_treninga tt
			WHERE  tt.trener_id = p_id_osoba
            AND    tt.vrijeme_pocetka > CURRENT_TIMESTAMP()
			AND    p_vrijeme_pocetka <= tt.vrijeme_zavrsetka
			AND    p_vrijeme_zavrsetka >= tt.vrijeme_pocetka
		) INTO v_rez;
	END IF;
    
    RETURN v_rez;
END //
```

**Svrha funkcije:**<br/>
&emsp;Funkcija služi za provjeru je li osoba slobodna u određenom terminu ili osoba već ima zakazan termin treninga, ili rezerviran termin treninga, koji se preklapa s unesenim.

**Parametri:**<br/>
- p_id_osoba - podatak tipa INTEGER koji definira *id* osobe za koju se provjerava termin
- p_uloga - podatak zipa ENUM koji prima jednu od dvije moguće ulazne vrijednosti, *'c'* ukoliko se radi o članu i *'t'* ukoliko se radi o treneru
- p_vrijeme_pocetka - podatak tipa TIMESTAMP koji definira početno vrijeme termina koji se provjerava
- p_vrijeme_zavrsetka - podatak tipa TIMESTAMP koji definira vrijeme kraja termina koji se provjerava

**Povratna vrijednost:**<br/>
&emsp;Povratna vrijednost je tipa BOOLEAN, a iznosi 0 (FALSE) ukoliko osoba ima već zakazanih termina koji se preklapaju s unesenim vremenskim rasponom, odnosno 1 (TRUE) ukoliko je osoba slobodna u tom vremenskom rasponu.

**Opis funkcije:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklarira varijabla *v_rez* tipa BOOLEAN u koju će se spremiti rezultat. Zatim se pomoću IF-ELSE grananja provjerava koja je vrijednost zapisana u parametru *p_uloga*, ukoliko se radi o vrijednosti *'c'* znači da se provjerava preklapanje termina treninga kojeg neki član želi rezervirati, inače ukoliko se radi o vrijednosti *'t'* znači da se provjerava preklapanje novog termina treninga kojeg unosi neki trener.<br/>
&emsp;Ukoliko se radi o članu izvršava se upit unutar kojeg se najprije koristeći naredbu JOIN povezuje tablica *rezervacija* sa tablicom *termin_treninga* putem primarnog ključa tablice *termin_treninga*, a potom se filtriraju samo nadolazeći termini treninga gdje je atribut *clan_id* tablice *rezervacija* jednak parametru *p_id_osoba* te koji završavaju nakon što uneseni termin počne i počinju prije nego uneseni termin završi, zatim se za svaki takav termin upisuje broj 1 kako bi se evidentiralo njegovo postojanje. Nad tom rezultirajućom tablicom na kraju se pomoću operatora EXISTS provjerava postoji li neki zapis i ukoliko postoji znači da postoji preklapanje, ali ukoliko ne postoji preklapanje tada EXISTS vraća 0 (FLASE) te se iz tog razloga koristi logička operacija NOT koja vraća 1 (TRUE) ukoliko ne postoji preklapanje tj. ukoliko je termin slobodan.<br/>
&emsp;Ukoliko se radi o treneru izvršava se upit unutar kojeg se iz tablice *termin_treninga* najprije filtriraju samo nadolazeći termini treninga gdje je atribut *trener_id* tablice *termin_treninga* jednak parametru *p_id_osoba* te koji završavaju nakon što uneseni termin počne i počinju prije nego uneseni termin završi, zatim se za svaki takav termin upisuje broj 1 kako bi se evidentiralo njegovo postojanje. Nad tom rezultirajućom tablicom na kraju se pomoću operatora EXISTS provjerava postoji li neki zapis i ukoliko postoji znači da postoji preklapanje, ali ukoliko ne postoji preklapanje tada EXISTS vraća 0 (FLASE) te se iz tog razloga koristi logička operacija NOT koja vraća 1 (TRUE) ukoliko ne postoji preklapanje tj. ukoliko je termin slobodan.<br/>
&emsp;Svaki od navedenih upita unutar pojedinog grananja kao rezultat vraća BOOLEAN vrijednost koja se korištenjem ključne riječi INTO potom sprema u varijablu *v_rez* te funkcija na kraju vraća vrijednost te vrijable.

## Funkcija koja vraća prvi slobodni termin unutar tjedan dana za pet dana od sada

```sql
CREATE FUNCTION fn_prvi_slobodan_termin(p_trener_id INTEGER, p_trening_id INTEGER) RETURNS TIMESTAMP
DETERMINISTIC
BEGIN
	DECLARE v_rubno_vrijeme TIMESTAMP DEFAULT CURRENT_DATE() + INTERVAL 5 DAY + INTERVAL 8 HOUR;
    DECLARE v_rez TIMESTAMP DEFAULT NULL;
	DECLARE v_vrijeme_pocetka, v_vrijeme_zavrsetka TIMESTAMP;
    DECLARE v_trajanje_treninga_min INTEGER;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
		SELECT vrijeme_pocetka,
			   vrijeme_zavrsetka
		FROM   termin_treninga
		WHERE  trener_id = p_trener_id
		AND    vrijeme_pocetka BETWEEN v_rubno_vrijeme
								   AND v_rubno_vrijeme + INTERVAL 7 DAY;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
	IF NOT EXISTS (
		SELECT 1
		FROM   zaposlenik
		WHERE  id = p_trener_id
		AND    id_radno_mjesto = 1
		AND    status_zaposlenika = 'aktivan') THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Došlo je do greške: uneseni \'id\' trenera ne postoji ili više nije aktivan.';
	ELSE
        SELECT planirano_trajanje_min
        INTO   v_trajanje_treninga_min
        FROM   trening
        WHERE  id = p_trening_id;
		
        OPEN cur;
		petlja: LOOP
			FETCH cur INTO v_vrijeme_pocetka, v_vrijeme_zavrsetka;
			
			IF (v_rez <> NULL) OR done THEN
				LEAVE petlja;
			END IF;
			
			IF TIMESTAMPDIFF(MINUTE, v_rubno_vrijeme, v_vrijeme_pocetka) >= v_trajanje_treninga_min + 30 THEN
				IF v_rubno_vrijeme + INTERVAL (v_trajanje_treninga_min + 30) MINUTE > DATE(v_rubno_vrijeme) + INTERVAL 22 HOUR THEN
					SET v_rubno_vrijeme = DATE(v_rubno_vrijeme) + INTERVAL 1 DAY + INTERVAL 8 HOUR;
				ELSE
					SET v_rez = v_rubno_vrijeme + INTERVAL 15 MINUTE;
				END IF;
			ELSE
				SET v_rubno_vrijeme = v_vrijeme_zavrsetka;
			END IF;
		END LOOP petlja;
		CLOSE cur;
	END IF;
	
    RETURN v_rez;
END //
```

**Svrha funkcije:**<br/>
&emsp;Funkcija služi sa pronalazak prvog slobodnog termina za određenog trenera i određeni trening, uzimajući u obzir da termini mogu biti zakazani između 8 i 22 sata, uzimajući u obzir da treneru treba 15 minuta odmora između treninga, te provjeravajući samo period od 7 dana počevši  5 dana od trenutka kada je funkcija pozvana kako bi članovi imali vremena za se organizirati i rezervirati termin.

**Parametri:**<br/>
- p_trener_id - podatak tipa INTEGER koji definira *id* trenera za kojeg se traži slobodan termin
- p_trening_id - podatak tipa INTEGER koji definira *id* treninga za kojeg se traži slobodan termin

**Povratna vrijednost:**<br/>
&emsp;Povratna vrijednost je tipa TIMESTAMP, a predstavlja vrijeme kada se može zakazati početak termina.

**Opis funkcije:**<br/>
&emsp;Na početku funkcije deklariraju se varijable koje se koriste kroz samu funkciju:
- *v_rubno_vrijeme* - varijabla tipa TIMESTAMP koja predstavlja vrijeme koje označava početak 7-dnevnog perioda koji se razmatra, postavljenja na početnu vrijednost u 8 ujutro za 5 dana od dana kada se provjerava pošto se trenzi počinju održavati tek od 8 sati ujutro
- *v_rez* - varijabla tipa TIMESTAMP u koju se pohranjuje rezultat (povratna vrijednost), postavljena na početnu vrijednost NULL
- *v_vrijeme_pocetka* - varijabla tipa TIMESTAMP u koju se pohranjuje vrijeme početka postojećih termina treninga
- *v_vrijeme_zavrsetka* - varijabla tipa TIMESTAMP u koju se pohranjuje vrijeme završetka postojećih termina treninga
- *v_trajanje_treninga_min* - varijabla tipa INTEGER u koju se pohranjuje trajanje treninga za kojeg se traži slobodan termin
- *done* - varijabla tipa BOOLEAN kojom se kontrolira izlazak iz petlje kada ponestane vrijednosti u kursoru, postavljena na početnu vrijednost FALSE

&emsp;Sljedeće se deklarira kursor *cur* u kojeg se spremaju svi zakazani termini treninga za trenera definiranog parametrom *p_trener_id* koji započinju unutar 7-dnevnog perioda koji se razmatra. Navedeno se postiže filtriranjem n-torki unutar tablice *termin_treninga* koje imaju vrijednost atributa *trener_id* jednaku vrijednosti atributa *p_trener_id* te koje imaju vrijednost atributa *vrijeme_pocetka* između početnog vremena razmatranja pohranjenog u varijabli *v_rubno_vrijeme* i krajnjeg vremena u razmaku od sedam dana. Navedna provjera atributa *vrijeme_pocetka* izvodi se korištenjem operatora BETWEEN i operatora INTERVAL. Također deklarira se i CONTINUE HANDLER FOR NOT FOUND koji se aktivira prilikom čitanja nepostojeće vrijednosti kursora te postavlja vrijednost varijable *done* na TRUE i dozvolja funkciji da nastavi s izvršavanjem.<br/>
&emsp;Funkcija potom ulazi u IF-ELSE grananje unutar kojeg se korištenjem logičke operacije NOT i operatora EXISTS provjera postoji li u tablici *zaposlenik* aktivan trener s vrijednošću atributa *id* istom kao što je i vrijednost dana parametrom *p_trener_id*, ukoliko takav trener ne postoji podiže se korisnički definirana greška koja javlja kako traženi trener ne postoji ili više nije aktivan te funkcija prekida s izvođenjem. Ukoliko trener postoji najprije se u varijablu *v_trajanje_treninga_min* sprema trajanje predanog treninga tako što se iz tablice *trening* filtrira n-torka gdje je vrijednost atributa *id* jednaka vrijednosti parametra *p_trening_id* te se iščitava vrijednost pohranjena u atributu *planirano_trajanje_min*.<br/>
&emsp;Zatim se otvara kursor *cur* te se pokreće petlja naziva *petlja* kojom se prolazi kroz sve zapise kursora. Prilikom svake itericije najprije se iščitavaju vrijednosti kursora u varijable *v_vrijeme_pocetka* i *v_vrijeme_zavrsetka*. Zatim se provjerava ako je pronađen neki slobodan termin i pohranjen u varijablu *v_rez* ili ako su isčitani svi zapisi kusora, ukoliko bar jedno od navedenih istinito petlja se prekida. Potom se unutar IF-ELSE grananja koristi funkcija TIMESTAMPDIFF kako bi se provjerilo je li vremenski raspon u minutama između vrijednosti varijabli *v_rubno_vrijeme* i *v_vrijeme_pocetka* veći ili jednak trajanju treninga uvećanom za 30 minuta koliko iznosi zbroj odmora prije i poslije treninga, ukoliko je vremenski raspon manji postavlja se vrijednost varijable *v_rubno_vrijeme* na vrijednost varijable *v_vrijeme_zavrsetka* te se nastavlja s iščitavanjem vrijednosti iz kursora. U slučaju da vremenski raspon zadovoljava ubacivanje termina treninga ulazi se u IF-ELSE grananje gdje se provjerava radi li se možda o kraju dana i prelazi li trajanje treninga s odmorima granicu od 22 sata navečer, ukoliko prelazi postavlja se vrijednost varijable *v_rubno_vrijeme* na 8 sati ujutro idućeg dana, a ukoliko ne prelazi tada se vrijednost varijable *v_rez* postavlja na na vrijednost varijable *v_rubno_vrijeme* uvećane za 15 minuta pomoću operatora INTERVAL čime se uključuje vrijeme za odmor i pripremu prije treninga. Nakon što funkcija izađe iz kursora vraća vrijednost varijable *v_rez* koja sadržava podatak tipa TIMESTAMP ukoliko je pronađeno vrijeme za ubacivanje termina, ili NULL ukoliko nije pronađeno.

## Funkcija koja za danu podružnicu vraća postotak prošlih termina koji nisu imali niti jednu rezervaciju

```sql
CREATE FUNCTION fn_termina_bez_rezervacije(p_podruznica_id INTEGER) RETURNS VARCHAR(4)
DETERMINISTIC
BEGIN
	DECLARE v_ukupno_termina, v_ukupno_bez_rezervacije INTEGER;
    
    DROP TEMPORARY TABLE IF EXISTS prosli_termini;
    CREATE TEMPORARY TABLE prosli_termini (
        broj_rezervacija INTEGER
	);
    
    INSERT INTO prosli_termini
		SELECT tt.rezervirano
		FROM   termin_treninga tt
		JOIN   prostorija p ON tt.prostorija_id = p.id
		WHERE  p.podruznica_id = p_podruznica_id
		AND    vrijeme_zavrsetka < CURRENT_TIMESTAMP();
    
    SELECT COUNT(*)
    INTO   v_ukupno_termina
    FROM   prosli_termini;
    
    IF NOT v_ukupno_termina THEN
		RETURN '0%';
	END IF;
    
    SELECT COUNT(*)
    INTO   v_ukupno_bez_rezervacije
    FROM   prosli_termini 
    WHERE  broj_rezervacija = 0;
    
    RETURN CONCAT(ROUND(v_ukupno_bez_rezervacije/v_ukupno_termina*100, 0), '%');
END //
```

**Svrha funkcije:**<br/>
&emsp;Funkcija služi za pregled udijela prošlih termina neke podružnice koji nisu imali zakazanu niti jednu rezervaciju, navedeno može biti korisno za uvid u rad pojedine podružnice te praćenje aktivnosti i interesa njezinih članova.

**Parametri:**<br/>
- p_podruznica_id - podatak tipa INTEGER koji definira *id* podružnice za koju se radi pregled prošlih termina

**Povratna vrijednost:**<br/>
&emsp;Povratna vrijednost je tipa VARCHAR veličine 4, a predstavlja postotak koji funkcija vraća zajedno sa pripadajućim simbolom postotka (%) pri čemu je najveća/najdulja moguća vrijednost *'100%'*.

**Opis funkcije:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklariraju varijable *v_ukupno_termina* i *v_ukupno_bez_rezervacije* tipa INTEGER u koje će se spremiti međurezultati. Nakon toga se kreira privremena tablica *prosli_termini* koja se sastoji od atributa *broj_rezervacija* unutar koje će se spremiti svi prošli termini neke podružnice čime se pohranjuje snapshot podataka u trenutku izvođenja te se na taj način izbjegava ponavljanje upita, a također se i osigurava nepromjenjivost podataka i brži pristup podacima prilikom daljnje obrade.<br/>
&emsp;Nakon kreiranja privremene tablice, korištenjem naredbe INSERT i ključne riječi INTO unosi se podatke u samu tablicu, podaci za unos su rezultat upita unutar kojega se najprije korištenjem naredbe JOIN spajaju tablice *termin_treninga* i *prostorija* putem primarnog ključa tablice *prostorija*, a zatim se filtriraju sve n-torke kojima je vrijednost atributa *podruznica_id* jednaka vrijednosti parametra *p_podruznica_id* i kojima je vrijednost atributa *vrijeme_zavrsetka* manja od trenutnog vremena te se kao rezultat vraća vrijednosti dobivene u atributu *rezervirano*. Sljedeće se korištenjem agregacijske funkcije COUNT prebrojava ukupan broj n-torki u tablici *prosli_termini* te se rezultat sprema u varijablu *v_ukupno_termina* koristeći ključnu riječ INTO. Dobivena vrijednost varijable *v_ukupno_termina* se potom provjerava korištenjem IF grananja i ukoliko iznosi 0 tada se odmah vraća *'0%'* pošto ako nema termina nema ni otkazanih termina ni daljnjeg izračuna. Nakon toga se unutar upita filtriraju sve n-torke unutar tablice *prosli_termini* kojima je vrijednost atributa *broj_rezervacija* jednaka 0, a dobivene rezultate se potom prebrojava korištenjem funkcije COUNT i sprema u varijablu *v_ukupno_bez_rezervacije* korištenjem ključne riječi INTO. Na kraju se vrijednost varijable *v_ukupno_bez_rezervacije* dijeli s vrijednošću varijable *v_ukupno_termina*, rezultat dijeljenja se potom množi sa 100 i zaokružuje na cijeli broj pomoću funkcije ROUND, te se korištenjem funkcije CONCAT spaja s simbolom postotka pri čemu se dobiva povratna vrijednost funkcije. 

# PROCEDURE

## Procedura koja raspodjeljuje nadolazeće termine treninga nekog trenera

```sql
CREATE PROCEDURE sp_raspodijeli_termine(IN p_trener_id INTEGER)
BEGIN
    DECLARE v_trener_id, v_podruznica_id, v_termin_treninga_id INTEGER;
    DECLARE v_vrijeme_pocetka_termina, v_vrijeme_zavrsetka_termina TIMESTAMP;
    DECLARE v_autocommit BOOLEAN;
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE cur CURSOR FOR
		SELECT id,
			   vrijeme_pocetka,
               vrijeme_zavrsetka
        FROM   termin_treninga
        WHERE  trener_id = p_trener_id
        AND    vrijeme_pocetka > CURRENT_TIMESTAMP();
	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET done = TRUE;
    DECLARE EXIT HANDLER FOR 1644 
		SELECT 'Došlo je do greške: ne postoji trener s unesenim \'id\'-jem.' AS PORUKA_GRESKE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
            SET AUTOCOMMIT = v_autocommit;
            SELECT 'Došlo je do greške: procedura \'raspodijeli_termine\' je prisilno zaustavljena, a sve promjene su poništene.' AS PORUKA_GRESKE;
		END;
    
    SET v_autocommit = @@autocommit;
    
	IF NOT EXISTS (
		SELECT 1
		FROM   zaposlenik
		WHERE  id = p_trener_id
		AND    id_radno_mjesto = 1) THEN
			SIGNAL SQLSTATE '45001';
	END IF;
    
    SELECT id_podruznica
    INTO   v_podruznica_id
    FROM   zaposlenik
    WHERE  id = p_trener_id;
    
	DROP TEMPORARY TABLE IF EXISTS termini_trenera;
	CREATE TEMPORARY TABLE termini_trenera (
		trener_id INTEGER,
        broj_termina INTEGER,
        
        PRIMARY KEY (trener_id)
	);
    
    INSERT INTO termini_trenera
		SELECT     	t.id, COUNT(tt.id)
        FROM	   	termin_treninga tt
        RIGHT JOIN (SELECT id
					FROM   zaposlenik
                    WHERE  id <> p_trener_id
                    AND    id_radno_mjesto = 1
                    AND    id_podruznica = v_podruznica_id
                    AND    status_zaposlenika = 'aktivan') AS t ON tt.trener_id = t.id
		WHERE 		vrijeme_pocetka > CURRENT_TIMESTAMP()
		GROUP BY   	t.id;
	
    OPEN cur;
    SET AUTOCOMMIT = OFF;
	petlja: LOOP
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
		START TRANSACTION;
		FETCH cur INTO v_termin_treninga_id, v_vrijeme_pocetka_termina, v_vrijeme_zavrsetka_termina;
        
        IF done THEN
			LEAVE petlja;
		END IF;
        
        SELECT	 trener_id
        INTO	 v_trener_id
        FROM	 termini_trenera
        WHERE	 trener_id NOT IN  (SELECT DISTINCT trener_id
									FROM   termin_treninga
									WHERE  v_vrijeme_pocetka_termina <= vrijeme_zavrsetka
									AND    v_vrijeme_zavrsetka_termina >= vrijeme_pocetka)
		ORDER BY broj_termina ASC
        LIMIT    1;
        
        IF v_trener_id IS NULL THEN
			UPDATE termin_treninga
            SET    otkazan = TRUE
            WHERE  termin_treninga.id = v_termin_treninga_id;
		ELSE
			UPDATE termin_treninga
            SET    trener_id = v_trener_id
            WHERE  termin_treninga.id = v_termin_treninga_id;
            
            UPDATE termini_trenera
            SET    broj_termina = broj_termina + 1
            WHERE  trener_id = v_trener_id;
		END IF;
		COMMIT;
    END LOOP petlja;
    SET AUTOCOMMIT = v_autocommit;
    CLOSE cur;
END //
```

**Svrha procedure:**<br/>
&emsp;Procedura služi za automatsku raspodjelu svih termina nekog trenera na ostale trenere pri čemu pazi da je trener slobodan u tom vremenu kada se odvija termin koji mu se dodjeljuje, a ukoliko ne postoji trener koji je slobodan u tom terminu tada se termin otkazuje. Također valja napomenuti kako procedura raspodjeljuje termine najprije na trenere koji su najmanje opterećeni treninzima, a ista može biti korisna prilikom iznenadnog odlaska nekog trenera bilo radi promjene radnog mjesta, godišnjeg odmora, bolovanja i slično.

**Parametri:**<br/>
- p_trener_id - ulazni parametar, podatak tipa INTEGER koji definira *id* trenera za kojeg se vrši preraspodijela termina

**Opis procedure:**<br/>
&emsp;Proceduru je prvotno pokretao trigger, ali zbog toga što se za svaki nadolazeći termin trenera pregledavaju i vrše usporedbe sa svim nadolazećim terminima odlučio sam ju maknuti iz triggera kako trajanje izvođenja triggera nebi utjecalo na performanse baze podataka. Procedura i dalje može imati znatan utjecaj na bazu podataka ako obrađuje veliku količinu podataka ali ovako barem imamo kontrolu kada želimo da se ista izvršava pa se samim time može odrediti da se procedura pokreće izvan aktivnih sati rada centara.<br/>
&emsp;Procedura započinje deklaracijom varijabli koje se koriste tokom daljnjeg izvršavanja, a to su:
- *v_trener_id* - varijabla tipa INTEGER u koju se pohranjuje id trenera koji je slobodan u traženom terminu
- *v_podruznica_id* - varijabla tipa INTEGER u koju se pohranjuje id podružnice u kojoj su treninzi zakazani
- *v_termin_treninga_id* - varijabla tipa INTEGER u koju se pohranjuje id treninga za kojeg se traži slobodan termin
- *v_vrijeme_pocetka_termina* - varijabla tipa TIMESTAMP u koju se pohranjuje vrijeme početka pojedinog treninga koji se raspodjeljuje
- *v_vrijeme_zavrsetka_termina* - varijabla tipa TIMESTAMP u koju se pohranjuje vrijeme završetka pojedinog treninga koji se raspodjeljuje
- v_autocommit - varijabla tipa BOOLEAN u koju se pohranjuje vrijednost/stanje autocommit postavke na početku procedure
- *done* - varijabla tipa BOOLEAN kojom se kontrolira izlazak iz petlje kada ponestane vrijednosti u kursoru, postavljena na početnu vrijednost FALSE

&emsp;Sljedeće se deklarira kursor *cur* u kojeg se spremaju svi nadolazeći zakazani termini treninga za trenera definiranog parametrom *p_trener_id*. Navedeno se postiže filtriranjem n-torki unutar tablice *termin_treninga* koje imaju vrijednost atributa *trener_id* jednaku vrijednosti atributa *p_trener_id* te koje imaju vrijednost atributa *vrijeme_pocetka* veću od trenutnog vremena kojeg dobivamo korištenjem funkcije CURRENT_TIMESTAMP. Deklarira se i CONTINUE HANDLER FOR NOT FOUND koji se aktivira prilikom čitanja nepostojeće vrijednosti kursora te postavlja vrijednost varijable *done* na TRUE i dozvolja proceduri da nastavi s izvršavanjem. Također se deklariraju i dva EXIT HANDLER-a, prvi FOR 1644 koji se aktivira za definiranu korisnički definiranu grešku te vraća poruku o neispravnom id-ju trenera, a drugi FOR SQLEXCEPTION koji se aktivira ukoliko dođe do bilo kakve druge greške prilikom izvođenja procedure i transakcije te izvršava naredbu ROLLBACK kojom poništava sve promjene napravljene unutar transakcije, također izvršava i naredbu SET kojom postavlja vrijednost sistemske varijable AUTOCOMMIT na početno stanje spremljeno u varijabli *v_autocommit*, te vraća poruku o grešci.<br/>
&emsp;Nakon dekalracijskog dijela procedure najprije se pomoću naredbe SET postavlja vrijednost varijable *v_autocommit* na vrijednost systemske varijable *@@autocommit* kako bi se pohranila vrijednost te varijable pošto će se kasnije izmjeniti prije ulaska u transakciju. Procedura potom ulazi u IF-ELSE grananje unutar kojeg se korištenjem logičke operacije NOT i operatora EXISTS provjerava postoji li u tablici *zaposlenik*  trener s vrijednošću atributa *id* istom kao što je i vrijednost dana parametrom *p_trener_id*, ukoliko takav trener ne postoji podiže se korisnički definirana greška koja aktivira EXIT HANDLER te procedura prekida s izvođenjem. Ukoliko trener postoji najprije se u varijablu *v_podruznica_id* sprema id podružnice u kojoj je trner zaposlen i u kojoj su treninzi zakazani, navedeno se radi tako što se iz tablice *zaposlenik* filtrira n-torka gdje je vrijednost atributa *id* jednaka vrijednosti parametra *p_trener_id* te se iščitava vrijednost pohranjena u atributu *id_podruznica*. Potom se kreira privremena tablica *termini_trenera* koja se sastoji od atributa *trener_id* i *broj_termina* unutar kojih će se spremiti svi svi treneri koji su zaposleni u istoj podružnici kao i trener čiji trenezi se raspodjeljuju zajedno s ukupnim brojem nadolazećih termina treninga koje svaki od njih ima zakazano. Atribut *trener_id* se također postavlja i kao primarni ključ tablice *termini_trenera* kako bi se kasnije izbjegla ograničenja SAFE_MODE-a MySQL Workbencha. Korištenjem primarne tablice pohranjuje se snapshot podataka u trenutku izvođenja te se na taj način izbjegava višestruko ponavljanje upita i osigurava brži pristup podacima prilikom daljnje obrade.<br/>
&emsp;Nakon pokretanja transakcije koristi se INSERT i ključna riječ INTO kako bi se unijelo podatke tablicu *termini_trenera*, podaci za unos su rezultat upita unutar kojega se najprije izvšava podupit kako si se iz tablice *zaposlenik* filtriralo vrijednosti atributa *id* za sve aktivne trenere koji su zaposleni u istoj podružnici kao i trener čiji se termini raspodijeljuju te se dobivenoj tablici zadaje alias *t*. Zatim se koristeći RIGHT JOIN spajaju tablice *termin_treninga* i tablica *t* kako bi se zadržalo sve aktivne trenere iz tablice *t* (ukljućujući one koji nemaju zakazanih termina), a rezultirajuću tablicu spajanja se potom filtrira prema atributu *vrijeme_pocetka* kako bi se zadržalo samo nadolazeće termine. Iz filtrirane tablice se korištenjem funkcije GROUP BY grupiraju svi termini treninga po atributu *id* tablice *t* čime se u tablicu *termini_ternera* upisuju vrijednosti atributa *id* u atribut *trener_id*, te ukupan broj treninga dobiven korištenjem agregacijske funkcije COUNT u atribut *broj_termina*.<br/>
&emsp;Sljedeće se otvara kursor *cur*, potom se korištenjem naredbe SET postavlja vrijednost sistemske varijable AUTOCOMMIT na OFF(0) čime se isključuje automatsko potvđivanje promjena nad podacima te se omugućuje potvrđivanje promjena korištenjem isključivo naredbe COMMIT, a zatim se pokreće petlja naziva *petlja* kojom se prolazi kroz sve zapise kursora. Prilikom svake itericije najprije se korištenjem naredbe SET TRANSACTION ISOLATION LEVEL postavlja izolacijsku razinu iduće transakcije na READ COMMITTED pri čemu se dozvoljava da se unutar transakcije čita samo podatke čiji je unos/izmjena potvrđena korištenjem naredbe COMMIT čime se spriječava takozvano "prljavo čitanje" nepotvrđenih podataka, te se korištenjem naredbe START TRANSACTION započinje sama transakcija. Na početku transakcije najprije se iščitavaju vrijednosti kursora u varijable *v_termin_treninga_id*, *v_vrijeme_pocetka_termina* i *v_vrijeme_zavrsetka_termina*. Zatim se provjerava ako je vrijednost varijable *done* jednaka TRUE i ako je znači da su iščitane sve vrijednosti iz kursora i petlja se prekida. Nakon toga se korištenjem upita traži id trenera koji je slobodan u traženom terminu na način da se unutar podupita najprije filtriraju svi treneri koji imaju termin treninga koji je u koliziji s terminom koji se razmatra, a zatim se u vanjskom upitu filtriraju svi treneri iz tablice *termini_trenera* koji se ne nalaze među filtriranim trenerima podupita. Dobivene rezultate se potom sortira zlazno prema atributu *broj_termina* koristeći naredbu ORDER BY i ključnu riječ ASC, a zatim se koristeći naredbu LIMIT 1 kao rezultat dobiva redak koji sadržava id trenera s najmanje treninga te se vrijednost atributa *trener_id* tog retka sprema u varijablu *v_trener_id*.<br/>
&emsp;Poslijednje na redu je raspodjela samog termina, navedeno se izvršava pomoću IF-ELSE grananja gdje se najprije provjerava je li uopće ikakva vrijednost upisana u varijablu *v_trener_id* tj. je li pronađen trener kojemu će se dodijeliti termin. Ukoliko je vrijednost varijable *v_trener_id* jednaka NULL znači da trener nije pronađen te se termin treninga otkazuje, navedeno se postiže korištenjem naredbe UPDATE pri čemu se ažurira tablica *termin_treninga* na način da se za n-torku gdje je vrijednost atributa *id* jednaka vrijednosti varijable *v_termin_treninga_id* postavlja vrijednost atributa *otkazan* na TRUE. Ukoliko je trener pronađen najprije se korištenjem naredbe UPDATE dodjeljuje termin tom treneru pri čemu se ažurira tablica *termin_treninga* na način da se za n-torku gdje je vrijednost atributa *id* jednaka vrijednosti varijable *v_termin_treninga_id* postavlja vrijednost atributa *trener_id* na vrijednost varijable *v_trener_id*, a potom se treneru kojemu je dodijeljen termin povećava broj termina u tablici *termini_trenera* kako bi se prilikom raspodijele sljedećeg termina rapolagalo s ispravnim podacima i dodjelilo termin ponovno treneru s najmanje zakazanih termina, navedeno se postiže korištenjem naredbe UPDATE pri čemu se ažurira tablica *termini_trenera* na način da se za n-torku gdje je vrijednost atributa *trener_id* jednaka vrijednosti varijable *v_trener_id* uvećava vrijednost atributa *broj_termina* za jedan. Na kraju svake iteracije se potvrđuju sve promjene napravljene unutar transakcije korištenjem naredbe COMMIT.<br/>
&emsp;Nakon što se izađe iz petlje se korištenjem naredbe SET postavlja vrijednost sistemske varijable AUTOCOMMIT na početno stanje spremljeno u varijabli *v_autocommit*, a potom se zatvara kursor te procedura završava s radom. 

## Procedura koja traži nektivne trenere s zakazin terminima i raspodjeljuje njihove termine

```sql
CREATE PROCEDURE sp_provjeri_trenere()
BEGIN
	DECLARE v_trener_id INTEGER;
    DECLARE done BOOLEAN DEFAULT FALSE;
	DECLARE cur CURSOR FOR
		SELECT   DISTINCT n.id
		FROM     (SELECT id
				  FROM   zaposlenik
				  WHERE  id_radno_mjesto = 1
				  AND    status_zaposlenika = 'neaktivan') AS n
		JOIN	 (SELECT id, trener_id
				  FROM   termin_treninga
				  WHERE  vrijeme_pocetka > CURRENT_TIMESTAMP()) AS tt
				  ON n.id = tt.trener_id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	OPEN cur;
	petlja: LOOP
		FETCH cur INTO v_trener_id;
        
        IF done THEN
			LEAVE petlja;
		END IF;
        
        CALL sp_raspodijeli_termine(v_trener_id);
        
    END LOOP petlja;
    CLOSE cur;
END //
```

**Svrha procedure:**<br/>
Procedura služi za provjeru postoji li neki neaktivni trener koji ima zakazane nadolazeće treninge, ukoliko postoji tada automatski raspodjeljuje sve te treninge na ostale aktivne trenere.

**Opis procedure:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklarira varijabla *v_trener_id* tipa INTEGER u kojeg će se spremati id pojedinog trenera prilikom vršenja preraspodijele treninga, te varijabla *done* kojom se kontrolira izlazak iz petlje kada ponestane vrijednosti u kursoru koja je postavljena na početnu vrijednost FALSE. Sljedeće se deklarira kursor *cur* u kojeg se spremaju id-jevi svih neaktivnih trenera koji imaju neki  zakazani termin u nadolazeće vrijeme. Navedeno se postiže tako da se prvim podupitom filtrira sve neaktivne trenere iz tablice *zaposlenik* te se dobivenoj izvedenoj tablici daje alias n. Potom se korištenjem drugog podupita filtrira sve nadolazeće termine treninga pri čemu se u rezultat uzima samo atribute *id* i *trener_id*, a rezultirajućoj izvedenoj tablici zadaje se alias tt. Potom se korištenjem naredbe JOIN spaja tablicu *n* sa tablicom *tt* korištenjem zajedničkog atributa *id* i *trener_id*, a korištenjem kljušne riječi DISTINCT osiguravamo da se u kursor spremaju samo jedinstveni rezultati atributa *id* tj. jedinstveni id-jevi trenera. Deklarira se i CONTINUE HANDLER FOR NOT FOUND koji se aktivira prilikom čitanja nepostojeće vrijednosti kursora te postavlja vrijednost varijable *done* na TRUE i dozvolja proceduri da nastavi s izvršavanjem.<br/>
&emsp;Sljedeće se otvara kursor *cur* te se pokreće petlja naziva *petlja* kojom se prolazi kroz sve zapise kursora. Prilikom svake itericije najprije se iščitava vrijednost kursora u varijablu *v_trener_id*. Zatim se provjerava ako je vrijednost varijable *done* jednaka TRUE i ako je znači da su iščitane sve vrijednosti iz kursora i petlja se prekida. Na kraju se za svakog nekativnog trenera spremljenog u kursoru poziva procedura *raspodijeli_termine* koja automatski raspodjeljuje sve nadolazeće termine treninga tog trenera na ostale aktivne trenere unutar iste podružnice.

## Procedura koja bilježi promjene nad količinom rezervacija na danom terminu

```sql
CREATE PROCEDURE sp_evidencija_rezervacija_termina(IN p_termin_treninga_id INTEGER, IN p_promjena INTEGER)
BEGIN
	DECLARE v_trenutno_rezervacija, v_max_kapacitet INTEGER;
    
    SELECT	 tt.rezervirano,
			 p.kapacitet
	INTO	 v_trenutno_rezervacija,
			 v_max_kapacitet
    FROM	 (SELECT *
			  FROM termin_treninga
			  WHERE id = p_termin_treninga_id) AS tt
    JOIN	 prostorija p ON tt.prostorija_id = p.id;
    
    
    IF v_trenutno_rezervacija + p_promjena > v_max_kapacitet THEN
		SIGNAL SQLSTATE '45002'
        SET MESSAGE_TEXT = 'Nije moguće unijeti novu rezervaciju: kapacitet termina je popunjen.';
	ELSE
		UPDATE termin_treninga
		SET    rezervirano = v_trenutno_rezervacija + p_promjena
		WHERE  id = p_termin_treninga_id;
	END IF;
END//
```

**Svrha procedure:**<br/>
&emsp;Procedura služi za bilježenje promjena nad količinom rezervacija na danom terminu pri čemu se automatizira bilježenje trenutnog broja rezervacija za svaki termin treninga. Proceduru pokreću triggeri (okidači).

**Parametri:**<br/>
- p_termin_treninga_id - ulazni parametar, podatak tipa INTEGER koji definira *id* termina treninga za kojeg se evidentira promjena broja rezervacija
- p_promjena - ulazni parametar, podatak tipa INTEGER koji definira vrijednost promjene broja rezervacija


**Opis procedure:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklariraju varijable *v_trenutno_rezervacija* i *v_max_kapacitet* tipa INTEGER u koje će se spremiti međurezultati. Zatim se pomoću podupita filtrira n-torku iz tablice *termin_treninga* gdje je vrijednost atributa *id* jednaka vrijednosti parametra *p_termin_treninga_id* pri čemu se dobiva izvedenu tablicu *tt* koju se potom korištenjem naredbe JOIN spaja sa tablicom *prostorija* putem primarnog ključa tablice *prostorija*, iz rezultirajuće n-torke sprema se vrijednost atributa *rezervirano* tablice *tt* unutar varijable *v_trenutno_rezervacija* te vrijednost atributa *kapacitet* unutar varijable *v_max_kapacitet*. Na kraju se korištenjem IF-ELSE grananja provjerava provjerava hoće li se dodavanjem vrijednosti parametra *p_promjena* na trenutni broj rezervacija termina *v_trenutno_rezervacija* premašiti maksimalni kapacitet *v_max_kapacitet* prostorije u kojoj se trening odvija, ukoliko se dodavanjem promjene premašuje maksimalni kapacitet prostorije tada se podiže korisnički definirana greška koja javlja kako nije moguće unijeti novu rezervaciju iz razloga jer je kapacitet termina popunjen. Ukoliko se dodavanjem promjene ne premašuje maksimalni kapacitet prostorije tada se promjena evidentira tako što se korištenjem naredbe UPDATE ažurira tablica *termin_treninga* na način da se za n-torku gdje je vrijednost atributa *id* jednaka vrijednosti varijable *p_termin_treninga_id* postavlja vrijednost atributa *rezervirano* na rezultat zbroja varijabli *v_trenutno_rezervacija* i *p_promjena*.

## Zamjena prostorija dvaju termina treninga

```sql
CREATE PROCEDURE sp_zamjeni_prostorije(IN p_termin_1 INTEGER, IN p_termin_2 INTEGER)
BEGIN
	DECLARE v_prostorija_1, v_prostorija_2 INTEGER;
    DECLARE v_autocommit BOOLEAN;
	DECLARE EXIT HANDLER FOR 3572 
		SELECT 'Došlo je do greške: redak se ne može zaključati jer je zaključan od strane neke druge transakcije.' AS PORUKA_GRESKE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			ROLLBACK;
            SET AUTOCOMMIT = v_autocommit;
            SELECT 'Došlo je do greške: procedura \'zamjeni_prostorije\' je prisilno zaustavljena, a sve promjene su poništene.' AS PORUKA_GRESKE;
		END;    
	
    SET v_autocommit = @@autocommit;
    SET AUTOCOMMIT = OFF;
    
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    START TRANSACTION;
    
    SELECT prostorija_id
    INTO   v_prostorija_1
    FROM   termin_treninga
    WHERE  id = p_termin_1
    FOR UPDATE NOWAIT;
    
    SELECT prostorija_id
    INTO   v_prostorija_2
    FROM   termin_treninga
    WHERE  id = p_termin_2
    FOR UPDATE NOWAIT;
    
    UPDATE termin_treninga
    SET    prostorija_id = v_prostorija_2
    WHERE  id = p_termin_1;
    
    UPDATE termin_treninga
    SET    prostorija_id = v_prostorija_1
    WHERE  id = p_termin_2;
    
    COMMIT;
    SET AUTOCOMMIT = v_autocommit;
END //
```

**Svrha procedure:**<br/>
Procedura služi za zamjenu prostorija dvaju treninga u kojima izvode što može biti korisno ukoliko se vidi da za neki termin treninga postoji veliki interes dok za neki drugi ne postoji toliki, a prostorije u kojima se održavaju su adekvatne za održavanje oba treninga. 

**Parametri:**<br/>
- p_termin_1 - ulazni parametar, podatak tipa INTEGER koji definira *id* termina treninga za kojeg se vrši zamjena prostorije
- p_termin_2 - ulazni parametar, podatak tipa INTEGER koji definira *id* termina treninga za kojeg se vrši zamjena prostorije


**Opis procedure:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklariraju varijable *v_prostorija_1* i *v_prostorija_2* tipa INTEGER u koje će se spremiti prostorije pojedinih termina treninga, te varijabla *v_autocommit* tipa BOOLEAN u koju se pohranjuje vrijednost/stanje autocommit postavke na početku procedure. Također se deklariraju i dva EXIT HANDLER-a, prvi FOR 3572 koji se aktivira i javlja poruku o grešci pri pokušaju zaključavanja retka korištenjem naredbe FOR UPDATE i ključne riječi NOWAIT pri čemu se zbog ključne riječi NOWAIT javlja greška s navedim kodom jer je redak već zaključan od strane neke druge transakcije, a drugi FOR SQLEXCEPTION koji se aktivira ukoliko dođe do bilo kakve druge greške prilikom izvođenja procedure i transakcije te izvršava naredbu ROLLBACK kojom poništava sve promjene napravljene unutar transakcije, također izvršava i naredbu SET kojom postavlja vrijednost sistemske varijable AUTOCOMMIT na početno stanje spremljeno u varijabli *v_autocommit*, te vraća poruku o grešci.<br/>
&emsp;Nakon dekalracijskog dijela procedure najprije se pomoću naredbe SET postavlja vrijednost varijable *v_autocommit* na vrijednost systemske varijable *@@autocommit* kako bi se pohranila vrijednost te varijable pošto će se kasnije izmjeniti prije ulaska u transakciju. Zatim se korištenjem naredbe SET postavlja vrijednost sistemske varijable AUTOCOMMIT na OFF(0) čime se isključuje automatsko potvđivanje promjena nad podacima te se omugućuje potvrđivanje promjena korištenjem isključivo naredbe COMMIT. Korištenjem naredbe SET TRANSACTION ISOLATION LEVEL postavlja se izolacijsku razinu iduće transakcije na READ COMMITTED pri čemu se dozvoljava da se unutar transakcije čita samo podatke čiji je unos/izmjena potvrđena korištenjem naredbe COMMIT čime se spriječava takozvano "prljavo čitanje" nepotvrđenih podataka, te se korištenjem naredbe START TRANSACTION započinje sama transakcija.<br/>
&emsp;Sljedeće se pomoću upita sprema vrijednost atributa *prostorija_id* tablice *termin_treninga* u varijablu *v_prostorija_1* tako što se najprije iz tablice filtrira n-torka koja ima vrijednost atributa *id* jednaku vrijednosti parametra *p_termin_1* te se taj redak na kraju i zaključava korištenjem naredbe FOR UPDATE i ključne riječi NOWAIT koja spriječava čekanje ukoliko je redak već zaključan od strane neke druge transakcije i odmah podiže grešku. Isto se ponavlja i za spremanje vrijednosti atributa *prostorija_id* prostorije termina definiranog parametrom *p_termin_2* u varijablu *v_prostorija_2*. Nakon što su prostorije termina evidentirane, korištenjem naredbe UPDATE dodjeljuje se prostorija drugog termina prvome pri čemu se ažurira tablica *termin_treninga* na način da se za n-torku gdje je vrijednost atributa *id* jednaka vrijednosti parametra *p_termin_1* postavlja vrijednost atributa *prostorija_id* na vrijednost varijable *v_prostorija_2*. Slično se ponavlja i za drugi termin samo što se za n-torku gdje je vrijednost atributa *id* jednaka vrijednosti parametra *p_termin_2* postavlja vrijednost atributa *prostorija_id* na vrijednost varijable *v_prostorija_1*.<br/>
&emsp;Na kraju se potvrđuju sve promjene napravljene unutar transakcije korištenjem naredbe COMMIT te se korištenjem naredbe SET postavlja vrijednost sistemske varijable AUTOCOMMIT na početno stanje spremljeno u varijabli *v_autocommit*. 

# TRIGGERI (OKIDAČI)

## Okidač koji prilikom unosa termina treninga računa vrijeme završetka ovisno o treningu

```sql
CREATE TRIGGER bi_termin_treninga
BEFORE INSERT ON termin_treninga
FOR EACH ROW
BEGIN
	DECLARE v_trajanje_treninga INTEGER;
	
	SELECT planirano_trajanje_min
		INTO v_trajanje_treninga
		FROM trening
		WHERE trening.id = NEW.trening_id;
	
	IF v_trajanje_treninga IS NULL THEN
		SIGNAL SQLSTATE '45003'
		SET MESSAGE_TEXT = 'Nije moguće unijeti termin treninga: nepostojeći trening.';
	END IF;
    
	SET NEW.vrijeme_zavrsetka = NEW.vrijeme_pocetka + INTERVAL v_trajanje_treninga MINUTE;
    
	IF NOT fn_slobodan_termin(NEW.trener_id, 't', NEW.vrijeme_pocetka, NEW.vrijeme_zavrsetka) THEN
		SIGNAL SQLSTATE '45004'
		SET MESSAGE_TEXT = 'Nije moguće unijeti termin treninga: postoji zakazan trening koji se preklapa s unesenim terminom.';
	END IF;
    
	SET NEW.otkazan = COALESCE(NEW.otkazan, FALSE);
END //
```

**Svrha triggera:**<br/>
&emsp;Trigger koji prije unosa računa vrijeme završetka termina treninga ovisno o treningu koji se izvodi, a također i provjerava preklapa li se termin s nekim postojećim terminom.

**Opis triggera:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklarira varijabla *v_trajanje_treninga* tipa INTEGER u koju će se spremiti trajanje treninga za kojeg je definiran termin. Nakon toga se pomoću upita filtrira n-torka iz tablice *trening* gdje je vrijednost atributa *id* jednaka vrijednosti atributa *trening_id* koji se unosi te se iz filtrirane n-torke sprema vrijednost atributa *planirano_trajanje_min* u varijablu *v_trajanje_treninga*. Zatim se koristeći IF grananje provjerava je vrijednost pohranjena u varijablu *v_trajanje_treninga*, ukoliko je vrijednost varijable jednaka NULL znači da trajanje treninga nije pronađeno tj. da je kao parametar predan nepostojeći trening te se automatski podiže korisnički definirana greška koja javlja kako nije moguć unos termina treninga jer uneseni trening ne postoji. Ukoliko trening postoji tada se novo unesena vrijednost atributa *vrijeme_zavrsetka* postavlja na vrijednost atributa *vrijeme_pocetka* uvećanu za vrijednost varijable *v_trajanje_treninga* u minutama što se postiže korištenjem operatora INTERVAL i ključne riječi MINUTE.<br/>
&emsp;Nadalje, prije unosa termina također se pomoću IF grananja provjerava i preklapanje unesenog termina sa postojećim terminima korištenjem logičke operacije NOT i korisnički definirane funkcije *slobodan_termin* te ukoliko postoji preklapanje automatski se podiže korisnički definirana greška koja javlja kako nije moguć unos termina treninga jer postoji zakazan termin koji se preklapa s unesenim. Na kraju se još pomoću funkcije COALESCE provjerave je li unesena vrijednost atributa *otkazan* jednaka NULL i ukoliko je tada isti postavljamo na FALSE čime se spriječava kršenje NOT NULL ograničenja nad atributom *otkazan* prilikom novih unosa tako što se ga postavlja na vrijednost koja je definirana ograničenjem DEFAULT.

## Okidač koji provjerava preklapanje rezervacije i povećava popunjenost termina

```sql
CREATE TRIGGER bi_rezervacija
BEFORE INSERT ON rezervacija
FOR EACH ROW
BEGIN
	DECLARE v_vrijeme_pocetka, v_vrijeme_zavrsetka TIMESTAMP;
    
    SELECT vrijeme_pocetka,
		   vrijeme_zavrsetka
	INTO   v_vrijeme_pocetka,
		   v_vrijeme_zavrsetka
	FROM   termin_treninga
    WHERE  id = NEW.termin_treninga_id;
    
	IF NOT fn_slobodan_termin(NEW.clan_id, 'c', v_vrijeme_pocetka, v_vrijeme_zavrsetka) THEN
		SIGNAL SQLSTATE '45005'
		SET MESSAGE_TEXT = 'Nije moguće unijeti rezervaciju termina treninga: preklapanje s postojećom rezervacijom.';
	ELSE
		CALL sp_evidencija_rezervacija_termina(NEW.termin_treninga_id, 1);
	END IF;
END //
```

**Svrha triggera:**<br/>
&emsp;Trigger služi kako bi prilikom unosa nove rezervacije provjerio ima li član već zakan neki trening u tome terminu s kojim se uneseni trening preklapa te ukoliko nema onda poziva proceduru koja provjerava ima li mjesta za rezervaciju termina i po potrebi evidentira termin na ukupnu sumu rezervacija.

**Opis triggera:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklariraju varijable *v_vrijeme_pocetka* i *v_vrijeme_zavrsetka* koje su tipa TIMESTAMP a koristit će se za pohranjivanje vremena početka i završetka termina treninga za kojeg se vrši rezervacija. Nakon toga se pomoću upita filtrira n-torka iz tablice *termin_treninga* gdje je vrijednost atributa *id* jednaka vrijednosti atributa *termin_treninga_id* koji se unosi te se iz filtrirane n-torke sprema vrijednost atributa *vrijeme_pocetka* u varijablu *v_vrijeme_pocetka*, te vrijednost atributa *vrijeme_zavrsetka* u varijablu *v_vrijeme_zavrsetka*.<br/>
&emsp;Nadalje, prije unosa termina također se pomoću IF grananja provjerava i preklapanje termina kojeg član želi rezervirati sa već rezerviranim terminima tog člana korištenjem logičke operacije NOT i korisnički definirane funkcije *slobodan_termin* te ukoliko postoji preklapanje automatski se podiže korisnički definirana greška koja javlja kako nije moguć unos rezervacije jer već postoji rezervacija u tom terminu. Ukoliko je termin dostupan za rezervaciju poziva se procedura *evidencija_rezervacija_termina* koja prije samog unosa još provjerava kapacitet termina te ako postoji slobodno mjesto evidentira termin na ukupnu sumu rezervacija.

## Okidač koji smanjuje popunjenost termina treninga kada se otkaže rezervacija

```sql
CREATE TRIGGER ad_rezervacija
AFTER DELETE ON rezervacija
FOR EACH ROW
BEGIN
	CALL sp_evidencija_rezervacija_termina(OLD.termin_treninga_id, -1);
END //
```

**Svrha triggera:**<br/>
Trigger služi za smanjivanje broja rezervacija na određenom terminu prilikom otkazivanja ili brisanja rezervacije.

**Opis triggera:**<br/>
&emsp;Poziva se procedura *evidencija_rezervacija_termina* koja smanjuje ukupnu sumu rezervacija termina na kojeg se rezervacija odnosi.

## Okidač koji pazi da se kapacitet prostorije ne postavi na manje od broja rezervacija

```sql
CREATE TRIGGER bu_prostorija
BEFORE UPDATE ON prostorija
FOR EACH ROW
BEGIN
	IF NEW.kapacitet < OLD.kapacitet
		AND EXISTS (
			SELECT  1
			FROM    termin_treninga
			WHERE   prostorija_id = NEW.id
			AND		vrijeme_pocetka > CURRENT_TIMESTAMP()
			AND     rezervirano > NEW.kapacitet
		) THEN
		SIGNAL SQLSTATE '45006'
		SET MESSAGE_TEXT = 'Greška prilikom promijene kapaciteta prostorije: postoje nadolazeći termini s više rezervacija od novo unesenog kapaciteta.';
	END IF;
END //
```

**Svrha triggera:**<br/>
&emsp;Trigger služi da prilikom smanjivanja kapaciteta neke prostorija, bilo zbog rekonstrukcije, renovacije ili prenamjene, provjeri postoji li neki termin treninga koji je zakazan u toj prostoriji, a ima više rezervacija nego novo uneseni kapacitet, ako postoji tada se ne dopušta smanjenje kapaciteta prije nego li se riješi "višak" rezervacija.

**Opis triggera:**<br/>
&emsp;Najprije se koristeći naredbu DECLARE deklarira varijabla *v_termin_s_vise_rezervacija* tipa BOOLEAN koja će poslužiti za evidentiranje ako postoji neki termin treninga s više rezervacija od kapaciteta kojeg se želi definirati. Najprije se korištenjem IF grananja provjerava je li novo unesena vrijednost atributa *kapacitet* manja od postojeće vrijednosti i postoji li neki nadolazeći termin treninga koji se održava u toj prostoriji, a ima više rezervacija nego što iznosi vrijednost novo unesenog atributa *kapacitet*. Drugi uvijet provjerava se na način da se operatoru EXISTS kao argument daje upit koji iz tablice *termin_treninga* filtrira nadolazeće termine kojima je vrijednost atributa *prostorija_id* tablice *termin_treninga* jednaka novo unesenoj vrijednosti atributa *id* i kojima je vrijednost atributa *rezervirano* veća od novo unesene vrijednosti atributa *kapacitet* te upit za svaki takav termin vraća broj 1 kako bi se evidentiralo njegovo postojanje, ako postoji barem jedan takav termin tada drugi uvijet vraća TRUE. Ukoliko barem jedan od dva uvijeta nije zadovoljen trigger odmah prestaje s izvođenjem te se izvršava željeno ažuriranje podataka unutar tablice *prostorija*. Međutim ukoliko su oba uvjeta zadovoljena to znači da se pokušava postaviti kapacitet prostorije na iznos manji od broja rezervacija na nekom od nadolazećih termina i u tom slučaju se automatski podiže korisnički definirana greška koja javlja kako je došlo do greške prilikom pokušaja promijene kapaciteta prostorije jer postoje prostorije koje na nekom od treninga imaju više rezervacija od novo unesenog kapaciteta, trigger tada prekida s radom, a ažuriranje podataka se odbacuje.

# AUTENTIFIKACIJA I AUTORIZACIJA

```sql
-- Korisnik - administrator
CREATE ROLE 'admin_ovlasti';
GRANT ALL PRIVILEGES ON fitness_centar.* TO 'admin_ovlasti';
CREATE USER 'AdminMiro' IDENTIFIED BY 'miro';
GRANT 'admin_ovlasti' TO 'AdminMiro';

-- Korisnik - trener
CREATE ROLE 'ovlasti_trenera';
GRANT SELECT, INSERT, UPDATE, DELETE ON fitness_centar.termin_treninga TO 'ovlasti_trenera';
GRANT SELECT, DELETE ON fitness_centar.rezervacija TO 'ovlasti_trenera';
CREATE USER 'TrenerIvo' IDENTIFIED BY 'ivo';
GRANT 'ovlasti_trenera' TO 'TrenerIvo';

-- Korisnik - član
CREATE ROLE 'ovlasti_clana';
GRANT SELECT ON fitness_centar.termin_treninga TO 'ovlasti_clana';
GRANT SELECT, INSERT ON fitness_centar.rezervacija TO 'ovlasti_clana';
CREATE USER 'ClanPero' IDENTIFIED BY 'pero';
GRANT 'ovlasti_clana' TO 'ClanPero';
```

**Opis:**<br/>
&emsp;Priloženim kodom kreirane su tri uloge za tri korisnika. Koriste se naredbe CREATE ROLE i CREATE USER za kreiranje ulage i korisnika te naredba GRANT kojom se dodjeluju ovlasti i uloge.<br/>
&emsp;Najprije se kreira uloga administratora naziva *admin_ovlasti* kojoj se dodjeluju sve ovlasti nad cijelom bazom podataka i korisnik *AdminMiro* kojem se definira lozinka i dodjeljuje uloga administratora.<br/>
&emsp;Zatim se kreira uloga trenera naziva *ovlasti_trenera* kojoj se dodjeluju ovlasti čitanja, pisanja, ažuriranja i brisanja nad tablicom *termin_treninga* kako bi trener mogao raditi sve potrebno sa svojim terminima treninga, te ovlasti čitanja i brisanja nad tablicom *rezervacija* kako bi trener mogao upravljati rezervacijama za svoje termine treninga, a potom se kreira i korisnik *TrenerIvo* kojem se definira lozinka i dodjeljuje uloga trenera.<br/>
&emsp;Na kraju se kreira uloga člana naziva *ovlasti_clana* kojoj se dodjeluje mogućnost čitanja nad tablicom *termin_treninga* kako bi član mogao pregledavati zakazane termine treninga, te ovlasti čitanja i pisanja nad tablicom *rezervacija* kako bi član mogao upravljati zakazivati rezervacije za željene termine treninga te pregledavati sve moguće promjene nad terminima koje je rezervirao, a potom se kreira i korisnik *ClanPero* kojem se definira lozinka i dodjeljuje uloga člana.

# INDEXI

&emsp;Pregledom svojih tablica, podataka, upita, pogleda, procedura i ostalih rutina i objekata koje sam definirao nad bazom podataka, odlučio sam pokušati dodati index nad atributom *vrijeme_pocetka* tablice *termin_treninga* pošto se navedeni atribut koristi u mnogima. Prije dodavanja odlučio sam korištenjem naredbe EXPLAIN nad već definiranim upitom provjeriti koriste li se ikakvi ključevi i indexi prilikom njegovog izvršavanja.

Ovo je upit nad kojim se koristi naredba EXPLAIN:

```sql
SELECT   COUNT(*) AS broj_trenera, broj_treninga
FROM     (SELECT trener_id, COUNT(*) AS broj_treninga
		  FROM termin_treninga
		  WHERE vrijeme_pocetka BETWEEN CURRENT_TIMESTAMP() AND CURRENT_TIMESTAMP() + INTERVAL 1 MONTH
		  GROUP BY trener_id) AS btt
GROUP BY broj_treninga
ORDER BY broj_treninga DESC;
```

Rezultat EXPLAIN-a sam spremio u JSON formatu, a on je sljedeći:

```JSON
[
	{
		"id" : 1,
		"select_type" : "PRIMARY",
		"table" : "<derived2>",
		"partitions" : null,
		"type" : "ALL",
		"possible_keys" : null,
		"key" : null,
		"key_len" : null,
		"ref" : null,
		"rows" : 129,
		"filtered" : 100.00,
		"Extra" : "Using temporary; Using filesort"
	},
	{
		"id" : 2,
		"select_type" : "DERIVED",
		"table" : "termin_treninga",
		"partitions" : null,
		"type" : "index",
		"possible_keys" : "fk_termin_treninga_zaposlenik",
		"key" : "fk_termin_treninga_zaposlenik",
		"key_len" : "4",
		"ref" : null,
		"rows" : 1166,
		"filtered" : 11.11,
		"Extra" : "Using where"
	}
]
```

&emsp;Iz navedenog je vidljivo kako se pri izvršavanju DERIVED tj. podupita koristi strani ključ tablice *zaposlenik*, dok se pri izvršavanju PRIMARY tj. vanjskog upita ne koriste nikakvi ključevi što je vjerovatno rezultat toga što vanjski upit u svom izvršavanju koristi rezultat unutarnjeg podupita, a to je izvedena tablica nad kojom nisu definirani nikakvi ključevi ni indexi.

&emsp;Nakon toga sam korištenjem naredbe ALTER TABLE i ključnih riječi ADD INDEX dodao index nad atributom *vrijeme_pocetka* tablice *termin_treninga*, a zatim sam ponovio EXPLAIN naredbu nad istim upitom. Rezultat je sljedeći:

```JSON
[
	{
		"id" : 1,
		"select_type" : "PRIMARY",
		"table" : "<derived2>",
		"partitions" : null,
		"type" : "ALL",
		"possible_keys" : null,
		"key" : null,
		"key_len" : null,
		"ref" : null,
		"rows" : 251,
		"filtered" : 100.00,
		"Extra" : "Using temporary; Using filesort"
	},
	{
		"id" : 2,
		"select_type" : "DERIVED",
		"table" : "termin_treninga",
		"partitions" : null,
		"type" : "range",
		"possible_keys" : "fk_termin_treninga_zaposlenik,idx_vrijeme_pocetka",
		"key" : "idx_vrijeme_pocetka",
		"key_len" : "4",
		"ref" : null,
		"rows" : 251,
		"filtered" : 100.00,
		"Extra" : "Using index condition; Using temporary"
	}
]

```

&emsp;Iz dobivenog rezultata vidimo kako se za izvršavanje vanjskog upita i dalje ne koriste nikakvi ključevi ni indexi, dok se za izvršavanje unutarnjeg podupita koristi definirani index *idx_vrijeme_pocetka*. Također provjerom nekih drugih upita, funkcija i procedura pronašao sam da se definirani index također koristi prilikom izvršavanja podupita unutar upita za inicijalizaciju kursora u proceduri *provjeri_trenere*.<br/>
&emsp;S obzirom da se definirani index koristi u izvršavanju nekih upita/podupita pri samo nešto više od 1000 testnih zapisa koji predstavljaju vremenski period od samo četiri mjeseca, odlučio sam da ću istog ubaciti u definiciju tablice jer će se prilikom još većeg broja zapisa vjerovatno koristiti u puno više upita ako ne i u svima u kojima se pojavljuje. Svjestan sam da index predstavlja prostorno opterećenje za bazu podataka i vremensko opterećenje prilikom vršenja operacija unosa, ažuriranja i brisanja podataka, ali smatram da može značajno poboljšati rad baze podataka pošto može znatno ubrzati dohvat podataka, a pritom treba napomenuti kako se dohvat podataka korištenjem atributa *vrijeme_pocetka* vrši unutar većine upita, pogleda, funkcija, procedura i ostalih.

# TRANSAKCIJE

## TRANSAKCIJA 1

**Svrha transakcije:**<br/>
&emsp;Transakcija služi za osiguravanje atomičnosti pri prebacivanju termina treninga na drugog trenera te ažuriranje novog broja termina tog trenera, a također i za osiguravanje da prilikom usporedbe termina s ostalim nadolazećim terminima nekog trenera pristupamo najnovijim podacima. Razlog zašto se izolacijska razina transakcije postavlja prilikom svake iteracije petlje je taj što nije cilj mijenjati izolacijsku razinu na nivou cijele sesije jer se želi zadržati zadana izolacijska razina REPEATABLE READ za sve ostale funkcionalnosti baze, ali se također želi koristiti razinu READ COMMITED unutar ove transakcije kako bi imali uvid u najnovije termine treninga koji su zabilježeni i potvrđeni.

**Opis transakcije:**<br/>
&emsp;Ova transakcija pojavljuje se u sklopu procedure ***raspodijeli_termine*** gdje je već prikazan kod i objašnjeni svi važniji dijelovi stoga ovdje samo želim istaknuti istu i objasniti dijelove vezane uz samu transakciju.<br/>
&emsp;Na samom početku procedure najprije se deklarira varijabla *v_autocommit* koja služi za pohranjivanje trenutnog stanja sistemske varijable AUTOCOMMIT, na taj način ne treba tokom izvođenja provjeravati na koju vrijednost je AUTOCOMMIT trenutno postavljen već se ga mijenja po želji i na kraju se koristi varijablu *v_autocommit* kako bi se vrijednost AUTOCOMMIT-a postavila na početnu. Dalje u proceduri koristi se naradba SET kako bi se u varijablu *v_autocommit* pohranila vrijednost systemske varijable @@autocommit. Valja napomenuti kako sistemske varijable *@@autocommit* i *AUTOCOMMIT* pristupaju istoj vrijednosti, jedina razlika je što se *@@autocommit* koristi uglavnom prilikom čitanja te vrijednosti, a *AUTOCOMMIT* prilikom mijenjanja te vrijednosti.<br/>
&emsp;U deklarativnom dijelu procedure također se deklarira i EXIT HANDLER FOR SQLEXCEPTION koji se aktivira ukoliko dođe do neke greške prilikom izvođenja procedure te izvršava naredbu ROLLBACK kojom poništava sve promjene napravljene unutar transakcije (ukoliko ih ima), također izvršava i naredbu SET kojom postavlja vrijednost sistemske varijable AUTOCOMMIT na početno stanje spremljeno u varijabli *v_autocommit*, te vraća poruku o grešci.<br/>
&emsp;Prije definiranja početka same transakcije koristi se naredba SET kako bismo postavili vrijednost sistemske varijable *AUTOCOMMIT* na OFF. Također korištenjem naredbe SET TRANSACTION ISOLATION LEVEL postavlja se izolacijsku razinu iduće transakcije na READ COMMITTED, na taj način se idućoj transakciji omogućuje čitanje samo podataka čiji je unos/izmjena potvrđena korištenjem naredbe COMMIT, time se spriječava takozvano "prljavo čitanje" nepotvrđenih podataka. Korištenjem naredbe START TRANSACTION definira se početak transakcije, a korištenjem naredbe COMMIT definira se kraj transakcije. Po završetku transakcije koristi se naredba SET kako bi se postavila vrijednost sistemske varijable *AUTOCOMMIT* na početnu vrijednost zapisanu u varijabli *v_autocommit*.

## TRANSAKCIJA 2

**Svrha transakcije:**<br/>
&emsp;Transakcija služi za osiguravanje atomičnosti pri zamjeni prostorija dvaju termina treninga te za zaključavanje redaka tih termina tako da nitko drugi ne može mijenjati ili brisati te retke dok god ta transakcije na završi s radom.

**Opis transakcije:**<br/>
&emsp;Ova transakcija pojavljuje se u sklopu procedure ***zamjeni_prostorije*** gdje je već prikazan kod i objašnjeni svi važniji dijelovi stoga ovdje samo želim istaknuti istu i objasniti dijelove vezane uz samu transakciju.<br/>
&emsp;Na samom početku procedure najprije se deklarira varijabla *v_autocommit* koja služi za pohranjivanje trenutnog stanja sistemske varijable AUTOCOMMIT, na taj način ne treba tokom izvođenja provjeravati na koju vrijednost je AUTOCOMMIT trenutno postavljen već se ga mijenja po želji i na kraju se koristi varijablu *v_autocommit* kako bi se vrijednost AUTOCOMMIT-a postavila na početnu. Valja napomenuti kako sistemske varijable *@@autocommit* i *AUTOCOMMIT* pristupaju istoj vrijednosti, jedina razlika je što se *@@autocommit* koristi uglavnom prilikom čitanja te vrijednosti, a *AUTOCOMMIT* prilikom mijenjanja te vrijednosti.<br/>
&emsp;U deklarativnom dijelu procedure također se deklarira i EXIT HANDLER FOR SQLEXCEPTION koji se aktivira ukoliko dođe do neke greške prilikom izvođenja procedure te izvršava naredbu ROLLBACK kojom poništava sve promjene napravljene unutar transakcije (ukoliko ih ima), također izvršava i naredbu SET kojom postavlja vrijednost sistemske varijable AUTOCOMMIT na početno stanje spremljeno u varijabli *v_autocommit*, te vraća poruku o grešci. Nadalje deklarira se i EXIT HANDLER FOR 3572 koji se aktivira ukoliko se zbog ključne riječi NOWAIT prilikom zaključavanja redaka javi greška koja označava kako je redak koji se pokušava zaključati već zaključan od strane neke druge transakcije.<br/>
&emsp;Prije definiranja početka same transakcije koristi se naredba SET kako bi se u varijablu *v_autocommit* pohranila vrijednost systemske varijable @@autocommit te kako bi se postavilo vrijednost sistemske varijable *AUTOCOMMIT* na OFF. Također korištenjem naredbe SET TRANSACTION ISOLATION LEVEL postavlja se izolacijsku razinu iduće transakcije na READ COMMITTED, na taj način se idućoj transakciji omogućuje čitanje samo podatke čiji je unos/izmjena potvrđena korištenjem naredbe COMMIT, time se spriječava takozvano "prljavo čitanje" nepotvrđenih podataka. Korištenjem naredbe START TRANSACTION definira se početak transakcije, a tokom same transakcije također se koristi naredba FOR UPDATE kako bi se zaključalo retke koje se koristi tako da ih nitko drugi ne može mijenjati ili brisati dok god ta transakcije na završi s radom, a korištenjem ključne riječi NOWAIT spriječava se čekanje ukoliko je redak već zaključan od strane neke druge transakcije i odmah se podiže greška. Po završetku transakcije koristi se naredba COMMIT kojom definira kraj transakcije, a potom naredba SET kako bi se postavila vrijednost sistemske varijable *AUTOCOMMIT* na početnu vrijednost zapisanu u varijabli *v_autocommit*.

# EVENTI

## Event koji svaki dan provjerava neaktivne trenere s zakazanim terminima

```sql
CREATE EVENT dnevna_provjera_trenera
	ON SCHEDULE
		EVERY 1 DAY
		STARTS IF(
					CURRENT_TIMESTAMP() < CURRENT_DATE() + INTERVAL 1 HOUR,
					CURRENT_DATE() + INTERVAL 1 HOUR,
					CURRENT_DATE() + INTERVAL 1 DAY + INTERVAL 1 HOUR
				)
    DO
		CALL provjeri_trenere();
```

**Svrha eventa:**<br/>
Event služi da se automatizira provjera trenera koji su možda postali neaktivni ali su njihovi nadolazeći termini i dalje zakazani te članovi i dalje računaju na te treninge, pa kako bi se osiguralo da će treninzi biti održani ovaj event svakodnevno pokreće proceduru koja provjerava postoje li takvi treneri i raspodjeljuje njihove treninge na ostale aktivne trenere unutar iste podružnice.

**Opis eventa:**<br/>
Korištenjem naredbe CREATE EVENT kreira se događaj naziva *dnevna_provjera_trenera*. Zatim se korištenjem ključne riječi ON SCHEDULE postavlja se raspored za izvršavanje događaja te se korištenjem ključnih riječi EVERY 1 DAY definira da će se događaj ponavljati svakih 1 dan, a korištenjem ključne riječi STARTS definira se kada događaj prvi put kreće s izvođenjem. Za definiranje početnog vremena izvođenja koristi se IF funkcija koja provjerava je li vrijeme u trenutku kreiranja događaja prije ili poslije jedan ujutro u tom danu, ukoliko je prije jedan ujutro tada se prvo izvršavanje zakazuje ja jedan sat ujutro istog tog dana, a ukoliko je nakon jedan ujutro tada se prvo izvršavanje zakazuje za jedan sat ujutro narednog dana. Na kraju se korištenjem ključne riječi DO specificira što će sve događaj izvršavati, u ovom slučaju će samo pozivati proceduru *provjeri_trenere*.