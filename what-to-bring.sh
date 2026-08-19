#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

JOBS = [
 ("src/pages/training.astro", "What to bring",
'''      <div class="fact">
        <h2>What to bring</h2>
        <ul class="bring">
          <li>Sports clothes</li>
          <li>Something to drink — water is available if you have a bottle</li>
          <li>Football boots, or trainers</li>
          <li>A change of clothes, if you like — there are showers</li>
        </ul>
        <p class="muted">Don't buy anything for your first session. We have the balls.</p>
      </div>'''),
 ("src/pages/ja/training.astro", "持ち物",
'''      <div class="fact">
        <h2>持ち物</h2>
        <ul class="bring">
          <li>動きやすい服装</li>
          <li>飲み物（ボトルをお持ちいただければ、水はこちらにあります）</li>
          <li>サッカーシューズ、または運動靴</li>
          <li>着替え（シャワーをご利用いただけます）</li>
        </ul>
        <p class="muted">初回のために新しく購入する必要はありません。ボールはこちらで用意します。</p>
      </div>'''),
]

for path, heading, new in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()
    pat = re.compile(r'<div class="fact">\s*<h2>\s*' + re.escape(heading) + r'\s*</h2>.*?</div>', re.S)
    s2, n = pat.subn(new.strip(), s, count=1)
    if n == 0:
        print(f"!! no <h2>{heading}</h2> block in {path}")
        continue
    p.write_text(s2); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- what to bring ---- */
.bring { list-style: none; padding: 0; margin: 0 0 0.75rem; font-size: 0.9375rem; }
.bring li {
  position: relative; padding: 0.3rem 0 0.3rem 1.25rem; line-height: 1.55;
}
.bring li::before {
  content: ""; position: absolute; left: 0; top: 0.95em;
  width: 0.4rem; height: 0.4rem; border-radius: 50%; background: var(--vermilion);
}
.fact .muted { font-size: 0.875rem; }
EOF

echo "Run: npm run dev"
