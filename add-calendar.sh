#!/usr/bin/env bash
# Pulls upcoming training sessions from a public Google Calendar at build time.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }
mkdir -p src/lib src/components .github/workflows

npm install node-ical --save

cat > src/lib/calendar.ts <<'EOF'
import ical from "node-ical";

// Public iCal address of the Japan GAA "Training" calendar.
// Google Calendar -> Settings -> Integrate calendar -> Public address in iCal format
export const ICS_URL = import.meta.env.TRAINING_ICS ?? "";

export type Session = { start: Date; end?: Date; title: string; location?: string };

/**
 * Upcoming sessions, soonest first. Never throws — if the calendar is
 * unreachable or unset the page falls back to "check Instagram", so a
 * Google outage can't break the build.
 */
export async function upcomingSessions(limit = 4): Promise<Session[]> {
  if (!ICS_URL) return [];
  try {
    const data = await ical.async.fromURL(ICS_URL);
    const now = new Date();
    const out: Session[] = [];

    for (const item of Object.values(data) as any[]) {
      if (item.type !== "VEVENT") continue;

      // expand recurring events for the next six months
      if (item.rrule) {
        const until = new Date(now.getTime() + 1000 * 60 * 60 * 24 * 182);
        for (const d of item.rrule.between(now, until, true)) {
          out.push({ start: d, title: item.summary ?? "Training", location: item.location });
        }
      } else if (item.start && new Date(item.start) >= now) {
        out.push({
          start: new Date(item.start),
          end: item.end ? new Date(item.end) : undefined,
          title: item.summary ?? "Training",
          location: item.location,
        });
      }
    }
    return out.sort((a, b) => a.start.valueOf() - b.start.valueOf()).slice(0, limit);
  } catch (err) {
    console.warn("[calendar] could not load training calendar:", err);
    return [];
  }
}
EOF

cat > src/components/Sessions.astro <<'EOF'
---
import { upcomingSessions } from "../lib/calendar";
const { lang = "en" } = Astro.props;
const sessions = await upcomingSessions();
const locale = lang === "ja" ? "ja-JP" : "en-IE";
const day  = (d: Date) => d.toLocaleDateString(locale, { weekday: "long", month: "long", day: "numeric" });
const time = (d: Date) => d.toLocaleTimeString(locale, { hour: "2-digit", minute: "2-digit", hour12: lang !== "ja" });
---
{sessions.length > 0 ? (
  <ul class="sessions">
    {sessions.map((s) => (
      <li>
        <span class="sessions__date">{day(s.start)}</span>
        <span class="sessions__time">{time(s.start)}{s.end && `–${time(s.end)}`}</span>
      </li>
    ))}
  </ul>
) : (
  <p>
    {lang === "ja"
      ? "次回の日程は Instagram をご覧いただくか、お問い合わせください。"
      : "Check Instagram or get in touch for the next session."}
  </p>
)}
EOF

cat > .github/workflows/daily-rebuild.yml <<'EOF'
# Rebuilds the site once a day so newly added training sessions appear.
# Requires repository secret CF_DEPLOY_HOOK (Cloudflare -> project -> Settings
# -> Builds -> Deploy hooks).
name: Daily rebuild

on:
  schedule:
    - cron: "0 20 * * *"   # 05:00 JST
  workflow_dispatch:        # lets anyone trigger it by hand from the Actions tab

jobs:
  rebuild:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Cloudflare build
        run: curl -fsS -X POST "${{ secrets.CF_DEPLOY_HOOK }}"
EOF

cat >> src/styles/global.css <<'EOF'

/* ---- upcoming sessions ---- */
.sessions { list-style: none; margin: 0 0 0.75rem; padding: 0; }
.sessions li {
  display: flex; justify-content: space-between; gap: 1rem;
  padding: 0.5rem 0; border-bottom: 1px solid var(--line);
  font-size: 0.9375rem;
}
.sessions li:last-child { border-bottom: 0; }
.sessions__date { font-weight: 500; }
.sessions__time { color: var(--pitch); font-family: var(--display); font-weight: 700; }
EOF

echo
echo "Now do three things:"
echo "  1. echo 'TRAINING_ICS=<your public iCal URL>' >> .env"
echo "  2. Add TRAINING_ICS as a build variable in Cloudflare (Settings -> Variables)"
echo "  3. Add CF_DEPLOY_HOOK as a GitHub Actions secret"
