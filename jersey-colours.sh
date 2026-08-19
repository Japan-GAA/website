#!/usr/bin/env bash
# Converts jersey photos named like "Men's Green Sleeveless.jpg" into
# public/photos/jersey-<colour>-<sleeve>.webp, and keys the page on colour too.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }
mkdir -p public/photos archive/originals

# existing navy files were keyed on sleeve alone
[ -f public/photos/jersey-sleeve.webp ] && mv public/photos/jersey-sleeve.webp public/photos/jersey-navy-sleeve.webp && echo "  renamed navy sleeved"
[ -f public/photos/jersey-sleeveless.webp ] && mv public/photos/jersey-sleeveless.webp public/photos/jersey-navy-sleeveless.webp && echo "  renamed navy sleeveless"

shopt -s nullglob nocaseglob
found=0
for f in *.jpg *.jpeg *.png *.webp; do
  low=$(echo "$f" | tr '[:upper:]' '[:lower:]')
  colour=""; for c in navy green white black red; do [[ "$low" == *"$c"* ]] && colour="$c"; done
  [ -z "$colour" ] && continue
  if [[ "$low" == *sleeveless* ]]; then sleeve="sleeveless"; else
     [[ "$low" == *sleeve* ]] && sleeve="sleeve" || continue; fi
  out="public/photos/jersey-$colour-$sleeve.webp"
  magick "$f" -resize 1000x -quality 82 "$out"
  printf "  %-34s -> %s  %s\n" "$f" "${out#public/photos/}" "$(du -h "$out" | cut -f1)"
  mv "$f" "archive/originals/jersey-$colour-$sleeve.${f##*.}"
  found=$((found+1))
done
shopt -u nocaseglob
echo "  converted $found photo(s)"

# ---- slug now includes colour --------------------------------------------
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/lib/jerseys.ts"); s = p.read_text()
old = 'slug: sleeve.toLowerCase().replace(/[^a-z0-9]+/g, "-"),'
new = 'slug: `${colour}-${sleeve}`.toLowerCase().replace(/[^a-z0-9]+/g, "-"),'
if old in s:
    p.write_text(s.replace(old, new)); print("  ok   slug now colour + sleeve")
else:
    print("  --   slug already updated (or not found)")
PY

# ---- missing photo shouldn't leave a broken image ------------------------
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/Stock.astro"); s = p.read_text()
if "existsSync" not in s:
    s = s.replace('import { jerseyStock, updatedOn } from "../lib/jerseys";',
                  'import { existsSync } from "node:fs";\nimport { jerseyStock, updatedOn } from "../lib/jerseys";')
    s = s.replace('        <img class="jersey__photo" src={`/photos/jersey-${g.slug}.webp`} alt="" loading="lazy" />',
'''        {existsSync(`public/photos/jersey-${g.slug}.webp`) && (
          <img class="jersey__photo" src={`/photos/jersey-${g.slug}.webp`} alt="" loading="lazy" />
        )}''')
    p.write_text(s); print("  ok   photo now optional per section")
else:
    print("  --   already guarded")
PY

echo
ls -1 public/photos/jersey-*.webp
echo
npm run build 2>&1 | tail -4
