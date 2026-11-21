#!/usr/bin/env bash
# triage.sh — Agente de triage. Prioriza y explica el último reporte de escaneo.
# Por diseño (como Auditgate): la IA ACONSEJA, nunca decide el gate.
#
#   - Si hay ANTHROPIC_API_KEY (u otra compatible), pide al modelo una
#     priorización y fixes. El resumen es consultivo.
#   - Si no hay llave, usa una base de conocimiento determinista (rule -> fix).
#
# Nunca ejecuta acciones; solo imprime recomendaciones.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECLAB="$(cd "$HERE/.." && pwd)"

REPORT="$(ls -t "$SECLAB"/.state/*/report.json 2>/dev/null | head -1)"
[ -z "$REPORT" ] && { echo "No hay reporte. Corre primero: make scan-all"; exit 0; }

echo "== Agente de triage · fuente: $REPORT =="
echo "   (la IA aconseja; el gate lo decide la regla determinista)"
echo

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  echo ">> Consultando al modelo (consultivo)…"
  FIND="$(python3 -c 'import json,sys;r=json.load(open(sys.argv[1]));print(json.dumps(r["findings"][:40]))' "$REPORT")"
  BODY=$(python3 -c '
import json,sys
findings=sys.argv[1]
prompt=("Eres un analista AppSec. Prioriza estos hallazgos (critico/alto/medio), "
        "explica el riesgo real en 1 linea y da el fix concreto. Responde en espanol, "
        "compacto, en vinetas. Hallazgos JSON: "+findings)
print(json.dumps({"model":"claude-3-5-sonnet-20241022","max_tokens":1200,
  "messages":[{"role":"user","content":prompt}]}))' "$FIND")
  curl -s https://api.anthropic.com/v1/messages \
    -H "x-api-key: ${ANTHROPIC_API_KEY}" \
    -H "anthropic-version: 2023-06-01" \
    -H "content-type: application/json" \
    --data "$BODY" | python3 -c '
import json,sys
try:
    d=json.load(sys.stdin); print(d["content"][0]["text"])
except Exception as e:
    print("No se pudo consultar el modelo:",e)'
  exit 0
fi

# ---- Modo determinista (sin llave): base de conocimiento ----
echo ">> Sin llave de modelo — triage determinista (base de conocimiento)."
echo
python3 - "$REPORT" <<'PY'
import json,sys,collections
r=json.load(open(sys.argv[1]))
KB={
 "secrets":"Rota la credencial YA (borrarla del código no basta: queda en el historial). Muévela a un vault/secret manager.",
 "sast":"Revisa el patrón inseguro en la línea indicada. Para exec/child_process usa listas de argumentos; para SQL, consultas parametrizadas.",
 "deps":"Actualiza la dependencia a una versión sin la CVE. Si no hay fix, evalúa alternativa o mitigación y documenta el riesgo residual.",
 "trivy":"Parchea el paquete/imagen base a una versión sin la vulnerabilidad; reconstruye y re-escanea.",
}
by=collections.Counter(f["tool"] for f in r["findings"])
sev=collections.Counter(f["severity"] for f in r["findings"])
print(f"  Total: {r['total']}   nuevas: {r['nuevas']}   subsanadas: {r['subsanadas']}")
print("  Por severidad:", dict(sev))
print()
order=["secrets","sast","deps","trivy"]
for tool in order:
    items=[f for f in r["findings"] if f["tool"]==tool]
    if not items: continue
    print(f"  ▸ {tool.upper()} ({len(items)})  →  {KB.get(tool,'Revisar.')}")
    for f in items[:3]:
        print(f"      - {f['severity']:<8} {f['rule']}  [{f['loc']}]")
    if len(items)>3: print(f"      … y {len(items)-3} más")
    print()
print("  Prioridad sugerida: secretos > SAST (RCE/inyección) > deps críticas > resto.")
PY
