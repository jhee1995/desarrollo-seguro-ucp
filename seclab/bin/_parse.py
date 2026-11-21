#!/usr/bin/env python3
"""Lee los reportes de los escaneres, imprime un resumen con gate, calcula el
diff de alarmas (nuevas / subsanadas) vs la corrida anterior y escribe:
  <state>/report.json     reporte legible por maquina
  <state>/metrics.prom    metricas Prometheus (para pushgateway/Grafana)
  <state>/_total          total de hallazgos (para el gate del shell)
  <state>/prev.json       snapshot de esta corrida (para el proximo diff)
"""
import json, os, sys, time, datetime

C = dict(g="\033[38;5;46m", y="\033[38;5;226m", c="\033[38;5;51m",
         r="\033[38;5;196m", d="\033[2m", b="\033[1m", x="\033[0m")

state = sys.argv[1]

def load(name):
    p = os.path.join(state, name)
    try:
        with open(p) as f:
            return json.load(f)
    except Exception:
        return None

findings = []   # (tool, sev, rule, loc)

# --- gitleaks: lista de objetos ---
g = load("gitleaks.json")
if isinstance(g, list):
    for it in g:
        findings.append(("secrets", "HIGH",
                         it.get("RuleID", "secret"),
                         f"{it.get('File','?')}:{it.get('StartLine','?')}"))

# --- semgrep: {results:[...]} ---
s = load("semgrep.json")
if isinstance(s, dict):
    for it in s.get("results", []):
        sev = (it.get("extra", {}).get("severity", "WARNING") or "WARNING").upper()
        findings.append(("sast", sev,
                         it.get("check_id", "rule").split(".")[-1],
                         f"{it.get('path','?')}:{it.get('start',{}).get('line','?')}"))

# --- osv-scanner: {results:[{packages:[{package, vulnerabilities:[...]}]}]} ---
o = load("osv.json")
if isinstance(o, dict):
    for res in o.get("results", []):
        src = res.get("source", {}).get("path", "?")
        for pkg in res.get("packages", []):
            name = pkg.get("package", {}).get("name", "?")
            ver = pkg.get("package", {}).get("version", "?")
            for v in pkg.get("vulnerabilities", []):
                findings.append(("deps", "HIGH", v.get("id", "CVE"),
                                 f"{name}@{ver} ({os.path.basename(src)})"))

# --- trivy: {Results:[{Vulnerabilities:[...]}]} ---
t = load("trivy.json")
if isinstance(t, dict):
    for res in t.get("Results", []) or []:
        for v in res.get("Vulnerabilities", []) or []:
            findings.append(("trivy", (v.get("Severity", "UNKNOWN") or "UNKNOWN").upper(),
                             v.get("VulnerabilityID", "CVE"),
                             f"{v.get('PkgName','?')}@{v.get('InstalledVersion','?')}"))

# --- conteos por herramienta ---
tools = {}
for tool, *_ in findings:
    tools[tool] = tools.get(tool, 0) + 1
total = len(findings)

# --- diff nuevas / subsanadas ---
def key(f):  # (tool, rule, loc) estable
    return f"{f[0]}|{f[2]}|{f[3]}"
cur_keys = set(key(f) for f in findings)
prev = load("prev.json") or {}
prev_keys = set(prev.get("keys", []))
nuevas = cur_keys - prev_keys
subsanadas = prev_keys - cur_keys

# ---------------- salida en pantalla ----------------
names = {"secrets": "secretos  (gitleaks)", "sast": "SAST      (semgrep) ",
         "deps": "SCA       (osv)     ", "trivy": "vulns     (trivy)   "}
out = []
out.append(f"\n   {C['b']}{C['c']}╭─ Resultado del escaneo ─────────────────────────╮{C['x']}")
order = ["secrets", "sast", "deps", "trivy"]
for tool in order:
    if tool in tools or tool in ("secrets", "sast", "deps"):
        n = tools.get(tool, 0)
        col = C['r'] if n else C['g']
        mark = "✖" if n else "✔"
        out.append(f"   {C['c']}│{C['x']} {col}{mark}{C['x']} {names.get(tool,tool)}  {col}{C['b']}{n:>3}{C['x']}"
                   f"{' '*22}{C['c']}│{C['x']}")
out.append(f"   {C['c']}╰─────────────────────────────────────────────────╯{C['x']}")

# top hallazgos (hasta 8)
sev_rank = {"CRITICAL": 0, "ERROR": 1, "HIGH": 1, "WARNING": 2, "MEDIUM": 2, "LOW": 3, "INFO": 4}
top = sorted(findings, key=lambda f: sev_rank.get(f[1], 5))[:8]
if top:
    out.append(f"\n   {C['b']}Hallazgos destacados:{C['x']}")
    for tool, sev, rule, loc in top:
        col = C['r'] if sev in ("CRITICAL", "ERROR", "HIGH") else C['y']
        out.append(f"     {col}{sev:<8}{C['x']} {C['d']}{tool:<7}{C['x']} {rule}  {C['d']}{loc}{C['x']}")

if nuevas or subsanadas:
    out.append("")
    if nuevas:
        out.append(f"   {C['r']}▲ {len(nuevas)} alarma(s) NUEVA(s) desde la ultima corrida{C['x']}")
    if subsanadas:
        out.append(f"   {C['g']}▼ {len(subsanadas)} alarma(s) SUBSANADA(s) — buen trabajo{C['x']}")

print("\n".join(out))

# ---------------- artefactos ----------------
now = datetime.datetime.now(datetime.timezone.utc).replace(microsecond=0, tzinfo=None).isoformat() + "Z"
report = {
    "generated": now, "dir": state, "total": total, "tools": tools,
    "nuevas": len(nuevas), "subsanadas": len(subsanadas),
    "findings": [{"tool": f[0], "severity": f[1], "rule": f[2], "loc": f[3]} for f in findings],
}
with open(os.path.join(state, "report.json"), "w") as f:
    json.dump(report, f, indent=2, ensure_ascii=False)

# metricas Prometheus (textfile / pushgateway)
lines = ["# HELP seclab_findings Hallazgos de seguridad por herramienta",
         "# TYPE seclab_findings gauge"]
for tool in order:
    lines.append(f'seclab_findings{{tool="{tool}"}} {tools.get(tool,0)}')
lines += [f'seclab_findings_total {total}',
          f'seclab_findings_new {len(nuevas)}',
          f'seclab_findings_fixed {len(subsanadas)}',
          f'seclab_scan_timestamp {int(time.time())}']
with open(os.path.join(state, "metrics.prom"), "w") as f:
    f.write("\n".join(lines) + "\n")

with open(os.path.join(state, "_total"), "w") as f:
    f.write(str(total))

with open(os.path.join(state, "prev.json"), "w") as f:
    json.dump({"keys": sorted(cur_keys), "at": now}, f)
