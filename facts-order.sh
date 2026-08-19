#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/components/Facts.astro"); s = p.read_text()
new = '''const facts = lang === "ja"
  ? [
      { n: "1995",  l: "日本支部 設立" },
      { n: "40回",  l: "東京での年間練習回数" },
      { n: "2+",    l: "年間の国際大会" },
      { n: "無料",  l: "初回参加" },
    ]
  : [
      { n: "1995",  l: "Founded in Japan" },
      { n: "40",    l: "Training sessions a year in Tokyo" },
      { n: "2+",    l: "International tournaments a year" },
      { n: "Free",  l: "First session" },
    ];'''
s2, n = re.subn(r"const facts = lang === \"ja\"\n.*?\];", new, s, count=1, flags=re.S)
if n == 0:
    print("!! couldn't find the facts array")
else:
    p.write_text(s2); print("  ok   Facts.astro")
PY

echo
npm run build 2>&1 | tail -5
