#!/usr/bin/env bash
# Put the four-photo strip back, below the "Coming up" list.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p public/photos

# the photos moved into events/ for the sheet-driven attempt; bring them back
declare -a MAP=(
  "yokohama-parade-2025.webp:events-1.webp"
  "sports-day-2025.webp:events-2.webp"
  "christmas-party-2025.webp:events-3.webp"
  "bbq.webp:events-4.webp"
)
for pair in "${MAP[@]}"; do
  src="public/photos/events/${pair%%:*}"; dst="public/photos/${pair##*:}"
  [ -f "$src" ] && cp "$src" "$dst" && echo "  restored $(basename "$dst")"
done

python3 - <<'PY'
import pathlib, re

# config array, if the earlier one was removed
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
block = '''export const EVENT_SHOTS = [
  { src: "/photos/events-1.webp", alt: "Japan GAA at the St Patrick's Day parade in Yokohama, 2025" },
  { src: "/photos/events-2.webp", alt: "Japan GAA Sports Day, 2025" },
  { src: "/photos/events-3.webp", alt: "The Japan GAA Christmas party, 2025" },
  { src: "/photos/events-4.webp", alt: "Club members at a barbecue by the river" },
];
'''
s = re.sub(r"export const EVENT_SHOTS = \[.*?\];\n", "", s, flags=re.S)
p.write_text(s.rstrip() + "\n\n" + block)
print("  ok   photos.js")

# insert the strip just before the "Previously" heading (or before the CTA)
JOBS = [
 ("src/pages/events.astro", "../components/Collage.astro", "../config/photos.js",
  "{past.length > 0 && ("),
 ("src/pages/ja/events.astro", "../../components/Collage.astro", "../../config/photos.js",
  "{past.length > 0 && ("),
]
for path, cimp, cfg, anchor in JOBS:
    p = pathlib.Path(path)
    if not p.exists(): print("!! missing", path); continue
    s = p.read_text()
    if "EVENT_SHOTS" in s and "<Collage" in s:
        print("  --  ", path, "already has the strip"); continue
    if "Collage" not in s:
        s = re.sub(r"(---\nimport )",
                   f'---\nimport Collage from "{cimp}";\nimport {{ EVENT_SHOTS }} from "{cfg}";\nimport ',
                   s, count=1)
    if anchor not in s:
        print("!! anchor not found in", path); continue
    s = s.replace(anchor, '<Collage shots={EVENT_SHOTS} variant="strip" />\n\n    ' + anchor, 1)
    p.write_text(s); print("  ok  ", path)
PY

echo
npm run build 2>&1 | tail -4
