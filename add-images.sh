#!/usr/bin/env bash
# Adds the club badge to the header + og:image, and the team photo below the hero.
# Run from ~/website AFTER placing:
#   public/badge.png      (club badge)
#   src/assets/hero.jpg   (team photo)
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
[ -f public/badge.png ]    || { echo "Missing public/badge.png"; exit 1; }
[ -f src/assets/hero.jpg ] || { echo "Missing src/assets/hero.jpg"; exit 1; }

python3 - <<'PY'
import re, pathlib

# --- Base.astro: badge in the masthead + og:image -------------------------
p = pathlib.Path("src/layouts/Base.astro"); s = p.read_text()

s = s.replace(
  '<a class="wordmark" href={lang === "ja" ? "/ja/" : "/"}>Japan <span>GAA</span></a>',
  '<a class="wordmark" href={lang === "ja" ? "/ja/" : "/"}>\n'
  '          <img class="badge" src="/badge.png" alt="" width="44" height="44" />\n'
  '          <span class="wordmark__text">Japan <span>GAA</span></span>\n'
  '        </a>'
)

if "og:image" not in s:
    s = s.replace(
      '<meta property="og:type" content="website" />',
      '<meta property="og:type" content="website" />\n'
      '    <meta property="og:image" content={new URL("/badge.png", SITE.url)} />\n'
      '    <meta name="twitter:card" content="summary" />\n'
      '    <link rel="icon" href="/badge.png" />'
    )
p.write_text(s)

# --- both homepages: photo band under the hero ---------------------------
band_en = '''
  <figure class="band">
    <Image src={hero} alt="Japan GAA players at a tournament" widths={[640, 1024, 1600]} sizes="100vw" loading="eager" />
  </figure>
'''
band_ja = '''
  <figure class="band">
    <Image src={hero} alt="大会でのJapan GAAのメンバー" widths={[640, 1024, 1600]} sizes="100vw" loading="eager" />
  </figure>
'''

for path, band, rel in (
    ("src/pages/index.astro",    band_en, "../assets/hero.jpg"),
    ("src/pages/ja/index.astro", band_ja, "../../assets/hero.jpg"),
):
    p = pathlib.Path(path); s = p.read_text()
    if "astro:assets" not in s:
        s = s.replace("---\nimport Base",
                      f'---\nimport {{ Image }} from "astro:assets";\nimport hero from "{rel}";\nimport Base', 1)
    if 'class="band"' not in s:
        s = s.replace("  <section class=\"panel\">", band.strip("\n") + "\n\n  <section class=\"panel\">", 1)
    p.write_text(s)
print("patched")
PY

cat >> src/styles/global.css <<'EOF'

/* ---- badge + hero band ---- */
.wordmark { display: flex; align-items: center; gap: 0.6rem; }
.badge { width: 44px; height: 44px; object-fit: contain; display: block; }
.wordmark__text { line-height: 1; }
@media (max-width: 30rem) { .wordmark__text { display: none; } }

.band { margin: 0 0 clamp(2rem, 5vw, 3.5rem); }
.band img {
  width: 100%;
  height: clamp(16rem, 42vw, 30rem);
  object-fit: cover;
  display: block;
  border-block: 1px solid var(--line);
}
EOF

echo "Done. Run: npm run dev"
