#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/lib src/pages/ja

cat > src/lib/jerseys.ts <<'EOF'
// Jersey stock, read from a published Google Sheet at build time.
// Sheet -> File -> Share -> Publish to web -> pick the sheet -> CSV -> copy link.
// One row per physical jersey. Columns: Color, Size, Sleeve, Fit, Price, Number
// Optional extra column: Sold — any non-empty value hides that row.
export const SHEET_CSV = "";   // <-- paste the published CSV link here

export type Group = {
  colour: string; sleeve: string; fit: string; price: string;
  sizes: { size: string; count: number; numbers: string[] }[];
  total: number;
};

const SIZE_ORDER = ["XS", "S", "M", "L", "XL", "XXL", "3XL"];

// Minimal CSV parser — handles quoted fields, which matters because
// prices are written as "11,000".
function parseCSV(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [], field = "", inQuotes = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (inQuotes) {
      if (c === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (c === '"') inQuotes = false;
      else field += c;
    } else if (c === '"') inQuotes = true;
    else if (c === ",") { row.push(field); field = ""; }
    else if (c === "\n") { row.push(field); rows.push(row); row = []; field = ""; }
    else if (c !== "\r") field += c;
  }
  if (field || row.length) { row.push(field); rows.push(row); }
  return rows.filter((r) => r.some((c) => c.trim()));
}

/** Grouped stock, or [] if the sheet is unset or unreachable. Never throws. */
export async function jerseyStock(): Promise<Group[]> {
  if (!SHEET_CSV) return [];
  try {
    const res = await fetch(SHEET_CSV);
    if (!res.ok) throw new Error(`sheet returned ${res.status}`);
    const rows = parseCSV(await res.text());
    if (rows.length < 2) return [];

    const head = rows[0].map((h) => h.trim().toLowerCase());
    const col = (name: string) => head.findIndex((h) => h === name);
    const iC = col("color") >= 0 ? col("color") : col("colour");
    const iS = col("size"), iSl = col("sleeve"), iF = col("fit");
    const iP = col("price"), iN = col("number"), iSold = col("sold");

    const groups = new Map<string, Group>();
    for (const r of rows.slice(1)) {
      if (iSold >= 0 && (r[iSold] ?? "").trim()) continue;
      const colour = (r[iC] ?? "").trim();
      const size   = (r[iS] ?? "").trim().toUpperCase();
      if (!colour || !size) continue;
      const sleeve = (r[iSl] ?? "").trim();
      const fit    = (r[iF] ?? "").trim();
      const price  = (r[iP] ?? "").trim();
      const num    = iN >= 0 ? (r[iN] ?? "").trim() : "";

      const key = [colour, sleeve, fit, price].join("|");
      if (!groups.has(key)) groups.set(key, { colour, sleeve, fit, price, sizes: [], total: 0 });
      const g = groups.get(key)!;
      let s = g.sizes.find((x) => x.size === size);
      if (!s) { s = { size, count: 0, numbers: [] }; g.sizes.push(s); }
      s.count++; g.total++;
      if (num) s.numbers.push(num);
    }

    const out = [...groups.values()];
    for (const g of out) {
      g.sizes.sort((a, b) => {
        const ai = SIZE_ORDER.indexOf(a.size), bi = SIZE_ORDER.indexOf(b.size);
        return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi);
      });
    }
    return out.sort((a, b) => a.colour.localeCompare(b.colour) || a.sleeve.localeCompare(b.sleeve));
  } catch (err) {
    console.warn("[jerseys] could not load stock sheet:", err);
    return [];
  }
}

export const updatedOn = (lang: "en" | "ja") =>
  new Date().toLocaleDateString(lang === "ja" ? "ja-JP" : "en-IE",
    { timeZone: "Asia/Tokyo", year: "numeric", month: "long", day: "numeric" });
EOF

cat > src/components/Stock.astro <<'EOF'
---
import { jerseyStock, updatedOn } from "../lib/jerseys";
const { lang = "en" } = Astro.props;
const stock = await jerseyStock();
const t = lang === "ja"
  ? { none: "在庫状況はお問い合わせください。", left: "残り", updated: "在庫状況", sleeveless: "ノースリーブ", sleeved: "半袖" }
  : { none: "Get in touch for current availability.", left: "left", updated: "Stock as of", sleeveless: "Sleeveless", sleeved: "Sleeved" };
---
{stock.length === 0 ? (
  <p>{t.none}</p>
) : (
  <>
    <ul class="stock">
      {stock.map((g) => (
        <li class="stock__row">
          <div class="stock__what">
            <span class="stock__name">{g.colour} · {g.sleeve} · {g.fit}</span>
            <span class="stock__price">¥{g.price}</span>
          </div>
          <ul class="stock__sizes">
            {g.sizes.map((s) => (
              <li><strong>{s.size}</strong> <span>×{s.count}</span></li>
            ))}
          </ul>
        </li>
      ))}
    </ul>
    <p class="muted">{t.updated} {updatedOn(lang)}.</p>
  </>
)}
EOF

cat > src/pages/jerseys.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
import Stock from "../components/Stock.astro";
---
<Base lang="en" pageKey="jerseys"
  title="Jerseys — Japan GAA"
  description="Japan GAA club jerseys, sleeved and sleeveless, in regular and player fit. Current stock and prices.">
  <div class="wrap prose">
    <header class="pagehead">
      <h1>Jerseys</h1>
      <p class="hero__lede">Club jerseys, sleeved and sleeveless, in regular and player fit.</p>
    </header>

    <Stock lang="en" />

    <h2>Prices</h2>
    <ul class="bring">
      <li>Paid members: ¥1,000 off all jerseys</li>
      <li>Everyone else: ¥1,000 off from the second jersey onwards</li>
    </ul>

    <h2>How to order</h2>
    <p>
      Email us with the colour, size and fit you want, and we'll sort it out at
      training. Stock changes, so it's worth confirming before you set your heart
      on a size.
    </p>
    <p><a class="cta" href="mailto:japangaa@gmail.com">Email us about a jersey</a></p>
  </div>
</Base>
EOF

cat > src/pages/ja/jerseys.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
import Stock from "../../components/Stock.astro";
---
<Base lang="ja" pageKey="jerseys"
  title="ジャージ — Japan GAA"
  description="Japan GAAのクラブジャージ。半袖・ノースリーブ、レギュラーフィットとプレイヤーフィットをご用意しています。">
  <div class="wrap prose">
    <header class="pagehead">
      <h1>ジャージ</h1>
      <p class="hero__lede">クラブジャージ。半袖とノースリーブ、レギュラーフィットとプレイヤーフィットがあります。</p>
    </header>

    <Stock lang="ja" />

    <h2>価格</h2>
    <ul class="bring">
      <li>会費をお支払いの方：全ジャージ 1,000円引き</li>
      <li>その他の方：2着目から 1,000円引き</li>
    </ul>

    <h2>ご注文方法</h2>
    <p>
      ご希望の色・サイズ・フィットをメールでお知らせください。練習の際にお渡しします。
      在庫は変動しますので、事前にご確認いただくのが確実です。
    </p>
    <p><a class="cta" href="mailto:japangaa@gmail.com">ジャージについて問い合わせる</a></p>
  </div>
</Base>
EOF

python3 - <<'PY'
import pathlib
p = pathlib.Path("src/consts.js"); s = p.read_text()
line = '  { key: "jerseys",  en: "/jerseys",         ja: "/ja/jerseys",         labelEn: "Jerseys",   labelJa: "ジャージ" },\n'
if '"jerseys"' not in s:
    s = s.replace('  { key: "history",', line + '  { key: "history",')
    p.write_text(s); print("  ok   nav entry added")
else:
    print("  --   nav entry already present")
PY

cat >> src/styles/global.css <<'EOF'

/* ---- jersey stock ---- */
.stock { list-style: none; padding: 0; margin: 1.5rem 0; }
.stock__row { border-top: 1px solid var(--line); padding: 1rem 0; }
.stock__row:last-child { border-bottom: 1px solid var(--line); }
.stock__what { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; }
.stock__name { font-family: var(--display); font-weight: 700; font-size: 1.0625rem; }
.stock__price { font-family: var(--display); font-weight: 700; color: var(--pitch); }
.stock__sizes { list-style: none; display: flex; flex-wrap: wrap; gap: 0.5rem; padding: 0; margin: 0.6rem 0 0; }
.stock__sizes li {
  border: 1px solid var(--line); border-radius: 2px;
  padding: 0.2rem 0.6rem; font-size: 0.875rem;
}
.stock__sizes strong { color: var(--ink); }
.stock__sizes span { color: var(--stone); }
EOF

echo
echo "Now paste the published CSV link into SHEET_CSV in src/lib/jerseys.ts"
npm run build 2>&1 | tail -4
