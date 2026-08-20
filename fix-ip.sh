#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/lib/events.ts"); s = p.read_text()

if re.search(r'\biP\s*=', s):
    print("  --   iP already declared")
else:
    # add iP to whichever line declares the other column indexes
    m = re.search(r'^(\s*)const iL = find\("location"\)(.*)$', s, re.M)
    if not m:
        print("!!   couldn't find the column-index line. Showing it:")
        for line in s.splitlines():
            if "find(" in line and "const i" in line:
                print("   ", line.strip())
    else:
        line = m.group(0)
        new = line.rstrip(";") + ', iP = find("photo", "image");'
        # avoid a double semicolon if the original already ended with one
        new = new.replace(";,", ",")
        s = s.replace(line, new)
        p.write_text(s)
        print("  ok   added:", new.strip())
PY

echo
echo "The declaration line now reads:"
grep -n 'const iL = find' src/lib/events.ts
echo
npm run build 2>&1 | tail -4
echo
echo "Events in the built page:"
grep -c "North Asian Gaelic Games" dist/events/index.html || true
