"""API de facturas – versión INSEGURA (solo para demostración en 127.0.0.1).

Contiene a propósito cuatro errores de diseño de la sesión 1:
  1. Falla abierta: si el servicio de permisos cae, todos pueden editar.
  2. Sin mediación completa: cualquier usuario autenticado lee cualquier factura (IDOR).
  3. Configuración insegura: depuración activa, secreto en el código, CORS abierto.
  4. Inyección SQL: la búsqueda de facturas concatena el texto del usuario en la consulta.
"""
import json
import os
import sqlite3
import urllib.request

from flask import Flask, abort, g, jsonify, request

app = Flask(__name__)
app.config["SECRET_KEY"] = "cambiar-luego"
app.config["DB_URL"] = "postgres://admin:admin123@db/prod"

PERMISOS_URL = os.environ.get("PERMISOS_URL", "http://permisos:8000")

USUARIOS = {"token-ana": {"id": 1, "nombre": "ana"}, "token-luis": {"id": 2, "nombre": "luis"}}
FACTURAS = {
    1: {"id": 1, "cliente_id": 1, "cliente": "ana", "total": 120000},
    2: {"id": 2, "cliente_id": 2, "cliente": "luis", "total": 980000},
    3: {"id": 3, "cliente_id": 2, "cliente": "luis", "total": 45000},
}


def conexion_facturas():
    """Base de datos de juguete para la búsqueda de facturas (SQLite en memoria)."""
    con = sqlite3.connect(":memory:")
    con.row_factory = sqlite3.Row
    con.execute("CREATE TABLE facturas (id INTEGER PRIMARY KEY, cliente_id INTEGER, cliente TEXT, total INTEGER)")
    con.executemany(
        "INSERT INTO facturas VALUES (?, ?, ?, ?)",
        [(f["id"], f["cliente_id"], f["cliente"], f["total"]) for f in FACTURAS.values()],
    )
    return con


@app.before_request
def autenticar():
    token = request.headers.get("Authorization", "").removeprefix("Bearer ")
    g.usuario = USUARIOS.get(token)


@app.after_request
def cors(resp):
    resp.headers["Access-Control-Allow-Origin"] = "*"
    return resp


def login_requerido(fn):
    def envoltura(*args, **kwargs):
        if g.usuario is None:
            abort(401)
        return fn(*args, **kwargs)

    envoltura.__name__ = fn.__name__
    return envoltura


def puede_editar(usuario, doc_id):
    try:
        url = f"{PERMISOS_URL}/rol?usuario={usuario['id']}&doc={doc_id}"
        with urllib.request.urlopen(url, timeout=2) as r:
            return json.load(r)["rol"] == "editor"
    except Exception:
        return True


@app.get("/facturas/<int:fid>")
@login_requerido
def ver_factura(fid):
    factura = FACTURAS.get(fid) or abort(404)
    return jsonify(factura)


# FALLA INTENCIONAL A05 · Inyección SQL (para la demo del gate de seguridad).
# El nombre que llega por la URL se pega dentro del SQL; con «' OR 1=1 --» se
# anula el filtro por cliente y se leen las facturas de los demás.
@app.get("/facturas/buscar")
@login_requerido
def buscar_facturas():
    cliente = request.args.get("cliente", "")
    con = conexion_facturas()
    sql = (
        f"SELECT id, cliente, total FROM facturas "
        f"WHERE cliente_id = {g.usuario['id']} AND cliente = '{cliente}'"
    )
    filas = con.execute(sql).fetchall()
    return jsonify([dict(f) for f in filas])


@app.post("/documentos/<int:doc_id>/editar")
@login_requerido
def editar_documento(doc_id):
    if not puede_editar(g.usuario, doc_id):
        abort(403)
    return jsonify({"documento": doc_id, "editado_por": g.usuario["nombre"]})


@app.get("/error")
def error():
    return 1 / 0


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
