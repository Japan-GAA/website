#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat > src/components/ScoringDiagram.astro <<'EOF'
---
const { lang = "ja" } = Astro.props;
const ja = lang === "ja";
const rows = ja
  ? [
      { cls: "point", name: "ポイント", value: "1点", how: "バーの上" },
      { cls: "two",   name: "2ポイント", value: "2点", how: "40mアークの外から蹴る" },
      { cls: "goal",  name: "ゴール",   value: "3点", how: "バーの下、ネットの中" },
    ]
  : [
      { cls: "point", name: "Point",       value: "1 point",  how: "over the bar" },
      { cls: "two",   name: "Two-pointer", value: "2 points", how: "kicked from outside the 40m arc" },
      { cls: "goal",  name: "Goal",        value: "3 points", how: "under the bar, into the net" },
    ];
---
<figure class="scoring">
  <svg viewBox="0 0 340 250" role="img" aria-label={ja ? "得点方法" : "How scoring works"}>
    <g stroke="var(--pitch)" stroke-width="6" fill="none" stroke-linecap="square">
      <line x1="95" y1="20" x2="95" y2="215" />
      <line x1="245" y1="20" x2="245" y2="215" />
      <line x1="80" y1="130" x2="260" y2="130" />
      <line x1="30" y1="215" x2="310" y2="215" />
    </g>
    <rect x="95" y="130" width="150" height="85" fill="var(--pitch)" opacity="0.08" />
    <circle cx="170" cy="72" r="12" fill="var(--vermilion)" />
    <circle cx="170" cy="175" r="12" fill="var(--pitch)" />
  </svg>

  <figcaption>
    <dl class="score">
      {rows.map((r) => (
        <div class={`score__row score__row--${r.cls}`}>
          <dt>{r.name}</dt>
          <dd class="score__value">{r.value}</dd>
          <dd class="score__how">{r.how}</dd>
        </div>
      ))}
    </dl>
  </figcaption>
</figure>
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- scoring key (replaces the flex caption) ---- */
.score { margin: 0; }
.score__row {
  display: grid;
  grid-template-columns: 1fr auto;
  column-gap: 1rem;
  padding: 0.7rem 0 0.7rem 1.4rem;
  border-bottom: 1px solid var(--line);
  position: relative;
}
.score__row:first-child { border-top: 1px solid var(--line); }
.score__row::before {
  content: ""; position: absolute; left: 0; top: 1.15rem;
  width: 0.7rem; height: 0.7rem; border-radius: 50%;
}
.score__row--point::before { background: var(--vermilion); }
.score__row--two::before   { background: #e08a1e; }
.score__row--goal::before  { background: var(--pitch); }

.score dt {
  font-family: var(--display); font-weight: 700; font-size: 1rem; margin: 0;
}
.score__value {
  margin: 0; font-family: var(--display); font-weight: 700;
  color: var(--pitch); white-space: nowrap; text-align: right;
}
.score__how {
  grid-column: 1 / -1; margin: 0.15rem 0 0;
  font-size: 0.9375rem; color: #3a4b43;
}
EOF

echo
npm run build 2>&1 | tail -4
