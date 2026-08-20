#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat > src/lib/sessions.ts <<'EOF'
// Training sessions, read from a published Google Sheet tab at build time.
// Columns: Date | Start time | Finish time | Location (if not Yashiokita park)
//
// Everything here is treated as Tokyo wall-clock time and never converted to a
// Date object, so the build machine's timezone can't shift anything.
export const SESSIONS_CSV = "";   // <-- paste the published CSV link for the training tab

export type Session = {
  y: number; m: number; d: number;
  start: string; end: string; location: string;
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
    const res = await fetch(SESSIONS_CSV);
    if (!res.ok) throw new Error(`sheet returned ${res.status}`);
    const rows = parseCSV(await res.text());
    if (rows.length < 2) return [];

    const head = rows[0].map((h) => h.trim().toLowerCase());
    const find = (...names: string[]) =>
      head.findIndex((h) => names.some((n) => h.startsWith(n)));
    const iD = find("date"), iS = find("start"), iF = find("finish", "end"), iL = find("location");

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
      });
    }
    return out.sort((a, b) => key(a) - key(b)).slice(0, limit);
  } catch (err) {
    console.warn("[sessions] could not load the training sheet:", err);
    return [];
  }
}

export { tidyTime };
EOF

cat > src/components/Sessions.astro <<'EOF'
---
import { upcomingSessions, tidyTime } from "../lib/sessions";
const { lang = "en" } = Astro.props;
const sessions = await upcomingSessions();
const ja = lang === "ja";

const DAYS_EN = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
const DAYS_JA = ["日","月","火","水","木","金","土"];
const MONTHS  = ["January","February","March","April","May","June","July","August","September","October","November","December"];

const dayName = (s) => new Date(Date.UTC(s.y, s.m - 1, s.d)).getUTCDay();

const label = (s) => ja
  ? `${s.m}月${s.d}日（${DAYS_JA[dayName(s)]}）`
  : `${DAYS_EN[dayName(s)]}, ${s.d} ${MONTHS[s.m - 1]}`;

const clock = (v) => {
  const t = tidyTime(v);
  if (typeof t === "string") return t;
  if (ja) return t.min ? `${t.h}:${String(t.min).padStart(2,"0")}` : `${t.h}時`;
  return `${t.h % 12 || 12}${t.min ? ":" + String(t.min).padStart(2,"0") : ""}${t.h < 12 ? "am" : "pm"}`;
};

const range = (s) => {
  if (!s.end) return clock(s.start);
  const a = tidyTime(s.start), b = tidyTime(s.end);
  if (typeof a === "string" || typeof b === "string") return `${clock(s.start)}–${clock(s.end)}`;
  if (ja) return `${clock(s.start)}〜${clock(s.end)}`;
  const suf = (h) => (h < 12 ? "am" : "pm");
  const bare = (t) => `${t.h % 12 || 12}${t.min ? ":" + String(t.min).padStart(2,"0") : ""}`;
  return suf(a.h) === suf(b.h) ? `${bare(a)}–${bare(b)}${suf(b.h)}` : `${clock(s.start)}–${clock(s.end)}`;
};
---
{sessions.length > 0 ? (
  <ul class="sessions">
    {sessions.map((s) => (
      <li>
        <span class="sessions__date">
          {label(s)}
          {s.location && <em class="sessions__where"> · {s.location}</em>}
        </span>
        <span class="sessions__time">{range(s)}</span>
      </li>
    ))}
  </ul>
) : (
  <p>
    {ja
      ? "次回の日程は Instagram をご覧いただくか、お問い合わせください。"
      : "Check Instagram or get in touch for the next session."}
  </p>
)}
EOF

cat >> src/styles/global.css <<'EOF'
.sessions__where { font-style: normal; color: var(--vermilion); font-size: 0.875em; }
EOF

echo
echo "Now paste the published CSV link for the training tab into SESSIONS_CSV in src/lib/sessions.ts"
npm run build 2>&1 | tail -4
