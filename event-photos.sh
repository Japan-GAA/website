#!/usr/bin/env bash
# Attach photos to event rows via a Photo column in the sheet.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p public/photos/events

# move the banner photos into the per-event folder with meaningful names
declare -a MAP=(
  "events-1.webp:yokohama-parade-2025.webp"
  "events-2.webp:sports-day-2025.webp"
  "events-3.webp:christmas-party-2025.webp"
  "events-4.webp:bbq.webp"
)
for pair in "${MAP[@]}"; do
  src="public/photos/${pair%%:*}"; dst="public/photos/events/${pair##*:}"
  [ -f "$src" ] && mv "$src" "$dst" && echo "  moved $(basename "$src") -> events/$(basename "$dst")"
done

python3 - <<'PY'
import pathlib, re

# ---- lib: read the Photo column ----------------------------------------
p = pathlib.Path("src/lib/events.ts"); s = p.read_text()
s = s.replace("  location: string; locationJa: string;",
              "  location: string; locationJa: string;\n  photo: string;")
s = s.replace('const iL = find("location"), iX = find("note");',
              'const iL = find("location"), iX = find("note"), iP = find("photo", "image");')
s = s.replace('        notesJa: cell(r, jX) || cell(r, iX),',
              '        notesJa: cell(r, jX) || cell(r, iX),\n        photo: cell(r, iP),')
p.write_text(s); print("  ok   events.ts")

# ---- past events become a photo grid ------------------------------------
p = pathlib.Path("src/components/EventList.astro"); s = p.read_text()
s = s.replace('const isUrl = (s: string) => /^https?:\\/\\//.test(s);',
'''const isUrl = (s: string) => /^https?:\\/\\//.test(s);
const photoSrc = (f: string) =>
  !f ? "" : (f.startsWith("/") ? f : `/photos/events/${f}`);''')

grid = '''{past ? (
  <ul class="pastgrid">
    {events.map((e: Ev) => (
      <li>
        {photoSrc(e.photo)
          ? <img src={photoSrc(e.photo)} alt={ja ? e.nameJa : e.name} loading="lazy" />
          : <span class="pastgrid__none" aria-hidden="true"><img src="/badge.png" alt="" loading="lazy" /></span>}
        <h3>{ja ? e.nameJa : e.name}</h3>
        <time>{when(e)}</time>
      </li>
    ))}
  </ul>
) : (
'''
s = s.replace('<ul class:list={["events", past && "events--past"]}>', grid + '  <ul class="events">')
s = s.rstrip()
s = s[: s.rfind("</ul>")] + "</ul>\n)}\n"
p.write_text(s); print("  ok   EventList.astro")
PY

cat >> src/styles/global.css <<'EOF'

/* ---- past events as a photo grid ---- */
.pastgrid {
  list-style: none; padding: 0; margin: 1.5rem 0 2.5rem;
  display: grid; gap: 1.5rem;
  grid-template-columns: repeat(auto-fill, minmax(13rem, 1fr));
}
.pastgrid img {
  width: 100%; aspect-ratio: 4 / 3; object-fit: cover;
  display: block; border-radius: 3px; margin-bottom: 0.6rem;
}
.pastgrid__none {
  display: grid; place-items: center; aspect-ratio: 4 / 3;
  background: var(--chalk); border: 1px solid var(--line);
  border-radius: 3px; margin-bottom: 0.6rem;
}
.pastgrid__none img { width: 55%; height: 55%; object-fit: contain; margin: 0; }
.pastgrid h3 { font-size: 1rem; margin: 0 0 0.1rem; letter-spacing: 0; }
.pastgrid time { font-size: 0.8125rem; color: var(--stone); }
EOF

# drop the banner strip from the events pages
python3 - <<'PY'
import pathlib
for path in ("src/pages/events.astro", "src/pages/ja/events.astro"):
    p = pathlib.Path(path)
    if not p.exists(): continue
    lines = p.read_text().splitlines(keepends=True)
    kept = [l for l in lines if "<Collage" not in l and "EVENT_SHOTS" not in l]
    if len(kept) != len(lines):
        p.write_text("".join(kept)); print("  ok  ", path, "banner removed")
PY

echo
echo "Add a 'Photo' column to the events tab. Values, one per row:"
ls -1 public/photos/events/ 2>/dev/null | sed 's/^/    /'
echo
npm run build 2>&1 | tail -4
