// Training sessions, read from a published Google Sheet tab at build time.
// Columns: Date | Start time | Finish time | Location (if not Yashiokita park)
//
// Everything here is treated as Tokyo wall-clock time and never converted to a
// Date object, so the build machine's timezone can't shift anything.
export const SESSIONS_CSV =
  "https://docs.google.com/spreadsheets/d/e/2PACX-1vR7mozWGSqorH_7knqSf8zkXy3XSzjrJdvor4oBBleXlP_1hnJADqgHsOgEQ6pVvF5Wly_MWI_tESYi/pub?gid=564548259&single=true&output=csv";   // <-- paste the published CSV link for the training tab

export type Session = {
  y: number; m: number; d: number;
  start: string; end: string; location: string; locationJa: string;
};

function parseCSV(text: string): string[][] {
  const rows: string[][] = [];
  let row: string[] = [], field = "", q = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (q) {
      if (c === '"' && text[i + 1] === '"') { field += '"'; i++; }
      else if (c === '"') q = false;
      else field += c;
    } else if (c === '"') q = true;
    else if (c === ",") { row.push(field); field = ""; }
    else if (c === "\n") { row.push(field); rows.push(row); row = []; field = ""; }
    else if (c !== "\r") field += c;
  }
  if (field || row.length) { row.push(field); rows.push(row); }
  return rows.filter((r) => r.some((c) => c.trim()));
}

/** "8/26/2026" or "2026-08-26" -> parts, or null */
function parseDate(v: string) {
  const s = v.trim();
  let m = s.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (m) return { y: +m[3], m: +m[1], d: +m[2] };
  m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (m) return { y: +m[1], m: +m[2], d: +m[3] };
  return null;
}

/** "7:00 PM" -> "7pm", "7:30 PM" -> "7:30pm", "19:00" -> "7pm" */
function tidyTime(v: string) {
  const s = v.trim();
  let m = s.match(/^(\d{1,2}):(\d{2})\s*([AaPp])\.?[Mm]\.?$/);
  let h: number, min: number;
  if (m) {
    h = +m[1] % 12 + (m[3].toLowerCase() === "p" ? 12 : 0);
    min = +m[2];
  } else {
    m = s.match(/^(\d{1,2}):(\d{2})$/);
    if (!m) return s;
    h = +m[1]; min = +m[2];
  }
  return { h, min };
}

/** Today in Tokyo, as plain numbers. */
function todayTokyo() {
  const p = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Tokyo", year: "numeric", month: "2-digit", day: "2-digit",
  }).format(new Date()).split("-");
  return { y: +p[0], m: +p[1], d: +p[2] };
}

/** Upcoming sessions, soonest first. Never throws. */
export async function upcomingSessions(limit = 4): Promise<Session[]> {
  if (!SESSIONS_CSV) return [];
  try {
    // Google's CDN caches published sheets for a few minutes and serves
    // different versions from different edges, so make every request unique.
    const url = SESSIONS_CSV + ((SESSIONS_CSV.includes("?") ? "&" : "?") + "_=" + Date.now());
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error(`sheet returned ${res.status}`);
    const rows = parseCSV(await res.text());
    if (rows.length < 2) return [];

    const head = rows[0].map((h) => h.trim().toLowerCase());
    const find = (...names: string[]) =>
      head.findIndex((h) => names.some((n) => h.startsWith(n)));
    const iD = find("date"), iS = find("start"), iF = find("finish", "end"), iL = find("location");

    const jaFor = (i: number, ...words: string[]) => {
      const byName = head.findIndex(
        (h) => words.some((w) => h.includes(w)) && /japan|日本/.test(h)
      );
      if (byName >= 0 && byName !== i) return byName;
      if (i < 0) return -1;
      const next = head[i + 1];
      if (next === undefined) return -1;
      return next === "" || next === head[i] ? i + 1 : -1;
    };
    const iLJa = jaFor(iL, "location");

    const t = todayTokyo();
    const key = (x: { y: number; m: number; d: number }) => x.y * 10000 + x.m * 100 + x.d;

    const out: Session[] = [];
    for (const r of rows.slice(1)) {
      const date = parseDate(r[iD] ?? "");
      if (!date || key(date) < key(t)) continue;
      out.push({
        ...date,
        start: (r[iS] ?? "").trim(),
        end: iF >= 0 ? (r[iF] ?? "").trim() : "",
        location: iL >= 0 ? (r[iL] ?? "").trim() : "",
        locationJa: (iLJa >= 0 ? (r[iLJa] ?? "").trim() : "")
                    || (iL >= 0 ? (r[iL] ?? "").trim() : ""),
      });
    }
    return out.sort((a, b) => key(a) - key(b)).slice(0, limit);
  } catch (err) {
    console.warn("[sessions] could not load the training sheet:", err);
    return [];
  }
}

export { tidyTime };
