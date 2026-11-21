#!/usr/bin/env bash
# notify.sh — publica el resumen del escaneo en Slack / Discord / Telegram y
# empuja las metricas a Prometheus Pushgateway. Se activa solo si hay webhook.
#
#   notify.sh <state_dir> <scan_dir>
#
# Variables de entorno (defina solo las que use):
#   SECLAB_WEBHOOK_SLACK     https://hooks.slack.com/services/...
#   SECLAB_WEBHOOK_DISCORD   https://discord.com/api/webhooks/...
#   SECLAB_TELEGRAM_TOKEN    123456:ABC...   + SECLAB_TELEGRAM_CHAT  <chat_id>
#   SECLAB_PUSHGATEWAY       http://localhost:9091   (default)
set -uo pipefail
STATE="${1:?state dir}"; SCANDIR="${2:-?}"
REPORT="$STATE/report.json"; METRICS="$STATE/metrics.prom"
[ -f "$REPORT" ] || exit 0

read -r TOTAL NEW FIXED SECR SAST DEPS < <(python3 - "$REPORT" <<'PY'
import json,sys
r=json.load(open(sys.argv[1])); t=r.get("tools",{})
print(r.get("total",0), r.get("nuevas",0), r.get("subsanadas",0),
      t.get("secrets",0), t.get("sast",0), t.get("deps",0))
PY
)

PROJ="$(basename "$SCANDIR")"
if [ "$TOTAL" -gt 0 ]; then EMOJI="🚫"; STATUS="BLOQUEA"; else EMOJI="✅"; STATUS="PASA"; fi
TEXT="${EMOJI} *DevSecOps · ${PROJ}* — gate ${STATUS}
Hallazgos: *${TOTAL}*  (secretos ${SECR} · SAST ${SAST} · deps ${DEPS})
▲ nuevas: ${NEW}   ▼ subsanadas: ${FIXED}"

# ---- Slack ----
if [ -n "${SECLAB_WEBHOOK_SLACK:-}" ]; then
  payload=$(python3 -c 'import json,sys;print(json.dumps({"text":sys.argv[1]}))' "$TEXT")
  curl -s -X POST -H 'Content-type: application/json' --data "$payload" \
       "$SECLAB_WEBHOOK_SLACK" >/dev/null && echo "   ↳ Slack notificado" || true
fi

# ---- Discord ----
if [ -n "${SECLAB_WEBHOOK_DISCORD:-}" ]; then
  payload=$(python3 -c 'import json,sys;print(json.dumps({"content":sys.argv[1]}))' "$TEXT")
  curl -s -X POST -H 'Content-type: application/json' --data "$payload" \
       "$SECLAB_WEBHOOK_DISCORD" >/dev/null && echo "   ↳ Discord notificado" || true
fi

# ---- Telegram ----
if [ -n "${SECLAB_TELEGRAM_TOKEN:-}" ] && [ -n "${SECLAB_TELEGRAM_CHAT:-}" ]; then
  curl -s -X POST "https://api.telegram.org/bot${SECLAB_TELEGRAM_TOKEN}/sendMessage" \
       --data-urlencode "chat_id=${SECLAB_TELEGRAM_CHAT}" \
       --data-urlencode "text=${TEXT}" \
       --data-urlencode "parse_mode=Markdown" >/dev/null && echo "   ↳ Telegram notificado" || true
fi

# ---- Pushgateway (Grafana/Prometheus) ----
PG="${SECLAB_PUSHGATEWAY:-http://localhost:9091}"
if [ -f "$METRICS" ]; then
  if curl -s --max-time 3 --data-binary @"$METRICS" \
       "${PG}/metrics/job/seclab/instance/${PROJ}" >/dev/null 2>&1; then
    echo "   ↳ metricas enviadas a Pushgateway (${PG})"
  fi
fi
exit 0
