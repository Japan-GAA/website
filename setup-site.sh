#!/usr/bin/env bash
# Run from the root of the website repo:  bash setup-site.sh
set -euo pipefail

[ -f astro.config.mjs ] || { echo "Run this from ~/website (no astro.config.mjs here)."; exit 1; }

mkdir -p src/layouts src/styles src/pages/ja public

# ---------------------------------------------------------------- site config
cat > src/consts.js <<'EOF'
export const SITE = {
  url: "https://japangaa.org",
  name: "Japan GAA",
};

// Every page is declared once, in both languages.
// `key` links the two versions together for the hreflang tags and the toggle.
export const PAGES = [
  { key: "home",     en: "/",                ja: "/ja/",                labelEn: "Home",      labelJa: "ホーム" },
  { key: "training", en: "/training",        ja: "/ja/training",        labelEn: "Training",  labelJa: "練習" },
  { key: "sport",    en: "/gaelic-football", ja: "/ja/gaelic-football", labelEn: "The sport", labelJa: "競技について" },
  { key: "news",     en: "/news",            ja: "/ja/news",            labelEn: "News",      labelJa: "ニュース" },
  { key: "club",     en: "/committee",       ja: "/ja/committee",       labelEn: "The club",  labelJa: "クラブ" },
  { key: "history",  en: "/history",         ja: "/ja/history",         labelEn: "History",   labelJa: "歴史" },
];

export const pathFor = (key, lang) => PAGES.find((p) => p.key === key)?.[lang];
EOF

# --------------------------------------------------------------------- styles
cat > src/styles/global.css <<'EOF'
/* Japan GAA — Irish green against hinomaru red, set on chalk.
   Display face is Bricolage Grotesque; Noto Sans JP carries both
   scripts so English and Japanese pages feel like one site. */

:root {
  --ink:        #10221b;
  --pitch:      #14663f;
  --pitch-lift: #1b8452;
  --vermilion:  #bc002d;
  --chalk:      #fafaf7;
  --stone:      #7d8a83;
  --line:       #dcded8;

  --display: "Bricolage Grotesque", "Noto Sans JP", system-ui, sans-serif;
  --body:    "Noto Sans JP", system-ui, -apple-system, sans-serif;

  --measure: 34rem;
  --gutter: clamp(1.25rem, 5vw, 4rem);
}

*, *::before, *::after { box-sizing: border-box; }

html { -webkit-text-size-adjust: 100%; }

body {
  margin: 0;
  background: var(--chalk);
  color: var(--ink);
  font-family: var(--body);
  font-size: 1.0625rem;
  line-height: 1.75;
  font-feature-settings: "palt" 1; /* tightens Japanese punctuation */
}

h1, h2, h3 {
  font-family: var(--display);
  font-weight: 700;
  line-height: 1.05;
  letter-spacing: -0.02em;
  margin: 0 0 0.5em;
  text-wrap: balance;
}

h1 { font-size: clamp(2.75rem, 9vw, 5.5rem); }
h2 { font-size: clamp(1.75rem, 4vw, 2.5rem); }
h3 { font-size: 1.25rem; }

p { max-width: var(--measure); }

a { color: var(--pitch); text-underline-offset: 0.2em; }
a:hover { color: var(--vermilion); }

:focus-visible {
  outline: 3px solid var(--vermilion);
  outline-offset: 3px;
}

.wrap { width: min(72rem, 100%); margin-inline: auto; padding-inline: var(--gutter); }
.stack > * + * { margin-top: 1.5rem; }

/* ---- header ---- */
.masthead {
  border-bottom: 1px solid var(--line);
  background: var(--chalk);
  position: sticky; top: 0; z-index: 10;
}
.masthead__inner {
  display: flex; align-items: center; gap: 1.5rem;
  min-height: 4.5rem; flex-wrap: wrap;
}
.wordmark {
  font-family: var(--display);
  font-weight: 800;
  font-size: 1.05rem;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: var(--ink);
  text-decoration: none;
  margin-right: auto;
}
.wordmark span { color: var(--vermilion); }

.nav { display: flex; gap: 1.25rem; flex-wrap: wrap; }
.nav a {
  color: var(--ink);
  text-decoration: none;
  font-size: 0.9375rem;
  padding-block: 0.25rem;
  border-bottom: 2px solid transparent;
}
.nav a:hover, .nav a[aria-current="page"] {
  border-bottom-color: var(--vermilion);
}

.lang {
  font-size: 0.875rem;
  font-weight: 600;
  text-decoration: none;
  color: var(--pitch);
  border: 1px solid var(--line);
  border-radius: 999px;
  padding: 0.3rem 0.9rem;
}
.lang:hover { border-color: var(--vermilion); }

/* ---- hero: the H-post is the signature ---- */
.hero {
  padding-block: clamp(3rem, 9vw, 6.5rem);
  display: grid;
  gap: clamp(2rem, 6vw, 4rem);
  grid-template-columns: 1fr;
  align-items: center;
}
@media (min-width: 62rem) {
  .hero { grid-template-columns: 1.35fr 1fr; }
}
.hero__eyebrow {
  font-family: var(--display);
  text-transform: uppercase;
  letter-spacing: 0.18em;
  font-size: 0.8125rem;
  font-weight: 700;
  color: var(--vermilion);
  margin: 0 0 1.25rem;
}
.hero__lede { font-size: 1.1875rem; color: #2c3d35; }

.posts { width: 100%; height: auto; display: block; }
.posts .bar { stroke: var(--pitch); stroke-width: 7; stroke-linecap: square; }
.posts .ball { fill: var(--vermilion); }
@media (prefers-reduced-motion: no-preference) {
  .posts .ball {
    animation: over 2.6s cubic-bezier(.3,.7,.4,1) 0.4s both;
  }
  @keyframes over {
    from { transform: translate(-120px, 150px) scale(.7); opacity: 0; }
    60%  { opacity: 1; }
    to   { transform: translate(0,0) scale(1); opacity: 1; }
  }
}

/* ---- call to action ---- */
.cta {
  display: inline-block;
  background: var(--pitch);
  color: var(--chalk);
  font-weight: 700;
  text-decoration: none;
  padding: 0.85rem 1.75rem;
  border-radius: 2px;
}
.cta:hover { background: var(--vermilion); color: var(--chalk); }

/* ---- panels ---- */
.panel { border-top: 1px solid var(--line); padding-block: clamp(2.5rem, 6vw, 4.5rem); }
.cards { display: grid; gap: 1.5rem; grid-template-columns: repeat(auto-fit, minmax(15rem, 1fr)); }
.card { border-left: 3px solid var(--pitch); padding-left: 1.25rem; }
.card h3 { margin-bottom: 0.25rem; }
.card p { font-size: 0.9375rem; color: #3a4b43; margin: 0; }

.foot {
  border-top: 1px solid var(--line);
  padding-block: 2.5rem;
  font-size: 0.875rem;
  color: var(--stone);
}
EOF

# --------------------------------------------------------------------- layout
cat > src/layouts/Base.astro <<'EOF'
---
import { SITE, PAGES } from "../consts.js";
import "../styles/global.css";

const { title, description, lang = "en", pageKey } = Astro.props;
const other = lang === "en" ? "ja" : "en";
const page  = PAGES.find((p) => p.key === pageKey);
const nav   = PAGES.filter((p) => p.key !== "home");
const here  = Astro.url.pathname;
---
<!doctype html>
<html lang={lang === "ja" ? "ja" : "en"}>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="canonical" href={new URL(here, SITE.url)} />

    {page && (
      <>
        <link rel="alternate" hreflang="en" href={new URL(page.en, SITE.url)} />
        <link rel="alternate" hreflang="ja" href={new URL(page.ja, SITE.url)} />
        <link rel="alternate" hreflang="x-default" href={new URL(page.en, SITE.url)} />
      </>
    )}

    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:type" content="website" />
    <meta property="og:url" content={new URL(here, SITE.url)} />
    <meta property="og:locale" content={lang === "ja" ? "ja_JP" : "en_IE"} />

    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link
      href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,600..800&family=Noto+Sans+JP:wght@400;500;700&display=swap"
      rel="stylesheet"
    />
  </head>

  <body>
    <header class="masthead">
      <div class="wrap masthead__inner">
        <a class="wordmark" href={lang === "ja" ? "/ja/" : "/"}>Japan <span>GAA</span></a>
        <nav class="nav" aria-label={lang === "ja" ? "メインナビゲーション" : "Main"}>
          {nav.map((p) => (
            <a
              href={p[lang]}
              aria-current={here.replace(/\/$/, "") === p[lang].replace(/\/$/, "") ? "page" : undefined}
            >{lang === "ja" ? p.labelJa : p.labelEn}</a>
          ))}
        </nav>
        {page && (
          <a class="lang" href={page[other]} lang={other} hreflang={other}>
            {other === "ja" ? "日本語" : "English"}
          </a>
        )}
      </div>
    </header>

    <main>
      <slot />
    </main>

    <footer class="foot">
      <div class="wrap">
        <p>Japan GAA — {lang === "ja" ? "東京を拠点とするゲーリックフットボールクラブ" : "Gaelic football in Tokyo"}</p>
      </div>
    </footer>
  </body>
</html>
EOF

# ------------------------------------------------------------ english home
cat > src/pages/index.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
---
<Base
  lang="en"
  pageKey="home"
  title="Japan GAA — Gaelic Football in Tokyo | ゲーリックフットボール"
  description="Japan GAA is a Gaelic football club in Tokyo. Beginners welcome, no experience needed, and your first session is free. Training in Shinagawa."
>
  <div class="wrap hero">
    <div>
      <p class="hero__eyebrow">Tokyo · 東京</p>
      <h1>Gaelic football in Tokyo.</h1>
      <p class="hero__lede">
        Ireland's national sport, played on a pitch in Shinagawa. Most of our
        players had never seen a Gaelic ball before they turned up. You don't
        need experience, you don't need kit, and the first session is free.
      </p>
      <p><a class="cta" href="/training">Come to training</a></p>
    </div>

    <!-- H-posts: the shape belongs to no other sport -->
    <svg class="posts" viewBox="0 0 320 260" role="img" aria-label="Gaelic football posts">
      <g class="bar" fill="none">
        <line x1="90"  y1="30" x2="90"  y2="240" />
        <line x1="230" y1="30" x2="230" y2="240" />
        <line x1="70"  y1="150" x2="250" y2="150" />
        <line x1="40"  y1="240" x2="280" y2="240" />
      </g>
      <circle class="ball" cx="160" cy="88" r="15" />
    </svg>
  </div>

  <section class="panel">
    <div class="wrap">
      <h2>Turning up</h2>
      <div class="cards">
        <div class="card">
          <h3>Anyone can play</h3>
          <p>Men's and ladies' football. Complete beginners are the normal case, not the exception.</p>
        </div>
        <div class="card">
          <h3>Two languages</h3>
          <p>Sessions run in Japanese and English. Bring whichever one you have.</p>
        </div>
        <div class="card">
          <h3>First one's free</h3>
          <p>Come along, try it, decide afterwards. No sign-up needed to visit.</p>
        </div>
      </div>
    </div>
  </section>
</Base>
EOF

# ----------------------------------------------------------- japanese home
cat > src/pages/ja/index.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
---
<Base
  lang="ja"
  pageKey="home"
  title="Japan GAA — 東京のゲーリックフットボールクラブ"
  description="Japan GAAは東京のゲーリックフットボールクラブです。初心者歓迎・経験不問、初回参加は無料。品川で練習しています。"
>
  <div class="wrap hero">
    <div>
      <p class="hero__eyebrow">Tokyo · 東京</p>
      <h1>東京で、ゲーリックフットボール。</h1>
      <p class="hero__lede">
        アイルランドの国技を、品川のグラウンドで。メンバーのほとんどが、
        参加するまでボールを見たこともありませんでした。経験も道具も必要
        ありません。初回は無料です。
      </p>
      <p><a class="cta" href="/ja/training">練習に参加する</a></p>
    </div>

    <svg class="posts" viewBox="0 0 320 260" role="img" aria-label="ゲーリックフットボールのゴールポスト">
      <g class="bar" fill="none">
        <line x1="90"  y1="30" x2="90"  y2="240" />
        <line x1="230" y1="30" x2="230" y2="240" />
        <line x1="70"  y1="150" x2="250" y2="150" />
        <line x1="40"  y1="240" x2="280" y2="240" />
      </g>
      <circle class="ball" cx="160" cy="88" r="15" />
    </svg>
  </div>

  <section class="panel">
    <div class="wrap">
      <h2>参加について</h2>
      <div class="cards">
        <div class="card">
          <h3>どなたでも</h3>
          <p>男子・女子の両方があります。初心者がほとんどです。</p>
        </div>
        <div class="card">
          <h3>日本語と英語</h3>
          <p>練習は日本語と英語の両方で行っています。</p>
        </div>
        <div class="card">
          <h3>初回無料</h3>
          <p>まず一度、見学・体験してから決めてください。事前登録は不要です。</p>
        </div>
      </div>
    </div>
  </section>
</Base>
EOF

# ------------------------------------------------------------- redirect map
cat > public/_redirects <<'EOF'
# Old Squarespace URLs -> new site.  Order matters: first match wins.
/home              /             301
/homejp            /ja/          301
/historyjp         /ja/history   301
/profiles          /committee    301
/eventlist         /training     301
/eventlist/*       /training     301
/newsletter        /news         301
/newsletter/*      /news/:splat  301
/about-us          /             301
/news-1            /news         301
/cover-page        /             301
EOF

echo
echo "Created:"
echo "  src/consts.js"
echo "  src/styles/global.css"
echo "  src/layouts/Base.astro"
echo "  src/pages/index.astro"
echo "  src/pages/ja/index.astro"
echo "  public/_redirects"
echo
echo "Next:  npm run dev   ->  http://localhost:4321"
