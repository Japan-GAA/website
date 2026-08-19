#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/config src/components src/pages/ja public/photos

# ---------------------------------------------------------------- photo slots
cat > src/config/photos.js <<'EOF'
// Photographs used across the site.
// Put the file in public/photos/ and name it here. Leave "" and the page
// simply renders without a photo — nothing breaks.
//
// To add one:
//   cp archive/images-web/<file>.webp public/photos/history.webp
//   then set history: "/photos/history.webp" below.
export const PHOTOS = {
  hero:      "",   // wide action or team shot — the homepage hero
  sport:     "",   // someone soloing / catching — the explainer page
  history:   "",   // an old team photo
  committee: "",   // committee group shot
  training:  "",   // a session in progress
  news:      "",   // fallback thumbnail for posts with no cover image
};
EOF

# ------------------------------------------------------------ photo component
cat > src/components/Photo.astro <<'EOF'
---
// Renders nothing at all if the slot is empty, so a missing photo can never
// leave a broken image on the page.
const { src, alt = "", caption, wide = false } = Astro.props;
---
{src && (
  <figure class={wide ? "photo photo--wide" : "photo"}>
    <img src={src} alt={alt} loading="lazy" decoding="async" />
    {caption && <figcaption>{caption}</figcaption>}
  </figure>
)}
EOF

# --------------------------------------------------------------- fact strip
cat > src/components/Facts.astro <<'EOF'
---
const { lang = "en" } = Astro.props;
const facts = lang === "ja"
  ? [
      { n: "1995",  l: "日本支部 設立" },
      { n: "20+",   l: "メンバーの出身国" },
      { n: "無料",  l: "初回参加" },
      { n: "40回",  l: "年間の練習回数" },
    ]
  : [
      { n: "1995",  l: "Founded in Japan" },
      { n: "20+",   l: "Nationalities" },
      { n: "Free",  l: "First session" },
      { n: "40",    l: "Sessions a year" },
    ];
---
<section class="facts">
  <div class="wrap facts__grid">
    {facts.map((f) => (
      <div class="facts__item">
        <span class="facts__n">{f.n}</span>
        <span class="facts__l">{f.l}</span>
      </div>
    ))}
  </div>
</section>
EOF

# ------------------------------------------------------------ english home
cat > src/pages/index.astro <<'EOF'
---
import { getCollection } from "astro:content";
import Base from "../layouts/Base.astro";
import Facts from "../components/Facts.astro";
import Sessions from "../components/Sessions.astro";
import { PHOTOS } from "../config/photos.js";
import { urlFor } from "../lib/news";

const latest = (await getCollection("news"))
  .filter((p) => !p.id.startsWith("ja/"))
  .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf())
  .slice(0, 3);
const fmt = (d) => d.toLocaleDateString("en-IE", { year: "numeric", month: "long" });
---
<Base lang="en" pageKey="home"
  title="Japan GAA — Gaelic Football in Tokyo | ゲーリックフットボール"
  description="Japan GAA plays Gaelic football in Tokyo. Beginners welcome, no experience needed, and your first session is free. Training at Yashio Kita Park, Shinagawa.">

  <section class:list={["hero2", PHOTOS.hero && "hero2--photo"]}>
    {PHOTOS.hero && <img class="hero2__bg" src={PHOTOS.hero} alt="" fetchpriority="high" />}
    <div class="wrap hero2__inner">
      <p class="hero2__eyebrow">Tokyo · 東京 · since 1995</p>
      <h1>Gaelic football in Tokyo</h1>
      <p class="hero2__fáilte"><em>Céad míle fáilte</em> — a hundred thousand welcomes.</p>
      <p class="hero2__lede">
        Ireland's national sport, played on grass in Shinagawa. Most of our players
        had never seen a Gaelic ball before they turned up. No experience needed,
        and the first session is free.
      </p>
      <p class="hero2__cta">
        <a class="cta" href="/training">Come to training</a>
        <a class="cta cta--ghost" href="/gaelic-football">What is Gaelic football?</a>
      </p>
    </div>
  </section>

  <Facts lang="en" />

  <section class="panel">
    <div class="wrap split">
      <div>
        <h2>Next sessions</h2>
        <Sessions lang="en" />
        <p class="muted">
          7–9pm at Yashio Kita Park, Shinagawa. The day of the week changes.
        </p>
        <p><a href="/training">Everything you need to know →</a></p>
      </div>
      <div>
        <h2>New to the sport?</h2>
        <p>
          You can catch the ball, carry it, kick it and strike it with your fist —
          but never throw it. Over the bar is a point, into the net is a goal, and
          a goal is worth three.
        </p>
        <p><a href="/gaelic-football">The two-minute explanation →</a></p>
      </div>
    </div>
  </section>

  <section class="panel">
    <div class="wrap">
      <h2>Latest news</h2>
      <ul class="newsgrid">
        {latest.map((post) => (
          <li>
            <a href={urlFor(post.id)}>
              {post.data.cover && <img src={post.data.cover} alt="" loading="lazy" />}
              <time>{fmt(post.data.date)}</time>
              <h3>{post.data.title}</h3>
            </a>
          </li>
        ))}
      </ul>
      <p><a href="/news">All news and the newsletter archive →</a></p>
    </div>
  </section>

  <section class="panel panel--join">
    <div class="wrap">
      <h2>Join us</h2>
      <p>
        Join a community that is passionate, determined, and supportive. Whether
        you're here for a day or committed to years, feel free to join us here at
        Japan GAA.
      </p>
      <p><a class="cta" href="/training">Come to a session</a></p>
    </div>
  </section>
</Base>
EOF

# ----------------------------------------------------------- japanese home
cat > src/pages/ja/index.astro <<'EOF'
---
import { getCollection } from "astro:content";
import Base from "../../layouts/Base.astro";
import Facts from "../../components/Facts.astro";
import Sessions from "../../components/Sessions.astro";
import { PHOTOS } from "../../config/photos.js";
import { urlFor } from "../../lib/news";

const latest = (await getCollection("news"))
  .filter((p) => p.id.startsWith("ja/") || p.data.archived)
  .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf())
  .slice(0, 3);
const fmt = (d) => d.toLocaleDateString("ja-JP", { year: "numeric", month: "long" });
---
<Base lang="ja" pageKey="home"
  title="Japan GAA 日本ゲーリック協会 — 東京のゲーリックフットボールクラブ"
  description="Japan GAAは東京で活動するゲーリックフットボールクラブです。未経験者大歓迎、初回参加は無料。品川区の八潮北公園で練習しています。">

  <section class:list={["hero2", PHOTOS.hero && "hero2--photo"]}>
    {PHOTOS.hero && <img class="hero2__bg" src={PHOTOS.hero} alt="" fetchpriority="high" />}
    <div class="wrap hero2__inner">
      <p class="hero2__eyebrow">Tokyo · 東京 · since 1995</p>
      <h1>東京で、ゲーリックフットボール</h1>
      <p class="hero2__fáilte"><em>Céad míle fáilte</em> — ようこそ！</p>
      <p class="hero2__lede">
        アイルランドの国技を、品川の芝生のグラウンドで。メンバーのほとんどが、
        参加するまでゲーリックフットボールを見たこともありませんでした。
        経験は必要ありません。初回参加は無料です。
      </p>
      <p class="hero2__cta">
        <a class="cta" href="/ja/training">練習に参加する</a>
        <a class="cta cta--ghost" href="/ja/gaelic-football">競技について</a>
      </p>
    </div>
  </section>

  <Facts lang="ja" />

  <section class="panel">
    <div class="wrap split">
      <div>
        <h2>次回の練習</h2>
        <Sessions lang="ja" />
        <p class="muted">
          品川区・八潮北公園にて 19:00〜21:00。曜日は回によって変わります。
        </p>
        <p><a href="/ja/training">練習の詳細はこちら →</a></p>
      </div>
      <div>
        <h2>はじめての方へ</h2>
        <p>
          ボールは手でキャッチして運び、蹴ることも、拳で打つこともできます。
          ただし投げることはできません。バーの上に入れると1ポイント、
          ネットに入れると3点のゴールです。
        </p>
        <p><a href="/ja/gaelic-football">2分で分かるルール →</a></p>
      </div>
    </div>
  </section>

  <section class="panel">
    <div class="wrap">
      <h2>最新ニュース</h2>
      <ul class="newsgrid">
        {latest.map((post) => (
          <li>
            <a href={urlFor(post.id)}>
              {post.data.cover && <img src={post.data.cover} alt="" loading="lazy" />}
              <time>{fmt(post.data.date)}</time>
              <h3>{post.data.title}</h3>
            </a>
          </li>
        ))}
      </ul>
      <p><a href="/ja/news">ニュース一覧・アーカイブ →</a></p>
    </div>
  </section>

  <section class="panel panel--join">
    <div class="wrap">
      <h2>入会について</h2>
      <p>
        Japan GAAは和気あいあいと仲の良いコミュニティーです。未経験でも大歓迎
        ですので、ご興味のある方は体験練習にお気軽にご参加ください。
      </p>
      <p><a class="cta" href="/ja/training">練習に参加する</a></p>
    </div>
  </section>
</Base>
EOF

# ------------------------------------------- drop photos into the other pages
python3 - <<'PY'
import pathlib, re
JOBS = [
 ("src/pages/gaelic-football.astro", "../components/Photo.astro", "../config/photos.js",
  "sport", 'alt="A Japan GAA player soloing the ball"', r"<h2>Moving the ball</h2>"),
 ("src/pages/ja/gaelic-football.astro", "../../components/Photo.astro", "../../config/photos.js",
  "sport", 'alt="ソロでボールを運ぶ選手"', r"<h2>ボールの運び方</h2>"),
 ("src/pages/history.astro", "../components/Photo.astro", "../config/photos.js",
  "history", 'alt="A Japan GAA team photo"', r"<h2>The History of Japan GAA</h2>"),
 ("src/pages/ja/history.astro", "../../components/Photo.astro", "../../config/photos.js",
  "history", 'alt="Japan GAAのチーム写真"', r"<h2>沿革</h2>"),
 ("src/pages/committee.astro", "../components/Photo.astro", "../config/photos.js",
  "committee", 'alt="The Japan GAA committee"', r"<h2>Committee</h2>"),
 ("src/pages/ja/committee.astro", "../../components/Photo.astro", "../../config/photos.js",
  "committee", 'alt="Japan GAAの運営メンバー"', r"<h2>運営メンバー</h2>"),
 ("src/pages/training.astro", "../components/Photo.astro", "../config/photos.js",
  "training", 'alt="A Japan GAA training session"', r'<section class="factgrid">'),
 ("src/pages/ja/training.astro", "../../components/Photo.astro", "../../config/photos.js",
  "training", 'alt="Japan GAAの練習風景"', r'<section class="factgrid">'),
]
for path, pimp, cimp, slot, alt, anchor in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("  skip (missing)", path); continue
    s = p.read_text()
    if "Photo.astro" not in s:
        s = re.sub(r"(---\nimport )",
                   f'---\nimport Photo from "{pimp}";\nimport {{ PHOTOS }} from "{cimp}";\nimport ',
                   s, count=1)
    tag = f'<Photo src={{PHOTOS.{slot}}} {alt} wide />\n\n    '
    s2, n = re.subn(anchor, tag + anchor.replace("\\", ""), s, count=1)
    if n == 0:
        print("  !! anchor not found in", path); continue
    p.write_text(s2); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* ================= redesign ================= */

/* ---- photo-led hero ---- */
.hero2 { position: relative; isolation: isolate; }
.hero2__inner { padding-block: clamp(3.5rem, 10vw, 7rem); position: relative; }
.hero2__bg {
  position: absolute; inset: 0; width: 100%; height: 100%;
  object-fit: cover; z-index: -2;
}
.hero2--photo::after {
  content: ""; position: absolute; inset: 0; z-index: -1;
  background: linear-gradient(105deg, rgba(16,34,27,.92) 0%, rgba(16,34,27,.78) 45%, rgba(16,34,27,.35) 100%);
}
.hero2--photo, .hero2--photo h1 { color: var(--chalk); }
.hero2--photo .hero2__lede { color: #dfe6e1; }
.hero2--photo .hero2__fáilte { color: #9fd9bb; }

.hero2__eyebrow {
  font-family: var(--display); text-transform: uppercase; letter-spacing: 0.2em;
  font-size: 0.75rem; font-weight: 700; color: var(--vermilion); margin: 0 0 1rem;
}
.hero2--photo .hero2__eyebrow { color: #ff8fa3; }
.hero2 h1 { max-width: 16ch; margin-bottom: 0.35em; }
.hero2__fáilte {
  font-size: 1.125rem; color: var(--pitch); margin: 0 0 1.25rem; max-width: none;
}
.hero2__fáilte em { font-weight: 600; }
.hero2__lede { font-size: 1.1875rem; max-width: 42ch; }
.hero2__cta { display: flex; gap: 0.85rem; flex-wrap: wrap; margin-top: 2rem; }

.cta--ghost {
  background: transparent; color: var(--pitch);
  box-shadow: inset 0 0 0 2px currentColor;
}
.hero2--photo .cta--ghost { color: var(--chalk); }
.cta--ghost:hover { background: var(--vermilion); box-shadow: none; color: var(--chalk); }

/* ---- fact strip ---- */
.facts { background: var(--pitch); color: var(--chalk); }
.facts__grid {
  display: grid; grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem 1rem; padding-block: 2rem;
}
@media (min-width: 46rem) { .facts__grid { grid-template-columns: repeat(4, 1fr); } }
.facts__item { display: flex; flex-direction: column; gap: 0.25rem; }
.facts__n { font-family: var(--display); font-weight: 800; font-size: clamp(1.75rem, 4vw, 2.5rem); line-height: 1; }
.facts__l { font-size: 0.8125rem; letter-spacing: 0.08em; text-transform: uppercase; opacity: 0.75; }

/* ---- two-up split ---- */
.split { display: grid; gap: clamp(2rem, 5vw, 3.5rem); grid-template-columns: 1fr; }
@media (min-width: 46rem) { .split { grid-template-columns: 1fr 1fr; } }
.split h2 { font-size: 1.5rem; }

/* ---- news grid ---- */
.newsgrid {
  list-style: none; padding: 0; margin: 1.5rem 0;
  display: grid; gap: 1.75rem;
  grid-template-columns: repeat(auto-fit, minmax(15rem, 1fr));
}
.newsgrid a { text-decoration: none; color: inherit; display: block; }
.newsgrid img {
  width: 100%; aspect-ratio: 3 / 2; object-fit: cover;
  display: block; border-radius: 3px; margin-bottom: 0.75rem;
}
.newsgrid time { font-size: 0.8125rem; color: var(--stone); }
.newsgrid h3 { font-size: 1.0625rem; line-height: 1.4; margin: 0.2rem 0 0; letter-spacing: 0; }
.newsgrid a:hover h3 { color: var(--vermilion); }

/* ---- inline photos ---- */
.photo { margin: 2rem 0; }
.photo img { width: 100%; height: auto; display: block; border-radius: 3px; }
.photo--wide img { aspect-ratio: 16 / 7; object-fit: cover; }
.photo figcaption { font-size: 0.8125rem; color: var(--stone); margin-top: 0.5rem; }

/* ---- join panel ---- */
.panel--join { background: var(--ink); color: var(--chalk); border-top: 0; }
.panel--join h2 { color: var(--chalk); }
.panel--join p { color: #cfd8d3; }
.panel--join .cta { background: var(--vermilion); }
.panel--join .cta:hover { background: var(--chalk); color: var(--ink); }
EOF

echo
echo "Now choose photos — candidates in your archive:"
ls archive/images-web 2>/dev/null | grep -iE "team|committee|dsc|agg|sports|day" | head -20 || echo "  (run from repo root with archive/images-web present)"
echo
echo "Then:  cp archive/images-web/<file> public/photos/hero.webp"
echo "       and set the paths in src/config/photos.js"
