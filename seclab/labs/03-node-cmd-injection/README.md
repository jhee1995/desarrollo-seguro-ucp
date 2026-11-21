# Lab 03 · Command injection + dependencia con CVE (Node)

**Dos fallas en una app Express:**
1. **Command injection (OWASP A03):** `/ping?host=` concatena la entrada en un
   comando de shell (`exec('ping -c 1 ' + host)`). → RCE.
2. **Dependencia vulnerable (OWASP A06):** `lodash@4.17.4` (prototype pollution,
   CVE-2019-10744), `minimist@1.2.0`, `express@4.17.1`. → lo caza el SCA.

> ⚠️ Solo laboratorio, en `127.0.0.1:8082`. Nunca contra terceros (Ley 1273/2009).

## Reproducir el RCE

```bash
cd seclab/labs/03-node-cmd-injection
docker compose up -d --build
./exploit.sh
docker compose down
```

Salida real (verificada) para `host=127.0.0.1;id`:
```
uid=0(root) gid=0(root) groups=0(root),...
```
El `;id` se ejecutó como comando: inyección confirmada.

## Cómo lo detecta el pipeline

- **SAST (semgrep):** marca `child_process.exec` con argumento no constante.
- **SCA (osv-scanner):** lee `package-lock.json` y reporta las CVE de lodash/minimist.

`./bin/scan.sh labs/03-node-cmd-injection` desde la raíz del seclab.

## La corrección

| Falla | Arreglo |
|---|---|
| **Command injection** | `execFile('ping', ['-c','1', host])` — argumentos como lista, nunca un string de shell. Validar `host` contra un patrón de hostname/IP. |
| **Dependencias** | Actualizar `lodash` ≥ 4.17.21, `minimist` ≥ 1.2.6, `express` al último. El SCA en el gate bloquea el PR que reintroduzca una versión vulnerable. |

Ver `app/server.js` — la línea `exec('ping -c 1 ' + host, ...)` es el fallo.
