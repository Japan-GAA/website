#!/usr/bin/env bash
# Drops the Sessions component into both training pages and wires up .env
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

ICS='https://calendar.google.com/calendar/ical/89fd7190dca3c1ae6079e488f944440e6a4f11f7c9cb9c00febde89b450e81fe%40group.calendar.google.com/public/basic.ics'

# .env for local dev; never committed
grep -q '^\.env$' .gitignore 2>/dev/null || echo '.env' >> .gitignore
if grep -q '^TRAINING_ICS=' .env 2>/dev/null; then
  echo ".env already has TRAINING_ICS — leaving it alone"
else
  echo "TRAINING_ICS=$ICS" >> .env
  echo "wrote TRAINING_ICS to .env"
fi

python3 - <<'PY'
import pathlib, sys

def patch(path, imp, old, new):
    p = pathlib.Path(path)
    if not p.exists():
        sys.exit(f"missing {path}")
    s = p.read_text()
    if "Sessions" not in s.split("---")[1]:
        s = s.replace("---\nimport Base", f"---\nimport Sessions from \"{imp}\";\nimport Base", 1)
    if old not in s:
        sys.exit(f"couldn't find the 'When' block in {path} — has it been edited?")
    p.write_text(s.replace(old, new))
    print("patched", path)

patch(
  "src/pages/training.astro",
  "../components/Sessions.astro",
'''      <div class="fact">
        <h2>When</h2>
        <p class="fact__big">7:00 – 9:00 pm</p>
        <p>
          The day of the week changes from session to session, so check
          <a href="https://www.instagram.com/japangaa">Instagram</a> or ask us
          for the next date.
        </p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>''',
'''      <div class="fact">
        <h2>Next sessions</h2>
        <Sessions lang="en" />
        <p class="muted">
          Sessions run 7–9pm. The day of the week changes, so check back here or
          on <a href="https://www.instagram.com/japangaa">Instagram</a>.
        </p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>''')

patch(
  "src/pages/ja/training.astro",
  "../../components/Sessions.astro",
'''      <div class="fact">
        <h2>日時</h2>
        <p class="fact__big">19:00 – 21:00</p>
        <p>
          曜日は回によって変わります。次回の日程は
          <a href="https://www.instagram.com/japangaa">Instagram</a>
          をご覧いただくか、お気軽にお問い合わせください。
        </p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>''',
'''      <div class="fact">
        <h2>次回の練習</h2>
        <Sessions lang="ja" />
        <p class="muted">
          練習は 19:00〜21:00 です。曜日は回によって変わりますので、
          こちらのページまたは
          <a href="https://www.instagram.com/japangaa">Instagram</a>
          をご確認ください。
        </p>
        <p><a href="mailto:japangaa@gmail.com">japangaa@gmail.com</a></p>
      </div>''')
PY

echo
echo "Local test:  npm run dev  ->  http://localhost:4321/training"
echo "Then add TRAINING_ICS in Cloudflare: project -> Settings -> Variables and Secrets"
