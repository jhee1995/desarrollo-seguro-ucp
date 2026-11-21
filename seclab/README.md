# SecLab · DevSecOps didáctico de extremo a extremo

Laboratorios con **vulnerabilidades reales**, su **explotación**, el **pipeline que las detecta** (secretos + SAST + SCA), el **gate** que bloquea, **monitoreo en tiempo real** en Grafana y un **agente de triage**. Todo corre con Docker: cero instalaciones en tu Ubuntu.

> ⚠️ **Scope y legalidad.** Todo el software de `labs/` es vulnerable **a propósito**
> y corre solo en `127.0.0.1` / redes Docker aisladas. Nunca lo expongas ni lo
> apuntes a sistemas de terceros (Ley 1273 de 2009).

## Requisito único

**Docker + Docker Compose.** Nada más. (En Ubuntu: `sudo apt install docker.io docker-compose-plugin && sudo usermod -aG docker $USER` y reinicia sesión.)

## Arranque en 60 segundos

```bash
cd seclab
make labs            # ver los laboratorios
make demo LAB=02-php-upload-shell   # levanta, EXPLOTA y baja un lab
make scan-all        # Heisenberg cocina el escaneo de todos los labs → gate
make monitor         # Grafana en http://localhost:3001 (admin / seclab)
make triage          # el agente prioriza el último reporte
```

`make help` lista todo.

## Los laboratorios

| Lab | Vulnerabilidad | Clase | Exploit verificado |
|---|---|---|---|
| **01-log4shell** | CVE-2021-44228 (RCE vía JNDI) | cadena de suministro | `uid=0` escribe `/tmp/pwned.txt` |
| **02-php-upload-shell** | subida sin validar → webshell (php2shell) | A05/A03 | `uid=33(www-data)` ejecuta comandos |
| **03-node-cmd-injection** | command injection + deps con CVE | A03/A06 | `uid=0` vía `host=127.0.0.1;id` |

Cada lab trae `docker-compose.yml`, `exploit.sh` y `README.md` con la corrección.

## El pipeline (un solo motor, local = CI)

```
  código  ──▶  bin/scan.sh  ──▶  gitleaks · semgrep · osv(-scanner) [· trivy]
                   │
                   ├─▶ gate: exit 1 si hay hallazgos  (igual en CI y en tu terminal)
                   ├─▶ report.json + metrics.prom + diff (nuevas / subsanadas)
                   ├─▶ Pushgateway → Prometheus → Grafana  (tiempo real)
                   └─▶ notify.sh → Slack / Discord / Telegram
```

- **Local:** `make scan-all` — Heisenberg cocina el escaneo y aplica el gate.
- **CI:** copia `ci/security-pipeline.yml` a `.github/workflows/` — mismo escaneo, bloquea el PR.
- **Monitoreo:** `make monitor` → dashboard `SecLab · DevSecOps en tiempo real`.
- **Alertas:** define `SECLAB_WEBHOOK_SLACK` / `_DISCORD` / `SECLAB_TELEGRAM_*` y cada escaneo las publica, con **seguimiento de alarmas subsanadas**.
- **Agente:** `make triage` — aconseja (la IA nunca decide el gate). Con `ANTHROPIC_API_KEY` usa el modelo; sin llave, base de conocimiento determinista.

## Metodología (todo el ciclo, automatizado)

| Fase | Aquí |
|---|---|
| **Modelar** | el README de cada lab nombra la amenaza (OWASP) |
| **Explotar** | `exploit.sh` — prueba contundente de impacto |
| **Detectar** | `scan.sh` — secretos + SAST + SCA |
| **Bloquear** | gate determinista (exit 1), local y en CI |
| **Monitorear** | Grafana en tiempo real + diff de alarmas |
| **Remediar** | sección «corrección» de cada lab + `triage` |
| **Verificar** | re-escanear → alarmas **subsanadas** suben en el dashboard |

## Estructura

```
seclab/
├─ Makefile                 un comando para todo
├─ bin/                     heisenberg.sh · scan.sh · _parse.py · notify.sh · triage.sh
├─ labs/                    01-log4shell · 02-php-upload-shell · 03-node-cmd-injection
├─ ci/security-pipeline.yml workflow de GitHub Actions
└─ monitoring/             Prometheus + Pushgateway + Grafana (dashboard provisionado)
```
