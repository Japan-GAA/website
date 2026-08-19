#!/usr/bin/env bash
# Repairs the broken <p class="hero__lede"> tags on the committee pages.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

FIXES = {
 "src/pages/committee.astro":
'''      <p class="hero__lede">
        Japan GAA is run entirely by volunteers. These are the people who
        organise the training, the tournaments and everything in between.
      </p>''',
 "src/pages/ja/committee.astro":
'''      <p class="hero__lede">
        Japan GAAはすべてボランティアによって運営されています。
        練習や大会の運営を担っているメンバーをご紹介します。
      </p>''',
}

for path, good in FIXES.items():
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()
    # any <p class="hero__lede" ... up to the closing </p>, malformed or not
    s2, n = re.subn(r'<p class="hero__lede"[^>]*?>?\s*.*?</p>', good.strip(), s, count=1, flags=re.S)
    if n == 0:
        print("!! no hero__lede block found in", path); continue
    p.write_text(s2)
    print("  ok  ", path)
PY

echo
echo "Building all pages…"
npm run build 2>&1 | tail -8
