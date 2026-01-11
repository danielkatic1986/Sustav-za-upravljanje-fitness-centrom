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

@app.route('/show_artikl', methods=['GET'])
def show_artikl():
    cur = mysql.connection.cursor()
    cur.execute('SELECT * FROM artikl')
    artikl_data = cur.fetchall()
    cur.close()

    return render_template('show_artikl.html', artikl_data=artikl_data)


@app.route('/insert_artikl_form', methods=['GET'])
def insert_artikl_form():
    return render_template('insert_artikl.html')


@app.route('/insert_artikl', methods=['POST'])
def insert_artikl():
    id = request.form['id']
    naziv = request.form['naziv']
    cijena = request.form['cijena']

    cur = mysql.connection.cursor()
    cur.execute('INSERT INTO artikl (id, naziv, cijena) VALUES (%s, %s, %s)', (id, naziv, cijena))
    mysql.connection.commit()
    cur.close()

    return redirect(url_for('show_artikl'))


@app.route('/show_racun', methods=['GET'])
def show_racun():
    cur = mysql.connection.cursor()
    cur.execute('SELECT * FROM pregled_racuna')
    racuni = cur.fetchall()
    cur.close()

    return render_template('show_racun.html', racuni=racuni)


@app.route('/insert_racun_form', methods=['GET'])
def insert_racun_form():

    cur = mysql.connection.cursor()
    cur.execute('SELECT * FROM zaposlenik')
    zaposlenici = cur.fetchall()

    cur.execute('SELECT * FROM kupac')
    kupci = cur.fetchall()
    cur.close()

    return render_template('insert_racun.html', zaposlenici=zaposlenici, kupci=kupci)


@app.route('/insert_racun', methods=['POST'])
def insert_racun():

    data = request.form

    id = data['id']
    id_zaposlenik = data['id_zaposlenik']
    id_kupac = data['id_kupac']
    broj = data['broj']
    datum_izdavanja = data['datum_izdavanja']

    cur = mysql.connection.cursor()
    cur.execute('INSERT INTO racun (id, id_zaposlenik, id_kupac, broj, datum_izdavanja) VALUES (%s, %s, %s, %s, %s)',
                (id, id_zaposlenik, id_kupac, broj, datum_izdavanja))
    mysql.connection.commit()
    cur.close()

    return redirect(url_for('show_racun'))


if __name__ == '__main__':
    app.run(debug=True, port=8000)
