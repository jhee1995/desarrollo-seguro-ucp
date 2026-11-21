<!doctype html>
<html lang="es"><head><meta charset="utf-8"><title>Subir comprobante</title></head>
<body style="font-family:system-ui;max-width:640px;margin:40px auto">
  <h1>Portal de comprobantes</h1>
  <p>Suba su comprobante de pago (JPG/PNG).</p>
  <!-- VULNERABLE: no valida extension ni contenido; guarda en el webroot -->
  <form action="upload.php" method="post" enctype="multipart/form-data">
    <input type="file" name="archivo" required>
    <button type="submit">Subir</button>
  </form>
</body></html>
