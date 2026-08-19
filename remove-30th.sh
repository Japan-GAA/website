#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
JOBS = [
 ("src/pages/history.astro", r'\s*<p>\s*In 2025 the club marked its thirtieth anniversary.*?</p>'),
 ("src/pages/ja/history.astro", r'\s*<p>\s*2025年には、在日アイルランド大使館にて.*?</p>'),
]
for path, pat in JOBS:
    p = pathlib.Path(path)
    if not p.exists(): print("!! missing", path); continue
    s = p.read_text()
    s2, n = re.subn(pat, "", s, count=1, flags=re.S)
    if n == 0: print("!! paragraph not found in", path); continue
    p.write_text(s2); print("  ok  ", path)
PY

echo
npm run build 2>&1 | tail -5
