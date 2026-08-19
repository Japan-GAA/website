#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
[ -f public/badge.png ] || { echo "public/badge.png not found"; ls public/*.png public/*.webp 2>/dev/null; exit 1; }

cat > src/components/Cover.astro <<'EOF'
---
// Card image for a news post. Posts with no photo show the club badge
// rather than a borrowed photo from some other event.
const { src, title = "" } = Astro.props;
---
{src ? (
  <img src={src} alt="" loading="lazy" />
) : (
  <span class="cover--none" role="img" aria-label={title}>
    <img src="/badge.png" alt="" loading="lazy" />
  </span>
)}
EOF

cat >> src/styles/global.css <<'EOF'

/* Badge as the placeholder cover. Overrides the goalposts version above. */
.cover--none { background: var(--chalk); border: 1px solid var(--line); }
.cover--none img {
  width: 55%; height: 55%; object-fit: contain; margin: 0; border-radius: 0;
}
.postlist__item .cover--none img { width: 70%; height: 70%; }
EOF

echo
npm run build 2>&1 | tail -4
