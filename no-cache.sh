#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib

FIX = {
  "src/lib/sessions.ts": ("SESSIONS_CSV", "[sessions]"),
  "src/lib/jerseys.ts":  ("SHEET_CSV",    "[jerseys]"),
}

for path, (const, tag) in FIX.items():
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()
    if "cache: \"no-store\"" in s:
        print("  --  ", path, "already fetching fresh"); continue

    old = f"const res = await fetch({const});"
    new = (f"// Google's CDN caches published sheets for a few minutes and serves\n"
           f"    // different versions from different edges, so make every request unique.\n"
           f"    const url = {const} + (({const}.includes(\"?\") ? \"&\" : \"?\") + \"_=\" + Date.now());\n"
           f"    const res = await fetch(url, {{ cache: \"no-store\" }});")
    if old not in s:
        print("!! fetch line not found in", path); continue
    p.write_text(s.replace(old, new)); print("  ok  ", path)
PY

echo
npm run build 2>&1 | tail -4
