#!/usr/bin/env bash
# Add a four-photo strip to the top of the events page.
#   bash events-banner.sh a.jpg b.jpg c.jpg d.jpg
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

if [ $# -eq 0 ]; then
  echo "Usage: bash events-banner.sh <file1> <file2> <file3> <file4>"
  echo
  echo "Loose image files here:"
  ls -1 *.jpg *.jpeg *.JPG *.png *.webp 2>/dev/null | sed 's/^/  /' || echo "  (none)"
  exit 1
fi
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }
mkdir -p public/photos archive/originals

i=1
for f in "$@"; do
  [ -f "$f" ] || { echo "Can't find: $f"; exit 1; }
  magick "$f" -resize 1000x -quality 82 "public/photos/events-$i.webp"
  printf "  %-34s -> events-%d.webp  %s\n" "$f" "$i" "$(du -h public/photos/events-$i.webp | cut -f1)"
  mv "$f" "archive/originals/events-$i.${f##*.}"
  i=$((i+1))
done
N=$((i-1))

python3 - "$N" <<'PY'
import pathlib, re, sys
n = int(sys.argv[1])

# config array
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
block = "export const EVENT_SHOTS = [\n" + "".join(
  f'  {{ src: "/photos/events-{i}.webp", alt: "Japan GAA" }},   // TODO: describe this photo\n'
  for i in range(1, n + 1)) + "];\n"
s = re.sub(r"export const EVENT_SHOTS = \[.*?\];\n", "", s, flags=re.S)
p.write_text(s.rstrip() + "\n\n" + block)
print("  ok   photos.js")

# drop the strip above the page heading, as on the sport page
JOBS = [("src/pages/events.astro", "../components/Collage.astro", "../config/photos.js"),
        ("src/pages/ja/events.astro", "../../components/Collage.astro", "../../config/photos.js")]
for path, cimp, cfg in JOBS:
    p = pathlib.Path(path)
    if not p.exists(): print("!! missing", path); continue
    s = p.read_text()
    if "Collage" not in s:
        s = re.sub(r"(---\nimport )",
                   f'---\nimport Collage from "{cimp}";\nimport {{ EVENT_SHOTS }} from "{cfg}";\nimport ',
                   s, count=1)
    if "EVENT_SHOTS" in s and "<Collage" in s:
        print("  --  ", path, "already has the strip"); continue
    s2, k = re.subn(r'(\s*)<header class="pagehead">',
                    lambda m: f'{m.group(1)}<Collage shots={{EVENT_SHOTS}} variant="strip" />\n{m.group(1)}<header class="pagehead">',
                    s, count=1)
    if k == 0: print("!! header not found in", path); continue
    p.write_text(s2); print("  ok  ", path)
PY

echo
npm run build 2>&1 | tail -4
