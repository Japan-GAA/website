#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/lib src/components src/pages/ja

cat > src/lib/events.ts <<'EOF'
// Club events (not training), read from a published Google Sheet tab.
// Columns: Event Name | Date | Finish Date (if different) | Location | Notes
export const EVENTS_CSV = "";   // <-- paste the published CSV link for the events tab

export type Ev = {
  name: string; notes: string; location: string;
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
    const iN = find("event", "name"), iD = find("date"), iE = find("finish", "end"),
          iL = find("location"), iX = find("note");

    const t = todayTokyo(), up: Ev[] = [], past: Ev[] = [];
    for (const r of rows.slice(1)) {
      const start = parseDate(r[iD] ?? "");
      const name = (r[iN] ?? "").trim();
      if (!start || !name) continue;
      const end = iE >= 0 ? parseDate(r[iE] ?? "") : null;
      const ev: Ev = {
        name, y: start.y, m: start.m, d: start.d,
        location: iL >= 0 ? (r[iL] ?? "").trim() : "",
        notes: iX >= 0 ? (r[iX] ?? "").trim() : "",
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
EOF

cat > src/components/EventList.astro <<'EOF'
---
import type { Ev } from "../lib/events";
const { events, lang = "en", past = false } = Astro.props;
const ja = lang === "ja";

const M_EN = ["January","February","March","April","May","June","July","August","September","October","November","December"];
const when = (e: Ev) => {
  const one = (y: number, m: number, d: number) => ja ? `${y}年${m}月${d}日` : `${d} ${M_EN[m-1]} ${y}`;
  if (e.endY === undefined) return one(e.y, e.m, e.d);
  if (e.y === e.endY && e.m === e.endM)
    return ja ? `${e.y}年${e.m}月${e.d}〜${e.endD}日` : `${e.d}–${e.endD} ${M_EN[e.m-1]} ${e.y}`;
  return `${one(e.y, e.m, e.d)} – ${one(e.endY!, e.endM!, e.endD!)}`;
};
const isUrl = (s: string) => /^https?:\/\//.test(s);
---
<ul class:list={["events", past && "events--past"]}>
  {events.map((e: Ev) => (
    <li class="event">
      <div class="event__when">{when(e)}</div>
      <div class="event__body">
        <h3>{e.name}</h3>
        {e.location && (
          <p class="event__where">
            {isUrl(e.location)
              ? <a href={e.location} target="_blank" rel="noopener">{ja ? "地図を見る" : "See the map"}</a>
              : e.location}
          </p>
        )}
        {!past && e.notes && <p class="event__notes">{e.notes}</p>}
      </div>
    </li>
  ))}
</ul>
EOF

cat > src/pages/events.astro <<'EOF'
---
import Base from "../layouts/Base.astro";
import EventList from "../components/EventList.astro";
import { clubEvents } from "../lib/events";
const { upcoming, past } = await clubEvents();
---
<Base lang="en" pageKey="events"
  title="Events — Japan GAA"
  description="Tournaments, socials and everything else Japan GAA gets up to beyond weekly training in Tokyo.">
  <div class="wrap prose">
    <header class="pagehead">
      <h1>Events</h1>
      <p class="hero__lede">
        Tournaments, socials and everything else that isn't a Tuesday at the park.
        Everyone is welcome at these, members or not.
      </p>
    </header>

    <h2>Coming up</h2>
    {upcoming.length
      ? <EventList events={upcoming} lang="en" />
      : <p>Nothing on the calendar right now. <a href="https://www.instagram.com/japangaa" target="_blank" rel="noopener">Instagram</a> has the latest.</p>}

    {past.length > 0 && (
      <>
        <h2>Previously</h2>
        <EventList events={past} lang="en" past />
      </>
    )}

    <p><a class="cta" href="mailto:japangaa@gmail.com">Ask us about an event</a></p>
  </div>
</Base>
EOF

cat > src/pages/ja/events.astro <<'EOF'
---
import Base from "../../layouts/Base.astro";
import EventList from "../../components/EventList.astro";
import { clubEvents } from "../../lib/events";
const { upcoming, past } = await clubEvents();
---
<Base lang="ja" pageKey="events"
  title="イベント — Japan GAA"
  description="大会や交流イベントなど、毎週の練習以外のJapan GAAの活動をご紹介します。">
  <div class="wrap prose">
    <header class="pagehead">
      <h1>イベント</h1>
      <p class="hero__lede">
        大会や交流イベントなど、練習以外の活動です。会員でなくても、どなたでも
        ご参加いただけます。
      </p>
    </header>

    <h2>今後の予定</h2>
    {upcoming.length
      ? <EventList events={upcoming} lang="ja" />
      : <p>現在、予定されているイベントはありません。最新情報は <a href="https://www.instagram.com/japangaa" target="_blank" rel="noopener">Instagram</a> をご覧ください。</p>}

    {past.length > 0 && (
      <>
        <h2>これまでの活動</h2>
        <EventList events={past} lang="ja" past />
      </>
    )}

    <p><a class="cta" href="mailto:japangaa@gmail.com">イベントについて問い合わせる</a></p>
  </div>
</Base>
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- events ---- */
.events { list-style: none; padding: 0; margin: 1.25rem 0 2.5rem; }
.event {
  display: grid; gap: 0.25rem 1.5rem; grid-template-columns: 1fr;
  padding: 1.1rem 0; border-top: 1px solid var(--line);
}
.event:last-child { border-bottom: 1px solid var(--line); }
@media (min-width: 40rem) { .event { grid-template-columns: 11rem 1fr; } }
.event__when {
  font-family: var(--display); font-weight: 700; color: var(--pitch);
  font-size: 0.9375rem;
}
.event__body h3 { font-size: 1.0625rem; margin: 0 0 0.2rem; letter-spacing: 0; }
.event__where { font-size: 0.875rem; margin: 0 0 0.35rem; color: var(--vermilion); }
.event__where a { color: var(--vermilion); }
.event__notes { font-size: 0.9375rem; margin: 0; color: #3a4b43; max-width: 44ch; }
.events--past .event { padding: 0.7rem 0; }
.events--past .event__when,
.events--past .event__body h3 { color: var(--stone); font-weight: 500; }
EOF

echo
echo "Paste the events tab CSV link into EVENTS_CSV in src/lib/events.ts"
npm run build 2>&1 | tail -4
