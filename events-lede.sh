#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/pages/events.astro"); s = p.read_text()
new = '''<p class="hero__lede">
        Tournaments, socials and everything else the club gets up to away from
        the training pitch. Everyone is welcome at these, members or not.
      </p>'''
s2, n = re.subn(r'<p class="hero__lede">.*?</p>', new, s, count=1, flags=re.S)
print("  ok   events.astro" if n else "  !!   lede not found")
if n: p.write_text(s2)
PY

echo
npm run build 2>&1 | tail -4
