#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib

# 1. events meta description
p = pathlib.Path("src/pages/events.astro"); s = p.read_text()
old = "Tournaments, socials and everything else Japan GAA gets up to beyond weekly training in Tokyo."
new = "Tournaments, socials and everything else Japan GAA gets up to away from the training pitch in Tokyo."
if old in s:
    p.write_text(s.replace(old, new)); print("  ok   events.astro description")
else:
    print("  --   description already changed (or differs)")

# 2. badge dimensions match the rendered size
p = pathlib.Path("src/layouts/Base.astro"); s = p.read_text()
old = 'width="44" height="44"'
if old in s:
    p.write_text(s.replace(old, 'width="60" height="60"')); print("  ok   badge dimensions")
else:
    print("  --   badge dimensions already set")
PY

echo
npm run build 2>&1 | tail -4
