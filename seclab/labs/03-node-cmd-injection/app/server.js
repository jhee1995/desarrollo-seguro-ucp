// VULNERABLE A PROPOSITO — command injection (OWASP A03).
// /ping?host= concatena entrada no confiable en un comando de shell.
// Solo laboratorio. NO exponer.
const express = require('express');
const { exec } = require('child_process');
const app = express();

app.get('/', (_req, res) =>
  res.type('text').send('Servicio de diagnostico. Uso: /ping?host=127.0.0.1\n'));

app.get('/ping', (req, res) => {
  const host = req.query.host || '127.0.0.1';
  // <-- LINEA VULNERABLE: exec con string concatenado -> inyeccion de comandos
  exec('ping -c 1 ' + host, (err, stdout, stderr) => {
    res.type('text').send(stdout + stderr + (err ? '\n[err] ' + err.message : ''));
  });
});

app.listen(3000, () => console.log('pinger escuchando en 3000'));
