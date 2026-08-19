#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

JOBS = [
 ("src/pages/gaelic-football.astro",
  '<p><a class="cta" href="/training">Come to training →</a></p>',
  '<Video id="tzPmmBCEMN4" title="All-Ireland final highlights" caption="Gaelic football at the top level — an All-Ireland final." />'),
 ("src/pages/ja/gaelic-football.astro",
  '<p><a class="cta" href="/ja/training">練習に参加する →</a></p>',
  '<Video id="tzPmmBCEMN4" title="オールアイルランド決勝のハイライト" caption="トップレベルのゲーリックフットボール — オールアイルランド決勝。" />'),
]

for path, anchor, video in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()

    if "Video.astro" not in s:
        imp = "../components/Video.astro" if "/ja/" not in path else "../../components/Video.astro"
        s = re.sub(r"(---\nimport )", f'---\nimport Video from "{imp}";\nimport ', s, count=1)

    if anchor not in s:
        print("!! anchor not found in", path); continue
    s = s.replace(anchor, video + "\n\n    " + anchor, 1)

    # the TODO asking for a video is now satisfied
    s = re.sub(r"\s*<!-- TODO: embed a short video[^>]*?\n", "\n    <!-- ", s, count=1)
    p.write_text(s); print("  ok  ", path)
PY

echo
npm run build 2>&1 | tail -5
