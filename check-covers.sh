#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re, subprocess
posts = sorted(pathlib.Path("src/content/news").glob("*.md"))
missing, nocover, transparent, tiny = [], [], [], []

for f in posts:
    t = f.read_text()
    m = re.search(r'^cover:\s*"([^"]+)"', t, re.M)
    if not m:
        nocover.append(f.name); continue
    p = pathlib.Path("public") / m.group(1).lstrip("/")
    if not p.exists():
        missing.append((f.name, m.group(1))); continue
    if p.stat().st_size < 15000:
        tiny.append((f.name, m.group(1), p.stat().st_size))
    try:
        out = subprocess.run(["magick", "identify", "-format", "%[opaque]", str(p)],
                             capture_output=True, text=True).stdout.strip()
        if out.lower() == "false":
            transparent.append((f.name, m.group(1)))
    except FileNotFoundError:
        pass

print(f"{len(posts)} posts\n")
print(f"No cover at all ({len(nocover)}):")
for n in nocover[:10]: print("   ", n)
print(f"\nCover file missing from public/news ({len(missing)}):")
for n, c in missing[:10]: print("   ", n, "->", c)
print(f"\nTransparent (renders blank on white) ({len(transparent)}):")
for n, c in transparent[:10]: print("   ", n, "->", c)
print(f"\nVery small, likely a logo or spacer ({len(tiny)}):")
for n, c, s in tiny[:10]: print(f"    {n} -> {c} ({s} bytes)")
PY
