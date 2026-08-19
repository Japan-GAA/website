#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib
URL = ("https://docs.google.com/spreadsheets/d/e/2PACX-1vR7mozWGSqorH_7knqSf8zkXy3XSzjrJd"
       "vor4oBBleXlP_1hnJADqgHsOgEQ6pVvF5Wly_MWI_tESYi/pub?gid=0&single=true&output=csv")
p = pathlib.Path("src/lib/jerseys.ts")
s = p.read_text()
old = 'export const SHEET_CSV = "";'
if old not in s:
    print("!! SHEET_CSV line not found — is it already set?")
else:
    p.write_text(s.replace(old, f'export const SHEET_CSV =\n  "{URL}";'))
    print("  ok   SHEET_CSV set")
PY

echo
echo "Fetching the sheet to check it parses…"
curl -fsSL "https://docs.google.com/spreadsheets/d/e/2PACX-1vR7mozWGSqorH_7knqSf8zkXy3XSzjrJdvor4oBBleXlP_1hnJADqgHsOgEQ6pVvF5Wly_MWI_tESYi/pub?gid=0&single=true&output=csv" | head -5 || echo "  (couldn't fetch — check the sheet is published)"

echo
npm run build 2>&1 | tail -4
