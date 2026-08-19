#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }
mkdir -p public/photos archive/originals

SRC="1757027619130.jpg"
[ -f "$SRC" ] || { echo "Can't find $SRC in $(pwd)"; ls *.jpg 2>/dev/null; exit 1; }

magick "$SRC" -resize 1600x -quality 82 public/photos/history.webp
ls -lh public/photos/history.webp
mv "$SRC" archive/originals/history.jpg

python3 - <<'PY'
import pathlib
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
s = s.replace('  history:   "",', '  history:   "/photos/history.webp",')
p.write_text(s)
print("history slot set")
PY
