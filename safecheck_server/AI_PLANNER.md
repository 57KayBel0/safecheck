# Meta AI trip planning

The Flutter trip tab now offers **Describe with AI** when server credentials
are configured. The authenticated `planning.propose` endpoint calls
`muse-spark-1.3` at `https://api.meta.ai/v1/chat/completions` with a strict
JSON schema. Missing details are presented as clarification questions.
The user can revise the proposal, review it with current contacts, and explicitly
confirm before `trip.startPlannedTrip` creates a trip.

**The live Meta provider call still needs verification with the owner's private
server key. Mocked tests verify the application contract and failure handling;
they do not establish live interpretation quality.**

## Behavior and boundaries

- Inputs contain trip text, bounded alternating conversation history and
  server-owned UTC/SAST time context. Profile, contact and GPS records are not
  added. Personal information typed into the conversation would be sent.
- The model is instructed to clarify missing or ambiguous details, including
  AM/PM and future departure. SafeCheck currently starts trips immediately on
  confirmation, rather than scheduling future departures.
- Responses contain only `tripType`, `description`, `checkInAtUtc` and
  `questions`. Unknown fields, malformed output and unsupported values fail
  validation. An out-of-bounds time requires clarification.
- Planning requires login and derives the owner from the authenticated session.
  It cannot start trips, schedule deadlines, record location or send messages.
- Durable per-owner quotas allow 5 attempts per 10-minute window and 30 per
  UTC day. An advisory transaction lock prevents concurrent requests bypassing
  the limit. Failed provider attempts count too. Unconfigured and invalid-input
  requests do not reserve quota. These are request limits, not a global money cap.
- Inputs are limited to 1500 characters per turn, 6 prior turns and 6000 total
  characters. Responses are capped at 64 KiB and 2048 completion tokens. The
  provider request times out after 30 seconds and is never automatically retried.
- Conversation history lives in widget memory. The planning service does not
  persist prompts or responses. Provider errors are redacted; no raw provider
  body, API key or trip text appears in the adapter's errors or logs.
- A complete draft is only ready for review. Location defaults to off and
  reminders to silent. Contacts are refreshed before review and read again at
  start. Another device can still change contacts between those operations.
- Confirmation preserves the reviewed absolute deadline, including seconds.
  The server rechecks it against its current clock inside the start transaction:
  at least one minute and no more than 24 hours must remain. An expired draft is
  rejected rather than shifted forward. Existing ownership, contact snapshots,
  one-active-trip and persistent deadline/alert behavior still apply.
- Pending user edits disable review; a failed change request invalidates the
  previous draft. A failed start is reconciled with the active-trip endpoint;
  mutations are never automatically retried.
- Manual setup remains available with no key or provider access. Once a trip
  starts, deterministic deadlines and alert processing need no further AI call.

## Private server configuration

Set `metaModelApiKey` in the appropriate environment of the existing private
`config/passwords.yaml`, or provide `MODEL_API_KEY` to the server process.
The resolver uses `session.serverpod.getPassword('metaModelApiKey')` first,
then the environment variable. Restart the server after configuration, and
refresh the Trip tab. Keep the key out of Flutter, source control, recordings
and chat messages.

Generated server/client/test-tool files are produced by Serverpod CLI 4.0.3,
not hand-edited. Use the repository's Serverpod workflow for future regeneration.
The new `planning_quota` migration must be applied before exposing the endpoint.
Do not modify production credentials or enable live SMS as part of verification.

## Verification

```sh
serverpod generate
serverpod create-migration
dart analyze --fatal-infos
dart test test/meta_trip_planner_test.dart test/planner_protocol_test.dart test/integration/planning_test.dart
cd ../safecheck_flutter
flutter test test/ai_trip_form_test.dart test/trip_review_test.dart
```

For a live check, use fictional trip data, clarify a missing time, confirm the
SAST interpretation, edit/dismiss the review, then confirm and check in. Inspect
the actual configured messaging mode; simulated messages are not sent. Also
verify manual setup after removing provider availability. Do not use model
quality claims or timing measurements from mocked responses in the submission.

Primary API references:

- [Meta quickstart](https://dev.meta.ai/docs/quickstart)
- [Chat Completions](https://dev.meta.ai/docs/protocols/chat-completions)
- [Structured output](https://dev.meta.ai/docs/structured-output)
