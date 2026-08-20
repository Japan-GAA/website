#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat >> src/styles/global.css <<'EOF'

/* Bigger badge and wordmark, and the name always visible.
   Overrides the earlier .badge / .wordmark rules. */
.masthead__inner { min-height: 5.5rem; }

.badge { width: 3.75rem; height: 3.75rem; }
.wordmark {
  gap: 0.75rem;
  font-size: 1.375rem;
  letter-spacing: 0.04em;
}

@media (max-width: 30rem) {
  .wordmark__text { display: inline; }   /* was hidden — the name matters most */
  .badge { width: 2.75rem; height: 2.75rem; }
  .wordmark { font-size: 1.0625rem; gap: 0.5rem; }
  .masthead__inner { min-height: 4.5rem; gap: 0.75rem 1rem; }
}
EOF

echo
npm run build 2>&1 | tail -4
