#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/components

cat > src/components/Cover.astro <<'EOF'
---
// Card image for a news post. Posts with no photo get the goalposts mark
// rather than a borrowed photo from some other event.
const { src, title = "" } = Astro.props;
---
{src ? (
  <img src={src} alt="" loading="lazy" />
) : (
  <span class="cover cover--none" role="img" aria-label={title}>
    <svg viewBox="0 0 160 120" aria-hidden="true" focusable="false">
      <g fill="none" stroke="currentColor" stroke-width="4" stroke-linecap="square">
        <line x1="52" y1="22" x2="52" y2="100" />
        <line x1="108" y1="22" x2="108" y2="100" />
        <line x1="44" y1="62" x2="116" y2="62" />
        <line x1="24" y1="100" x2="136" y2="100" />
      </g>
      <circle cx="80" cy="42" r="7" fill="currentColor" />
    </svg>
  </span>
)}
EOF

python3 - <<'PY'
import pathlib, re
JOBS = [("src/pages/news/index.astro", "../../components/Cover.astro"),
        ("src/pages/ja/news/index.astro", "../../../components/Cover.astro")]
for path, imp in JOBS:
    p = pathlib.Path(path)
    if not p.exists(): print("!! missing", path); continue
    s = p.read_text()
    if "Cover.astro" not in s:
        s = s.replace("---\nimport Base", f'---\nimport Cover from "{imp}";\nimport Base', 1)
    s2, n = re.subn(r'\{post\.data\.cover && <img src=\{post\.data\.cover\} alt="" loading="lazy" />\}',
                    '<Cover src={post.data.cover} title={post.data.title} />', s, count=1)
    if n == 0: print("!! cover line not found in", path); continue
    p.write_text(s2); print("  ok  ", path)

# homepage grid too
for path, imp in [("src/pages/index.astro", "../components/Cover.astro"),
                  ("src/pages/ja/index.astro", "../../components/Cover.astro")]:
    p = pathlib.Path(path)
    if not p.exists(): continue
    s = p.read_text()
    if "Cover.astro" not in s:
        s = s.replace("---\nimport", f'---\nimport Cover from "{imp}";\nimport', 1)
    s2, n = re.subn(r'\{post\.data\.cover && <img src=\{post\.data\.cover\} alt="" loading="lazy" />\}',
                    '<Cover src={post.data.cover} title={post.data.title} />', s, count=1)
    if n: p.write_text(s2); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- placeholder cover ---- */
.newsgrid a:not(:has(img))::before,
.postlist__item a:not(:has(img))::before { content: none; }

.cover--none {
  display: grid; place-items: center;
  aspect-ratio: 3 / 2; width: 100%;
  background: var(--pitch); color: var(--chalk);
  border-radius: 3px; margin-bottom: 0.75rem;
}
.cover--none svg { width: 45%; height: auto; opacity: 0.55; }
.postlist__item .cover--none { width: 7rem; height: 5rem; aspect-ratio: auto; margin: 0; }
EOF

echo
npm run build 2>&1 | tail -4
