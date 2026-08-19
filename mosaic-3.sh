#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
new = '''export const COLLAGE = [
  // Three photos: 1 runs full width across the top, 2 and 3 sit side by side
  // beneath it. TODO: replace each alt with a real description.
  { src: "/photos/hero.webp", alt: "Japan GAA players in action" },
  { src: "/photos/collage-1.webp", alt: "Japan GAA" },
  { src: "/photos/collage-3.webp", alt: "Japan GAA" },
  // spare: { src: "/photos/collage-2.webp", alt: "Japan GAA" },
  // spare: { src: "/photos/collage-4.webp", alt: "Japan GAA" },
];
'''
s = re.sub(r"export const COLLAGE = \[.*?\];\n", new, s, flags=re.S)
p.write_text(s)
print(new)
PY

cat >> src/styles/global.css <<'EOF'

/* Three-photo mosaic: one wide across the top, two beneath.
   Overrides the earlier .collage--3 rule. */
.collage--3 {
  grid-template-columns: 1fr 1fr;
  grid-template-rows: 0.8fr 1fr;
  aspect-ratio: 1 / 1;
}
.collage--3 figure:nth-child(1) { grid-column: 1 / -1; grid-row: 1; }
.collage--3 figure:nth-child(2) { grid-column: 1; grid-row: 2; }
.collage--3 figure:nth-child(3) { grid-column: 2; grid-row: 2; }
EOF

echo "Run: npm run dev"
