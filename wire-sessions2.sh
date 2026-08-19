#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re, sys

JOBS = [
  ("src/pages/training.astro", "../components/Sessions.astro", "When",
'''      <div class="fact">
        <h2>Next sessions</h2>
        <Sessions lang="en" />
        <p class="muted">
          Sessions run 7–9pm. The day of the week changes, so check back here or
          on <a href="https://www.instagram.com/japangaa">Instagram</a>.
        </p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>'''),
  ("src/pages/ja/training.astro", "../../components/Sessions.astro", "日時",
'''      <div class="fact">
        <h2>次回の練習</h2>
        <Sessions lang="ja" />
        <p class="muted">
          練習は 19:00〜21:00 です。曜日は回によって変わりますので、
          こちらのページまたは
          <a href="https://www.instagram.com/japangaa">Instagram</a>
          をご確認ください。
        </p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>'''),
]

for path, imp, heading, new in JOBS:
    p = pathlib.Path(path)
    if not p.exists():
        print("skip (missing):", path); continue
    s = p.read_text()

    if "Sessions.astro" not in s:
        s = re.sub(r"(---\nimport )", f'---\nimport Sessions from "{imp}";\nimport ', s, count=1)

    # match the whole .fact block whose <h2> is the heading, up to its </div>
    pat = re.compile(
        r'<div class="fact">\s*<h2>\s*' + re.escape(heading) + r'\s*</h2>.*?</div>',
        re.S,
    )
    s2, n = pat.subn(new.strip(), s, count=1)
    if n == 0:
        print(f"!! no <h2>{heading}</h2> block found in {path}")
        print("   here is what the file contains around 'fact':")
        for m in re.finditer(r'<h2>([^<]{0,30})</h2>', s):
            print("     <h2>" + m.group(1) + "</h2>")
        continue
    p.write_text(s2)
    print("patched", path)
PY

echo
echo "Run: npm run dev  ->  http://localhost:4321/training"
