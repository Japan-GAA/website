#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
fails = []

JOBS = [
 ("src/pages/gaelic-football.astro", "fastest field sport in the world",
  '<Video id="I1Vw66Zs0dQ" title="Hurling" caption="Hurling — the fastest field sport in the world." />'),
 ("src/pages/ja/gaelic-football.astro", "世界最速の球技",
  '<Video id="I1Vw66Zs0dQ" title="ハーリング" caption="ハーリング — 世界最速の球技。" />'),
]

for path, marker, video in JOBS:
    p = pathlib.Path(path)
    if not p.exists(): fails.append(f"{path} missing"); continue
    s = p.read_text()
    if marker not in s:
        fails.append(f"{path}: '{marker}' not found"); continue
    # insert after the paragraph containing that phrase
    i = s.find(marker)
    end = s.find("</p>", i)
    if end == -1: fails.append(f"{path}: no closing </p>"); continue
    end += len("</p>")
    s = s[:end] + "\n\n    " + video + s[end:]
    p.write_text(s); print("  ok  ", path)

if fails:
    print("\nNOT APPLIED:")
    for f in fails: print("  !!", f)
PY

echo
npm run build 2>&1 | tail -5
