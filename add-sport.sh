#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/pages/ja src/components

cat > src/components/ScoringDiagram.astro <<'EOF'
---
const { lang = "en" } = Astro.props;
const goal  = lang === "ja" ? "ゴール = 3点"  : "Goal — 3 points";
const point = lang === "ja" ? "ポイント = 1点" : "Point — 1 point";
const under = lang === "ja" ? "バーの下・ネットの中" : "under the bar, into the net";
const over  = lang === "ja" ? "バーの上" : "over the bar";
---
<figure class="scoring">
  <svg viewBox="0 0 340 250" role="img" aria-label={`${goal} / ${point}`}>
    <g stroke="var(--pitch)" stroke-width="6" fill="none" stroke-linecap="square">
      <line x1="95" y1="20" x2="95" y2="215" />
      <line x1="245" y1="20" x2="245" y2="215" />
      <line x1="80" y1="130" x2="260" y2="130" />
      <line x1="30" y1="215" x2="310" y2="215" />
    </g>
    <rect x="95" y="130" width="150" height="85" fill="var(--pitch)" opacity="0.08" />
    <circle cx="170" cy="72" r="12" fill="var(--vermilion)" />
    <circle cx="170" cy="175" r="12" fill="var(--pitch)" />
  </svg>
  <figcaption>
    <p><span class="dot dot--point"></span><strong>{point}</strong> — {over}</p>
    <p><span class="dot dot--goal"></span><strong>{goal}</strong> — {under}</p>
  </figcaption>
</figure>
EOF

cat > src/pages/gaelic-football.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
import ScoringDiagram from "../components/ScoringDiagram.astro";
---
<Base lang="en" pageKey="sport"
  title="What is Gaelic Football? — Japan GAA"
  description="Gaelic football is Ireland's national sport: fifteen a side, played with the hands and feet, amateur at every level. A short guide for anyone in Japan who has never seen it.">

  <div class="wrap prose">
    <header class="pagehead">
      <h1>What is Gaelic football?</h1>
      <p class="hero__lede">
        Ireland's national sport — and almost certainly nothing like anything
        you've played before. It takes about two minutes to understand and one
        session to get hooked.
      </p>
    </header>

    <h2>The short version</h2>
    <p>
      Fifteen players a side on a large grass pitch. You can catch the ball, carry
      it, kick it and strike it with your fist. You cannot throw it. The aim is to
      put it over the crossbar or into the net at the other end. Games are amateur
      at every level, right up to an All-Ireland final in front of 82,000 people —
      nobody is paid to play.
    </p>

    <h2>Scoring — the part that confuses everyone</h2>
    <p>
      The posts are H-shaped, like rugby posts with a soccer goal underneath. There
      are two ways to score, and they're worth different amounts.
    </p>

    <ScoringDiagram lang="en" />

    <p>
      Scores are written as two numbers: goals first, then points. So
      <strong>1–08</strong> means one goal and eight points, which is eleven in
      total. A team on 0–15 beats a team on 2–08.
    </p>

    <h2>Moving the ball</h2>
    <ul class="rules">
      <li><strong>Four steps.</strong> You can carry the ball for four steps before you have to do something with it.</li>
      <li><strong>The solo.</strong> Drop the ball onto your foot and kick it back into your hands. Then you get another four steps. This is the skill that takes practice.</li>
      <li><strong>The bounce.</strong> You can bounce the ball too, but not twice in a row.</li>
      <li><strong>The hand pass.</strong> Strike the ball with a closed fist or open hand. Throwing is a foul.</li>
      <li><strong>Kicking.</strong> Kick to a teammate or at the posts, from the hands or off the ground.</li>
    </ul>

    <h2>How physical is it?</h2>
    <p>
      Shoulder-to-shoulder contact is part of the game, but there is no tackling
      the way there is in rugby — you can't grab, drag or wrestle an opponent to
      the ground. Most people find it less punishing than rugby and more physical
      than soccer.
    </p>

    <h2>If you've played something else</h2>
    <ul class="rules">
      <li><strong>Soccer:</strong> your fitness and your kicking transfer directly. The hands take the getting used to.</li>
      <li><strong>Rugby:</strong> the catching and the contact will feel familiar. You'll have to stop throwing.</li>
      <li><strong>Basketball:</strong> the hand pass, the bounce and the movement off the ball are all recognisable.</li>
      <li><strong>Nothing at all:</strong> this is the most common case at Japan GAA, and it's genuinely fine.</li>
    </ul>

    <h2>The other Gaelic games</h2>
    <p>
      The GAA also runs <strong>hurling</strong> and <strong>camogie</strong>,
      played with a stick called a hurley and a small hard ball — often described
      as the fastest field sport in the world. Japan GAA's focus is Gaelic
      football, men's and ladies'.
    </p>

    <h2>Where to see it</h2>
    <p>
      The easiest way to understand it is to watch ten minutes of an All-Ireland
      final, then come and try it. Our sessions are open to complete beginners and
      the first one is free.
    </p>
    <p><a class="cta" href="/training">Come to training →</a></p>

    <!-- TODO: embed a short video (All-Ireland highlights or a club clip).
         TODO: confirm the format played at the Asian Gaelic Games — smaller-sided
         than 15-a-side — and add a line about what people actually play here. -->
  </div>
</Base>
EOF

cat > src/pages/ja/gaelic-football.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
import ScoringDiagram from "../../components/ScoringDiagram.astro";
// TODO: 日本語ネイティブのメンバーによる確認・修正が必要です（下書きです）。
---
<Base lang="ja" pageKey="sport"
  title="ゲーリックフットボールとは — Japan GAA"
  description="ゲーリックフットボールはアイルランドの国技です。手と足の両方を使う、15人制のスポーツ。日本ではまだ知られていない競技を、はじめての方向けに解説します。">

  <div class="wrap prose">
    <header class="pagehead">
      <h1>ゲーリックフットボールとは</h1>
      <p class="hero__lede">
        アイルランドの国技で、おそらく今まで経験したどのスポーツとも違います。
        ルールは2分で分かり、1回の練習で好きになる競技です。
      </p>
    </header>

    <h2>かんたんに言うと</h2>
    <p>
      15人対15人、広い芝生のグラウンドで行います。ボールは手でキャッチして運び、
      蹴ることも、握った拳で打つこともできます。ただし「投げる」ことはできません。
      相手陣のバーの上、またはネットの中にボールを入れると得点です。
      アイルランドでは8万人の観客が入る決勝戦でも、選手は全員アマチュアです。
    </p>

    <h2>得点のしくみ</h2>
    <p>
      ゴールポストはH字型で、ラグビーのポストの下にサッカーのゴールがある形です。
      得点の方法は2種類あり、点数が異なります。
    </p>

    <ScoringDiagram lang="ja" />

    <p>
      スコアは「ゴール数－ポイント数」で表記します。たとえば
      <strong>1–08</strong> は1ゴールと8ポイントで、合計11点です。
      0–15 のチームは 2–08 のチームに勝ちます。
    </p>

    <h2>ボールの運び方</h2>
    <ul class="rules">
      <li><strong>4歩まで</strong>：ボールを持って走れるのは4歩までです。</li>
      <li><strong>ソロ</strong>：ボールを自分の足に落として蹴り上げ、手に戻します。またそこから4歩進めます。練習が必要なのはこの技術です。</li>
      <li><strong>バウンド</strong>：ドリブルのようにバウンドさせることもできますが、2回続けてはできません。</li>
      <li><strong>ハンドパス</strong>：握った拳、または開いた手でボールを打ちます。投げるのは反則です。</li>
      <li><strong>キック</strong>：手からでも地面からでも蹴ることができます。</li>
    </ul>

    <h2>激しいスポーツですか？</h2>
    <p>
      肩と肩でぶつかるコンタクトはありますが、ラグビーのようなタックルはありません。
      相手をつかんだり、引き倒したりすることは反則です。
      ラグビーより負担が少なく、サッカーより身体接触が多い、という感覚の方が多いです。
    </p>

    <h2>他の競技の経験がある方へ</h2>
    <ul class="rules">
      <li><strong>サッカー</strong>：体力とキックはそのまま活かせます。手を使うことに慣れが必要です。</li>
      <li><strong>ラグビー</strong>：キャッチとコンタクトは馴染みやすいです。投げないことに慣れてください。</li>
      <li><strong>バスケットボール</strong>：ハンドパス、バウンド、オフザボールの動きが活かせます。</li>
      <li><strong>未経験</strong>：Japan GAAではこれが一番多いパターンです。まったく問題ありません。</li>
    </ul>

    <h2>その他のゲーリックスポーツ</h2>
    <p>
      GAAは<strong>ハーリング</strong>と<strong>カモギー</strong>も統括しています。
      ハーリーというスティックと硬い小さなボールを使う競技で、
      「世界最速の球技」とも呼ばれます。Japan GAAが主に活動しているのは
      ゲーリックフットボール（男子・女子）です。
    </p>

    <h2>まずは見て、やってみてください</h2>
    <p>
      一番分かりやすいのは、実際にやってみることです。
      練習は未経験の方も大歓迎で、初回参加は無料です。
    </p>
    <p><a class="cta" href="/ja/training">練習に参加する →</a></p>
  </div>
</Base>
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- sport explainer ---- */
.scoring {
  margin: 2rem 0; display: grid; gap: 1.5rem; align-items: center;
  grid-template-columns: 1fr;
}
@media (min-width: 40rem) { .scoring { grid-template-columns: 1fr 1fr; } }
.scoring svg { width: 100%; height: auto; }
.scoring figcaption p { display: flex; align-items: center; gap: 0.6rem; margin: 0 0 0.75rem; }
.dot { width: 0.85rem; height: 0.85rem; border-radius: 50%; flex: none; }
.dot--goal { background: var(--pitch); }
.dot--point { background: var(--vermilion); }

.rules { list-style: none; padding: 0; margin: 1.25rem 0; }
.rules li {
  padding: 0.75rem 0 0.75rem 1.25rem;
  border-left: 3px solid var(--line);
  margin-bottom: 0.5rem;
}
.rules li strong { color: var(--pitch); }
EOF

echo "Added /gaelic-football and /ja/gaelic-football"
