#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/layouts/Base.astro"); s = p.read_text()

new = '''<p class="foot__contact">
          {lang === "ja" ? (
            <>ご質問は <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> まで、お気軽にお問い合わせください。</>
          ) : (
            <>Any questions? Get in touch at <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a>.</>
          )}
        </p>'''

s2, n = re.subn(r'<p class="foot__contact">.*?</p>', new, s, count=1, flags=re.S)
print("  ok   footer contact line" if n else "  !!   footer contact block not found")
if n: p.write_text(s2)
PY

echo
npm run build 2>&1 | tail -4
