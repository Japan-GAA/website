#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
fails = []

# --- English: after the membership/pay-as-you-go paragraph ----------------
p = pathlib.Path("src/pages/training.astro"); s = p.read_text()
marker = "up to the full amount"
i = s.find(marker)
if i == -1:
    fails.append("English membership paragraph")
else:
    end = s.find("</p>", i) + len("</p>")
    add = ('\n      <p>\n'
           '        There\'s no pressure to work up to full membership. Plenty of people come\n'
           '        to a handful of sessions a year and pay as they go, and that\'s completely\n'
           '        normal.\n'
           '      </p>')
    if "no pressure to work up" not in s:
        s = s[:end] + add + s[end:]
        p.write_text(s); print("  ok   training.astro")
    else:
        print("  --   already present in training.astro")

# --- Japanese -------------------------------------------------------------
p = pathlib.Path("src/pages/ja/training.astro"); s = p.read_text()
marker = "上限を正会費額とします"
i = s.find(marker)
if i == -1:
    fails.append("Japanese membership paragraph")
else:
    end = s.find("</p>", i) + len("</p>")
    add = ('\n      <p>\n'
           '        必ず年会費をお支払いいただく必要はありません。年に数回だけ参加して\n'
           '        都度払いをされている方もたくさんいますので、どうぞお気軽にご参加ください。\n'
           '      </p>')
    if "必ず年会費をお支払い" not in s:
        s = s[:end] + add + s[end:]
        p.write_text(s); print("  ok   ja/training.astro")
    else:
        print("  --   already present in ja/training.astro")

if fails:
    print("\nNOT APPLIED:")
    for f in fails: print("  !!", f)
PY

echo
npm run build 2>&1 | tail -4
