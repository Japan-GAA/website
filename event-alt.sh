#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
block = '''export const EVENT_SHOTS = [
  { src: "/photos/events-1.webp", alt: "Japan GAA at the St Patrick's Day parade in Yokohama, 2025" },
  { src: "/photos/events-2.webp", alt: "Japan GAA Sports Day, 2025" },
  { src: "/photos/events-3.webp", alt: "The Japan GAA Christmas party, 2025" },
  { src: "/photos/events-4.webp", alt: "Club members at a barbecue by the river" },
];
'''
s2, n = re.subn(r"export const EVENT_SHOTS = \[.*?\];\n", block, s, flags=re.S)
if n == 0:
    print("!! EVENT_SHOTS not found — has events-banner.sh been run?")
else:
    p.write_text(s2); print("  ok   alt text written")
PY

echo
npm run build 2>&1 | tail -4
