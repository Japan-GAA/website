#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/components/Facts.astro"); s = p.read_text()
old = '{ n: "40回",  l: "東京での年間練習回数" },'
new = '{ n: "約40回", l: "東京での年間練習回数" },'
if new in s:
    print("  --   already approximate")
elif old in s:
    p.write_text(s.replace(old, new)); print("  ok   Facts.astro (ja)")
else:
    print("!!   couldn't find the line. Current array:")
    m = re.search(r"const facts = lang.*?\];", s, re.S)
    print(m.group(0) if m else "  (not found)")
PY

echo
npm run build 2>&1 | tail -4
