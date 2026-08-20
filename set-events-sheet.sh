#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

URL="https://docs.google.com/spreadsheets/d/e/2PACX-1vR7mozWGSqorH_7knqSf8zkXy3XSzjrJdvor4oBBleXlP_1hnJADqgHsOgEQ6pVvF5Wly_MWI_tESYi/pub?gid=556239163&single=true&output=csv"

python3 - "$URL" <<'PY'
import pathlib, sys
url = sys.argv[1]
p = pathlib.Path("src/lib/events.ts"); s = p.read_text()
old = 'export const EVENTS_CSV = "";'
if old not in s:
    print("!! EVENTS_CSV line not found — already set?")
else:
    p.write_text(s.replace(old, f'export const EVENTS_CSV =\n  "{url}";'))
    print("  ok   EVENTS_CSV set")
PY

echo
echo "Sheet contents:"
curl -fsSL "$URL" | head -6 || echo "  (couldn't fetch — is that tab published?)"

echo
npm run build 2>&1 | tail -4
