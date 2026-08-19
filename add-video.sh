#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/components

cat > src/components/Video.astro <<'EOF'
---
// Click-to-load YouTube embed.
// Shows a thumbnail until the visitor clicks, so the page doesn't pull ~1MB of
// YouTube player code (and set cookies) for people who never press play.
// Uses youtube-nocookie.com, which doesn't track visitors who don't watch.
const { id, title = "Video", caption } = Astro.props;
const thumb = `https://i.ytimg.com/vi/${id}/maxresdefault.jpg`;
---
<figure class="video">
  <button class="video__frame" data-yt={id} aria-label={`Play: ${title}`}>
    <img src={thumb} alt="" loading="lazy" width="1280" height="720" />
    <span class="video__play" aria-hidden="true">
      <svg viewBox="0 0 68 48" width="68" height="48">
        <path d="M66.5 7.7a8.6 8.6 0 0 0-6-6C55 0 34 0 34 0S13 0 7.5 1.6a8.6 8.6 0 0 0-6 6A90 90 0 0 0 0 24a90 90 0 0 0 1.5 16.3 8.6 8.6 0 0 0 6 6C13 48 34 48 34 48s21 0 26.5-1.7a8.6 8.6 0 0 0 6-6A90 90 0 0 0 68 24a90 90 0 0 0-1.5-16.3z" fill="var(--vermilion)"/>
        <path d="M27 34l18-10-18-10z" fill="#fff"/>
      </svg>
    </span>
  </button>
  {caption && <figcaption>{caption}</figcaption>}
</figure>

<script>
  document.querySelectorAll(".video__frame").forEach((btn) => {
    btn.addEventListener("click", () => {
      const id = btn.getAttribute("data-yt");
      const f = document.createElement("iframe");
      f.src = `https://www.youtube-nocookie.com/embed/${id}?autoplay=1&rel=0`;
      f.title = btn.getAttribute("aria-label") ?? "Video";
      f.allow = "accelerometer; autoplay; clipboard-write; encrypted-media; picture-in-picture";
      f.allowFullscreen = true;
      f.loading = "lazy";
      btn.replaceWith(f);
    });
  });
</script>
EOF

python3 - <<'PY'
import pathlib, re, sys
JOBS = [
  ("src/pages/gaelic-football.astro", "../components/Video.astro",
   'title="Gaelic football explained"',
   'caption="Gaelic football in about a minute."'),
  ("src/pages/ja/gaelic-football.astro", "../../components/Video.astro",
   'title="ゲーリックフットボールとは"',
   'caption="ゲーリックフットボールの動きを1分ほどで。"'),
]
for path, imp, title, cap in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()
    if "Video.astro" not in s:
        s = re.sub(r"(---\nimport Base)", f'---\nimport Video from "{imp}";\nimport Base', s, count=1)
    # insert immediately after the closing </header> of the page head
    s2, n = re.subn(r"</header>",
        f'</header>\n\n    <Video id="vSOe-USZzok" {title} {cap} />',
        s, count=1)
    if n == 0:
        print("!! no </header> in", path); continue
    p.write_text(s2); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- video ---- */
.video { margin: 0 0 2.5rem; }
.video__frame {
  display: block; position: relative; width: 100%; padding: 0; border: 0;
  background: var(--ink); cursor: pointer; border-radius: 3px; overflow: hidden;
  aspect-ratio: 16 / 9;
}
.video__frame img { width: 100%; height: 100%; object-fit: cover; display: block; }
.video__frame:hover img { opacity: 0.85; }
.video__play {
  position: absolute; inset: 0; display: grid; place-items: center;
}
.video__play svg { filter: drop-shadow(0 2px 8px rgba(0,0,0,.35)); }
.video iframe { width: 100%; aspect-ratio: 16 / 9; border: 0; border-radius: 3px; display: block; }
.video figcaption { font-size: 0.875rem; color: var(--stone); margin-top: 0.6rem; }
EOF

echo "Video added to both sport pages"
