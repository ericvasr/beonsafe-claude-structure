#!/usr/bin/env bash
# Claude Code statusline — model · dir (branch) · $cost  [CAVEMAN]
# Cross-platform: WSL (python3) + Windows Git Bash (python). jq not required.
input=$(cat)
# Pick first interpreter that actually parses (Git Bash ships a dead python3 stub —
# try each candidate and keep the first that yields output).
PROG='
import json,sys,os
d=json.load(sys.stdin)
m=d.get("model",{}).get("display_name","?")
cur=d.get("workspace",{}).get("current_dir","") or os.path.expanduser("~")
dirn=os.path.basename(cur.rstrip("/\\")) or cur
cost=d.get("cost",{}).get("total_cost_usd",0) or 0
print("\t".join([m,dirn,cur,"%.2f"%cost]))
'
parsed=""
for c in python3 python py; do
  command -v "$c" >/dev/null 2>&1 || continue
  parsed=$(printf '%s' "$input" | "$c" -c "$PROG" 2>/dev/null)
  [ -n "$parsed" ] && break
done
IFS=$'\t' read -r MODEL DIRN CUR COST <<<"$parsed"
[ -z "$MODEL" ] && MODEL="?"

BR=""
if command -v git >/dev/null 2>&1; then
  BR=$(git -C "$CUR" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi

ESC=$(printf '\033')
DIM="${ESC}[2m"; CYAN="${ESC}[36m"; BLUE="${ESC}[34m"; GRN="${ESC}[32m"; YEL="${ESC}[33m"; ORG="${ESC}[38;5;172m"; R="${ESC}[0m"
OUT="${CYAN}${MODEL}${R}${DIM} · ${R}${BLUE}${DIRN}${R}"
[ -n "$BR" ] && OUT="${OUT}${DIM} (${R}${GRN}${BR}${R}${DIM})${R}"
[ -n "$COST" ] && [ "$COST" != "0.00" ] && OUT="${OUT}${DIM} · ${R}${YEL}\$${COST}${R}"

FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"
if [ -f "$FLAG" ] && [ ! -L "$FLAG" ]; then
  MODE=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')
  case "$MODE" in
    off) ;;
    lite|full|ultra|wenyan-lite|wenyan|wenyan-full|wenyan-ultra|commit|review|compress)
      if [ "$MODE" = "full" ]; then BADGE="[CAVEMAN]"; else BADGE="[CAVEMAN:$(printf '%s' "$MODE" | tr 'a-z' 'A-Z')]"; fi
      OUT="${OUT}${DIM} · ${R}${ORG}${BADGE}${R}" ;;
  esac
fi
printf '%s' "$OUT"
