#!/usr/bin/env bash
# Find Japanese columns by header name rather than by position,
# so the sheet columns can be reordered freely.
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib, re

HELPER = '''
    // A Japanese column is any header mentioning Japanese / 日本語, e.g.
    // "Notes (Japanese)". Falls back to the next column along if the header
    // is blank or a duplicate, which is how the sheets were first written.
    const jaFor = (i: number, ...words: string[]) => {
      const byName = head.findIndex(
        (h) => words.some((w) => h.includes(w)) && /japan|日本/.test(h)
      );
      if (byName >= 0 && byName !== i) return byName;
      if (i < 0) return -1;
      const next = head[i + 1];
      if (next === undefined) return -1;
      return next === "" || next === head[i] ? i + 1 : -1;
    };
'''

# ---- events.ts ----------------------------------------------------------
p = pathlib.Path("src/lib/events.ts"); s = p.read_text()
s = re.sub(r"\n    // The Japanese column sits immediately.*?\n    \};\n", HELPER, s, flags=re.S)
s = s.replace("const jN = jaOf(iN), jL = jaOf(iL), jX = jaOf(iX);",
              'const jN = jaFor(iN, "event", "name"), jL = jaFor(iL, "location"), jX = jaFor(iX, "note");')
p.write_text(s); print("  ok   events.ts")

# ---- sessions.ts --------------------------------------------------------
p = pathlib.Path("src/lib/sessions.ts"); s = p.read_text()
s = re.sub(r"\n    // The Japanese location sits in the next column.*?\? iL \+ 1 : -1;\n",
'''
    const jaFor = (i: number, ...words: string[]) => {
      const byName = head.findIndex(
        (h) => words.some((w) => h.includes(w)) && /japan|日本/.test(h)
      );
      if (byName >= 0 && byName !== i) return byName;
      if (i < 0) return -1;
      const next = head[i + 1];
      if (next === undefined) return -1;
      return next === "" || next === head[i] ? i + 1 : -1;
    };
    const iLJa = jaFor(iL, "location");
''', s, flags=re.S)
p.write_text(s); print("  ok   sessions.ts")
PY

echo
npm run build 2>&1 | tail -4
