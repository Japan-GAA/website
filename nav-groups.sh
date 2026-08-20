#!/usr/bin/env bash
# Groups the nav into dropdowns: Events (Training, Events) and The club (Committee, History).
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/consts.js"); s = p.read_text()

# add the events page if it isn't declared yet
if '"events"' not in s:
    line = '  { key: "events",   en: "/events",          ja: "/ja/events",          labelEn: "Events",    labelJa: "イベント" },\n'
    s = s.replace('  { key: "sport",', line + '  { key: "sport",')

# nav structure: groups of page keys
if "export const NAV" not in s:
    s = s.rstrip() + '''

// Top-level navigation. A group with more than one child becomes a dropdown.
export const NAV = [
  { labelEn: "Events",    labelJa: "活動",       children: ["training", "events"] },
  { labelEn: "The sport", labelJa: "競技について", children: ["sport"] },
  { labelEn: "News",      labelJa: "ニュース",   children: ["news"] },
  { labelEn: "The club",  labelJa: "クラブ",     children: ["club", "history"] },
  { labelEn: "Jerseys",   labelJa: "ジャージ",   children: ["jerseys"] },
];
'''
p.write_text(s); print("  ok   consts.js")
PY

python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/layouts/Base.astro"); s = p.read_text()

s = s.replace('import { SITE, PAGES } from "../consts.js";',
              'import { SITE, PAGES, NAV } from "../consts.js";')
s = re.sub(r"\nconst nav\s*=.*?\n", "\nconst page_for = (k) => PAGES.find((p) => p.key === k);\n", s, count=1)

new_nav = '''<nav class="nav" aria-label={lang === "ja" ? "メインナビゲーション" : "Main"}>
          {NAV.map((group) => {
            const kids = group.children.map(page_for).filter(Boolean);
            const label = lang === "ja" ? group.labelJa : group.labelEn;
            const active = kids.some((k) => here.replace(/\\/$/, "") === k[lang].replace(/\\/$/, ""));
            return kids.length === 1 ? (
              <a href={kids[0][lang]} aria-current={active ? "page" : undefined}>{label}</a>
            ) : (
              <div class="nav__group">
                <button type="button" class="nav__toggle" aria-expanded="false"
                        aria-current={active ? "page" : undefined}>
                  {label}<span class="nav__chev" aria-hidden="true">▾</span>
                </button>
                <ul class="nav__menu" hidden>
                  {kids.map((k) => (
                    <li><a href={k[lang]}>{lang === "ja" ? k.labelJa : k.labelEn}</a></li>
                  ))}
                </ul>
              </div>
            );
          })}
        </nav>'''

s2, n = re.subn(r'<nav class="nav".*?</nav>', new_nav, s, count=1, flags=re.S)
print("  ok   Base.astro nav" if n else "  !!   nav block not found")
if n:
    if "nav__toggle" not in s2.split("</body>")[1] if "</body>" in s2 else True:
        s2 = s2.replace("  </body>", '''    <script>
      // Click-to-open menus: hover doesn't work on touch screens.
      const groups = document.querySelectorAll(".nav__group");
      const closeAll = (except) => groups.forEach((g) => {
        if (g === except) return;
        g.querySelector(".nav__toggle").setAttribute("aria-expanded", "false");
        g.querySelector(".nav__menu").hidden = true;
      });
      groups.forEach((g) => {
        const btn = g.querySelector(".nav__toggle");
        const menu = g.querySelector(".nav__menu");
        btn.addEventListener("click", () => {
          const open = btn.getAttribute("aria-expanded") === "true";
          closeAll(g);
          btn.setAttribute("aria-expanded", String(!open));
          menu.hidden = open;
        });
      });
      document.addEventListener("click", (e) => {
        if (!e.target.closest(".nav__group")) closeAll();
      });
      document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") closeAll();
      });
    </script>
  </body>''')
    p.write_text(s2)
PY

cat >> src/styles/global.css <<'EOF'

/* ---- grouped navigation ---- */
.nav__group { position: relative; }
.nav__toggle {
  font: inherit; font-size: 0.9375rem; color: var(--ink);
  background: none; border: 0; cursor: pointer;
  padding: 0.25rem 0; border-bottom: 2px solid transparent;
  display: inline-flex; align-items: center; gap: 0.3rem;
}
.nav__toggle:hover,
.nav__toggle[aria-expanded="true"],
.nav__toggle[aria-current="page"] { border-bottom-color: var(--vermilion); }
.nav__chev { font-size: 0.7em; line-height: 1; }
.nav__toggle[aria-expanded="true"] .nav__chev { transform: rotate(180deg); }

.nav__menu {
  position: absolute; top: calc(100% + 0.5rem); left: 0; z-index: 20;
  list-style: none; margin: 0; padding: 0.4rem 0;
  background: var(--chalk); border: 1px solid var(--line); border-radius: 3px;
  min-width: 10rem; box-shadow: 0 6px 20px rgba(16,34,27,.09);
}
.nav__menu a {
  display: block; padding: 0.5rem 1rem; font-size: 0.9375rem;
  text-decoration: none; color: var(--ink); border: 0;
}
.nav__menu a:hover { background: var(--pitch); color: var(--chalk); }
EOF

echo
npm run build 2>&1 | tail -4
