from flask import Flask, request, jsonify
from flask_mysqldb import MySQL

app = Flask(__name__)

app.config['JSON_AS_ASCII'] = False

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'blagajnik'
app.config['MYSQL_PASSWORD'] = 'blagajnik'
app.config['MYSQL_DB'] = 'trgovina'
# app.config["MYSQL_AUTOCOMMIT"] = True ili False ... odaberite po želji i prema tome onda koristite ili ne koristite mysql.connection.commit()

mysql = MySQL(app)


@app.route('/artikl', methods=['GET'])
def get_artikl():

    cur = mysql.connection.cursor()
    cur.execute('SELECT * FROM artikl')
    artikli = cur.fetchall()
    cur.close()

    return jsonify(artikli)


# curl -X POST -F "id=24" -F "naziv=Puding" -F "cijena=9.5" http://localhost:8000/artikl
@app.route('/artikl', methods=['POST'])
def insert_artikl():

    #data = request.get_json()
    data = request.form
    print(data)
    id = data['id']
    naziv = data['naziv']
    cijena = data['cijena']

    cur = mysql.connection.cursor()
    cur.execute('INSERT INTO artikl (id, naziv, cijena) VALUES (%s, %s, %s)', (id, naziv, cijena))
    mysql.connection.commit()
    cur.close()

    return jsonify({'msg':  'Artikl ' + naziv + ' uspješno spremljen!'})


# curl -X PUT -F "naziv=Jogurt" -F "cijena=6.2" http://localhost:8000/artikl/24
@app.route('/artikl/<int:id>', methods=['PUT'])
def update_artikl(id):

    #data = request.get_json()
    data = request.form
    print(data)
    naziv = data['naziv']
    cijena = data['cijena']

    cur = mysql.connection.cursor()
    cur.execute('UPDATE artikl SET naziv=%s, cijena=%s WHERE id=%s', (naziv, cijena, id))
    mysql.connection.commit()
    cur.close()

    return jsonify({'msg': 'Artikl ' + naziv + ' uspješno ažuriran!'})


# curl -X DELETE http://localhost:8000/artikl/24
@app.route('/artikl/<int:id>', methods=['DELETE'])
def delete_artikl(id):

    cur = mysql.connection.cursor()
    cur.execute('DELETE FROM artikl WHERE id=%s', (id,))
    mysql.connection.commit()
    cur.close()

    return jsonify({'msg': 'Artikl ' + str(id) + ' uspješno izbrisan!'})


# http://localhost:8000/racun/31
@app.route('/racun/<int:id>', methods=['GET'])
def show_pregled_racuna(id):

    cur = mysql.connection.cursor()
    cur.execute('SELECT * FROM pregled_racuna WHERE id=%s', (id,))
    result = cur.fetchall()

    cur.execute('SELECT * FROM pregled_stavki_racuna WHERE id_racun=%s', (id,))
    stavka_racun_result = cur.fetchall()

    cur.close()

    return jsonify({'pregled_racuna': result, 'stavka_racun': stavka_racun_result})


# curl -X POST -F "id=34" -F "id_zaposlenik=12" -F "id_kupac=2" -F "broj=00004" -F "datum_izdavanja=2023-12-20" http://localhost:8000/racun
@app.route('/racun', methods=['POST'])
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

    return jsonify({'msg': 'Račun ' + broj + ' uspješno spremljen!'})


# curl -X POST -F "id=45" -F "id_racun=34" -F "id_artikl=22" -F "kolicina=4" http://localhost:8000/stavka_racun
@app.route('/stavka_racun', methods=['POST'])
def insert_stavka_racun():
    data = request.form

    id_racun = data['id_racun']
    id_artikl = data['id_artikl']
    kolicina = data['kolicina']

    cur = mysql.connection.cursor()
    cur.execute('INSERT INTO stavka_racun (id_racun, id_artikl, kolicina) VALUES (%s, %s, %s)',
                (id_racun, id_artikl, kolicina))
    mysql.connection.commit()
    cur.close()

    return jsonify({'msg': 'Stavka računa za artikl ' + id_artikl + ' uspješno spremljena!'})


@app.route('/izvjestaj', methods=['GET'])
def show_izvjestaj():

    cur = mysql.connection.cursor()
    cur.execute('SELECT * FROM izvjestaj')
    result = cur.fetchall()
    cur.close()

    return jsonify(result)


# curl -X POST -F "p_par=ulazniparametar" http://localhost:8000/call_obracun
@app.route('/call_obracun', methods=['POST'])
def call_obracun():
    data = request.form
    p_par = data['p_par']

    cur = mysql.connection.cursor()
    cur.callproc('obracun', [p_par, 0])
    cur.execute('SELECT @_obracun_1')
    p_out = cur.fetchone()
    cur.close()

    return jsonify({'p_out': p_out})


if __name__ == '__main__':
    app.run(debug=True, port=8000)
