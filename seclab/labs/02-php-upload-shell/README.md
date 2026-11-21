# Lab 02 · Subida de archivos → webshell (php2shell)

**Vulnerabilidad:** subida de archivos sin validación (OWASP A05/A03). El portal
acepta cualquier archivo y lo guarda en el webroot, donde Apache ejecuta `.php`.
Subir una webshell = **RCE**.

> ⚠️ Solo laboratorio, en `127.0.0.1:8081`. Software vulnerable a propósito.
> Nunca contra sistemas de terceros (Ley 1273 de 2009).

## Reproducir

```bash
cd seclab/labs/02-php-upload-shell
docker compose up -d --build
./exploit.sh
docker compose down
```

Salida real (verificada):
```
-> id
uid=33(www-data) gid=33(www-data) groups=33(www-data)
-> uname -a
Linux ... aarch64 GNU/Linux
```
El servidor ejecutó comandos que **nosotros** elegimos, enviados por HTTP.

## Cómo lo detecta el pipeline

- **SAST (semgrep):** marca `move_uploaded_file` sobre un destino derivado del
  nombre del archivo sin validar (patrón de upload inseguro).
- **DAST:** un escaneo activo detecta el endpoint de subida que acepta `.php`.

Desde la raíz del seclab: `./bin/scan.sh labs/02-php-upload-shell`.

## La corrección

| Control | Qué hacer |
|---|---|
| **Validar tipo** | Allowlist de extensiones **y** verificación de contenido real (`finfo`/magic bytes), no solo la extensión. |
| **Fuera del webroot** | Guardar los archivos donde el servidor **no** los ejecute; servirlos por un handler que fuerza `Content-Disposition`. |
| **Renombrar** | Nombre aleatorio del servidor; nunca usar el nombre del cliente. |
| **Sin ejecución** | En la carpeta de subidas: `php_admin_flag engine off` / quitar el handler de PHP. |

Ver `app/upload.php` — la línea `$destino = $dir . $nombre;` es el fallo: el
nombre del cliente decide dónde y con qué extensión se guarda.
