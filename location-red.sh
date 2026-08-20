#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat >> src/styles/global.css <<'EOF'

/* Red everywhere except the green training panel, where yellow reads better. */
.sessions__where { color: var(--vermilion); }
.nextup .sessions__where { color: #f5c542; }
EOF

echo
npm run build 2>&1 | tail -4
