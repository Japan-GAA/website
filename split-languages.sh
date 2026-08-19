#!/usr/bin/env bash
# Splits news posts by language. Archive posts stay bilingual and show in both.
# Run from ~/website after add-news.sh
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/content/news/ja src/pages/news src/pages/ja/news src/lib

cat > src/lib/news.ts <<'EOF'
import { getCollection } from "astro:content";

// Language is decided by where the file lives, not by frontmatter:
//   src/content/news/foo.md      -> English  (or bilingual, if archived)
//   src/content/news/ja/foo.md   -> Japanese
// A Japanese post is paired with its English one simply by sharing a filename.

export const slugOf = (id: string) => id.replace(/^ja\//, "");
export const isJa   = (id: string) => id.startsWith("ja/");

const byDate = (a: any, b: any) => b.data.date.valueOf() - a.data.date.valueOf();

export async function newsFor(lang: "en" | "ja") {
  const all = await getCollection("news");
  return all
    .filter((p) => {
      if (lang === "ja") return isJa(p.id) || p.data.archived;
      return !isJa(p.id);            // English posts + bilingual archive
    })
    .sort(byDate);
}

// URL a post should live at
export const urlFor = (id: string) =>
  isJa(id) ? `/ja/news/${slugOf(id)}` : `/news/${id}`;

// Does a counterpart exist in the other language?
export async function counterpart(id: string) {
  const all = await getCollection("news");
  const slug = slugOf(id);
  const want = isJa(id) ? slug : `ja/${slug}`;
  return all.find((p) => p.id === want) ?? null;
}
EOF

cat > src/pages/news/index.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
import { newsFor, urlFor } from "../../lib/news";
const posts = await newsFor("en");
const fmt = (d: Date) => d.toLocaleDateString("en-IE", { year: "numeric", month: "long" });
---
<Base lang="en" pageKey="news" title="News — Japan GAA"
  description="Reports, results and club news from Japan GAA, plus the full newsletter archive from 2019 onwards.">
  <div class="wrap">
    <header class="pagehead">
      <h1>News</h1>
      <p>Everything happening at the club, and the full newsletter archive back to 2019.</p>
    </header>
    <ul class="postlist">
      {posts.map((post) => (
        <li class="postlist__item">
          <a href={urlFor(post.id)}>
            {post.data.cover && <img src={post.data.cover} alt="" loading="lazy" width="400" height="260" />}
            <div>
              <time datetime={post.data.date.toISOString()}>{fmt(post.data.date)}</time>
              <h2>{post.data.title}</h2>
            </div>
          </a>
        </li>
      ))}
    </ul>
  </div>
</Base>
EOF

cat > src/pages/ja/news/index.astro <<'EOF'
---
import Base from "../../../layouts/Base.astro";
import { newsFor, urlFor } from "../../../lib/news";
const posts = await newsFor("ja");
const fmt = (d: Date) => d.toLocaleDateString("ja-JP", { year: "numeric", month: "long" });
---
<Base lang="ja" pageKey="news" title="ニュース — Japan GAA"
  description="Japan GAAの活動報告・大会結果と、2019年からのニュースレターのアーカイブです。">
  <div class="wrap">
    <header class="pagehead">
      <h1>ニュース</h1>
      <p>クラブの活動内容と、2019年からのニュースレターのアーカイブです。</p>
    </header>
    <ul class="postlist">
      {posts.map((post) => (
        <li class="postlist__item">
          <a href={urlFor(post.id)}>
            {post.data.cover && <img src={post.data.cover} alt="" loading="lazy" width="400" height="260" />}
            <div>
              <time datetime={post.data.date.toISOString()}>{fmt(post.data.date)}</time>
              <h2>{post.data.title}</h2>
            </div>
          </a>
        </li>
      ))}
    </ul>
  </div>
</Base>
EOF

cat > src/pages/news/\[...slug\].astro <<'EOF'
---
import { getCollection, render } from "astro:content";
import Base from "../../layouts/Base.astro";
import { isJa, slugOf, counterpart } from "../../lib/news";

export async function getStaticPaths() {
  const posts = await getCollection("news");
  return posts.filter((p) => !isJa(p.id))
    .map((post) => ({ params: { slug: post.id }, props: { post } }));
}

const { post } = Astro.props;
const { Content } = await render(post);
const other = await counterpart(post.id);
const fmt = post.data.date.toLocaleDateString("en-IE", { year: "numeric", month: "long", day: "numeric" });
---
<Base title={`${post.data.title} — Japan GAA`}
      description={`${post.data.title} — Japan GAA, Gaelic football in Tokyo.`}>
  <article class="wrap prose">
    <header class="pagehead">
      <time datetime={post.data.date.toISOString()}>{fmt}</time>
      <h1>{post.data.title}</h1>
      {other && <p><a class="lang" href={`/ja/news/${slugOf(post.id)}`} lang="ja" hreflang="ja">日本語</a></p>}
    </header>
    <Content />
    <p class="prose__back"><a href="/news">← All news</a></p>
  </article>
</Base>
EOF

cat > src/pages/ja/news/\[...slug\].astro <<'EOF'
---
import { getCollection, render } from "astro:content";
import Base from "../../../layouts/Base.astro";
import { isJa, slugOf, counterpart } from "../../../lib/news";

export async function getStaticPaths() {
  const posts = await getCollection("news");
  return posts.filter((p) => isJa(p.id))
    .map((post) => ({ params: { slug: slugOf(post.id) }, props: { post } }));
}

const { post } = Astro.props;
const { Content } = await render(post);
const other = await counterpart(post.id);
const fmt = post.data.date.toLocaleDateString("ja-JP", { year: "numeric", month: "long", day: "numeric" });
---
<Base lang="ja" title={`${post.data.title} — Japan GAA`}
      description={`${post.data.title} — Japan GAA 日本ゲーリック協会`}>
  <article class="wrap prose">
    <header class="pagehead">
      <time datetime={post.data.date.toISOString()}>{fmt}</time>
      <h1>{post.data.title}</h1>
      {other && <p><a class="lang" href={`/news/${slugOf(post.id)}`} lang="en" hreflang="en">English</a></p>}
    </header>
    <Content />
    <p class="prose__back"><a href="/ja/news">← ニュース一覧</a></p>
  </article>
</Base>
EOF

echo "Done. Run: npm run dev  ->  /news and /ja/news"
