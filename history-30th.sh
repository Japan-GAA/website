#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

# ---- English -------------------------------------------------------------
p = pathlib.Path("src/pages/history.astro"); s = p.read_text()
s = s.replace(
  '<Photo src={PHOTOS.history} alt="A Japan GAA team photo" wide />',
  '<Photo src={PHOTOS.history} alt="Japan GAA members at the club\'s 30th anniversary celebration at the Embassy of Ireland in Tokyo" caption="Japan GAA\'s 30th anniversary, celebrated at the Embassy of Ireland in Tokyo." wide />'
)
s = s.replace(
  '''    <!-- TODO: the account stops at 2017.''',
  '''    <p>
      In 2025 the club marked its thirtieth anniversary with a celebration at the
      Embassy of Ireland in Tokyo — three decades of Gaelic games in Japan, and a
      membership that keeps renewing itself.
    </p>

    <!-- TODO: confirm the anniversary year and the exact venue wording.
         TODO: the account stops at 2017.'''
)
p.write_text(s); print("ok  src/pages/history.astro")

# ---- Japanese ------------------------------------------------------------
p = pathlib.Path("src/pages/ja/history.astro"); s = p.read_text()
s = s.replace(
  '<Photo src={PHOTOS.history} alt="Japan GAAのチーム写真" wide />',
  '<Photo src={PHOTOS.history} alt="在日アイルランド大使館で行われたJapan GAA創立30周年の記念行事" caption="在日アイルランド大使館で行われた、Japan GAA創立30周年の記念行事。" wide />'
)
s = s.replace(
  '''    <!-- TODO: 日本語版は英語版より内容が古く''',
  '''    <p>
      2025年には、在日アイルランド大使館にてJapan GAA創立30周年の記念行事が
      行われました。日本でゲーリックスポーツが続いて30年、メンバーは代を重ねながら
      活動を続けています。
    </p>

    <!-- TODO: 周年の年と会場の表記を確認してください。
         TODO: 日本語版は英語版より内容が古く'''
)
p.write_text(s); print("ok  src/pages/ja/history.astro")
PY
