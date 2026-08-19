#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
fails = []

# ---- 1. drop the intro paragraph on both committee pages -----------------
for path in ("src/pages/committee.astro", "src/pages/ja/committee.astro"):
    p = pathlib.Path(path)
    if not p.exists(): fails.append(f"{path} missing"); continue
    s = p.read_text()
    s2, n = re.subn(r'\s*<p class="hero__lede">.*?</p>', "", s, count=1, flags=re.S)
    if n == 0: fails.append(f"{path}: intro paragraph"); continue
    p.write_text(s2); print("  ok  ", path, "intro removed")

# ---- 2. one name per line in the roster ----------------------------------
for path in ("src/pages/committee.astro", "src/pages/ja/committee.astro"):
    p = pathlib.Path(path)
    if not p.exists(): continue
    s = p.read_text()
    old_en = '<span class="roster__name">{r.people.join(" · ")}</span>'
    old_ja = '<span class="roster__name">{r.people.join(" ・ ")}</span>'
    new = ('<span class="roster__names">\n'
           '            {r.people.map((n) => <span class="roster__name">{n}</span>)}\n'
           '          </span>')
    if old_en in s: s = s.replace(old_en, new)
    elif old_ja in s: s = s.replace(old_ja, new)
    else:
        fails.append(f"{path}: roster names"); continue
    p.write_text(s); print("  ok  ", path, "names stacked")

if fails:
    print("\nNOT APPLIED:")
    for f in fails: print("  !!", f)
PY

cat >> src/styles/global.css <<'EOF'

/* Committee roster: one name per line, so pairs don't wrap awkwardly. */
.roster__names { display: flex; flex-direction: column; align-items: flex-end; gap: 0.15rem; }
.roster li { align-items: baseline; }
@media (max-width: 30rem) {
  .roster li { flex-direction: column; gap: 0.35rem; }
  .roster__names { align-items: flex-start; }
  .roster__role { align-self: flex-start; }
}
EOF

echo
npm run build 2>&1 | tail -5
