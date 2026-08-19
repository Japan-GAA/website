#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

cat > src/components/Facts.astro <<'EOF'
---
const { lang = "en" } = Astro.props;
const facts = lang === "ja"
  ? [
      { n: "1995",  l: "日本支部 設立" },
      { n: "2+",    l: "年間の国際大会" },
      { n: "無料",  l: "初回参加" },
      { n: "40回",  l: "年間の練習回数" },
    ]
  : [
      { n: "1995",  l: "Founded in Japan" },
      { n: "2+",    l: "International tournaments a year" },
      { n: "Free",  l: "First session" },
      { n: "40",    l: "Sessions a year" },
    ];
---
<section class="facts">
  <div class="wrap facts__grid">
    {facts.map((f) => (
      <div class="facts__item">
        <span class="facts__n">{f.n}</span>
        <span class="facts__l">{f.l}</span>
      </div>
    ))}
  </div>
</section>
EOF

# undo the flat-statement styling appended by facts.sh
python3 - <<'PY'
import pathlib, re
p = pathlib.Path("src/styles/global.css"); s = p.read_text()
s2, n = re.subn(r"\n/\* Fact strip: four equal statements.*?border-top: 2px solid var\(--vermilion\);\n\}\n", "\n", s, flags=re.S)
p.write_text(s2)
print("removed override block" if n else "!! override block not found — check the end of global.css")
PY

echo
npm run build 2>&1 | tail -5
