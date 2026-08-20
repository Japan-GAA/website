#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

echo "Before:"
grep -rn "ジャージ" src/ | sed 's/^/  /'
echo

python3 - <<'PY'
import pathlib
n = 0
for p in pathlib.Path("src").rglob("*"):
    if not p.is_file() or p.suffix not in (".astro", ".js", ".ts"): continue
    s = p.read_text()
    if "ジャージ" not in s: continue
    p.write_text(s.replace("ジャージ", "ユニフォーム"))
    print("  ok  ", p); n += 1
print(f"\n{n} file(s) changed")
PY

echo
npm run build 2>&1 | tail -4
