<?php
// ------------------------------------------------------------------
// VULNERABLE A PROPOSITO — subida de archivos sin restricciones.
// No valida extension, tipo MIME ni contenido, y guarda el archivo
// DENTRO del webroot, donde Apache ejecuta cualquier .php.
// Resultado: subir shell.php => webshell => RCE. (OWASP A03/A05)
// Solo para el laboratorio del curso. NO usar en produccion.
// ------------------------------------------------------------------
$dir = __DIR__ . '/uploads/';
if (!is_dir($dir)) { mkdir($dir, 0777, true); }

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['archivo'])) {
    $nombre = basename($_FILES['archivo']['name']);          // <-- sin saneo
    $destino = $dir . $nombre;                                // <-- destino en webroot
    if (move_uploaded_file($_FILES['archivo']['tmp_name'], $destino)) {
        echo "Archivo subido: <a href='uploads/" . htmlspecialchars($nombre) . "'>" .
             htmlspecialchars($nombre) . "</a>";
    } else {
        http_response_code(500); echo "Error al subir.";
    }
} else {
    http_response_code(400); echo "Peticion invalida.";
}
