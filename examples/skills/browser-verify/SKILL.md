---
name: browser-verify
description: How to verify frontend/UI changes in a REAL browser (headless Chrome screenshot) instead of trusting lint/build/API-shape alone. Invoke before merging/deploying any web/ change that alters what the user sees — charts, overlays, layout, styling, new UI. Covers the reporter local passwordless-web setup (port 43100), the exact headless-Chrome screenshot command, the timing pitfalls, and when a screenshot is required vs optional.
---

# Browser Verification (reporter)

Lint + build + API-shape checks do NOT prove the UI renders correctly. For any `web/` change that alters **what the user sees**, capture a real-browser screenshot and inspect it before claiming done or deploying. "It builds" ≠ "it looks right" — several UI regressions this project shipped passed lint/build but were visually broken.

## When a screenshot is REQUIRED
- New or changed chart / overlay / canvas rendering (lightweight-charts etc.)
- Layout, styling, spacing, color, or component-structure changes
- Anything where the bug class is "renders wrong" not "wrong data"

## When it's optional (data-shape checks suffice)
- Pure copy/text changes, or changes where a `curl` of the API response fully confirms correctness
- Backend-only changes with no `web/` diff

## Setup — local passwordless web on 43100

Production web (43000) sits behind a login gate (307 redirect), so headless Chrome can't reach pages. Run a local instance with the gate open (`middleware.ts` opens it when `LOGIN_PASSWORD` is unset):

```bash
cd /Users/iljoyoo/workspace/reporter/web
LOGIN_PASSWORD= nohup pnpm run start -p 43100 > /tmp/web43100.log 2>&1 &
sleep 8   # wait for Next to boot
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:43100/   # expect 200
```

The local web proxies API calls to `127.0.0.1:8010` (the launchd `com.reporter.server.api`). **Build first** — `pnpm run start` serves the prebuilt `.next`, so run `pnpm run build` after code changes before starting.

## Warm the API, then screenshot

Headless Chrome renders the page but client-side fetches (analysis polling, `/trend`, `/chart`) can lag. **Warm every endpoint the page hits first**, then screenshot:

```bash
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
CODE=071200
for ep in trend analysis growth financials peers; do
  curl -s -o /dev/null "http://localhost:8010/api/companies/$CODE/$ep"; done
curl -s -o /dev/null "http://localhost:8010/api/chart?symbol=$CODE&market=KR&tf=day"

nohup "$CHROME" --headless --disable-gpu --no-sandbox --hide-scrollbars \
  --window-size=1400,3600 --force-device-scale-factor=1 \
  --screenshot="$CLAUDE_JOB_DIR/tmp/shot.png" \
  "http://localhost:43100/companies/$CODE" > /dev/null 2>&1 &
CPID=$!; sleep 40; kill $CPID 2>/dev/null; sleep 1
```

Then crop to the region of interest with PIL and Read the PNG:

```bash
python3 -c "from PIL import Image; Image.open('$CLAUDE_JOB_DIR/tmp/shot.png').crop((160,1180,1240,1760)).save('$CLAUDE_JOB_DIR/tmp/crop.png')"
```
Read the cropped PNG to inspect it. Screenshots go under `$CLAUDE_JOB_DIR/tmp` (never `/tmp`).

## Pitfalls (learned the hard way)
- **`--virtual-time-budget` + `--dump-dom` yields 0 bytes** on polling pages. Use a plain `--screenshot` with a background process + `sleep` + `kill`, not `--timeout`/`--dump-dom`.
- **Charts still show a loading state** even after 40s if the API wasn't warmed, or if the client retries slowly. Warm endpoints first; if still loading, the issue is client fetch timing (a test-harness limitation), not necessarily a product bug — fall back to confirming the API payload via `curl` and trust the (mechanically unchanged) render path.
- **A tall page shifts the target's Y-offset** as sections load. Screenshot the full `--window-size` height (e.g. 3600px) then crop, rather than guessing coordinates.
- Kill the local 43100 web when done: `lsof -ti :43100 | xargs kill`.

## Honesty rule
If headless rendering can't be made to resolve (fetch hangs in the harness), say so explicitly in the PR/summary — mark browser verification as "not done, confirmed via API payload + unchanged render path" and ask the user to eyeball it. Never claim visual verification you didn't actually perform.
