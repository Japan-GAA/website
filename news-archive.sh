#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

TPL = '''---
import Base from "../{up}layouts/Base.astro";
import {{ newsFor, urlFor }} from "../{up}lib/news";
const posts = await newsFor("{lang}");

// group by year, newest first
const years = [...new Set(posts.map((p) => p.data.date.getFullYear()))].sort((a, b) => b - a);
const fmt = (d) => d.toLocaleDateString("{locale}", {{ timeZone: "Asia/Tokyo", month: "long" }});
---
<Base lang="{lang}" pageKey="news" title="{title}"
  description="{desc}">
  <div class="wrap">
    <header class="pagehead">
      <h1>{h1}</h1>
      <p class="hero__lede">{lede}</p>
    </header>

    {{years.map((year) => (
      <section class="archive">
        <h2 class="archive__year">{{year}}</h2>
        <ul class="newsgrid">
          {{posts.filter((p) => p.data.date.getFullYear() === year).map((post) => (
            <li>
              <a href={{urlFor(post.id)}}>
                {{post.data.cover && <img src={{post.data.cover}} alt="" loading="lazy" />}}
                <time>{{fmt(post.data.date)}}</time>
                <h3>{{post.data.title}}</h3>
              </a>
            </li>
          ))}}
        </ul>
      </section>
    ))}}
  </div>
</Base>
'''

pathlib.Path("src/pages/news/index.astro").write_text(TPL.format(
  up="../", lang="en", locale="en-IE",
  title="News and archive — Japan GAA",
  desc="Club news from Japan GAA, plus the full newsletter archive going back to 2019 — tournaments, training, socials and photos.",
  h1="News", lede="Everything happening at the club, and the full archive back to 2019."))

pathlib.Path("src/pages/ja/news/index.astro").write_text(TPL.format(
  up="../../", lang="ja", locale="ja-JP",
  title="ニュース・アーカイブ — Japan GAA",
  desc="Japan GAAの活動報告と、2019年からのニュースレター・アーカイブ。大会、練習、イベントの記録と写真。",
  h1="ニュース", lede="クラブの活動内容と、2019年からのアーカイブです。"))
print("  ok   both news index pages rebuilt")
PY

cat >> src/styles/global.css <<'EOF'

/* ---- news archive by year ---- */
.archive { margin-bottom: 3rem; }
.archive__year {
  font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.16em;
  color: var(--vermilion); border-top: 2px solid var(--vermilion);
  padding-top: 0.6rem; margin: 0 0 1.5rem;
}
.archive .newsgrid { margin-top: 0; }
EOF

echo
npm run build 2>&1 | tail -4
