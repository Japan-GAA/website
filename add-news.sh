#!/usr/bin/env bash
# Adds the news collection config and page templates.
# Run from ~/website AFTER convert-newsletter.py
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
[ -d src/content/news ] || { echo "src/content/news missing — run convert-newsletter.py first"; exit 1; }
mkdir -p src/pages/news src/pages/ja/news

cat > src/content.config.ts <<'EOF'
import { defineCollection, z } from "astro:content";
import { glob } from "astro/loaders";

const news = defineCollection({
  loader: glob({ pattern: "**/*.md", base: "./src/content/news" }),
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    cover: z.string().optional(),
    // true for the imported Squarespace newsletters, false/absent for new posts
    archived: z.boolean().default(false),
  }),
});

export const collections = { news };
EOF

cat > src/pages/news/index.astro <<'EOF'
---
import { getCollection } from "astro:content";
import Base from "../../layouts/Base.astro";

const posts = (await getCollection("news")).sort(
  (a, b) => b.data.date.valueOf() - a.data.date.valueOf()
);
const fmt = (d: Date) =>
  d.toLocaleDateString("en-IE", { year: "numeric", month: "long" });
---
<Base
  lang="en"
  pageKey="news"
  title="News — Japan GAA"
  description="Reports, results and club news from Japan GAA, plus the full newsletter archive from 2019 onwards."
>
  <div class="wrap">
    <header class="pagehead">
      <h1>News</h1>
      <p>Everything happening at the club, and the full newsletter archive back to 2019.</p>
    </header>

    <ul class="postlist">
      {posts.map((post) => (
        <li class="postlist__item">
          <a href={`/news/${post.id}`}>
            {post.data.cover && (
              <img src={post.data.cover} alt="" loading="lazy" width="400" height="260" />
            )}
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

export async function getStaticPaths() {
  const posts = await getCollection("news");
  return posts.map((post) => ({ params: { slug: post.id }, props: { post } }));
}

const { post } = Astro.props;
const { Content } = await render(post);
const fmt = post.data.date.toLocaleDateString("en-IE", {
  year: "numeric", month: "long", day: "numeric",
});
---
<Base
  title={`${post.data.title} — Japan GAA`}
  description={`${post.data.title} — Japan GAA, Gaelic football in Tokyo.`}
>
  <article class="wrap prose">
    <header class="pagehead">
      <time datetime={post.data.date.toISOString()}>{fmt}</time>
      <h1>{post.data.title}</h1>
    </header>
    <Content />
    <p class="prose__back"><a href="/news">← All news</a></p>
  </article>
</Base>
EOF

cat > src/pages/ja/news/index.astro <<'EOF'
---
import { getCollection } from "astro:content";
import Base from "../../../layouts/Base.astro";

const posts = (await getCollection("news")).sort(
  (a, b) => b.data.date.valueOf() - a.data.date.valueOf()
);
const fmt = (d: Date) =>
  d.toLocaleDateString("ja-JP", { year: "numeric", month: "long" });
---
<Base
  lang="ja"
  pageKey="news"
  title="ニュース — Japan GAA"
  description="Japan GAAの活動報告・大会結果と、2019年からのニュースレターのアーカイブです。"
>
  <div class="wrap">
    <header class="pagehead">
      <h1>ニュース</h1>
      <p>クラブの活動内容と、2019年からのニュースレターのアーカイブです。記事は日英併記です。</p>
    </header>

    <ul class="postlist">
      {posts.map((post) => (
        <li class="postlist__item">
          <a href={`/news/${post.id}`}>
            {post.data.cover && (
              <img src={post.data.cover} alt="" loading="lazy" width="400" height="260" />
            )}
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

cat >> src/styles/global.css <<'EOF'

/* ---- news ---- */
.pagehead { padding-block: clamp(2.5rem, 6vw, 4rem) 1.5rem; }
.pagehead time {
  display: block;
  font-family: var(--display);
  text-transform: uppercase;
  letter-spacing: 0.14em;
  font-size: 0.8125rem;
  font-weight: 700;
  color: var(--vermilion);
  margin-bottom: 0.75rem;
}

.postlist { list-style: none; margin: 0 0 4rem; padding: 0; }
.postlist__item { border-top: 1px solid var(--line); }
.postlist__item:last-child { border-bottom: 1px solid var(--line); }
.postlist__item a {
  display: grid;
  grid-template-columns: 7rem 1fr;
  gap: 1.5rem;
  align-items: center;
  padding-block: 1.25rem;
  text-decoration: none;
  color: inherit;
}
.postlist__item img {
  width: 7rem; height: 5rem; object-fit: cover; display: block; border-radius: 2px;
}
.postlist__item time {
  font-size: 0.8125rem; color: var(--stone); letter-spacing: 0.04em;
}
.postlist__item h2 {
  font-size: 1.0625rem; line-height: 1.4; margin: 0.15rem 0 0; letter-spacing: 0;
}
.postlist__item a:hover h2 { color: var(--vermilion); }
@media (max-width: 34rem) {
  .postlist__item a { grid-template-columns: 4.5rem 1fr; gap: 1rem; }
  .postlist__item img { width: 4.5rem; height: 3.5rem; }
}

.prose { max-width: 42rem; padding-bottom: 5rem; }
.prose h2 { font-size: 1.375rem; margin-top: 2.5rem; }
.prose h3 { font-size: 1.125rem; margin-top: 2rem; }
.prose p { max-width: none; }
.prose img {
  width: 100%; height: auto; display: block; margin-block: 2rem; border-radius: 2px;
}
.prose__back { margin-top: 3rem; padding-top: 1.5rem; border-top: 1px solid var(--line); }
EOF

echo "Added: content.config.ts, /news, /news/[slug], /ja/news"
