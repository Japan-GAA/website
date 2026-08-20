#!/usr/bin/env bash
# Fetch each sheet once per build instead of once per page.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

JOBS = [
  ("src/lib/events.ts",   "clubEvents",       "{ upcoming: Ev[]; past: Ev[] }"),
  ("src/lib/sessions.ts", "upcomingSessions", "Session[]"),
  ("src/lib/jerseys.ts",  "jerseyStock",      "Group[]"),
]

for path, fn, ret in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("!! missing", path); continue
    s = p.read_text()
    if f"__{fn}_cache" in s:
        print("  --  ", path, "already memoised"); continue

    # rename the real function, then wrap it
    s = s.replace(f"export async function {fn}(", f"async function {fn}Uncached(", 1)

    args = "limit = 4" if fn == "upcomingSessions" else ("limit = 4" if fn == "jerseyStock" else "")
    call = "limit" if args else ""
    wrapper = f'''
// Astro renders each page separately, so without this the sheet would be
// fetched once per page. Google rate-limits that and the extra calls come back
// empty, which is how one language ended up with data and the other without.
// One fetch per build, shared by every page.
let __{fn}_cache: Promise<{ret}> | null = null;
export function {fn}({args}): Promise<{ret}> {{
  if (!__{fn}_cache) __{fn}_cache = {fn}Uncached({call});
  return __{fn}_cache;
}}
'''
    s = s.rstrip() + "\n" + wrapper
    p.write_text(s); print("  ok  ", path)
PY

echo
npm run build 2>&1 | tail -6
echo
echo "Events in the built English page:"
grep -c "North Asian Gaelic Games" dist/events/index.html || true
echo "Events in the built Japanese page:"
grep -c "North Asian" dist/ja/events/index.html || true
