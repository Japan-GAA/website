#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

files = list(pathlib.Path("src").rglob("*.astro"))
changed = 0

for p in files:
    s = orig = p.read_text()

    # external links only: http(s), not mailto, not already targeted
    def fix(m):
        tag = m.group(0)
        if "target=" in tag or "mailto:" in tag:
            return tag
        return tag[:-1].rstrip() + ' target="_blank" rel="noopener">' if tag.endswith(">") else tag

    # add target + rel to <a href="http...">
    s = re.sub(r'<a\s+[^>]*href="https?://[^"]+"[^>]*>',
               lambda m: m.group(0) if "target=" in m.group(0)
                         else re.sub(r'\s*rel="[^"]*"', "", m.group(0))[:-1] + ' target="_blank" rel="noopener">',
               s)

    if s != orig:
        p.write_text(s); changed += 1
        print("  ok  ", p)

print(f"\n{changed} file(s) changed")
PY

# tell screen readers the social links leave the site
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/Social.astro"); s = p.read_text()
if "opens in a new tab" not in s:
    s = s.replace('aria-label={l.name}', 'aria-label={`${l.name} (opens in a new tab)`}')
    p.write_text(s); print("  ok   Social.astro aria-labels")
else:
    print("  --   Social.astro already done")
PY

echo
echo "External links now opening in a new tab:"
grep -rn 'target="_blank"' src/pages src/components | sed 's/:.*href="/  → /' | sed 's/".*//' | sort -u
echo
npm run build 2>&1 | tail -4
