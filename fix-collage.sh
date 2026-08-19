#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib
for path in ("src/pages/index.astro", "src/pages/ja/index.astro"):
    p = pathlib.Path(path)
    lines = p.read_text().splitlines(keepends=True)
    kept = [l for l in lines if "hero2__bg" not in l and "PHOTOS.hero" not in l]
    p.write_text("".join(kept))
    print(f"{path}: removed {len(lines)-len(kept)} line(s)")

print("\n--- hero section of index.astro ---")
s = pathlib.Path("src/pages/index.astro").read_text()
start = s.find('<section class="hero2')
end   = s.find("<Facts")
print(s[start:end])
PY
