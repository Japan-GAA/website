#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

JOBS = [
 ("src/pages/gaelic-football.astro", "The other Gaelic games",
'''<h2>The other Gaelic games</h2>
    <p>
      The GAA also runs <strong>hurling</strong> and <strong>camogie</strong>,
      played with a stick called a hurley and a small hard ball — often described
      as the fastest field sport in the world.
    </p>
    <p>
      Japan GAA plays Gaelic football, men's and ladies'. <strong>Hurling may be
      on the way</strong> — if you'd be interested in playing, tell us, because
      whether it happens depends on how many people put their hand up.
    </p>
    <p><a href="mailto:japangaa@gmail.com">Register your interest →</a></p>'''),
 ("src/pages/ja/gaelic-football.astro", "その他のゲーリックスポーツ",
'''<h2>その他のゲーリックスポーツ</h2>
    <p>
      GAAは<strong>ハーリング</strong>と<strong>カモギー</strong>も統括しています。
      ハーリーというスティックと硬い小さなボールを使う競技で、
      「世界最速の球技」とも呼ばれます。
    </p>
    <p>
      Japan GAAが活動しているのはゲーリックフットボール（男子・女子）ですが、
      <strong>ハーリングの立ち上げも検討中です。</strong>
      実現するかは参加希望者の人数次第ですので、ご興味のある方はぜひご連絡ください。
    </p>
    <p><a href="mailto:japangaa@gmail.com">興味がある方はこちら →</a></p>'''),
]

for path, heading, new in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()
    pat = re.compile(r'<h2>\s*' + re.escape(heading) + r'\s*</h2>\s*<p>.*?</p>', re.S)
    s2, n = pat.subn(new.strip(), s, count=1)
    if n == 0:
        print(f"!! couldn't find the '{heading}' section in {path}"); continue
    p.write_text(s2); print("  ok  ", path)
PY

echo
npm run build 2>&1 | tail -5
