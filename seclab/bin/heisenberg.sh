#!/usr/bin/env bash
# heisenberg.sh — Heisenberg "cocina" el escaneo mientras un comando corre.
#
#   heisenberg.sh "Cocinando el escaneo…" -- <comando...>
#       corre <comando> en segundo plano, anima a Heisenberg hasta que termina,
#       y devuelve el mismo exit code del comando.
#   heisenberg.sh --demo
#       solo muestra la animación unos segundos (para probarla).
#
# Sin dependencias: bash + tput. Degrada a texto plano si no hay TTY.
set -u

GREEN=$'\033[38;5;46m'; YEL=$'\033[38;5;226m'; CYAN=$'\033[38;5;51m'
DIM=$'\033[2m'; BOLD=$'\033[1m'; RED=$'\033[38;5;196m'; RST=$'\033[0m'
HIDE=$'\033[?25l'; SHOW=$'\033[?25h'

msg="${1:-Cocinando…}"

# Burbujas y vapor que rotan por frame
BUBBLES=( "°  o   .  " " o  .  °  " ".  °  o  ." "o  .   ° o" )
STEAM=(   "   ~       " "     ~     " "       ~   " "  ~    ~   " )
PIPET=( "      o" "     o " "    o  " "   o   " )   # gota que cae

frame() {
  local i=$1 b="${BUBBLES[$((i % 4))]}" s="${STEAM[$((i % 4))]}" pz="${PIPET[$((i % 4))]}"
  cat <<FR
${CYAN}${s}${RST}
        ${DIM}\\${RST}${pz}${RST}            ${YEL}┌─ LOS POLLOS DEVSECOPS ─┐${RST}
         ${DIM}\\${RST}                 ${YEL}│${RST}  ${BOLD}HEISENBERG${RST} está cocinando
      ${YEL}.-----------.${RST}        ${YEL}│${RST}  la receta del escaneo
     ${YEL}/  ${BOLD}_________${RST}${YEL}  \\${RST}       ${YEL}└────────────────────────┘${RST}
    ${YEL}|  / ${RST}o   o${YEL} \\  |${RST}
    ${YEL}|  |   ${RST}<${YEL}     |  |${RST}      ${DIM}"No half measures."${RST}
    ${YEL}|   \\  ${RST}\\___/${YEL}  /   |${RST}
     ${YEL}\\   '-------'   /${RST}
      ${YEL}'-----------'${RST}
       ${GREEN}._________.${RST}
      ${GREEN}(${RST}${b}${GREEN})${RST}   ${GREEN}100% puro${RST}
    ${GREEN}.-'-----------'-.${RST}
   ${GREEN}[_|_|_|_|_|_|_|_|_]${RST}  ${CYAN}gitleaks · semgrep · osv · trivy${RST}
FR
}

spinner='|/-\\'
animate_until() { # $1 = archivo-centinela; anima hasta que exista
  local done_file="$1" i=0 sp=0
  tput civis 2>/dev/null; printf '%s' "$HIDE"
  tput clear 2>/dev/null
  while [ ! -f "$done_file" ]; do
    tput cup 0 0 2>/dev/null || printf '\033[H'
    frame "$i"
    printf "\n   ${BOLD}${GREEN}%s${RST} ${YEL}%s${RST}  ${DIM}(%ss)${RST}\n" \
      "${spinner:$((sp%4)):1}" "$msg" "$((i/5))"
    i=$((i+1)); sp=$((sp+1)); sleep 0.2
  done
  printf '%s' "$SHOW"; tput cnorm 2>/dev/null
}

if [ "${1:-}" = "--demo" ]; then
  d=$(mktemp -u); ( sleep 4; : > "$d" ) &
  animate_until "$d"; rm -f "$d"
  printf "\n   ${GREEN}✔ receta lista.${RST}\n"; exit 0
fi

# Modo wrapper:  heisenberg.sh "msg" -- comando...
cmd=(); seen=0
for a in "$@"; do
  if [ "$seen" = 1 ]; then cmd+=("$a"); fi
  if [ "$a" = "--" ]; then seen=1; fi
done

if [ "${#cmd[@]}" -eq 0 ]; then
  # sin comando: anima 3s
  d=$(mktemp -u); ( sleep 3; : > "$d" ) & animate_until "$d"; rm -f "$d"; exit 0
fi

# Si no hay TTY, corre el comando sin animación
if [ ! -t 1 ]; then
  printf '>> %s\n' "$msg"; "${cmd[@]}"; exit $?
fi

done_file=$(mktemp -u); log_file=$(mktemp)
( "${cmd[@]}" >"$log_file" 2>&1; echo $? >"${done_file}.rc"; : > "$done_file" ) &
animate_until "$done_file"
rc=$(cat "${done_file}.rc" 2>/dev/null || echo 1)
tput clear 2>/dev/null || printf '\033[2J\033[H'
if [ "$rc" = "0" ]; then
  printf "   ${GREEN}✔ %s — listo.${RST}\n\n" "$msg"
else
  printf "   ${RED}✖ %s — exit %s.${RST}\n\n" "$msg" "$rc"
fi
tail -n 40 "$log_file"
rm -f "$done_file" "${done_file}.rc" "$log_file"
exit "$rc"
