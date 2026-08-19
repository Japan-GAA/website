#!/usr/bin/env bash
set -euo pipefail
[ -f astro.config.mjs ] || { echo "Run this from ~/website"; exit 1; }

python3 - <<'PY'
import pathlib

en = pathlib.Path("src/pages/training.astro"); s = en.read_text()
s = s.replace('''      <p><strong>Your first session is free.</strong> Come along, try it, and decide afterwards.</p>
      <!-- TODO: how to pay — cash on the day, bank transfer, PayPay? -->''',
'''      <p class="callout">
        <strong>Coming for the first time? There's nothing to pay and nothing to
        arrange.</strong> Your first session is free — just turn up.
      </p>
      <p class="muted">
        When you do join, you can pay by cash on the day, bank transfer, or PayPay.
      </p>''')
en.write_text(s)

ja = pathlib.Path("src/pages/ja/training.astro"); s = ja.read_text()
s = s.replace('''      <p><strong>初回参加は無料です。</strong>まず一度体験してから、ご検討ください。</p>
      <!-- TODO: 支払い方法 -->''',
'''      <p class="callout">
        <strong>初めての方は、お支払いも事前のお手続きも必要ありません。</strong>
        初回参加は無料です。そのままお越しください。
      </p>
      <p class="muted">
        ご入会後のお支払いは、当日現金・銀行振込・PayPay からお選びいただけます。
      </p>''')
ja.write_text(s)
print("payment added to both pages")
PY

cat >> src/styles/global.css <<'EOF'

.callout {
  border-left: 3px solid var(--vermilion);
  padding: 0.9rem 0 0.9rem 1.25rem;
  margin-block: 1.75rem 0.75rem;
  font-size: 1.0625rem;
}
.muted { color: var(--stone); font-size: 0.9375rem; }
EOF

echo "Done. Run: npm run dev"
