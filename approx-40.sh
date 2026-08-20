#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/Facts.astro"); s = p.read_text()
old = '{ n: "40",    l: "Training sessions a year in Tokyo" },'
new = '{ n: "~40",   l: "Training sessions a year in Tokyo" },'
if new in s:
    print("  --   already approximate")
elif old in s:
    p.write_text(s.replace(old, new)); print("  ok   Facts.astro")
else:
    print("!!   couldn't find the line — current facts array:")
    import re
    m = re.search(r"const facts = lang.*?\];", s, re.S)
    print(m.group(0) if m else "  (array not found)")
PY

echo
npm run build 2>&1 | tail -4
