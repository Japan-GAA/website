#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

news = pathlib.Path("public/news")
posts = sorted(pathlib.Path("src/content/news").glob("*.md"))

# 1. rename any file whose name contains brackets — they break markdown links
mapping = {}
for f in sorted(news.iterdir()):
    if "(" in f.name or ")" in f.name:
        new = f.name.replace("(", "-").replace(")", "")
        f.rename(news / new)
        mapping[f.name] = new
print(f"renamed {len(mapping)} file(s) with brackets")

# 2. update every reference in the markdown
touched = 0
for p in posts:
    s = orig = p.read_text()
    for old, new in mapping.items():
        s = s.replace(old, new)
    # repair covers truncated at the first bracket
    m = re.search(r'^cover:\s*"(/news/[^"]*)"', s, re.M)
    if m and not m.group(1).endswith(".webp"):
        stem = m.group(1).split("/")[-1].replace("(", "-").replace(")", "")
        hit = [f.name for f in news.iterdir() if f.name.startswith(stem)]
        if hit:
            s = s.replace(m.group(0), f'cover: "/news/{hit[0]}"')
        else:
            s = re.sub(r'^cover:.*\n', "", s, count=1, flags=re.M)
            print(f"  no match for {p.name} — cover removed")
    if s != orig:
        p.write_text(s); touched += 1
print(f"updated {touched} post(s)")

# 3. report anything still broken
bad = 0
for p in posts:
    for ref in re.findall(r'\((/news/[^)]*)\)', p.read_text()):
        if not (pathlib.Path("public") / ref.lstrip("/")).exists():
            print("  still missing:", p.name, ref); bad += 1
print("all image references resolve" if not bad else f"{bad} broken reference(s)")
PY

cat >> src/styles/global.css <<'EOF'

/* Posts with no image keep the card the same height as the rest. */
.newsgrid a:not(:has(img))::before,
.postlist__item a:not(:has(img))::before {
  content: ""; display: block; background: var(--pitch); opacity: 0.12; border-radius: 3px;
}
.newsgrid a:not(:has(img))::before { aspect-ratio: 3 / 2; margin-bottom: 0.75rem; }
.postlist__item a:not(:has(img))::before { width: 7rem; height: 5rem; }
EOF

echo
npm run build 2>&1 | tail -4
