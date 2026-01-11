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


if __name__ == '__main__':
    app.run(debug=True, port=8000)
