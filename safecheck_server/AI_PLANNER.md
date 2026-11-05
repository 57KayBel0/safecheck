# SafeCheck AI companion

The Flutter Trip tab keeps **Describe with AI** visible even when the availability
check times out or reports missing configuration. Retry the check or use manual
journey fields. The status checks configuration, not live provider access.
Private credentials never enter Flutter.

## Journey preparation

`planning.propose` uses `muse-spark-1.3` with a strict four-field draft schema:
`tripType`, `description`, `checkInAtUtc`, `questions`. The server includes UTC
and SAST time context. Bounded conversation history lives in widget memory.
AI interpretation cannot start trips, schedule deadlines or send messages.

`planning.prepareSafetyPlan` accepts transport, a traveller-provided description,
chosen exact deadline and grace period. Its strict response contains check-in
advice, at most four precautions and three uncertainties. The server adds a
source label. Failed/unconfigured/quota-limited requests return a clearly
labelled standard plan. The model is instructed not to predict danger, invent
crime statistics, identify safe routes or promise protection. There is one
automated check-in deadline; extra suggested reminders are not scheduled.

Review uses the current contact list, selected contact IDs, exact SAST deadline,
grace period, optional plan and per-journey privacy choices. Location defaults
off. AI incident briefs and contact resolution permissions default off. Unsent
AI edits block confirmation. `trip.startJourney` validates ownership, current
contacts, a 1-minute to 24-hour deadline, 0–10 minutes of grace and the reviewed
plan. Only confirmation creates the trip. A lost start response reloads the
active trip rather than automatically retrying the mutation.

The server snapshots selected contacts and their acceptance/channel permissions.
A contact edited/deleted after start does not rewrite that snapshot. A confirmed
plan is saved as reviewed input, not as verified information about the world.

## Independent monitoring and incident response

- Persistent deadline calls use `alertAt` (deadline plus grace), with the
  existing minute sweep as a recovery path. Check-in and alert creation use
  conditional active-state updates; only one terminal transition wins.
- `trip.extendJourney` changes a still-active owned trip by 1–120 minutes,
  including during grace, within a total 24-hour journey. The backend saves the
  new deadline and replaces its persistent call. Old calls recheck stored time.
- `trip.requestHelp` requires an explicit UI confirmation and raises an incident
  immediately. It does not contact emergency services. History distinguishes
  requested help from missed check-in.
- Alert creation, a deterministic standard brief, private-link grants and pending
  notification rows share one transaction. Dispatch runs before AI enrichment.
  A standard brief separates recorded facts, attributed traveller descriptions,
  unknowns and bounded next steps. A missed check-in is not proof of danger.
- If explicitly enabled for that journey, an independent bounded worker asks
  Meta to organize the brief. The model selects fact indexes and allowed action
  codes; the server preserves every fact and uncertainty and rejects invented
  indexes/actions. Location review is allowed only when a consented point exists.
  Contact records, phone/profile data and coordinates are not automatically
  included. User-entered description text may contain personal information.
- AI cannot change deadlines, resolve an incident or control delivery. The
  existing SMS is not delayed or rewritten by Meta; its private incident link
  shows the current standard/AI-organized brief. At most two enrichments run per
  server instance. A pending worker can be recovered by the sweep; a processing
  request abandoned for two minutes falls back without automatic provider retry.
- Incident links are 256-bit bearer credentials, stored as hashes in the access
  table, expiring after 48 hours. They disclose limited incident information and
  an existing consented location link. The full link remains in message history.
  The public page escapes content and sends no-store/no-referrer/CSP headers.
- The traveller can resolve their own incident. A contact's link permits
  resolution only if the traveller explicitly opted in for that journey and
  the contact had accepted their invitation at start. Anyone holding such a
  forwarded link has that permission. Resolution records actor/time/note and
  skips pending messages. Claimed/submitted messages cannot be recalled.

## Provider limits and privacy

The adapters use `https://api.meta.ai/v1/chat/completions`, strict structured
output, no tools and no automatic retries. The new plan/brief adapter caps the
response at 32 KiB and 1200 completion tokens, with a 25-second plan timeout and
45-second incident timeout. Planning keeps its earlier 64 KiB / 2048-token /
30-second bounds. Server errors do not expose keys or raw provider responses.

All AI features share durable per-account limits of five attempts per ten-minute
window and thirty per UTC day. Failed provider attempts consume quota. Invalid
inputs and missing credentials do not. These limits are not a global spend cap.
AI summaries use the existing standard brief if quota/provider access fails.

Planning conversations are not persisted by the planning service. Confirmed
safety plans, incident briefs and resolution records are retained with trips and
alerts; no general history purge has been implemented. Expired incident-access
rows are deleted by the running sweep. See the public privacy-policy draft for
other records and provider/backup retention items still needing owner review.

## Private configuration and deployment

Use the existing server-only `metaModelApiKey` password, or `MODEL_API_KEY` in
the server process. Cloud passwords require redeployment to take effect. Keep
keys out of Flutter, Git, recordings and chat. No key value is needed to review
or merge this code. Serverpod CLI 4.0.3 generated client/server/test-tool files.
The migrations `20261102165504453` (AI quotas) and `20261103074431917` (companion)
are additive; existing trips retain zero grace and their earlier alert behavior.

Before deployment, pull the reviewed branch, install dependencies and run the
project's generation/build checks. From `safecheck_server`, use:

```powershell
serverpod cloud deploy --project safecheck
```

Cloud runs the repository pre-deploy generator and Flutter release build. Check
the rollout/migration result before reloading the app. Keep the existing private
Cloud password; re-entering the key is unnecessary if it is already set.

## Verification and a three-minute demo

Mocked tests and CI establish contracts, authorization, races and fallback
behavior. **They do not verify live Meta access, model quality, actual SMS
delivery or reliable background GPS.** The owner must verify a real request
with their private deployed key. Use fictional trip/contact data or consented
test recipients; simulated messages remain labelled **Demo — SMS not sent**.
WhatsApp is simulated unless the separate [Twilio Sandbox configuration](WHATSAPP_SANDBOX.md)
is explicitly enabled. BulkSMS live sending requires separate deliberate
configuration; provider submission is not confirmed delivery.

1. Describe a journey, clarify its time, and create a safety plan. Confirm the
   source says AI; a standard fallback is not evidence of a live Meta call.
2. Review selected contacts, exact SAST time, grace and privacy choices. Dismiss
   once to show no trip starts, then confirm. Show the server countdown.
3. Show check-in/extend/help controls. For an overdue demo, use the two-minute
   duration and zero grace; use recording cuts to omit waiting.
4. Open Alerts and show the recorded facts, uncertainties, source and each
   message's actual status. Copy/open a private incident link only with demo
   data and explain its bearer permission. Resolve after checking the outcome.
5. Separately test missing/bad provider configuration: manual journeys, deadline
   creation, standard briefs and notification dispatch must still work.

Primary API references:

- [Meta Chat Completions](https://dev.meta.ai/docs/protocols/chat-completions)
- [Meta structured output](https://dev.meta.ai/docs/structured-output)

## Verification update — 4 November 2026

The configured endpoint is `https://api.meta.ai/v1/chat/completions`, model
`muse-spark-1.3`. A genuine fictional incident-summary inference returned HTTP
200 in 43.303 seconds, with all supplied facts and unknowns preserved after
strict validation. The historical eight-second timeout has insufficient timing
diagnostics to identify its exact phase; this slower successful response shows
that eight seconds is an inadequate general summary budget.

Incident summaries now use a bounded 45-second request budget. Interactive
safety plans retain 25 seconds. Constructor overrides must be positive and no
more than 60 seconds. There are no automatic retries. Responses are capped at
32 KiB; invalid JSON, refusals, tool calls, malformed envelopes and invalid
structured output fall back safely. Authentication, throttling, timeout and
unavailable errors are classified without provider bodies or credentials.
Alerts and notification dispatch precede asynchronous incident enrichment;
provider failures leave the factual standard brief and alert intact.

`dart run tool/verify_meta.dart --approve-inference --summary` uses fictional
data and prints only sanitized validation/timing metadata. The `--plan` variant
checks planning separately. These commands make genuine provider requests and
require explicit authorization; ordinary automated tests use mocks.

The genuine safety-plan request separately reached its 25-second timeout
(25.269 seconds observed, one attempt, no retry). The successful summary
confirms credentials, model access and response handling; it does not establish
reliable latency for every interactive request. Standard-plan fallback remains
necessary for the demo.
