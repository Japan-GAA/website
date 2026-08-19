#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

MAP = "https://maps.app.goo.gl/DLmB27aQEgWyWzAp7"
fails = []

def swap(path, pattern, new, label):
    p = pathlib.Path(path)
    if not p.exists():
        fails.append(f"{path} missing"); return
    s = p.read_text()
    s2, n = re.subn(pattern, lambda m: new.strip(), s, count=1, flags=re.S)
    if n == 0:
        fails.append(f"{path}: {label}")
    else:
        p.write_text(s2); print(f"  ok   {path}: {label}")

# ---------------- English ----------------
swap("src/pages/index.astro", r'<p class="hero2__lede">.*?</p>',
f'''<p class="hero2__lede">
        Ireland's national sport, played in Japan. Welcoming experienced players
        and those who want to try it for the first time. No experience needed,
        and the first session is free.
      </p>''', "hero lede")

swap("src/pages/index.astro", r'<p class="muted">\s*7–9pm at Yashio.*?</p>',
f'''<p class="muted">
          At <a href="{MAP}" rel="noopener">Yashio Kita Park, Shinagawa</a>
        </p>''', "sessions location")

swap("src/pages/index.astro",
     r'<h2>New to the sport\?</h2>\s*<p>.*?</p>\s*<p><a href="/gaelic-football">.*?</a></p>',
'''<h2>New to the sport?</h2>
        <p>It looks like a mix between soccer, rugby and basketball.</p>
        <p><a href="/gaelic-football">Read the rules →</a></p>''', "new to the sport")

# ---------------- Japanese ----------------
swap("src/pages/ja/index.astro", r'<p class="hero2__lede">.*?</p>',
'''<p class="hero2__lede">
        アイルランドの国技を、日本で。経験者の方も、はじめて挑戦してみたい方も
        歓迎しています。経験は必要ありません。初回参加は無料です。
      </p>''', "hero lede")

swap("src/pages/ja/index.astro", r'<p class="muted">\s*品川区・八潮北公園.*?</p>',
f'''<p class="muted">
          <a href="{MAP}" rel="noopener">品川区・八潮北公園</a>にて
        </p>''', "sessions location")

swap("src/pages/ja/index.astro",
     r'<h2>はじめての方へ</h2>\s*<p>.*?</p>\s*<p><a href="/ja/gaelic-football">.*?</a></p>',
'''<h2>はじめての方へ</h2>
        <p>サッカーとラグビー、バスケットボールを合わせたような競技です。</p>
        <p><a href="/ja/gaelic-football">ルールを見る →</a></p>''', "new to the sport")

if fails:
    print("\nNOT APPLIED:")
    for f in fails: print("  !!", f)
PY

echo
npm run build 2>&1 | tail -5
