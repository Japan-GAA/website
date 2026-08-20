#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/lib/events.ts"); s = p.read_text()

s = re.sub(r"export type Ev = \{.*?\};",
'''export type Ev = {
  name: string; nameJa: string;
  notes: string; notesJa: string;
  location: string; locationJa: string;
  y: number; m: number; d: number;
  endY?: number; endM?: number; endD?: number;
};''', s, flags=re.S)

s = re.sub(r"    const head = rows\[0\].*?\n    const t = todayTokyo\(\), up: Ev\[\] = \[\], past: Ev\[\] = \[\];",
'''    const head = rows[0].map((h) => h.trim().toLowerCase());
    const find = (...n: string[]) => head.findIndex((h) => n.some((x) => h.startsWith(x)));

    // The Japanese column sits immediately after its English one. Its header may
    // be blank, a duplicate of the English header, or mention Japanese.
    const jaOf = (i: number) => {
      if (i < 0) return -1;
      const next = head[i + 1];
      if (next === undefined) return -1;
      const looksJa = next === "" || next === head[i] || /japan|日本/.test(next);
      return looksJa ? i + 1 : -1;
    };

    const iN = find("event", "name"), iD = find("date"), iE = find("finish", "end"),
          iL = find("location"), iX = find("note");
    const jN = jaOf(iN), jL = jaOf(iL), jX = jaOf(iX);

    const cell = (r: string[], i: number) => (i >= 0 ? (r[i] ?? "").trim() : "");

    const t = todayTokyo(), up: Ev[] = [], past: Ev[] = [];''', s, flags=re.S)

s = re.sub(r"      const ev: Ev = \{.*?\n      \};",
'''      const ev: Ev = {
        name, nameJa: cell(r, jN) || name,
        y: start.y, m: start.m, d: start.d,
        location: cell(r, iL),
        locationJa: cell(r, jL) || cell(r, iL),
        notes: cell(r, iX),
        notesJa: cell(r, jX) || cell(r, iX),
        ...(end ? { endY: end.y, endM: end.m, endD: end.d } : {}),
      };''', s, flags=re.S)

p.write_text(s); print("  ok   events.ts")
PY

python3 - <<'PY'
import pathlib
p = pathlib.Path("src/components/EventList.astro"); s = p.read_text()
s = s.replace("<h3>{e.name}</h3>", "<h3>{ja ? e.nameJa : e.name}</h3>")
s = s.replace("{e.location && (", "{(ja ? e.locationJa : e.location) && (")
s = s.replace("""            {isUrl(e.location)
              ? <a href={e.location} target="_blank" rel="noopener">{ja ? "地図を見る" : "See the map"}</a>
              : e.location}""",
"""            {isUrl(ja ? e.locationJa : e.location)
              ? <a href={ja ? e.locationJa : e.location} target="_blank" rel="noopener">{ja ? "地図を見る" : "See the map"}</a>
              : (ja ? e.locationJa : e.location)}""")
s = s.replace("{!past && e.notes && <p class=\"event__notes\">{e.notes}</p>}",
              "{!past && (ja ? e.notesJa : e.notes) && <p class=\"event__notes\">{ja ? e.notesJa : e.notes}</p>}")
p.write_text(s); print("  ok   EventList.astro")
PY

echo
npm run build 2>&1 | tail -4
