#!/usr/bin/env bash
# GGDF logo + icon social links in the footer on every page.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }
mkdir -p public/photos archive/originals src/components

# ---- find and convert the logo (keeps transparency) ----------------------
shopt -s nullglob nocaseglob
src=""
for f in *ggdf* *global*game* *development*fund* *gg-df*; do src="$f"; break; done
shopt -u nocaseglob
if [ -z "$src" ]; then
  echo "Couldn't spot the logo. Loose image files here:"
  ls -1 *.jpg *.jpeg *.png *.webp *.svg 2>/dev/null | sed 's/^/  /' || echo "  (none)"
  echo
  echo "Re-run as:  bash footer.sh \"<filename>\""
  [ $# -ge 1 ] && src="$1" || exit 1
fi
[ $# -ge 1 ] && src="$1"
magick "$src" -resize 480x -background none public/photos/ggdf.webp
ls -lh public/photos/ggdf.webp
mv "$src" "archive/originals/ggdf.${src##*.}"

# ---- social icons --------------------------------------------------------
cat > src/components/Social.astro <<'EOF'
---
const links = [
  { name: "Instagram", url: "https://www.instagram.com/japangaa" },
  { name: "Facebook",  url: "https://www.facebook.com/gaajapan" },
];
---
<ul class="social">
  {links.map((l) => (
    <li>
      <a href={l.url} rel="me noopener" aria-label={l.name} title={l.name}>
        {l.name === "Instagram" ? (
          <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
            <path d="M12 2.2c3.2 0 3.6 0 4.86.07 1.17.06 1.8.25 2.23.42.56.22.96.48 1.38.9.42.42.68.82.9 1.38.17.42.36 1.06.42 2.23.06 1.26.07 1.64.07 4.86s0 3.6-.07 4.86c-.06 1.17-.25 1.8-.42 2.23a3.8 3.8 0 0 1-.9 1.38 3.8 3.8 0 0 1-1.38.9c-.42.17-1.06.36-2.23.42-1.26.06-1.64.07-4.86.07s-3.6 0-4.86-.07c-1.17-.06-1.8-.25-2.23-.42a3.8 3.8 0 0 1-1.38-.9 3.8 3.8 0 0 1-.9-1.38c-.17-.42-.36-1.06-.42-2.23C2.2 15.6 2.2 15.22 2.2 12s0-3.6.07-4.86c.06-1.17.25-1.8.42-2.23.22-.56.48-.96.9-1.38.42-.42.82-.68 1.38-.9.42-.17 1.06-.36 2.23-.42C8.4 2.2 8.78 2.2 12 2.2Zm0 3.1a6.7 6.7 0 1 0 0 13.4 6.7 6.7 0 0 0 0-13.4Zm0 11a4.3 4.3 0 1 1 0-8.6 4.3 4.3 0 0 1 0 8.6Zm7-11.3a1.57 1.57 0 1 1-3.13 0 1.57 1.57 0 0 1 3.13 0Z"/>
          </svg>
        ) : (
          <svg viewBox="0 0 24 24" aria-hidden="true" focusable="false">
            <path d="M22 12a10 10 0 1 0-11.56 9.88v-6.99H7.9V12h2.54V9.8c0-2.5 1.5-3.89 3.77-3.89 1.1 0 2.24.2 2.24.2v2.46h-1.26c-1.24 0-1.63.77-1.63 1.56V12h2.78l-.45 2.89h-2.33v6.99A10 10 0 0 0 22 12Z"/>
          </svg>
        )}
      </a>
    </li>
  ))}
</ul>
EOF

# ---- rebuild the footer --------------------------------------------------
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/layouts/Base.astro"); s = p.read_text()

if "Social.astro" not in s:
    s = s.replace('import { SITE, PAGES } from "../consts.js";',
                  'import Social from "../components/Social.astro";\nimport { SITE, PAGES } from "../consts.js";')
s = re.sub(r"\nconst socials = \[.*?\];\n", "\n", s, flags=re.S)

new = '''    <footer class="foot">
      <div class="wrap foot__inner">
        <p class="foot__contact">
          Please contact <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> for your questions!<br />
          練習やイベント参加に関するご質問は <a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a> までお問い合わせください！
        </p>
        <Social />
      </div>
      <div class="wrap foot__partner">
        <img src="/photos/ggdf.webp" alt="Global Games Development Fund" width="240" height="80" loading="lazy" />
      </div>
    </footer>'''
s2, n = re.subn(r'<footer class="foot">.*?</footer>', new, s, count=1, flags=re.S)
print("  ok   footer rebuilt" if n else "  !!   footer block not found")
if n: p.write_text(s2)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- footer ---- */
.foot__inner {
  display: flex; justify-content: space-between; align-items: flex-start;
  gap: 1.5rem; flex-wrap: wrap;
}
.social { list-style: none; display: flex; gap: 0.75rem; padding: 0; margin: 0; }
.social a {
  display: grid; place-items: center; width: 2.4rem; height: 2.4rem;
  border: 1px solid var(--line); border-radius: 50%; color: var(--pitch);
}
.social a:hover { color: var(--chalk); background: var(--vermilion); border-color: var(--vermilion); }
.social svg { width: 1.1rem; height: 1.1rem; fill: currentColor; display: block; }

.foot__partner { margin-top: 2rem; padding-top: 1.75rem; border-top: 1px solid var(--line); }
.foot__partner img { width: auto; height: 3.5rem; max-width: 100%; object-fit: contain; display: block; }
EOF

echo
npm run build 2>&1 | tail -4
