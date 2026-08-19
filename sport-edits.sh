#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
fails = []

def swap(path, pattern, new, label):
    p = pathlib.Path(path)
    if not p.exists(): fails.append(f"{path} missing"); return
    s = p.read_text()
    s2, n = re.subn(pattern, lambda m: new.strip(), s, count=1, flags=re.S)
    if n == 0: fails.append(f"{path}: {label}")
    else: p.write_text(s2); print(f"  ok   {path}: {label}")

EN = "src/pages/gaelic-football.astro"
JA = "src/pages/ja/gaelic-football.astro"

# ---- 1. lede
swap(EN, r'<p class="hero__lede">.*?</p>',
'''<p class="hero__lede">
        Ireland's national sport, and almost certainly nothing like anything
        you've played before. Feel free to just come along to training and we'll
        teach you — or check the video below.
      </p>''', "lede")
swap(JA, r'<p class="hero__lede">.*?</p>',
'''<p class="hero__lede">
        アイルランドの国技で、おそらく今まで経験したどのスポーツとも違います。
        まずは練習にお越しいただければ、一から教えます。下の動画もご覧ください。
      </p>''', "lede")

# ---- 2. the short version
swap(EN, r'<h2>The short version</h2>\s*<p>.*?</p>',
'''<h2>The short version</h2>
    <p>
      Fifteen players a side — or nine in Asia — on a large grass pitch. You can
      catch the ball, carry it, kick it and strike it with your fist. You cannot
      throw it. The aim is to put it over the crossbar or into the net at the
      other end. Games are amateur at every level, right up to an All-Ireland
      final in front of 82,000 people. Nobody is paid to play.
    </p>''', "short version")
swap(JA, r'<h2>かんたんに言うと</h2>\s*<p>.*?</p>',
'''<h2>かんたんに言うと</h2>
    <p>
      15人対15人（アジアでは9人制）、広い芝生のグラウンドで行います。ボールは手で
      キャッチして運び、蹴ることも、握った拳で打つこともできます。ただし「投げる」
      ことはできません。相手陣のバーの上、またはネットの中にボールを入れると得点です。
      アイルランドでは8万人の観客が入る決勝戦でも、選手は全員アマチュアで、
      報酬を受け取る選手はいません。
    </p>''', "short version")

# ---- 3. scoring: two-pointer + spacing
swap(EN, r'<p>\s*Scores are written as two numbers.*?</p>',
'''<p>
      Since 2026 there is a third way to score: a kick over the bar from on or
      outside the <strong>40-metre arc</strong> is worth two points instead of
      one. It has to be kicked rather than hand-passed, and no teammate can touch
      it on the way over. The umpire raises an orange flag.
    </p>
    <p>Scores are written as two numbers: goals first, then points. So <strong>1–08</strong> means one goal and eight points, which is eleven in total. A team on 0–15 beats a team on 2–08. Two-pointers count as two in the points column.</p>''', "scoring")
swap(JA, r'<p>\s*スコアは「ゴール数－ポイント数」.*?</p>',
'''<p>
      2026年からは、3つ目の得点方法が加わりました。<strong>40メートルのアーク（弧）</strong>
      の上、またはその外から蹴ってバーの上に入れると、1点ではなく2点になります。
      ハンドパスではなくキックであること、味方が途中で触っていないことが条件です。
      審判はオレンジの旗を上げます。
    </p>
    <p>スコアは「ゴール数－ポイント数」で表記します。たとえば <strong>1–08</strong> は1ゴールと8ポイントで、合計11点です。0–15 のチームは 2–08 のチームに勝ちます。2点シュートはポイント欄に2として数えます。</p>''', "scoring")

# ---- 4. how physical
swap(EN, r'<h2>How physical is it\?</h2>\s*<p>.*?</p>',
'''<h2>How physical is it?</h2>
    <p>
      Shoulder-to-shoulder contact is part of the men's game, but there is no
      tackling the way there is in rugby — you can't grab, drag or wrestle an
      opponent to the ground. It is less physical than rugby or Australian
      football.
    </p>''', "physical")
swap(JA, r'<h2>激しいスポーツですか？</h2>\s*<p>.*?</p>',
'''<h2>激しいスポーツですか？</h2>
    <p>
      肩と肩でぶつかるコンタクトは男子の試合の一部ですが、ラグビーのような
      タックルはありません。相手をつかんだり、引き倒したりすることはできません。
      ラグビーやオーストラリアンフットボールほど激しくはありません。
    </p>''', "physical")

# ---- 5. if you've played something else
swap(EN, r'<h2>If you\'ve played something else</h2>\s*<ul class="rules">.*?</ul>',
'''<h2>If you've played something else</h2>
    <p>
      Soccer, rugby and basketball all give you useful skills — but our members
      have come from a wide range of sporting backgrounds, including none at all.
    </p>''', "backgrounds")
swap(JA, r'<h2>他の競技の経験がある方へ</h2>\s*<ul class="rules">.*?</ul>',
'''<h2>他の競技の経験がある方へ</h2>
    <p>
      サッカー、ラグビー、バスケットボールの経験はいずれも活かせますが、
      メンバーの競技歴はさまざまで、まったくの未経験から始めた人もたくさんいます。
    </p>''', "backgrounds")

# ---- 6. hurl wording
p = pathlib.Path(EN); s = p.read_text()
s = s.replace("a stick called a hurley and a small hard ball — often described\n      as the fastest field sport in the world.",
              "a stick called a hurl and a small hard ball. It is often described as\n      the fastest field sport in the world.")
s = s.replace("a stick called a hurley", "a stick called a hurl")
p.write_text(s); print("  ok   hurl wording")

if fails:
    print("\nNOT APPLIED:")
    for f in fails: print("  !!", f)
PY

# ---- scoring diagram gains the two-pointer line
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/ScoringDiagram.astro"); s = p.read_text()
if "two" not in s:
    s = s.replace('const over  = lang === "ja" ? "バーの上" : "over the bar";',
      'const over  = lang === "ja" ? "バーの上" : "over the bar";\n'
      'const two   = lang === "ja" ? "2ポイント = 2点" : "Two-pointer — 2 points";\n'
      'const arc   = lang === "ja" ? "40mアークの外から" : "from outside the 40m arc";')
    s = s.replace('    <p><span class="dot dot--goal"></span><strong>{goal}</strong> — {under}</p>',
      '    <p><span class="dot dot--two"></span><strong>{two}</strong> — {arc}</p>\n'
      '    <p><span class="dot dot--goal"></span><strong>{goal}</strong> — {under}</p>')
    p.write_text(s); print("  ok   ScoringDiagram")
else:
    print("  --   ScoringDiagram already updated")
PY

cat >> src/styles/global.css <<'EOF'
.dot--two { background: #e08a1e; }
EOF

echo
npm run build 2>&1 | tail -5
