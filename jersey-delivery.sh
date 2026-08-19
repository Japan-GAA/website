#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
ONEILLS = "https://www.oneills.com/int_en/shop-by-team/gaa/asia-gulf/japan-gaa-club.html"
fails = []

# ---------------- English ----------------
p = pathlib.Path("src/pages/jerseys.astro"); s = p.read_text()
new = f'''<h2>How to order</h2>
    <p>
      Email us with the colour, size and fit you want, and we'll sort it out at
      training. Stock changes, so it's worth confirming before you set your heart
      on a size.
    </p>
    <p><a class="cta" href="mailto:japangaa@gmail.com">Email us about a jersey</a></p>

    <h2>Delivery in Japan</h2>
    <ul class="bring">
      <li>One jersey: ¥430 by Letter Pack</li>
      <li>Two or more: from ¥860, depending on size and weight</li>
    </ul>
    <p class="muted">Or collect it at training, at no cost.</p>

    <h2>Ordering from outside Japan</h2>
    <p>
      O'Neills carry the Japan GAA club range and ship internationally.
    </p>
    <p><a href="{ONEILLS}" rel="noopener">Japan GAA on O'Neills →</a></p>'''
s2, n = re.subn(r'<h2>How to order</h2>.*?</p>\s*<p><a class="cta"[^>]*>.*?</a></p>', new, s, count=1, flags=re.S)
if n == 0: fails.append("English how-to-order block")
else: p.write_text(s2); print("  ok   jerseys.astro")

# ---------------- Japanese ----------------
p = pathlib.Path("src/pages/ja/jerseys.astro"); s = p.read_text()
new = f'''<h2>ご注文方法</h2>
    <p>
      ご希望の色・サイズ・フィットをメールでお知らせください。練習の際にお渡しします。
      在庫は変動しますので、事前にご確認いただくのが確実です。
    </p>
    <p><a class="cta" href="mailto:japangaa@gmail.com">ジャージについて問い合わせる</a></p>

    <h2>国内配送</h2>
    <ul class="bring">
      <li>1着：レターパックで 430円</li>
      <li>2着以上：860円から（サイズ・重量によります）</li>
    </ul>
    <p class="muted">練習の際に直接お渡しする場合は、送料はかかりません。</p>

    <h2>海外からのご注文</h2>
    <p>
      O'Neills が Japan GAA のクラブ用品を取り扱っており、海外発送に対応しています。
    </p>
    <p><a href="{ONEILLS}" rel="noopener">O'Neills の Japan GAA ページ →</a></p>'''
s2, n = re.subn(r'<h2>ご注文方法</h2>.*?</p>\s*<p><a class="cta"[^>]*>.*?</a></p>', new, s, count=1, flags=re.S)
if n == 0: fails.append("Japanese how-to-order block")
else: p.write_text(s2); print("  ok   ja/jerseys.astro")

if fails:
    print("\nNOT APPLIED:")
    for f in fails: print("  !!", f)
PY

echo
npm run build 2>&1 | tail -4
