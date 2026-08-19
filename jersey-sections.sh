#!/usr/bin/env bash
# Regroup jerseys by sleeve type, with a photo per section.
#   bash jersey-sections.sh <sleeved-photo> <sleeveless-photo>
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

if [ $# -lt 2 ]; then
  echo "Usage: bash jersey-sections.sh <sleeved-photo> <sleeveless-photo>"
  echo
  echo "Loose image files here:"
  ls -1 *.jpg *.jpeg *.JPG *.png *.webp 2>/dev/null | sed 's/^/  /' || echo "  (none)"
  exit 1
fi
command -v magick >/dev/null || { echo "ImageMagick missing: brew install imagemagick"; exit 1; }
mkdir -p public/photos archive/originals

magick "$1" -resize 1000x -quality 82 public/photos/jersey-sleeve.webp
magick "$2" -resize 1000x -quality 82 public/photos/jersey-sleeveless.webp
ls -lh public/photos/jersey-sleeve*.webp
mv "$1" "archive/originals/jersey-sleeve.${1##*.}"
mv "$2" "archive/originals/jersey-sleeveless.${2##*.}"

# ---- regroup: colour + sleeve, with fit as a sub-choice ------------------
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/lib/jerseys.ts"); s = p.read_text()

s = re.sub(r"export type Group = \{.*?\};",
'''export type Group = {
  colour: string; sleeve: string; price: string; slug: string;
  fits: { fit: string; sizes: { size: string; count: number }[] }[];
  total: number;
};''', s, flags=re.S)

s = re.sub(r"    const groups = new Map<string, Group>\(\);.*?\n    const out = \[\.\.\.groups\.values\(\)\];",
'''    const groups = new Map<string, Group>();
    for (const r of rows.slice(1)) {
      if (iSold >= 0 && (r[iSold] ?? "").trim()) continue;
      const colour = (r[iC] ?? "").trim();
      const size   = (r[iS] ?? "").trim().toUpperCase();
      if (!colour || !size) continue;
      const sleeve = (r[iSl] ?? "").trim();
      const fit    = (r[iF] ?? "").trim() || "Standard";
      const price  = (r[iP] ?? "").trim();

      // one section per colour + sleeve type; fit is a choice within it
      const key = [colour, sleeve].join("|");
      if (!groups.has(key)) groups.set(key, {
        colour, sleeve, price, total: 0, fits: [],
        slug: sleeve.toLowerCase().replace(/[^a-z0-9]+/g, "-"),
      });
      const g = groups.get(key)!;
      let f = g.fits.find((x) => x.fit === fit);
      if (!f) { f = { fit, sizes: [] }; g.fits.push(f); }
      let sz = f.sizes.find((x) => x.size === size);
      if (!sz) { sz = { size, count: 0 }; f.sizes.push(sz); }
      sz.count++; g.total++;
    }

    const out = [...groups.values()];''', s, flags=re.S)

s = s.replace('''    for (const g of out) {
      g.sizes.sort((a, b) => {
        const ai = SIZE_ORDER.indexOf(a.size), bi = SIZE_ORDER.indexOf(b.size);
        return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi);
      });
    }
    return out.sort((a, b) => a.colour.localeCompare(b.colour) || a.sleeve.localeCompare(b.sleeve));''',
'''    for (const g of out)
      for (const f of g.fits)
        f.sizes.sort((a, b) => {
          const ai = SIZE_ORDER.indexOf(a.size), bi = SIZE_ORDER.indexOf(b.size);
          return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi);
        });
    return out.sort((a, b) => a.colour.localeCompare(b.colour) || a.sleeve.localeCompare(b.sleeve));''')
p.write_text(s); print("  ok   jerseys.ts regrouped")
PY

cat > src/components/Stock.astro <<'EOF'
---
import { jerseyStock, updatedOn } from "../lib/jerseys";
const { lang = "en" } = Astro.props;
const stock = await jerseyStock();

const label = (sleeve: string) => {
  const k = sleeve.toLowerCase();
  if (lang === "ja") return k.startsWith("sleeveless") ? "ノースリーブ" : "半袖";
  return k.startsWith("sleeveless") ? "Sleeveless" : "Sleeved";
};
const t = lang === "ja"
  ? { none: "在庫状況はお問い合わせください。", updated: "在庫状況" }
  : { none: "Get in touch for current availability.", updated: "Stock as of" };
---
{stock.length === 0 ? (
  <p>{t.none}</p>
) : (
  <>
    {stock.map((g) => (
      <section class="jersey">
        <img class="jersey__photo" src={`/photos/jersey-${g.slug}.webp`} alt="" loading="lazy" />
        <div class="jersey__body">
          <h2>{g.colour} — {label(g.sleeve)}</h2>
          <p class="jersey__price">¥{g.price}</p>
          {g.fits.map((f) => (
            <div class="jersey__fit">
              <span class="jersey__fitname">{f.fit}</span>
              <ul class="stock__sizes">
                {f.sizes.map((s) => <li><strong>{s.size}</strong> <span>×{s.count}</span></li>)}
              </ul>
            </div>
          ))}
        </div>
      </section>
    ))}
    <p class="muted">{t.updated} {updatedOn(lang)}.</p>
  </>
)}
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- jersey sections ---- */
.jersey {
  display: grid; gap: 1.5rem; align-items: start;
  grid-template-columns: 1fr;
  padding: 1.75rem 0; border-top: 1px solid var(--line);
}
.jersey:last-of-type { border-bottom: 1px solid var(--line); }
@media (min-width: 40rem) { .jersey { grid-template-columns: 11rem 1fr; } }
.jersey__photo { width: 100%; aspect-ratio: 3 / 4; object-fit: cover; border-radius: 3px; display: block; }
.jersey__body h2 { font-size: 1.25rem; margin: 0 0 0.2rem; }
.jersey__price { font-family: var(--display); font-weight: 700; color: var(--pitch); margin: 0 0 1rem; }
.jersey__fit { margin-bottom: 0.9rem; }
.jersey__fitname {
  display: block; font-size: 0.75rem; text-transform: uppercase;
  letter-spacing: 0.12em; color: var(--stone); margin-bottom: 0.35rem;
}
EOF

echo
npm run build 2>&1 | tail -4
