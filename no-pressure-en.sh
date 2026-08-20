#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib
p = pathlib.Path("src/pages/training.astro")
s = p.read_text()

if "no pressure to work up" in s:
    print("  --   already present")
else:
    anchor = '      <p class="callout">'
    if anchor not in s:
        raise SystemExit("!! callout paragraph not found — paste the section again")
    add = ('      <p>\n'
           '        There\'s no pressure to work up to full membership. Plenty of people come\n'
           '        to a handful of sessions a year and pay as they go, and that\'s completely\n'
           '        normal.\n'
           '      </p>\n')
    p.write_text(s.replace(anchor, add + anchor, 1))
    print("  ok   training.astro")
PY

echo
npm run build 2>&1 | tail -4
