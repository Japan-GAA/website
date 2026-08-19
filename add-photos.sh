#!/usr/bin/env bash
# Converts the four dropped-in photos into web-sized WebP for the mosaic.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }
mkdir -p public/photos archive/originals

i=1
for f in photo_2026-08-19_15-21-*.jpg; do
  [ -e "$f" ] || { echo "No photo_2026-08-19_15-21-*.jpg files in $(pwd)"; exit 1; }
  out="public/photos/collage-$i.webp"
  magick "$f" -resize 1400x -quality 82 "$out"
  printf "  %-28s -> %-32s %s\n" "$f" "$out" "$(du -h "$out" | cut -f1)"
  mv "$f" "archive/originals/collage-$i.jpg"
  i=$((i+1))
done

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
new = '''export const COLLAGE = [
  // Reorder these freely — position 1 is tall on the left, 2 is top-right,
  // 3 is tall on the bottom-right, 4 is bottom-left.
  // TODO: replace each alt with a real description of that photo.
  { src: "/photos/collage-1.webp", alt: "Japan GAA" },
  { src: "/photos/collage-2.webp", alt: "Japan GAA" },
  { src: "/photos/collage-3.webp", alt: "Japan GAA" },
  { src: "/photos/collage-4.webp", alt: "Japan GAA" },
  // spare: { src: "/photos/hero.webp", alt: "Japan GAA players in action" },
];
'''
s = re.sub(r"export const COLLAGE = \[.*?\];\n", new, s, flags=re.S)
p.write_text(s)
print("\nconfig updated")
PY

echo
echo "Originals moved to archive/originals/  —  run: npm run dev"
