# ---------------------------------------
#    Flask aplikacija – Fitness centar
#       HTML sučelje (BP2 projekt)
# ---------------------------------------

from flask import Flask, render_template, request, redirect, url_for
from flask_mysqldb import MySQL

app = Flask(__name__)

app.config['JSON_AS_ASCII'] = False

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'flask_user'
app.config['MYSQL_PASSWORD'] = 'flask_lozinka'
app.config['MYSQL_DB'] = 'fitness_centar'
# app.config["MYSQL_AUTOCOMMIT"] = True ili False ... odaberite po želji i prema tome onda koristite ili ne koristite mysql.connection.commit()

mysql = MySQL(app)

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/clanovi")
def clanovi():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT
            c.id,
            c.ime,
            c.prezime,
            m.naziv,
            c.datum_uclanjenja,
            c.aktivan
        FROM clan c
        JOIN mjesto m ON c.id_mjesto = m.id
        ORDER BY c.id DESC
    """)
    clanovi = cur.fetchall()
    cur.close()

    return render_template("clanovi.html", clanovi=clanovi)

@app.route("/clanovi/novi", methods=["GET", "POST"])
def clan_novi():

    cur = mysql.connection.cursor()
    cur.execute("SELECT id, naziv, postanski_broj, drzava FROM mjesto")
    mjesta = cur.fetchall()
    cur.close()

    if request.method == "POST":
        ime = request.form["ime"]
        prezime = request.form["prezime"]
        oib = request.form["oib"]
        spol = request.form["spol"]
        datum_rodenja = request.form["datum_rodenja"]
        id_mjesto = request.form["id_mjesto"]
        adresa = request.form["adresa"]
        email = request.form["email"]
        telefon = request.form["telefon"]

        cur = mysql.connection.cursor()
        cur.execute("""
            INSERT INTO clan
            (ime, prezime, oib, spol, datum_rodenja, id_mjesto, adresa, email, telefon,
             datum_uclanjenja, datum_posljednje_aktivnosti, aktivan)
            VALUES
            (%s, %s, %s, %s, %s, %s, %s, %s, %s,
             CURDATE(), CURDATE(), 1)
        """, (
            ime, prezime, oib, spol, datum_rodenja,
            id_mjesto, adresa, email, telefon
        ))

        mysql.connection.commit()
        cur.close()

        return redirect(url_for("clanovi"))

    return render_template("clan_novi.html", mjesta=mjesta)

@app.route("/clanovi/uredi/<int:id>", methods=["GET", "POST"])
def clan_uredi(id):

    # dohvat mjesta (za dropdown)
    cur = mysql.connection.cursor()
    cur.execute("SELECT id, naziv, postanski_broj, drzava FROM mjesto ORDER BY naziv")
    mjesta = cur.fetchall()

    # dohvat postojećeg člana
    cur.execute("""
        SELECT
            ime, prezime, oib, spol, datum_rodenja,
            id_mjesto, adresa, email, telefon, aktivan
        FROM clan
        WHERE id = %s
    """, (id,))
    clan = cur.fetchone()

    if clan is None:
        cur.close()
        return redirect(url_for("clanovi"))

    if request.method == "POST":
        ime = request.form["ime"]
        prezime = request.form["prezime"]
        oib = request.form["oib"]
        spol = request.form["spol"]
        datum_rodenja = request.form["datum_rodenja"]
        id_mjesto = request.form["id_mjesto"]
        adresa = request.form["adresa"]
        email = request.form["email"]
        telefon = request.form["telefon"]
        aktivan = request.form.get("aktivan", 0)

        cur.execute("""
            UPDATE clan SET
                ime = %s,
                prezime = %s,
                oib = %s,
                spol = %s,
                datum_rodenja = %s,
                id_mjesto = %s,
                adresa = %s,
                email = %s,
                telefon = %s,
                aktivan = %s
            WHERE id = %s
        """, (
            ime, prezime, oib, spol, datum_rodenja,
            id_mjesto, adresa, email, telefon, aktivan, id
        ))

        mysql.connection.commit()
        cur.close()

        return redirect(url_for("clanovi"))

    cur.close()
    return render_template(
        "clan_uredi.html",
        clan=clan,
        mjesta=mjesta,
        id=id
    )

@app.route("/clanovi/obrisi/<int:id>")
def clan_obrisi(id):

    cur = mysql.connection.cursor()

    # opcionalno: provjera postoji li član
    cur.execute("SELECT id FROM clan WHERE id = %s", (id,))
    clan = cur.fetchone()

    if clan:
        cur.execute("DELETE FROM clan WHERE id = %s", (id,))
        mysql.connection.commit()

    cur.close()
    return redirect(url_for("clanovi"))

@app.route("/clanarine")
def clanarine():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT id, ime, prezime, aktivan
        FROM clan
        ORDER BY prezime, ime
    """)
    clanovi = cur.fetchall()
    cur.close()

    return render_template("clanarine.html", clanovi=clanovi)

@app.route("/clanarine/<int:id_clan>")
def clanarine_clana(id_clan):
    cur = mysql.connection.cursor()

    # Dohvati podatke o članu
    cur.execute("""
        SELECT ime, prezime
        FROM clan
        WHERE id = %s
    """, (id_clan,))
    clan = cur.fetchone()

    if clan is None:
        cur.close()
        return redirect(url_for("clanarine"))

    # Dohvati sve članarine tog člana
    cur.execute("""
        SELECT
            tc.naziv,
            sc.naziv,
            c.datum_pocetka,
            c.datum_zavrsetka
        FROM clanarina c
        JOIN tip_clanarine tc ON tc.id = c.id_tip
        JOIN status_clanarine sc ON sc.id = c.id_status
        WHERE c.id_clan = %s
        ORDER BY c.datum_pocetka DESC
    """, (id_clan,))
    clanarine = cur.fetchall()

    cur.close()

    return render_template(
        "clanarine_clana.html",
        clan=clan,
        clanarine=clanarine,
        id_clan=id_clan
    )

@app.route("/clanarine/nova", defaults={"id_clan": None}, methods=["GET", "POST"])
@app.route("/clanarine/nova/<int:id_clan>", methods=["GET", "POST"])
def clanarina_nova(id_clan):
    cur = mysql.connection.cursor()

    if request.method == "POST":
        id_clan = request.form["id_clan"]
        id_tip = request.form["id_tip"]
        id_status = request.form["id_status"]
        datum_pocetka = request.form["datum_pocetka"]

        # Dohvati trajanje tipa
        cur.execute(
            "SELECT trajanje_mjeseci FROM tip_clanarine WHERE id = %s",
            (id_tip,)
        )
        trajanje = cur.fetchone()[0]

        try:
            cur.execute("""
                INSERT INTO clanarina
                (id_clan, id_tip, id_status, datum_pocetka, datum_zavrsetka)
                VALUES
                (%s, %s, %s, %s, DATE_ADD(%s, INTERVAL %s MONTH))
            """, (
                id_clan, id_tip, id_status,
                datum_pocetka, datum_pocetka, trajanje
            ))

            mysql.connection.commit()
            cur.close()

            return redirect(url_for("clanarine_clana", id_clan=id_clan))

        except Exception as e:
            mysql.connection.rollback()
            cur.close()

            poruka = "Greška prilikom dodavanja članarine."

            if "aktivnu članarinu" in str(e):
                poruka = "Član već ima aktivnu članarinu."

            # ponovno učitaj podatke za formu
            if id_clan:
                cur = mysql.connection.cursor()
                cur.execute("SELECT id, ime, prezime FROM clan WHERE id = %s", (id_clan,))
                clanovi = [cur.fetchone()]
            else:
                cur = mysql.connection.cursor()
                cur.execute("SELECT id, ime, prezime FROM clan ORDER BY prezime")
                clanovi = cur.fetchall()

            cur.execute("SELECT id, naziv FROM tip_clanarine ORDER BY naziv")
            tipovi = cur.fetchall()

            cur.execute("SELECT id, naziv FROM status_clanarine ORDER BY id")
            statusi = cur.fetchall()
            cur.close()

            return render_template(
                "clanarina_nova.html",
                clanovi=clanovi,
                tipovi=tipovi,
                statusi=statusi,
                id_clan=id_clan,
                greska=poruka
            )


    # GET
    if id_clan:
        cur.execute("SELECT id, ime, prezime FROM clan WHERE id = %s", (id_clan,))
        clanovi = [cur.fetchone()]
    else:
        cur.execute("SELECT id, ime, prezime FROM clan ORDER BY prezime")
        clanovi = cur.fetchall()

    cur.execute("SELECT id, naziv FROM tip_clanarine ORDER BY naziv")
    tipovi = cur.fetchall()

    cur.execute("SELECT id, naziv FROM status_clanarine ORDER BY id")
    statusi = cur.fetchall()

    cur.close()

    return render_template(
        "clanarina_nova.html",
        clanovi=clanovi,
        tipovi=tipovi,
        statusi=statusi,
        id_clan=id_clan
    )

if __name__ == '__main__':
    app.run(debug=True, port=8000)
