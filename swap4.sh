#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
s = s.replace('  { src: "/photos/collage-4.webp", alt: "Japan GAA" },',
              '  { src: "/photos/hero.webp", alt: "Japan GAA players in action" },')
s = s.replace('  // spare: { src: "/photos/hero.webp", alt: "Japan GAA players in action" },',
              '  // spare: { src: "/photos/collage-4.webp", alt: "Japan GAA" },')
p.write_text(s)
print(re.search(r"export const COLLAGE = \[.*?\];", s, re.S).group(0))
PY
