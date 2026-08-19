import ical from "node-ical";

// Public iCal address of the Japan GAA "Training" calendar.
// Google Calendar -> Settings -> Integrate calendar -> Public address in iCal format
export const ICS_URL =
  import.meta.env.TRAINING_ICS ??
  "https://calendar.google.com/calendar/ical/89fd7190dca3c1ae6079e488f944440e6a4f11f7c9cb9c00febde89b450e81fe%40group.calendar.google.com/public/basic.ics";

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
