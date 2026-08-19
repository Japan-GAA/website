#!/usr/bin/env bash
# Build the how-to-play photo strip on /gaelic-football
#   bash sport-collage.sh solo.jpg catch.jpg kick.jpg handpass.jpg
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }

if [ $# -eq 0 ]; then
  echo "Usage: bash sport-collage.sh <file1> <file2> <file3> <file4>"
  echo
  echo "Loose image files here:"
  ls -1 *.jpg *.jpeg *.JPG *.png *.webp 2>/dev/null | sed 's/^/  /' || echo "  (none)"
  exit 1
fi

mkdir -p public/photos archive/originals
i=1
for f in "$@"; do
  [ -f "$f" ] || { echo "Can't find: $f"; exit 1; }
  magick "$f" -resize 1000x -quality 82 "public/photos/sport-$i.webp"
  printf "  %-32s -> sport-%d.webp  %s\n" "$f" "$i" "$(du -h public/photos/sport-$i.webp | cut -f1)"
  mv "$f" "archive/originals/sport-$i.${f##*.}"
  i=$((i+1))
done
N=$((i-1))

# ---- config -------------------------------------------------------------
python3 - "$N" <<'PY'
import pathlib, sys, re
n = int(sys.argv[1])
p = pathlib.Path("src/config/photos.js"); s = p.read_text()
block = "export const SPORT_SHOTS = [\n" + "".join(
  f'  {{ src: "/photos/sport-{i}.webp", alt: "Japan GAA" }},   // TODO: describe this photo\n'
  for i in range(1, n + 1)) + "];\n"
s = re.sub(r"export const SPORT_SHOTS = \[.*?\];\n", "", s, flags=re.S)
p.write_text(s.rstrip() + "\n\n" + block)
print(block)
PY

# ---- Collage takes a shots prop now -------------------------------------
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/components/Collage.astro"); s = p.read_text()
s = s.replace('import { COLLAGE } from "../config/photos.js";\nconst shots = COLLAGE.filter((p) => p && p.src).slice(0, 4);',
 'import { COLLAGE } from "../config/photos.js";\n'
 'const { shots: given, variant = "hero" } = Astro.props;\n'
 'const shots = (given ?? COLLAGE).filter((p) => p && p.src).slice(0, 4);')
s = s.replace('class:list={["collage", `collage--${shots.length}`]}',
              'class:list={["collage", `collage--${variant}`, variant === "hero" && `collage--${shots.length}`]}')
p.write_text(s); print("Collage.astro now accepts shots + variant")
PY

# ---- swap the single sport photo for the strip --------------------------
python3 - <<'PY'
import pathlib, re
JOBS = [("src/pages/gaelic-football.astro", "../components/Collage.astro", "../config/photos.js"),
        ("src/pages/ja/gaelic-football.astro", "../../components/Collage.astro", "../../config/photos.js")]
for path, cimp, cfg in JOBS:
    p = pathlib.Path(path)
    if not p.exists(): print("skip", path); continue
    s = p.read_text()
    if "Collage" not in s:
        s = re.sub(r"(---\nimport )",
                   f'---\nimport Collage from "{cimp}";\nimport {{ SPORT_SHOTS }} from "{cfg}";\nimport ',
                   s, count=1)
    lines = [l for l in s.splitlines(keepends=True) if "PHOTOS.sport" not in l]
    s = "".join(lines)
    anchor = "<h2>Moving the ball</h2>" if "ja/" not in path else "<h2>ボールの運び方</h2>"
    s2, n = re.subn(re.escape(anchor),
                    '<Collage shots={SPORT_SHOTS} variant="strip" />\n\n    ' + anchor, s, count=1)
    if n == 0: print("!! anchor missing in", path); continue
    p.write_text(s2); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- in-article photo strip ---- */
.collage--strip {
  aspect-ratio: auto; grid-template-rows: auto;
  grid-template-columns: repeat(2, 1fr);
  width: min(72rem, calc(100vw - 2 * var(--gutter)));
  margin: 2rem 50% 2.5rem; transform: translateX(-50%);
}
@media (min-width: 48rem) {
  .collage--strip { grid-template-columns: repeat(4, 1fr); }
}
.collage--strip figure { grid-column: auto !important; grid-row: auto !important; }
.collage--strip img { aspect-ratio: 3 / 4; }
EOF

echo
echo "Run: npm run dev  ->  /gaelic-football"
