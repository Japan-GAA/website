#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re, sys

fails = []

def swap(path, pattern, new, label, flags=re.S):
    p = pathlib.Path(path)
    if not p.exists():
        fails.append(f"{path}: missing file"); return
    s = p.read_text()
    s2, n = re.subn(pattern, lambda m: new.strip(), s, count=1, flags=flags)
    if n == 0:
        fails.append(f"{path}: {label} — no match")
    else:
        p.write_text(s2); print(f"  ok   {path}: {label}")

# ---- 1. pin the timezone in the Sessions component -----------------------
p = pathlib.Path("src/components/Sessions.astro")
if p.exists():
    s = p.read_text()
    s = re.sub(
        r'const day\s*=.*?\n', 
        'const TZ = "Asia/Tokyo";\n'
        'const day  = (d: Date) => d.toLocaleDateString(locale, { timeZone: TZ, weekday: "long", month: "long", day: "numeric" });\n',
        s, count=1)
    s = re.sub(
        r'const time\s*=.*?\n',
        'const time = (d: Date) => d.toLocaleTimeString(locale, { timeZone: TZ, hour: "numeric", minute: "2-digit", hour12: lang !== "ja" });\n',
        s, count=1)
    p.write_text(s)
    print("  ok   Sessions.astro: timezone pinned to Asia/Tokyo")
else:
    fails.append("src/components/Sessions.astro missing")

# ---- 2. access details (English) ----------------------------------------
swap("src/pages/training.astro",
     r'<!-- TODO: nearest station.*?-->',
'''<ul class="access">
          <li>14 min walk from <strong>Shinagawa Seaside</strong> (Rinkai Line)</li>
          <li>20 min walk from <strong>Aomono-yokochō</strong> (Keikyū Line)</li>
          <li>10 min by bus from <strong>Shinagawa</strong></li>
        </ul>''', "access list")

# ---- 3. what to bring (English) ------------------------------------------
swap("src/pages/training.astro",
     r'<div class="fact">\s*<h2>What to bring</h2>.*?</div>',
'''<div class="fact">
        <h2>What to bring</h2>
        <p>
          Sports clothes and something to drink. Football boots are better on the
          grass, but trainers are fine — don't buy anything for your first session.
          We have the balls.
        </p>
        <p><strong>Showers are available</strong> at the park.</p>
      </div>''', "what to bring")

# ---- 4. Japanese equivalents ---------------------------------------------
swap("src/pages/ja/training.astro",
     r'<!-- TODO: 最寄駅.*?-->',
'''<ul class="access">
          <li>りんかい線「<strong>品川シーサイド</strong>」駅から徒歩14分</li>
          <li>京急線「<strong>青物横丁</strong>」駅から徒歩20分</li>
          <li>「<strong>品川</strong>」駅からバスで約10分</li>
        </ul>''', "アクセス")

swap("src/pages/ja/training.astro",
     r'<div class="fact">\s*<h2>持ち物</h2>.*?</div>',
'''<div class="fact">
        <h2>持ち物</h2>
        <p>
          動きやすい服装と飲み物をご用意ください。芝生ではサッカーシューズの方が
          動きやすいですが、運動靴でも問題ありません。初回のために新しく購入する
          必要はありません。ボールはこちらで用意します。
        </p>
        <p><strong>シャワーもご利用いただけます。</strong></p>
      </div>''', "持ち物")

print()
if fails:
    print("NOT APPLIED:")
    for f in fails: print("  !!", f)
    sys.exit(1)
print("All edits applied.")
PY

echo
echo "Check:  npm run build && grep -c 'Shinagawa Seaside' dist/training/index.html"
