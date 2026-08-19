#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
for path in ("src/pages/gaelic-football.astro", "src/pages/ja/gaelic-football.astro"):
    p = pathlib.Path(path)
    if not p.exists(): print("skip", path); continue
    s = p.read_text()

    # lift the strip out of wherever it is
    lines = s.splitlines(keepends=True)
    strip = [l for l in lines if "<Collage" in l]
    if not strip:
        print("!! no <Collage> found in", path); continue
    s = "".join(l for l in lines if "<Collage" not in l)

    # drop it in immediately before the page header
    s2, n = re.subn(r'(\s*)<header class="pagehead">',
                    lambda m: f'{m.group(1)}{strip[0].strip()}\n{m.group(1)}<header class="pagehead">',
                    s, count=1)
    if n == 0:
        print("!! no <header class=\"pagehead\"> in", path); continue
    p.write_text(s2); print("  ok  ", path)
PY

cat >> src/styles/global.css <<'EOF'

/* strip sitting at the very top of a page needs no space above it */
.prose > .collage--strip:first-child { margin-top: 0; margin-bottom: 0; }
EOF

echo "Run: npm run dev"
