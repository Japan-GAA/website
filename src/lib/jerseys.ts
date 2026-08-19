// Jersey stock, read from a published Google Sheet at build time.
// Sheet -> File -> Share -> Publish to web -> pick the sheet -> CSV -> copy link.
// One row per physical jersey. Columns: Color, Size, Sleeve, Fit, Price, Number
// Optional extra column: Sold — any non-empty value hides that row.
export const SHEET_CSV =
  "https://docs.google.com/spreadsheets/d/e/2PACX-1vR7mozWGSqorH_7knqSf8zkXy3XSzjrJdvor4oBBleXlP_1hnJADqgHsOgEQ6pVvF5Wly_MWI_tESYi/pub?gid=0&single=true&output=csv";   // <-- paste the published CSV link here

export type Group = {
  colour: string; sleeve: string; price: string; slug: string;
  fits: { fit: string; sizes: { size: string; count: number }[] }[];
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

    const out = [...groups.values()];
    for (const g of out)
      for (const f of g.fits)
        f.sizes.sort((a, b) => {
          const ai = SIZE_ORDER.indexOf(a.size), bi = SIZE_ORDER.indexOf(b.size);
          return (ai < 0 ? 99 : ai) - (bi < 0 ? 99 : bi);
        });
    return out.sort((a, b) => a.colour.localeCompare(b.colour) || a.sleeve.localeCompare(b.sleeve));
  } catch (err) {
    console.warn("[jerseys] could not load stock sheet:", err);
    return [];
  }
}

export const updatedOn = (lang: "en" | "ja") =>
  new Date().toLocaleDateString(lang === "ja" ? "ja-JP" : "en-IE",
    { timeZone: "Asia/Tokyo", year: "numeric", month: "long", day: "numeric" });
