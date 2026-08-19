#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat >> src/styles/global.css <<'EOF'

/* Bigger social icons. Overrides the earlier .social rules. */
.social { gap: 1rem; }
.social a { width: 3.5rem; height: 3.5rem; border-width: 2px; }
.social svg { width: 1.75rem; height: 1.75rem; }
EOF

echo
npm run build 2>&1 | tail -4
