#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
cat >> src/styles/global.css <<'EOF'

/* Feature photos break out past the text column on wide screens.
   Aspect ratio is gentler than the 16:7 band so faces survive the crop. */
.prose .photo--wide {
  width: min(72rem, calc(100vw - 2 * var(--gutter)));
  margin-left: 50%;
  transform: translateX(-50%);
}
.prose .photo--wide img { aspect-ratio: 16 / 9; }
.prose .photo--wide figcaption {
  max-width: 42rem; margin-inline: auto;
}

/* If a photo still crops badly, swap the line above for:
   .prose .photo--wide img { aspect-ratio: auto; }
   which shows the whole image at its natural proportions. */
EOF
echo "done — npm run dev"
