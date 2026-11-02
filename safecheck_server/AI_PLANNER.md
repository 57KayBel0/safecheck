# Meta AI trip planning: service and integration status

`lib/src/planning/meta_trip_planner.dart` is a backend-only adapter for
Meta Model API. It calls `muse-spark-1.3` at
`https://api.meta.ai/v1/chat/completions` using a strict JSON schema.
`trip_plan_draft.dart` validates the resulting proposal.

**The service is not yet connected to an authenticated endpoint or the Flutter
app. No live Meta call has been verified. Adding a key alone does not enable
an AI planning feature.**

## Service behavior

- Inputs are trip text, bounded user/assistant history and a server-owned clock.
  The app's profile, contact list and recorded GPS points are not automatically
  included. Personal information typed into the conversation would be sent.
- Requests include UTC and SAST time context. The model is instructed to ask
  about missing or ambiguous information, including AM/PM and future departure.
  Actual model interpretation still needs a live evaluation and user review.
- Responses contain `tripType`, `description`, `checkInAtUtc` and `questions`.
  Unknown details remain null and require clarification. Unknown fields and
  malformed responses are rejected. Unsupported time bounds produce a question.
- Readiness means **ready for review**, never permission to start a trip.
  A draft cannot access a database, scheduler or message sender.
- Request size, history, response size, output tokens and wait time are bounded.
  The adapter makes no automatic retries. This is not a per-user or daily spend
  cap; the authenticated endpoint still needs request quotas before exposure.
- Provider errors are mapped to safe messages. API keys, raw provider errors
  and trip text are not included in exception messages or logged by the adapter.

## Server-only configuration for the eventual endpoint

Use the existing private Serverpod password configuration or the server's
`MODEL_API_KEY` environment variable. A constructor wiring example is:

```dart
final planner = MetaTripPlanner(
  apiKey: pod.getPassword('metaModelApiKey') ??
      Platform.environment['MODEL_API_KEY'],
);
```

This example is not installed in `server.dart` yet. Keep the key on the server;
do not place it in Flutter, source control, a demo recording or chat messages.
Mocked tests use a fake key and a fake transport, and incur no model usage.

## Remaining app integration

1. Connect the project's Serverpod MCP, as required by `AGENTS.md`, and use
   its generation/restart workflow. Do not hand-edit generated clients.
2. Add a login-required planning endpoint that derives the owner from the
   authenticated session, enforces per-user quotas and invokes the service.
3. Present clarifications in Flutter, then populate the shared review dialog.
   Contacts and location settings remain explicit app choices.
4. Add a confirmation operation that revalidates the proposed time and fields
   against the current server clock and the authenticated user's state. Preserve
   the proposed exact deadline; the existing duration-only start API must not
   silently move it forward by starting the original full interval again.
5. Generate and test the endpoint/client changes through the supported workflow.
   Verify a real Meta request with fictional trip data and inspect failure cases.
6. Update the user-facing AI/privacy information before exposing this workflow.
   Keep manual trip setup available when planning is unavailable.

The existing deterministic deadline/alert path must continue working without
an AI call after the user confirms a trip.

## Verification

```sh
dart test test/meta_trip_planner_test.dart test/planner_protocol_test.dart
```

The tests cover the provider request, SAST date boundaries, response validation,
unsupported times, history/input bounds, credential errors, timeouts and error
redaction. The protocol test guards against drift in supported trip types.
They do not measure the live model's interpretation quality.

Primary API references:

- [Meta quickstart](https://dev.meta.ai/docs/quickstart)
- [Chat Completions](https://dev.meta.ai/docs/protocols/chat-completions)
- [Structured output](https://dev.meta.ai/docs/structured-output)
