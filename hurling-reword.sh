#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/pages/gaelic-football.astro")
s = p.read_text()
old = re.compile(
  r"Japan GAA plays Gaelic football, men's and ladies'\..*?put their hand up\.", re.S)
new = ("Japan GAA plays Gaelic football, men's and ladies'. <strong>Hurling may be\n"
       "      on the way</strong> — if you'd be interested in playing, let us know.")
s2, n = old.subn(new, s, count=1)
if n == 0:
    print("!! couldn't find the sentence — has it already been changed?")
else:
    p.write_text(s2); print("  ok   src/pages/gaelic-football.astro")
PY

echo
npm run build 2>&1 | tail -5
