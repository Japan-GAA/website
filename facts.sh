#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat > src/components/Facts.astro <<'EOF'
---
const { lang = "en" } = Astro.props;
const facts = lang === "ja"
  ? ["1995年設立", "東京で毎週練習", "国際大会に参加", "定期的な交流イベント"]
  : ["Founded in 1995", "Weekly training in Tokyo", "International tournaments", "Regular social events"];
---
<section class="facts">
  <div class="wrap facts__grid">
    {facts.map((f) => <div class="facts__item">{f}</div>)}
  </div>
</section>
EOF

cat >> src/styles/global.css <<'EOF'

/* Fact strip: four equal statements rather than big numbers.
   Overrides the earlier .facts__grid / .facts__item rules. */
.facts__grid {
  grid-template-columns: repeat(2, 1fr);
  gap: 1.25rem 1.5rem;
  padding-block: 1.75rem;
}
@media (min-width: 52rem) { .facts__grid { grid-template-columns: repeat(4, 1fr); } }
.facts__item {
  display: block;
  font-family: var(--display);
  font-weight: 700;
  font-size: clamp(0.95rem, 1.5vw, 1.125rem);
  line-height: 1.3;
  letter-spacing: -0.01em;
  padding-top: 0.85rem;
  border-top: 2px solid var(--vermilion);
}
EOF

echo
npm run build 2>&1 | tail -5
