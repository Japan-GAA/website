#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

JOBS = [
 ("src/pages/training.astro", "en",
  '''      <aside class="nextup">
        <h2>Next sessions</h2>
        <Sessions lang="en" />
        <p class="muted">
          7–9pm at Yashio Kita Park, Shinagawa. The day of the week changes, so
          check here or on <a href="https://www.instagram.com/japangaa">Instagram</a>.
        </p>
      </aside>'''),
 ("src/pages/ja/training.astro", "ja",
  '''      <aside class="nextup">
        <h2>次回の練習</h2>
        <Sessions lang="ja" />
        <p class="muted">
          品川区・八潮北公園にて 19時〜21時。曜日は回によって変わりますので、
          こちらまたは <a href="https://www.instagram.com/japangaa">Instagram</a>
          をご確認ください。
        </p>
      </aside>'''),
]

for path, lang, aside in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()

    # 1. pull the sessions block out of the fact grid
    s2, n = re.subn(r'\s*<div class="fact">\s*<h2>[^<]*</h2>\s*<Sessions[^>]*/>.*?</div>', "", s, count=1, flags=re.S)
    if n == 0:
        print("!! couldn't find the Sessions fact block in", path); continue
    s = s2

    # 2. wrap the page header and put the sessions panel beside it
    s2, n = re.subn(r'(<header class="pagehead">.*?</header>)',
                    lambda m: '<div class="trainhead">\n      ' + m.group(1) + "\n" + aside + "\n    </div>",
                    s, count=1, flags=re.S)
    if n == 0:
        print("!! no page header in", path); continue

    p.write_text(s2); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- training page: next sessions beside the heading ---- */
.trainhead {
  display: grid; gap: clamp(1.5rem, 4vw, 3rem);
  grid-template-columns: 1fr; align-items: start;
}
@media (min-width: 54rem) {
  .trainhead { grid-template-columns: 1.15fr 1fr; }
  .trainhead .pagehead { padding-bottom: 0; }
}
.nextup {
  background: var(--pitch); color: var(--chalk);
  padding: 1.5rem 1.5rem 1.25rem; border-radius: 3px;
  margin-block: clamp(2.5rem, 6vw, 4rem) 1.5rem;
}
@media (min-width: 54rem) { .nextup { margin-top: clamp(2.5rem, 6vw, 4rem); } }
.nextup h2 {
  font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.14em;
  color: #9fd9bb; margin-bottom: 1rem;
}
.nextup .sessions li { border-bottom-color: rgba(255,255,255,.18); }
.nextup .sessions__time { color: #fff; }
.nextup .muted { color: #cfe3d8; margin-bottom: 0; margin-top: 1rem; }
.nextup .muted a { color: #fff; }
.nextup p:not(.muted) { color: #dfe6e1; }
EOF

echo "Run: npm run dev  ->  /training"
