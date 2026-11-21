#!/usr/bin/env bash
# scan.sh — "cocina" un escaneo de seguridad sobre un directorio usando solo
# Docker (cero instalaciones): secretos + SAST + SCA (+ SBOM/vulns opcional).
# Produce: resumen con gate, reporte JSON, metricas Prometheus y diff de
# alarmas (nuevas / subsanadas). Opcionalmente notifica a Slack/Discord/Telegram.
#
#   bin/scan.sh [ruta]                 escanea ruta (default: .)
#   bin/scan.sh --with-trivy [ruta]    agrega Trivy (SBOM + vulns de SO/deps)
#   bin/scan.sh --soft [ruta]          no falla aunque haya hallazgos
#   bin/scan.sh --no-anim [ruta]       sin animacion (CI)
#
# Env: SECLAB_WEBHOOK_SLACK / _DISCORD / TELEGRAM_* -> notifica (ver notify.sh)
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECLAB="$(cd "$HERE/.." && pwd)"

GREEN=$'\033[38;5;46m'; YEL=$'\033[38;5;226m'; CYAN=$'\033[38;5;51m'
RED=$'\033[38;5;196m'; DIM=$'\033[2m'; BOLD=$'\033[1m'; RST=$'\033[0m'

WITH_TRIVY=0; SOFT=0; ANIM=1; TARGET="."
for a in "$@"; do
  case "$a" in
    --with-trivy) WITH_TRIVY=1;;
    --soft) SOFT=1;;
    --no-anim) ANIM=0;;
    __run) :;;
    *) TARGET="$a";;
  esac
done

# ---- fase interna: corre los escaneres (se invoca envuelta por heisenberg) ----
if [ "${1:-}" = "__run" ]; then
  SCANDIR="$2"; STATE="$3"; WITH_TRIVY="$4"
  mkdir -p "$STATE"
  DR="docker run --rm -v ${SCANDIR}:/scan -v ${STATE}:/scan/.state"

  echo ">> secretos (gitleaks)"
  $DR zricethezav/gitleaks:latest detect --no-git --source=/scan \
     --report-format=json --report-path=/scan/.state/gitleaks.json >/dev/null 2>&1 || true

  echo ">> SAST (semgrep)"
  $DR semgrep/semgrep:latest semgrep scan --config=p/default --json \
     --output=/scan/.state/semgrep.json /scan >/dev/null 2>&1 || true

  echo ">> SCA (osv-scanner)"
  $DR ghcr.io/google/osv-scanner:latest --format=json \
     --output=/scan/.state/osv.json -r /scan >/dev/null 2>&1 || true

  if [ "$WITH_TRIVY" = "1" ]; then
    echo ">> SBOM + vulns (trivy)"
    docker run --rm -v "${SCANDIR}:/scan" -v "${STATE}:/scan/.state" \
       -v trivy-db-cache:/root/.cache/ aquasec/trivy:latest fs --quiet \
       --format=json --output=/scan/.state/trivy.json /scan >/dev/null 2>&1 || true
  fi
  echo ">> escaneres terminados"
  exit 0
fi

# ---------------------------- orquestacion -----------------------------------
SCANDIR="$(cd "$TARGET" 2>/dev/null && pwd)"
[ -z "$SCANDIR" ] && { echo "${RED}Ruta no existe: $TARGET${RST}"; exit 2; }
STATE="$SECLAB/.state/$(echo "$SCANDIR" | md5 2>/dev/null || echo "$SCANDIR" | md5sum | cut -d' ' -f1)"
mkdir -p "$STATE"

printf "\n${BOLD}${YEL}  LOS POLLOS DEVSECOPS${RST} — escaneando ${CYAN}%s${RST}\n\n" "$SCANDIR"

if [ "$ANIM" = "1" ] && [ -t 1 ]; then
  "$HERE/heisenberg.sh" "Cocinando el escaneo…" -- "$0" __run "$SCANDIR" "$STATE" "$WITH_TRIVY"
else
  "$0" __run "$SCANDIR" "$STATE" "$WITH_TRIVY"
fi

# ---------------------------- parseo + gate ----------------------------------
SUMMARY="$(python3 "$HERE/_parse.py" "$STATE")"
echo "$SUMMARY"
TOTAL="$(cat "$STATE/_total" 2>/dev/null || echo 0)"

# ---------------------------- notificar --------------------------------------
if [ -x "$HERE/notify.sh" ]; then
  "$HERE/notify.sh" "$STATE" "$SCANDIR" || true
fi

# ---------------------------- gate -------------------------------------------
echo
if [ "$TOTAL" -gt 0 ]; then
  if [ "$SOFT" = "1" ]; then
    printf "   ${YEL}● %s hallazgo(s). Modo --soft: no bloquea.${RST}\n" "$TOTAL"; exit 0
  fi
  printf "   ${RED}${BOLD}🚫 GATE: %s hallazgo(s) — bloquea.${RST}  ${DIM}(exit 1)${RST}\n" "$TOTAL"
  exit 1
fi
printf "   ${GREEN}${BOLD}✅ GATE: sin hallazgos — pasa.${RST}  ${DIM}(exit 0)${RST}\n"
exit 0
