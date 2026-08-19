#!/usr/bin/env bash
# Adds /training and /ja/training
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/pages/ja

cat > src/pages/training.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
const MAP = "https://maps.app.goo.gl/DLmB27aQEgWyWzAp7";
---
<Base lang="en" pageKey="training"
  title="Training — Japan GAA | Gaelic Football in Tokyo"
  description="Japan GAA trains at Yashio Kita Park in Shinagawa, Tokyo. Beginners welcome, no experience needed, and your first session is free.">

  <div class="wrap">
    <header class="pagehead">
      <h1>Training</h1>
      <p class="hero__lede">
        Your first session is free, and beginners are welcome. Most of our players
        had never seen a Gaelic ball before they turned up — you don't need
        experience, and you don't need to know the rules.
      </p>
    </header>

    <section class="factgrid">
      <div class="fact">
        <h2>Where</h2>
        <p>
          <strong>Yashio Kita Park</strong><br />
          八潮北公園<br />
          1-3-1 Yashio, Shinagawa-ku, Tokyo 140-0003
        </p>
        <p><a href={MAP} rel="noopener">Open in Google Maps →</a></p>
        <!-- TODO: nearest station + walking time. Ōi-keibajō-mae (Tokyo Monorail)
             looks closest — confirm with the committee before publishing. -->
      </div>

      <div class="fact">
        <h2>When</h2>
        <!-- TODO: training days and times. Not in the LINE note. -->
        <p>Get in touch and we'll tell you when the next session is.</p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>

      <div class="fact">
        <h2>What to bring</h2>
        <!-- TODO: confirm with the committee — boots or trainers? -->
        <p>Sports clothes, something to drink, and trainers or football boots. We have the balls.</p>
      </div>
    </section>

    <section class="panel">
      <h2>Membership</h2>
      <p>Fees for 2026:</p>
      <dl class="fees">
        <div><dt>Adult membership</dt><dd>¥15,000</dd></div>
        <div><dt>Student membership</dt><dd>¥7,500</dd></div>
        <div><dt>Per session</dt><dd>¥1,000</dd></div>
      </dl>
      <p>
        Membership covers every training session for the year — we ran around 40
        of them last year. If you'd rather pay as you go, sessions are ¥1,000
        each, and what you pay counts towards the membership fee up to the full
        amount.
      </p>
      <p><strong>Your first session is free.</strong> Come along, try it, and decide afterwards.</p>
      <!-- TODO: how to pay — cash on the day, bank transfer, PayPay? -->
      <p><a class="cta" href="mailto:japangaa@gmail.com">Get in touch</a></p>
    </section>
  </div>
</Base>
EOF

cat > src/pages/ja/training.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
const MAP = "https://maps.app.goo.gl/DLmB27aQEgWyWzAp7";
---
<Base lang="ja" pageKey="training"
  title="練習について — Japan GAA 日本ゲーリック協会"
  description="Japan GAAは品川区の八潮北公園で練習しています。未経験者大歓迎、初回参加は無料です。">

  <div class="wrap">
    <header class="pagehead">
      <h1>練習について</h1>
      <p class="hero__lede">
        初回参加は無料です。未経験の方も大歓迎ですので、お気軽にご参加ください。
        メンバーのほとんどが、参加するまでゲーリックフットボールを見たことが
        ありませんでした。ルールを知らなくても大丈夫です。
      </p>
    </header>

    <section class="factgrid">
      <div class="fact">
        <h2>場所</h2>
        <p>
          <strong>八潮北公園</strong><br />
          〒140-0003 東京都品川区八潮1-3-1
        </p>
        <p><a href={MAP} rel="noopener">Googleマップで開く →</a></p>
        <!-- TODO: 最寄駅と徒歩分数を確認 -->
      </div>

      <div class="fact">
        <h2>日時</h2>
        <!-- TODO: 練習日・時間 -->
        <p>次回の練習日については、お気軽にお問い合わせください。</p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>

      <div class="fact">
        <h2>持ち物</h2>
        <p>動きやすい服装、飲み物、運動靴またはサッカーシューズ。ボールはこちらで用意します。</p>
      </div>
    </section>

    <section class="panel">
      <h2>会費</h2>
      <p>今年度より会費が改定されました。2026年度の会費は以下の通りです。</p>
      <dl class="fees">
        <div><dt>一般会員</dt><dd>15,000円</dd></div>
        <div><dt>学生会員</dt><dd>7,500円</dd></div>
        <div><dt>都度払い（1回）</dt><dd>1,000円</dd></div>
      </dl>
      <p>
        この会費には、年間すべてのトレーニングが含まれます。
        （参考：昨年は年間40回程トレーニングを実施しました）
        また、1回ごとの都度払いも可能で1回1,000円です。都度払いでお支払い
        いただく場合は、上限を正会費額とします。
      </p>
      <p><strong>初回参加は無料です。</strong>まず一度体験してから、ご検討ください。</p>
      <!-- TODO: 支払い方法 -->
      <p><a class="cta" href="mailto:japangaa@gmail.com">お問い合わせ</a></p>
    </section>
  </div>
</Base>
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- training ---- */
.factgrid {
  display: grid; gap: 2rem;
  grid-template-columns: repeat(auto-fit, minmax(15rem, 1fr));
  padding-bottom: clamp(2rem, 5vw, 3.5rem);
}
.fact { border-top: 3px solid var(--pitch); padding-top: 1rem; }
.fact h2 {
  font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.14em;
  color: var(--vermilion); margin-bottom: 0.75rem;
}
.fact p { font-size: 0.9688rem; margin: 0 0 0.75rem; }

.fees { margin: 1.5rem 0; max-width: var(--measure); }
.fees > div {
  display: flex; justify-content: space-between; gap: 1rem;
  padding: 0.7rem 0; border-bottom: 1px solid var(--line);
}
.fees dt { margin: 0; }
.fees dd {
  margin: 0; font-family: var(--display); font-weight: 700;
  font-size: 1.125rem; color: var(--pitch);
}
EOF

echo "Added /training and /ja/training"
