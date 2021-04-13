const express = require("express");
var bodyParser = require('body-parser')
const jwt = require('jsonwebtoken');
var cors = require('cors')
require('crypto').randomBytes(64).toString('hex')
const dotenv = require('dotenv');
const app = express();
var jsonParser = bodyParser.json()

var urlencodedParser = bodyParser.urlencoded({ extended: false })

dotenv.config();

var mysql = require('mysql');
var conn = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'atm'
});

conn.connect();

function generateAccessToken(username) {
    return jwt.sign(username, process.env.TOKEN_SECRET, { expiresIn: '1800s' });
}

app.use(cors());

app.listen(3000, () => {
    console.log("El servidor está inicializado en el puerto 3000");
});

app.get('/', function (req, res) {
    res.send('ONLINE');
});

app.get('/getBalance/:cuentaId', function (req, res) {
    conn.query(`SELECT * FROM cuentas WHERE cliente_id = ${ req.params.cuentaId } LIMIT 1`, function (error, results) {
        if (error) throw error;

        return res.status(200).json({
            success: true,
            result: results[0]
        });
    });
});

app.patch('/retirarEfectivo/:cuentaId/:cantidad', function (req, res) {
    const { cantidad, cuentaId } = req.params;
    conn.query(`SELECT * FROM cuentas WHERE cliente_id = ${cuentaId} LIMIT 1`, function (error, results) {
        if (error) throw error;

        const cuenta = results[0];

        if (cuenta.balance >= cantidad) {
            const newBalance = cuenta.balance - cantidad;
            conn.query(`UPDATE cuentas SET balance = ${newBalance} WHERE id = ${cuentaId }`, function(error, newResults) {
                return res.status(200).json({
                    success: true,
                    result: newResults[0]
                });
            })            
        } else {
            return res.status(400).json({
                success: false,
                error: 'Fondos insuficientes'
            });
        }
    });
});


app.patch('/depositarDinero/:cuentaEmisora/:numCuenta/:cantidad', function (req, res) {
    const { cantidad, numCuenta, cuentaEmisora } = req.params;

  conn.query(`SELECT * FROM cuentas WHERE cliente_id = ${cuentaEmisora} LIMIT 1`, function (error, results) {
    if (error) throw error;

    const cuenta = results[0];

    if (cuenta.balance >= cantidad) {
      const newBalance = cuenta.balance - cantidad;
      conn.query(`UPDATE cuentas SET balance = ${newBalance} WHERE id = ${cuentaEmisora}`, function (error, newResults) {

        conn.query(`UPDATE cuentas SET balance = balance+${cantidad} WHERE numeroCuenta = ${numCuenta}`, function (error, newResults) {
          return res.status(200).json({
            success: true,
            result: newResults[0]
          });
        })
      })
    } else {
      return res.status(400).json({
        success: false,
        error: 'Fondos insuficientes'
      });
    }
  });


  
    
});

app.get('/login/:tarjeta/:nip', urlencodedParser, (req, res) => {
    const { tarjeta, nip } = req.params;

    console.log(req.body);

    console.log(`SELECT * FROM tarjetas WHERE numeroTarjeta = ${tarjeta}`);

    conn.query(`SELECT * FROM tarjetas WHERE numeroTarjeta = ${ tarjeta }`, (error, results) => {
        const tarjeta = results[0];

        if(tarjeta.nip == nip) {
            conn.query(`SELECT * FROM cuentas WHERE id = ${tarjeta.cuenta_id}`, (error, resultsCuenta) => {
                const cuenta = resultsCuenta[0];
                const token = generateAccessToken({
                    cuentaId: tarjeta.cuenta_id
                });

                return res.status(200).json({
                    success: true,
                    cuenta,
                    token
                });
            })            
        } else {
            return res.status(400).json({
                success: false,
                error: 'Nip incorrecto'
            });
        }
    });
});
