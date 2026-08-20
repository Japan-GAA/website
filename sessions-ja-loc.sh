#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/lib/sessions.ts"); s = p.read_text()

s = s.replace("  start: string; end: string; location: string;",
              "  start: string; end: string; location: string; locationJa: string;")

s = s.replace('    const iD = find("date"), iS = find("start"), iF = find("finish", "end"), iL = find("location");',
'''    const iD = find("date"), iS = find("start"), iF = find("finish", "end"), iL = find("location");

    // The Japanese location sits in the next column; its header may be blank,
    // a duplicate, or mention Japanese.
    const next = iL >= 0 ? head[iL + 1] : undefined;
    const iLJa = next !== undefined && (next === "" || next === head[iL] || /japan|日本/.test(next))
      ? iL + 1 : -1;''')

s = s.replace('        location: iL >= 0 ? (r[iL] ?? "").trim() : "",',
'''        location: iL >= 0 ? (r[iL] ?? "").trim() : "",
        locationJa: (iLJa >= 0 ? (r[iLJa] ?? "").trim() : "")
                    || (iL >= 0 ? (r[iL] ?? "").trim() : ""),''')

p.write_text(s); print("  ok   sessions.ts")
PY

python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/Sessions.astro"); s = p.read_text()
old = '{s.location && <em class="sessions__where">{s.location}</em>}'
new = '{(ja ? s.locationJa : s.location) && <em class="sessions__where">{ja ? s.locationJa : s.location}</em>}'
if old in s:
    p.write_text(s.replace(old, new)); print("  ok   Sessions.astro")
else:
    print("!!   location line not found — current markup:")
    import re
    m = re.search(r'sessions__where.*', s)
    print("   ", m.group(0) if m else "(not found)")
PY

echo
npm run build 2>&1 | tail -4
