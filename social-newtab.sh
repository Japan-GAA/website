#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/components/Social.astro")
s = p.read_text()
if 'target="_blank"' in s:
    print("  --   already set")
else:
    s2, n = re.subn(r'(<a href=\{l\.url\})', r'\1 target="_blank"', s, count=1)
    if n == 0:
        print("!!   couldn't find the link tag. Current:")
        m = re.search(r"<a href=.*?>", s)
        print("   ", m.group(0) if m else "(not found)")
    else:
        p.write_text(s2); print("  ok   Social.astro")
PY

echo
echo "Any other dynamic hrefs that may need checking:"
grep -rn 'href={' src/pages src/components | grep -v 'target=' | grep -viE 'mailto|urlFor|/ja|page\[|"/' || echo "  none"
echo
npm run build 2>&1 | tail -4
