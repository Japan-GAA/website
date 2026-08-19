#!/usr/bin/env bash
# Swaps the All-Ireland video id, whether or not add-second-video.sh has run yet.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
OLD="idxjc-4TIA8"; NEW="tzPmmBCEMN4"
n=0
for f in add-second-video.sh src/pages/gaelic-football.astro src/pages/ja/gaelic-football.astro; do
  [ -f "$f" ] || continue
  if grep -q "$OLD" "$f"; then
    sed -i '' "s/$OLD/$NEW/g" "$f"; echo "  updated $f"; n=$((n+1))
  fi
done
[ "$n" -gt 0 ] || echo "  nothing contained $OLD — has add-second-video.sh been run?"
