#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib
CUTS = {
 "src/pages/training.astro": [
   '        <p class="muted">Don\'t buy anything for your first session. We have the balls.</p>\n',
 ],
 "src/pages/ja/training.astro": [
   '        <p class="muted">初回のために新しく購入する必要はありません。ボールはこちらで用意します。</p>\n',
 ],
}
for path, cuts in CUTS.items():
    p = pathlib.Path(path)
    if not p.exists(): print("!! missing", path); continue
    s = p.read_text()
    before = len(s)
    for c in cuts:
        s = s.replace(c, "")
    # fall back to a line-level match if whitespace differs
    if len(s) == before:
        keep = [l for l in s.splitlines(keepends=True)
                if "We have the balls" not in l and "ボールはこちらで用意します" not in l]
        s = "".join(keep)
    p.write_text(s)
    print("  ok  ", path, "" if len(s) < before else "(nothing removed — check by hand)")

# bus line wording
p = pathlib.Path("src/pages/training.astro"); s = p.read_text()
s = s.replace("<li>10 min by bus from <strong>Shinagawa</strong></li>",
              "<li>10 min by bus from <strong>Shinagawa Station</strong></li>")
p.write_text(s); print("  ok   bus line")
PY

echo "Run: npm run dev"
