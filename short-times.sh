#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat > src/components/Sessions.astro <<'EOF'
---
import { upcomingSessions } from "../lib/calendar";
const { lang = "en" } = Astro.props;
const sessions = await upcomingSessions();

const TZ = "Asia/Tokyo";
const locale = lang === "ja" ? "ja-JP" : "en-IE";

const day = (d: Date) =>
  d.toLocaleDateString(locale, { timeZone: TZ, weekday: "long", month: "long", day: "numeric" });

// Read the wall-clock hour/minute in Tokyo, whatever timezone the build runs in.
const hm = (d: Date) => {
  const [h, m] = new Intl.DateTimeFormat("en-GB", {
    timeZone: TZ, hour: "2-digit", minute: "2-digit", hour12: false,
  }).format(d).split(":").map(Number);
  return { h, m };
};

// "7–9pm", "7:30–9pm", "11am–1pm"   /   "19時〜21時", "19:30〜21:00"
const range = (start: Date, end?: Date) => {
  const a = hm(start);
  const b = end ? hm(end) : null;

  if (lang === "ja") {
    const one = ({ h, m }: { h: number; m: number }) =>
      m ? `${h}:${String(m).padStart(2, "0")}` : `${h}時`;
    return b ? `${one(a)}〜${one(b)}` : one(a);
  }

  const suffix = (h: number) => (h < 12 ? "am" : "pm");
  const clock = ({ h, m }: { h: number; m: number }) =>
    `${h % 12 || 12}${m ? ":" + String(m).padStart(2, "0") : ""}`;

  if (!b) return `${clock(a)}${suffix(a.h)}`;
  return suffix(a.h) === suffix(b.h)
    ? `${clock(a)}–${clock(b)}${suffix(b.h)}`
    : `${clock(a)}${suffix(a.h)}–${clock(b)}${suffix(b.h)}`;
};
---
{sessions.length > 0 ? (
  <ul class="sessions">
    {sessions.map((s) => (
      <li>
        <span class="sessions__date">{day(s.start)}</span>
        <span class="sessions__time">{range(s.start, s.end)}</span>
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

echo "Sessions.astro rewritten — npm run dev"
