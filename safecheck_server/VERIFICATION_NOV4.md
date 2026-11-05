# Local verification — 4 November 2026

Branch: `codex/safecheck-trip-review-nov2`. This records local source checks;
it does not certify a deployed build.

## Later live-provider verification

The private provider entries were found under `test:` and moved to the existing
`development:` mapping. Values were preserved, as were all unrelated database
and authentication settings. No credential or recipient value was displayed.

- Twilio read-only authentication returned HTTP 200. Recent inbound WhatsApp
  activity matched the configured sender and the single configured recipient.
- Exactly **one real WhatsApp submission** was attempted in an isolated fixture.
  Twilio returned **HTTP 400**. Delivery was not confirmed. A later read-only
  message lookup found no controlled-test message resource.
- Twilio's diagnostic-log endpoint returned HTTP 401, so its numeric rejection
  code remains to be obtained privately from the Console. No resend was made.
- Exactly **one Meta incident-summary inference request** was attempted. It hit
  the existing eight-second timeout; successful AI summary generation remains
  unverified. No inference retry was made.
- A separate **read-only** model-metadata request returned HTTP 200 and confirmed
  access to the configured model. This validates key/model access without an
  additional inference. It does not establish that generation fits eight seconds.
- The real attempt retained the standard brief and preserved its facts and
  uncertainties after the timeout.
- A subsequent isolated **offline replay made zero provider requests** and
  passed every check: missed trip, one incident, failed notification record,
  standard-summary fallback, preserved facts/uncertainties, private incident
  view, owner resolution, and no repeated dispatch/enrichment after retries.
- The reusable live-test preflight now supports the account's configured
  WhatsApp test sender after verifying matching inbound activity. Twilio UTC
  timestamps with a numeric offset are normalized for Dart's HTTP-date parser.
  Three new timestamp regression tests passed. Failure count assertions avoid
  printing message rows, and rejected submissions can report a numeric provider
  error code without copying the provider's raw response.
- After those test-harness corrections, whole-workspace analysis again reported
  no issues; formatting and the scoped diff check passed. Recent backend logs
  showed successful sweeps and no new backend errors.

Live delivery and an AI-generated incident brief are **not verified successes**.
The one-submission/one-inference budget was respected. No app deployment, merge,
data reset or migration change was performed. The fixture did not alter normal
application trip/contact/history data.

## Backend and database

- Serverpod MCP returned the Flutter tooling URI and recent successful deadline
  sweeps. Dart MCP tools are absent from this Codex session, so no driver-based
  live UI walkthrough has been performed.
- A read-only connection through the existing managed PostgreSQL Unix socket
  confirmed the SafeCheck migration version `20261103074431917`, matching the
  latest migration in the repository. No migration file was changed.
- At inspection, PostgreSQL showed five idle client connections, the probe's
  active connection, and no transactions older than one minute. The database
  was neither reset nor manually repaired.
- The retained server logs contain one 15-second connection-acquisition timeout
  at `2026-11-04T07:19:57Z`, in the future-call scanner's PostgreSQL pool path.
  The next minute recovered; 313 recorded overdue sweeps succeeded. This does
  not establish the original cause. Current observations do not justify
  increasing connection limits or changing trip/deadline logic.
- Serverpod's managed database resolves its transport at runtime. Direct TCP
  probes based on the YAML port failed; attaching through the managed Unix
  socket worked. Those failed probes do not demonstrate database drift.
- The MCP migration operation cannot reach Insights on localhost:8081, although
  other MCP operations work. The applied version above was checked directly
  using read-only SQL instead.

## Automated checks

- Flutter: **95 tests passed**.
- Focused Twilio/Meta/protocol/companion unit suite: **55 tests passed**.
- Whole-workspace `dart analyze --fatal-infos`: **no issues found**. The sender
  style lint and the new manual harness's brace lints were fixed. Formatting
  completed successfully.
- Complete backend suite: **138 tests passed, one deliberately gated live
  WhatsApp test skipped**. The test launcher exited successfully and stopped
  only the fresh PostgreSQL process that it owned, retaining its data directory.
- The first backend fixture exited silently because test-mode configuration
  lacked its database password. Serverpod suppresses constructor output. A
  separate random test-only password was added to the ignored private password
  file while preserving existing private entries; no value is recorded here.
- The first managed test-cluster initialization exceeded the fixture's two-minute
  allowance. Its directory was preserved, and a separate fresh test cluster was
  prepared successfully with a longer cold-start allowance before rerunning
  the full suite. The ignored local diagnostic launcher
  `.dart_tool/run_isolated_backend_tests.dart` boots that fresh cluster, supplies
  `SERVERPOD_DATABASE_DATA_PATH` to the unchanged test suite and runs
  `dart test --concurrency=1 --reporter=expanded`.
- Final Serverpod log inspection showed successful recent sweeps and no recent
  errors. Flutter logs showed the running debug app without new runtime errors.

## Provider and demo evidence

- At the initial verification, local private development configuration contained no Twilio Sandbox entries
  or `metaModelApiKey`; this process has no `MODEL_API_KEY`. No real WhatsApp
  submission or live Meta request had been performed at that point. The later
  live attempt is recorded above.
- Twilio mock tests verify form encoding, authorization, exact message content,
  allowlist/age guards and sanitized terminal handling of ambiguous submissions.
  Passing integration cases additionally exercise missed deadlines, SMS fallback
  and repeated processing. Concurrent lifecycle and outbox-claim tests passed.
- Meta unit/widget tests exercise structured drafts, clarification, UTC/SAST
  boundaries, missing/bad credentials, timeouts, redaction and standard/manual
  fallback. Mock success is not evidence of live Meta availability.
- `test/manual/whatsapp_sandbox_live_test.dart` is explicitly gated and skipped
  in ordinary runs. It is prepared for one enrolled recipient and checks a real
  missed-check-in submission plus provider delivery without live SMS fallback.
- [The demo runbook](../HACKATHON_DEMO.md) contains the three-minute storyboard,
  controlled-test command and recording prerequisites. Actual provider evidence,
  the recorded video and its URL remain to be collected.

Existing source changes, generated output and private credentials were
preserved. No merge, publication or deployment was performed.
## Approved implementation follow-up

The approved Limited Trial implementation adds a separate single-use
ContentSid probe and a `limited-trial` alert sender that fails WhatsApp locally.
The generic template cannot mark safety alerts delivered or suppress SMS.
Numeric provider diagnostics retain only validated five-/six-digit codes,
HTTP status and fixed reasons. No provider body, credential or phone number is
logged. The non-secret development mode was changed with an equality check
confirming all other credential/configuration values were preserved.

Real provider evidence: one genuine fictional Muse Spark incident-summary
inference returned HTTP 200 in 43.303 seconds. Strict validation preserved every
fact and unknown. A separate fictional safety-plan inference timed out after
25.269 seconds, with one attempt and no retries. Summary budget is now 45
seconds; interactive safety plans retain 25 seconds. Exact cause/phase of the
historical eight-second timeout remains unproven. Meta latency is a demo risk.

Focused checks: 61 Meta adapter/planner tests and 12 Twilio adapter/probe tests
passed. The probe's local dry run returned `consoleReferenceAvailable: false`
and `networkRequests: 0`. No new real WhatsApp request was made. Sender/template
comparison requires the private Console reference and any real send requires
separate approval. The original HTTP 400 numeric code remains unavailable.

Final full-suite results: **164 backend tests passed, one real-send test
skipped; all 95 Flutter tests passed**. Backend tests used a new isolated
managed PostgreSQL cluster; existing development data and migrations were
preserved. Final root `dart analyze --fatal-infos` completed with **No issues
found** after fixing two brace-style lints. Dart formatting passed. The only
post-suite source edits added braces without changing behavior.
New integration coverage checks plan-to-resolution, AI-pending resolution and
trial-probe acceptance not suppressing permitted SMS fallback.

Serverpod MCP log reads succeeded with successful deadline sweeps. Its first
restart call timed out after 300 seconds; a later MCP restart explicitly
returned `Hot restart completed.` Post-restart logs show successful deadline
sweeps, the backend web server listening and the Flutter debug app available.
Dart MCP tools are absent, so a driver-based UI walkthrough remains
unverified. No model schema or migration changed for this implementation.

The updated root `HACKATHON_DEMO.md` contains a three-minute script and explicit
baseline-versus-hackathon attribution. Submission remains gated on final video
and README URL, required public build parity/access, repository/reuse eligibility
and device walkthrough. Real WhatsApp safety-alert delivery is not supported by
this restricted trial. No merge, deployment, upgrade or data reset occurred.
