#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/pages/ja/gaelic-football.astro")
s = p.read_text()
old = re.compile(r"Japan GAAが活動しているのはゲーリックフットボール.*?ご連絡ください。", re.S)
new = ("Japan GAAが活動しているのはゲーリックフットボール（男子・女子）ですが、\n"
       "      <strong>ハーリングの立ち上げも検討中です。</strong>\n"
       "      ご興味のある方は、ぜひお知らせください。")
s2, n = old.subn(new, s, count=1)
if n == 0:
    print("!! couldn't find the sentence — check src/pages/ja/gaelic-football.astro by hand")
else:
    p.write_text(s2); print("  ok   src/pages/ja/gaelic-football.astro")
PY

echo
npm run build 2>&1 | tail -5
