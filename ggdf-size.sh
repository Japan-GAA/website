#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick missing"; exit 1; }

# re-render the logo bigger so it stays sharp at the larger display size
orig=$(ls archive/originals/ggdf.* 2>/dev/null | head -1 || true)
if [ -n "$orig" ]; then
  magick "$orig" -resize 900x -background none public/photos/ggdf.webp
  ls -lh public/photos/ggdf.webp
else
  echo "  (no original in archive/originals — keeping the existing file)"
fi

cat >> src/styles/global.css <<'EOF'

/* Partner logo: larger and centred. Overrides the earlier .foot__partner rules. */
.foot__partner { text-align: center; margin-top: 2.5rem; padding-top: 2rem; }
.foot__partner img {
  height: auto;
  width: min(22rem, 80%);
  margin-inline: auto;
}
EOF

echo
npm run build 2>&1 | tail -4
