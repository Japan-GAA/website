#!/usr/bin/env bash
# Rewrites the homepages and layout using the original Japan GAA copy.
# Run from the root of the website repo:  bash apply-content.sh
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/layouts src/pages/ja

cat > src/layouts/Base.astro <<'EOF'
---
import { SITE, PAGES } from "../consts.js";
import "../styles/global.css";

const { title, description, lang = "en", pageKey } = Astro.props;
const other = lang === "en" ? "ja" : "en";
const page  = PAGES.find((p) => p.key === pageKey);
const nav   = PAGES.filter((p) => p.key !== "home");
const here  = Astro.url.pathname;

const socials = [
  ["Instagram", "https://www.instagram.com/japangaa"],
  ["Facebook",  "https://www.facebook.com/gaajapan"],
];
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
    <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,600..800&family=Noto+Sans+JP:wght@400;500;700&display=swap" rel="stylesheet" />
  </head>
  <body>
    <header class="masthead">
      <div class="wrap masthead__inner">
        <a class="wordmark" href={lang === "ja" ? "/ja/" : "/"}>Japan <span>GAA</span></a>
        <nav class="nav" aria-label={lang === "ja" ? "メインナビゲーション" : "Main"}>
          {nav.map((p) => (
            <a href={p[lang]} aria-current={here.replace(/\/$/, "") === p[lang].replace(/\/$/, "") ? "page" : undefined}>
              {lang === "ja" ? p.labelJa : p.labelEn}
            </a>
          ))}
        </nav>
        {page && (
          <a class="lang" href={page[other]} lang={other} hreflang={other}>
            {other === "ja" ? "日本語" : "English"}
          </a>
        )}
      </div>
    </header>

    <main><slot /></main>

    <footer class="foot">
      <div class="wrap">
        <p class="foot__contact">
          Please contact <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> for your questions!<br />
          練習やイベント参加に関するご質問は <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> までお問い合わせください！
        </p>
        <p class="foot__social">
          {socials.map(([name, url]) => <a href={url} rel="me noopener">{name}</a>)}
        </p>
      </div>
    </footer>
  </body>
</html>
EOF

cat > src/pages/index.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
---
<Base
  lang="en"
  pageKey="home"
  title="Japan GAA — Gaelic Football in Tokyo | ゲーリックフットボール"
  description="The official website of the Japan Gaelic Athletic Association. Home to the Gaelic Games in Japan — training, tournaments and social events in Tokyo."
>
  <div class="wrap hero">
    <div>
      <p class="hero__eyebrow">Tokyo · 東京</p>
      <h1>Welcome <em>Céad míle fáilte</em></h1>
      <p class="hero__lede">
        Welcome to the official website of Japan GAA, home to the Gaelic Games
        in Japan. You can find all you need to know about the history of our
        club, as well as information on upcoming training sessions, tournaments,
        and social events.
      </p>
      <p><a class="cta" href="/training">Upcoming training →</a></p>
    </div>
    <svg class="posts" viewBox="0 0 320 260" role="img" aria-label="Gaelic football posts">
      <g class="bar" fill="none">
        <line x1="90" y1="30" x2="90" y2="240" />
        <line x1="230" y1="30" x2="230" y2="240" />
        <line x1="70" y1="150" x2="250" y2="150" />
        <line x1="40" y1="240" x2="280" y2="240" />
      </g>
      <circle class="ball" cx="160" cy="88" r="15" />
    </svg>
  </div>

  <section class="panel">
    <div class="wrap cards">
      <div class="card">
        <h3>Our history</h3>
        <p>Find out more about our history.</p>
        <p><a href="/history">Learn more →</a></p>
      </div>
      <div class="card">
        <h3>Upcoming events</h3>
        <p>Training sessions, tournaments and social events.</p>
        <p><a href="/training">Learn more →</a></p>
      </div>
      <div class="card">
        <h3>Who we are</h3>
        <p>The committee and the players.</p>
        <p><a href="/committee">Meet the team →</a></p>
      </div>
    </div>
  </section>

  <section class="panel">
    <div class="wrap">
      <h2>Latest news</h2>
      <p>Take a look at our newsletter for all that's happening at the club.</p>
      <p><a href="/news">Read the newsletter →</a></p>
    </div>
  </section>

  <section class="panel">
    <div class="wrap">
      <h2>Membership</h2>
      <p>
        Interested? Join a community that is passionate, determined, and
        supportive. Whether you're here for a day or committed to years, feel
        free to join us here at Japan GAA.
      </p>
      <!-- TODO: fees and payment method from the LINE note -->
      <p><a class="cta" href="mailto:japangaa@gmail.com">Contact us</a></p>
    </div>
  </section>
</Base>
EOF

cat > src/pages/ja/index.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
---
<Base
  lang="ja"
  pageKey="home"
  title="Japan GAA 日本ゲーリック協会 — 東京のゲーリックフットボールクラブ"
  description="日本ゲーリック協会の公式サイトです。東京を拠点に、練習・大会・イベントを行っています。未経験者も大歓迎です。"
>
  <div class="wrap hero">
    <div>
      <p class="hero__eyebrow">Tokyo · 東京</p>
      <h1>ようこそ！ <em>Céad míle fáilte</em></h1>
      <p class="hero__lede">
        日本ゲーリック協会（Japan GAA）のホームページへようこそ！
        こちらのサイトでは、Japan GAAに纏わる歴史や、今後の活動などを
        まとめております。
      </p>
      <p><a class="cta" href="/ja/training">今後の練習 →</a></p>
    </div>
    <svg class="posts" viewBox="0 0 320 260" role="img" aria-label="ゲーリックフットボールのゴールポスト">
      <g class="bar" fill="none">
        <line x1="90" y1="30" x2="90" y2="240" />
        <line x1="230" y1="30" x2="230" y2="240" />
        <line x1="70" y1="150" x2="250" y2="150" />
        <line x1="40" y1="240" x2="280" y2="240" />
      </g>
      <circle class="ball" cx="160" cy="88" r="15" />
    </svg>
  </div>

  <section class="panel">
    <div class="wrap cards">
      <div class="card">
        <h3>Japan GAAの歴史</h3>
        <p>クラブのこれまでの歩みをご紹介します。</p>
        <p><a href="/ja/history">詳細こちら →</a></p>
      </div>
      <div class="card">
        <h3>今後の予定・活動</h3>
        <p>練習、大会、イベントの予定です。</p>
        <p><a href="/ja/training">詳細こちら →</a></p>
      </div>
      <div class="card">
        <h3>Japan GAAとは</h3>
        <p>運営メンバーと選手をご紹介します。</p>
        <p><a href="/ja/committee">メンバー紹介 →</a></p>
      </div>
    </div>
  </section>

  <section class="panel">
    <div class="wrap">
      <h2>最新ニュース</h2>
      <p>Japan GAAの活動内容をご覧ください。</p>
      <p><a href="/ja/news">ニュースレターを読む →</a></p>
    </div>
  </section>

  <section class="panel">
    <div class="wrap">
      <h2>年会費</h2>
      <p>
        Japan GAAは和気あいあいと仲の良いコミュニティーです。未経験でも大歓迎
        ですので、ご興味のある方は体験練習にお気軽にご参加ください。
      </p>
      <!-- TODO: 参加費・支払い方法（LINEのメモより） -->
      <p><a class="cta" href="mailto:japangaa@gmail.com">お問い合わせ</a></p>
    </div>
  </section>
</Base>
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- footer additions ---- */
.foot__contact { max-width: none; color: var(--stone); }
.foot__contact a { color: var(--pitch); }
.foot__social { display: flex; gap: 1.25rem; margin-top: 1rem; }
.hero h1 em { font-style: italic; font-weight: 600; color: var(--pitch); display: block; font-size: 0.5em; margin-top: 0.25em; }
.card p + p { margin-top: 0.5rem; }
.card p a { font-weight: 600; text-decoration: none; }
.card p a:hover { text-decoration: underline; }
EOF

echo "Rewrote: Base.astro, index.astro, ja/index.astro, appended to global.css"
