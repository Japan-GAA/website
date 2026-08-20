#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

CJK = re.compile(r"[\u3040-\u30ff\u3400-\u9fff]")

def split_title(t: str):
    m = CJK.search(t)
    if not m:
        return t.strip(), ""
    i = m.start()
    # numbers and separators immediately before the first Japanese character
    # belong with it: "... News letter 11-12月の..." -> "11-12月の..."
    while i > 0 and t[i-1] in "0123456789-–—/ ":
        i -= 1
    en = t[:i].strip(" :–—-")
    ja = t[i:].strip()
    return en or t.strip(), ja

posts = sorted(pathlib.Path("src/content/news").glob("*.md"))
changed = 0
for p in posts:
    s = p.read_text()
    m = re.search(r'^title:\s*"(.*)"\s*$', s, re.M)
    if not m: continue
    if re.search(r'^titleJa:', s, re.M): continue
    en, ja = split_title(m.group(1))
    if not ja: continue
    en = en.replace("News letter", "Newsletter").replace("Newsletter Newsletter", "Newsletter")
    esc = lambda x: x.replace('\\', '\\\\').replace('"', '\\"')
    s = s.replace(m.group(0), f'title: "{esc(en)}"\ntitleJa: "{esc(ja)}"')
    p.write_text(s); changed += 1
    print(f'  {en}\n      -> {ja}')
print(f"\n{changed} of {len(posts)} posts split")
PY

# schema
python3 - <<'PY'
import pathlib
p = pathlib.Path("src/content.config.ts"); s = p.read_text()
if "titleJa" not in s:
    s = s.replace("    title: z.string(),", "    title: z.string(),\n    titleJa: z.string().optional(),")
    p.write_text(s); print("  ok   content.config.ts")
else:
    print("  --   schema already has titleJa")
PY

# render the Japanese title on Japanese pages
python3 - <<'PY'
import pathlib
EDITS = [
 ("src/pages/ja/news/index.astro", "<h3>{post.data.title}</h3>", "<h3>{post.data.titleJa ?? post.data.title}</h3>"),
 ("src/pages/ja/index.astro",      "<h3>{post.data.title}</h3>", "<h3>{post.data.titleJa ?? post.data.title}</h3>"),
 ("src/pages/news/[...slug].astro", "<h1>{post.data.title}</h1>", "<h1>{post.data.title}</h1>"),
]
for path, old, new in EDITS:
    p = pathlib.Path(path)
    if not p.exists(): print("!! missing", path); continue
    s = p.read_text()
    if old != new and old in s:
        p.write_text(s.replace(old, new)); print("  ok  ", path)
    else:
        print("  --  ", path)

# the bilingual archive posts live at /news/<slug>; show the Japanese title there
# only when the reader came from the Japanese index — simplest is to show both
# stacked on the post page itself.
p = pathlib.Path("src/pages/ja/news/[...slug].astro")
if p.exists():
    s = p.read_text()
    if "titleJa" not in s:
        s = s.replace("<h1>{post.data.title}</h1>", "<h1>{post.data.titleJa ?? post.data.title}</h1>")
        p.write_text(s); print("  ok   ja/news/[...slug].astro")
PY

echo
npm run build 2>&1 | tail -4
