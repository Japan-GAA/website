#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/pages/ja

cat > src/pages/history.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
---
<Base lang="en" pageKey="history"
  title="History — Japan GAA | Gaelic Football in Tokyo since 1995"
  description="The history of Japan GAA, the Japan branch of the Gaelic Athletic Association, founded in 1995 and playing Gaelic football in Tokyo ever since.">

  <div class="wrap prose">
    <header class="pagehead">
      <h1>About</h1>
      <p class="hero__lede">The history of Japan GAA.</p>
    </header>

    <h2>The History of Japan GAA</h2>

    <p>
      The Gaelic Athletics Association (GAA) was founded in Ireland in 1884 to
      promote Gaelic sports (principally Gaelic football, hurling and camogie)
      and Irish national identity. The Japan branch of GAA was founded in 1995.
    </p>

    <p>
      Japan GAA is a non-profit volunteer organisation devoted to promoting
      international friendship and understanding in Japan and Asia, primarily
      through participation in Gaelic sports and Irish culture. Like other GAA
      clubs in Asia, Japan GAA has undergone several turnovers in membership in
      its history, but each year manages to pull together an excellent group of
      players.
    </p>

    <p>
      Over the years, the members have come from many different countries beyond
      Ireland and Japan, including China, Malaysia, Australia, New Zealand,
      Canada, USA, UK, Germany, Sweden, Norway and Switzerland. The club has long
      worked to recruit members of the local community; the women's team has been
      predominantly Japanese nationals for some years now.
    </p>

    <p>
      As the club has developed, Japan GAA has steadily increased its activities
      from a few months of preparation for the Asian Gaelic Games (AGG) to a full
      12-month calendar of sporting and social events. Members can be found
      training from early spring to late autumn, playing a full part in St.
      Patrick's Day events in March, hosting an international multi-sports day and
      attending the North Asian Gaelic Games (NAGG) in early summer, and
      participating in Irish events across Japan throughout the year.
    </p>

    <p>
      Japan GAA has sent teams to every AGG since their inception in 1996 and to
      every NAGG since they started in 2008. We hosted NAGG in 2010 and 2019.
      Over the years we have had successes at every level in Asia. Members have
      also travelled to Ireland to play for Asia representative teams at the GAA
      World Games. The Women's team played a game at Croke Park, the premier
      stadium of Gaelic sports, in 2017.
    </p>

    <!-- TODO: the account stops at 2017. Worth adding recent results —
         e.g. AGG Bangkok 2025, where the Men's A and B teams both won their
         categories and the Women reached the semifinals. -->
  </div>
</Base>
EOF

cat > src/pages/ja/history.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
---
<Base lang="ja" pageKey="history"
  title="Japan GAAについて — 日本ゲーリック協会の沿革"
  description="日本ゲーリック協会（ジャパンGAA）の沿革。1990年代半ばに設立された非営利のボランティア団体です。">

  <div class="wrap prose">
    <header class="pagehead">
      <h1>Japan GAAについて</h1>
      <p class="hero__lede">ジャパンGAAの沿革。</p>
    </header>

    <h2>沿革</h2>

    <p>
      ジャパンGAAは90年代半ばにできたボランティアによる非営利の団体で、日本、
      そしてアジアで、主にゲール由来のスポーツとアイルランド文化を通して、
      国際交流や相互理解を進めて行くことを目的として活動しています。他のアジアの
      各クラブと同様、ジャパンGAAもメンバーが何度も変わりましたが、毎年、
      素晴らしい選手によるグループを作り上げてきました。
    </p>

    <p>
      ジャパンGAAの歴史を見ると、クラブ・メンバーはいくつもの国から集まって
      いました。一部の国を上げると次のようになります：アイルランド、日本、中国、
      マレーシア、イングランド、スコットランド、ウェールズ、USA、オーストラリア、
      スウェーデン、ニュージーランド、カナダなど。最近、日本人からより多くの
      メンバーを集めることに力を入れた結果、女子チームのメンバーのほとんどが
      日本人プレーヤーで構成されています。
    </p>

    <p>
      ジャパンGAAは、かつてはエージアン・ゲーリック・ゲームス (Asian Gaelic
      Games) の前の数ヶ月のみの活動でしたが、毎年少しづつ一年を通しての様々な
      イベントに活動の幅を広げてきました。トレーニングを春の早い時期から始めたり、
      ３月のセント・パトリックス・デーの準備から参加、初夏の北アジア大会への
      参加といった、日本での文化関連イベントとそれ以外にも広がっています。
    </p>

    <p>
      近年では、女子チームは、2016年のオールアジア大会にて、ジュニアカップ・
      トーナメント優勝。男子チームは、2016年の北アジア大会にて優勝し、
      シルバーウェアの栄光を持ち帰りました。
    </p>

    <!-- TODO: 日本語版は英語版より内容が古く、以下が欠けています。
         日本語を書けるメンバーに加筆してもらってください。
           ・GAAは1884年にアイルランドで設立、日本支部は1995年設立
           ・1996年の第1回アジア大会以降すべてに、2008年開始の北アジア大会
             以降すべてにチームを派遣
           ・北アジア大会を2010年と2019年に日本で開催
           ・GAAワールドゲームズにアジア代表として参加
           ・2017年、女子チームがクローク・パークで試合
           ・2016年以降の実績（2025年バンコクのアジア大会など） -->
  </div>
</Base>
EOF

echo "Added /history and /ja/history"
