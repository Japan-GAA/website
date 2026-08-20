#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/Sessions.astro"); s = p.read_text()
old = '{s.location && <em class="sessions__where"> · {s.location}</em>}'
new = '{s.location && <em class="sessions__where">{s.location}</em>}'
if old in s:
    p.write_text(s.replace(old, new)); print("  ok   dropped the inline separator")
else:
    print("  --   already changed (or markup differs)")
PY

cat >> src/styles/global.css <<'EOF'

/* Session location on its own line beneath the date, readable on both
   the pale page and the green panel. */
.sessions__date { display: flex; flex-direction: column; gap: 0.1rem; }
.sessions__where { font-style: normal; font-size: 0.8125rem; color: #b8860b; }
.nextup .sessions__where { color: #f5c542; }
EOF

echo
npm run build 2>&1 | tail -4
