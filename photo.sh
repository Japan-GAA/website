#!/usr/bin/env bash
# Add a photo to one of the site's slots.
#   bash photo.sh "my photo.jpg" training
# Slots: sport | history | committee | training | news
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }

if [ $# -lt 2 ]; then
  echo "Usage: bash photo.sh <file> <slot>"
  echo "Slots: sport history committee training news"
  echo
  echo "Loose image files in this folder:"
  ls -1 *.jpg *.jpeg *.JPG *.png *.webp 2>/dev/null | sed 's/^/  /' || echo "  (none)"
  exit 1
fi

SRC="$1"; SLOT="$2"
[ -f "$SRC" ] || { echo "Can't find: $SRC"; exit 1; }
case "$SLOT" in sport|history|committee|training|news) ;; *) echo "Unknown slot: $SLOT"; exit 1 ;; esac

mkdir -p public/photos archive/originals
OUT="public/photos/$SLOT.webp"
magick "$SRC" -resize 1600x -quality 82 "$OUT"
echo "wrote $OUT  ($(du -h "$OUT" | cut -f1))"
mv "$SRC" "archive/originals/$SLOT-original.${SRC##*.}"

python3 - "$SLOT" <<'PY'
import pathlib, re, sys
slot = sys.argv[1]
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
s2, n = re.subn(rf'(  {slot}:\s*)"[^"]*",', rf'\g<1>"/photos/{slot}.webp",', s, count=1)
if n == 0:
    print(f"!! couldn't find the '{slot}' line in src/config/photos.js — set it by hand")
else:
    p.write_text(s2)
    print([l for l in s2.splitlines() if l.strip().startswith(slot + ":")][0])
PY

echo "Run: npm run dev"
