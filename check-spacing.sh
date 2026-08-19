#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

p = pathlib.Path("src/pages/committee.astro"); s = p.read_text()
old = re.compile(r'<p class="muted">\s*For anything at all.*?</p>', re.S)
new = ('<p class="muted">For anything at all, '
       '<a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> reaches the committee.</p>')
s2, n = old.subn(new, s, count=1)
print("  ok   committee.astro" if n else "  !!   English line not found")
if n: p.write_text(s2)

p = pathlib.Path("src/pages/ja/committee.astro"); s = p.read_text()
old = re.compile(r'<p class="muted">\s*ご質問は.*?</p>', re.S)
new = ('<p class="muted">ご質問は '
       '<a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> まで、'
       'お気軽にお問い合わせください。</p>')
s2, n = old.subn(new, s, count=1)
print("  ok   ja/committee.astro" if n else "  !!   Japanese line not found")
if n: p.write_text(s2)
PY

echo
echo "Checking for the same pattern elsewhere:"
grep -rn "</a>[A-Za-z]" src/pages src/components 2>/dev/null || echo "  none found"
echo
npm run build 2>&1 | tail -5
