#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/pages/ja

cat > src/committee.js <<'EOF'
// Committee roles. First names only by default — full names are opt-in,
// and anyone who leaves the committee comes off this list.
// Emails are role-based, so they survive a handover. Set `email` once the
// Cloudflare Email Routing addresses are live.
export const COMMITTEE = [
  { roleEn: "Chairperson",            roleJa: "会長",           people: ["Ciaran"] },
  { roleEn: "Vice-chair",             roleJa: "副会長",         people: ["Rintarou"] },
  { roleEn: "Secretary",              roleJa: "書記",           people: ["Andrew"] },
  { roleEn: "Treasurer",              roleJa: "会計",           people: ["Maya"] },
  { roleEn: "Social media",           roleJa: "広報・SNS",      people: ["Fumika", "Amanda"] },
  { roleEn: "Development and events", roleJa: "普及・イベント", people: ["Haruka", "Shinnosuke"] },
];
EOF

cat > src/pages/committee.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
import Video from "../components/Video.astro";
import { COMMITTEE } from "../committee.js";
---
<Base lang="en" pageKey="club"
  title="The Club — Japan GAA | Committee and Squads"
  description="Meet the people behind Japan GAA — the committee, and the squads that travelled to the Asian Gaelic Games in Bangkok in 2025.">

  <div class="wrap prose">
    <header class="pagehead">
      <h1>The club</h1>
      <p class="hero__lede">
        Japan GAA is run entirely by volunteers. These are the people who
        organise the training, the tournaments and everything in between.
      </p>
    </header>

    <h2>Committee</h2>
    <ul class="roster">
      {COMMITTEE.map((r) => (
        <li>
          <span class="roster__role">{r.roleEn}</span>
          <span class="roster__name">{r.people.join(" · ")}</span>
        </li>
      ))}
    </ul>
    <p class="muted">
      For anything at all, <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a>
      reaches the committee.
    </p>

    <h2>The squads</h2>
    <p>
      The teams that travelled to the Asian Gaelic Games in Bangkok in 2025.
      Player profiles are on the way.
    </p>
    <Video id="3TIFTrn7vYs" title="Japan GAA at the Asian Gaelic Games 2025" caption="Japan GAA at the Asian Gaelic Games, Bangkok 2025." />

    <p><a class="cta" href="/training">Come to training →</a></p>
  </div>
</Base>
EOF

cat > src/pages/ja/committee.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
import Video from "../../components/Video.astro";
import { COMMITTEE } from "../../committee.js";
---
<Base lang="ja" pageKey="club"
  title="クラブについて — Japan GAA 日本ゲーリック協会"
  description="Japan GAAを運営するメンバーと、2025年バンコクのアジア・ゲーリック大会に出場したチームをご紹介します。">

  <div class="wrap prose">
    <header class="pagehead">
      <h1>クラブについて</h1>
      <p class="hero__lede">
        Japan GAAはすべてボランティアによって運営されています。
        練習や大会の運営を担っているメンバーをご紹介します。
      </p>
    </header>

    <h2>運営メンバー</h2>
    <ul class="roster">
      {COMMITTEE.map((r) => (
        <li>
          <span class="roster__role">{r.roleJa}</span>
          <span class="roster__name">{r.people.join(" ・ ")}</span>
        </li>
      ))}
    </ul>
    <p class="muted">
      ご質問は <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> まで、
      お気軽にお問い合わせください。
    </p>

    <h2>チーム</h2>
    <p>
      2025年、バンコクで開催されたアジア・ゲーリック大会に出場したチームです。
      選手紹介は準備中です。
    </p>
    <Video id="3TIFTrn7vYs" title="アジア・ゲーリック大会2025" caption="2025年 アジア・ゲーリック大会（バンコク）" />

    <p><a class="cta" href="/ja/training">練習に参加する →</a></p>
  </div>
</Base>
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- committee roster ---- */
.roster { list-style: none; padding: 0; margin: 1.5rem 0; max-width: var(--measure); }
.roster li {
  display: flex; justify-content: space-between; gap: 1.5rem; flex-wrap: wrap;
  padding: 0.85rem 0; border-bottom: 1px solid var(--line);
}
.roster li:first-child { border-top: 1px solid var(--line); }
.roster__role {
  font-size: 0.8125rem; text-transform: uppercase; letter-spacing: 0.1em;
  color: var(--stone); align-self: center;
}
.roster__name {
  font-family: var(--display); font-weight: 700; font-size: 1.125rem; color: var(--pitch);
}
EOF

echo "Added /committee and /ja/committee"
