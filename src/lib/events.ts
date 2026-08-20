// Club events (not training), read from a published Google Sheet tab.
// Columns: Event Name | Date | Finish Date (if different) | Location | Notes
export const EVENTS_CSV =
  "https://docs.google.com/spreadsheets/d/e/2PACX-1vR7mozWGSqorH_7knqSf8zkXy3XSzjrJdvor4oBBleXlP_1hnJADqgHsOgEQ6pVvF5Wly_MWI_tESYi/pub?gid=556239163&single=true&output=csv";   // <-- paste the published CSV link for the events tab

export type Ev = {
  name: string; nameJa: string;
  notes: string; notesJa: string;
  location: string; locationJa: string;
  y: number; m: number; d: number;
  endY?: number; endM?: number; endD?: number;
};

const MONTHS = ["jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"];

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

/** "Sep 12, 2026" | "9/12/2026" | "2026-09-12" */
function parseDate(v: string) {
  const s = v.trim();
  let m = s.match(/^([A-Za-z]{3,})\.?\s+(\d{1,2}),?\s+(\d{4})$/);
  if (m) {
    const mi = MONTHS.indexOf(m[1].slice(0, 3).toLowerCase());
    if (mi >= 0) return { y: +m[3], m: mi + 1, d: +m[2] };
  }
  m = s.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (m) return { y: +m[3], m: +m[1], d: +m[2] };
  m = s.match(/^(\d{4})-(\d{1,2})-(\d{1,2})$/);
  if (m) return { y: +m[1], m: +m[2], d: +m[3] };
  return null;
}

function todayTokyo() {
  const p = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Tokyo", year: "numeric", month: "2-digit", day: "2-digit",
  }).format(new Date()).split("-");
  return { y: +p[0], m: +p[1], d: +p[2] };
}

const key = (x: { y: number; m: number; d: number }) => x.y * 10000 + x.m * 100 + x.d;

/** { upcoming, past } — never throws. */
export async function clubEvents(): Promise<{ upcoming: Ev[]; past: Ev[] }> {
  const empty = { upcoming: [], past: [] };
  if (!EVENTS_CSV) return empty;
  try {
    const url = EVENTS_CSV + ((EVENTS_CSV.includes("?") ? "&" : "?") + "_=" + Date.now());
    const res = await fetch(url, { cache: "no-store" });
    if (!res.ok) throw new Error(`sheet returned ${res.status}`);
    const rows = parseCSV(await res.text());
    if (rows.length < 2) return empty;

    const head = rows[0].map((h) => h.trim().toLowerCase());
    const find = (...n: string[]) => head.findIndex((h) => n.some((x) => h.startsWith(x)));

    // A Japanese column is any header mentioning Japanese / 日本語, e.g.
    // "Notes (Japanese)". Falls back to the next column along if the header
    // is blank or a duplicate, which is how the sheets were first written.
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

    const iN = find("event", "name"), iD = find("date"), iE = find("finish", "end"),
          iL = find("location"), iX = find("note");
    const jN = jaFor(iN, "event", "name"), jL = jaFor(iL, "location"), jX = jaFor(iX, "note");

    const cell = (r: string[], i: number) => (i >= 0 ? (r[i] ?? "").trim() : "");

    const t = todayTokyo(), up: Ev[] = [], past: Ev[] = [];
    for (const r of rows.slice(1)) {
      const start = parseDate(r[iD] ?? "");
      const name = (r[iN] ?? "").trim();
      if (!start || !name) continue;
      const end = iE >= 0 ? parseDate(r[iE] ?? "") : null;
      const ev: Ev = {
        name, nameJa: cell(r, jN) || name,
        y: start.y, m: start.m, d: start.d,
        location: cell(r, iL),
        locationJa: cell(r, jL) || cell(r, iL),
        notes: cell(r, iX),
        notesJa: cell(r, jX) || cell(r, iX),
        ...(end ? { endY: end.y, endM: end.m, endD: end.d } : {}),
      };
      // an event counts as upcoming until its finish date has passed
      const last = end ?? start;
      (key(last) >= key(t) ? up : past).push(ev);
    }
    up.sort((a, b) => key(a) - key(b));
    past.sort((a, b) => key(b) - key(a));
    return { upcoming: up, past };
  } catch (err) {
    console.warn("[events] could not load the events sheet:", err);
    return empty;
  }
}
