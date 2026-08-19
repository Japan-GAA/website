#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/components public/photos

# ---- config: swap the single hero for a set of four -----------------------
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/config/photos.js")
s = p.read_text()
s = re.sub(
  r'  hero:.*\n',
'''  // Homepage mosaic — up to 4 photos, shown top-left, top-right,
  // bottom-right (tall), bottom-left. Mix them up: a men's team shot, a
  // ladies' team shot, an action shot, and something social.
  // Fewer than 4 is fine; 0 falls back to the goalposts graphic.
''', s, count=1)
if "COLLAGE" not in s:
    s += '''
export const COLLAGE = [
  { src: "/photos/hero.webp", alt: "Japan GAA players in action" },
  // { src: "/photos/team-mens.webp",  alt: "The men's team" },
  // { src: "/photos/team-ladies.webp", alt: "The ladies' team" },
  // { src: "/photos/social.webp",      alt: "Japan GAA members at a social event" },
];
'''
p.write_text(s)
print(s)
PY

# ---- the mosaic component -------------------------------------------------
cat > src/components/Collage.astro <<'EOF'
---
import { COLLAGE } from "../config/photos.js";
const shots = COLLAGE.filter((p) => p && p.src).slice(0, 4);
---
{shots.length > 0 ? (
  <div class:list={["collage", `collage--${shots.length}`]}>
    {shots.map((p, i) => (
      <figure style={`--i:${i}`}>
        <img src={p.src} alt={p.alt ?? ""} loading={i === 0 ? "eager" : "lazy"} decoding="async" />
      </figure>
    ))}
  </div>
) : (
  <svg class="posts" viewBox="0 0 320 260" role="img" aria-label="Gaelic football posts">
    <g class="bar" fill="none">
      <line x1="90" y1="30" x2="90" y2="240" />
      <line x1="230" y1="30" x2="230" y2="240" />
      <line x1="70" y1="150" x2="250" y2="150" />
      <line x1="40" y1="240" x2="280" y2="240" />
    </g>
    <circle class="ball" cx="160" cy="88" r="15" />
  </svg>
)}
EOF

# ---- rewire both homepages: text left, mosaic right -----------------------
python3 - <<'PY'
import pathlib, re

JOBS = [("src/pages/index.astro", "../components/Collage.astro", "../config/photos.js"),
        ("src/pages/ja/index.astro", "../../components/Collage.astro", "../../config/photos.js")]

for path, cimp, _ in JOBS:
    p = pathlib.Path(path); s = p.read_text()

    # import Collage, drop the PHOTOS import (no longer used on this page)
    if "Collage.astro" not in s:
        s = re.sub(r"(---\nimport )", f'---\nimport Collage from "{cimp}";\nimport ', s, count=1)
    s = re.sub(r'import \{ PHOTOS \} from "[^"]*";\n', "", s)

    # section wrapper: no more photo-background variant
    s = s.replace('<section class:list={["hero2", PHOTOS.hero && "hero2--photo"]}>',
                  '<section class="hero2 hero2--split">')
    s = re.sub(r'\s*\{PHOTOS\.hero && <img class="hero2__bg"[^}]*?/>\}', "", s)

    # close the text column and add the mosaic beside it
    s = re.sub(r'(\s*)</div>\n  </section>\n\n  <Facts',
               r'\1  </div>\n\1  <Collage />\n\1</div>\n  </section>\n\n  <Facts',
               s, count=1)
    s = s.replace('<div class="wrap hero2__inner">',
                  '<div class="wrap hero2__inner">\n      <div class="hero2__text">')
    p.write_text(s); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- split hero with photo mosaic ---- */
.hero2--split .hero2__inner {
  display: grid; gap: clamp(2rem, 5vw, 3.5rem);
  grid-template-columns: 1fr; align-items: center;
}
@media (min-width: 60rem) {
  .hero2--split .hero2__inner { grid-template-columns: 1.05fr 1fr; }
}
.hero2__text h1 { max-width: 14ch; }

.collage {
  display: grid; gap: 0.5rem;
  grid-template-columns: 1fr 1fr;
  grid-template-rows: repeat(3, 1fr);
  aspect-ratio: 1 / 1;
}
.collage figure {
  margin: 0; overflow: hidden; border-radius: 3px; background: var(--line);
}
.collage img { width: 100%; height: 100%; object-fit: cover; display: block; }

/* pinwheel: tall left, short top-right, tall bottom-right, short bottom-left */
.collage--4 figure:nth-child(1) { grid-column: 1; grid-row: 1 / span 2; }
.collage--4 figure:nth-child(2) { grid-column: 2; grid-row: 1; }
.collage--4 figure:nth-child(3) { grid-column: 2; grid-row: 2 / span 2; }
.collage--4 figure:nth-child(4) { grid-column: 1; grid-row: 3; }

.collage--3 { grid-template-rows: repeat(2, 1fr); aspect-ratio: 4 / 3; }
.collage--3 figure:nth-child(1) { grid-column: 1; grid-row: 1 / span 2; }
.collage--3 figure:nth-child(2) { grid-column: 2; grid-row: 1; }
.collage--3 figure:nth-child(3) { grid-column: 2; grid-row: 2; }

.collage--2 { grid-template-rows: 1fr; aspect-ratio: 16 / 9; }
.collage--2 figure { grid-row: 1; }
.collage--2 figure:nth-child(1) { grid-column: 1; }
.collage--2 figure:nth-child(2) { grid-column: 2; }

.collage--1 { grid-template-columns: 1fr; grid-template-rows: 1fr; aspect-ratio: 4 / 3; }

@media (prefers-reduced-motion: no-preference) {
  .collage figure {
    animation: rise .55s cubic-bezier(.2,.7,.3,1) both;
    animation-delay: calc(var(--i) * 90ms + 150ms);
  }
  @keyframes rise {
    from { opacity: 0; transform: translateY(14px) scale(.98); }
    to   { opacity: 1; transform: none; }
  }
}
EOF

echo
echo "Done. Add 3 more photos to public/photos/ and uncomment them in src/config/photos.js"
