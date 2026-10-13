# Flutter & Serverpod project

This project is a Flutter app (frontend) backed by a Serverpod server (backend). Always build the app's backend with Serverpod.
Build for multiple users, use Serverpod's built-in authentication, which is already set up in `lib/server.dart`.

The user starts the server and Flutter app with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself. The Flutter app is started along with it, or can be launched from the MCP tool `spawn_flutter_app`.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload both the server and the Flutter app.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `tail_flutter_logs` to read the raw stdout/stderr of the Flutter app.
- `hot_reload` / `hot_restart` to reload or restart the server and the Flutter app. ALWAYS call `hot_restart` after doing changes in the Flutter app that may not work with normal hot reload (which is automatically applied).
- `spawn_flutter_app` to start a Flutter app declared under `serverpod: flutter_apps:` in the server `pubspec.yaml`.
- `get_flutter_app_dtd` (Dart tooling daemon) for connecting to the app through the `dart` MCP.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `safecheck_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

Tests need no Docker. `config/test.yaml` sets `database.dataPath`, so Serverpod starts and manages the test database (an embedded PostgreSQL) itself, and the project's `docker-compose.yaml` is not used for it. Just run `dart test` in the server package.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically). Will also hot restart Flutter app
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for any issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP) to connect to the app
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

The app is launched from `safecheck_flutter/lib/driver.dart`, which starts the Flutter driver extension with text entry emulation turned off so the app stays usable by hand. To let the driver type, set `enableTextEntryEmulation: true` there and `hot_restart` the app.

The `serverpod` MCP server is provided by `serverpod mcp-server` (run with the server package as working directory, or pass `--server-dir safecheck_server`). It bridges to a running `serverpod start`. If its tools are not available in your session, say so and ask the user to register it rather than silently switching to the CLI.

## About the app: SafeCheck

SafeCheck is a personal safety app for South Africa. Before a trip, a user sets a check-in deadline. If they do not tap "I'm safe" before the deadline, the server creates an alert for their trusted contacts. Version 1 is a demo: **no real SMS is ever sent**. Simulated messages are stored and shown in the app labelled exactly "Demo — SMS not sent", and the UI must never claim that contacts were notified.

Out of scope for now (next phase): PINs, duress mode, location tracking, photos, escalation, real SMS delivery.

### Server (`safecheck_server/lib/src/`)

- `common/` — `SafeCheckException` (user-facing error with `message` + `code`: `validation`, `not_found`, `conflict`, `unauthenticated`), validation helpers (`normalizeSaPhone` → `+27XXXXXXXXX`, text length limits, trip duration 1–1440 min), `lockOwner` (Postgres advisory lock per user for cross-row invariants).
- `profile/` — `UserProfile` (one per user: display name, phone) and `ProfileEndpoint`.
- `contacts/` — `TrustedContact` (max 5 per user, no duplicates, not the user's own number) and `ContactEndpoint` (list/add/update/remove).
- `trips/` — `Trip`, `TripType`, `TripStatus` (`active` → `checkedIn` | `missed`), `ContactSnapshot`, `TripSnapshot` (trip + `serverTime` for clock-skew-free countdowns), `TripEndpoint`, `TripService` (all lifecycle rules) and `TripDeadlineFutureCall`.
- `alerts/` — `SafetyAlert` (one per trip), `SimulatedSms` (one per snapshot contact) and `AlertEndpoint` (read-only lists).

Rules that must keep holding:

- Every private endpoint sets `requireLogin => true` and filters by `ownerIdOf(session)` (the auth `userIdentifier`). Another user's ids are reported as `not_found`, never as forbidden, so existence is not leaked.
- One active trip per user: checked under `lockOwner` and enforced by the unique index on the server-only column `trip.activeOwnerId` (set while active, NULL afterwards).
- A trip leaves `active` only through a single conditional `updateWhere(... status = active ...)`: check-in also requires `deadline > now`, deadline processing requires `deadline <= now`. Postgres row locking makes exactly one caller win, so concurrent check-ins, future calls and sweeps are safe. Alert + SMS rows are written in the same transaction as the winning update; the unique index on `safety_alert.tripId` is a second guard against duplicates.
- Trips copy the contact list into `trip.contacts` at start; alerts and messages use that snapshot, so later contact edits never change an existing trip.
- Deadlines: `TripService.start` schedules `futureCalls.callAtTime(deadline, identifier: 'trip-deadline-<id>').tripDeadline.processDeadline(id)` (persistent, survives restarts) and check-in cancels it. `server.dart` also registers a recurring `sweepOverdue` every minute as a safety net, and `getActiveTrip`/`history`/`startTrip` process the caller's overdue trips lazily. All paths are idempotent.
- Times are stored in UTC; SMS text shows SAST (UTC+2).

### Flutter app (`safecheck_flutter/lib/`)

- `main.dart` → `SignInScreen` (Serverpod email sign-up/sign-in; in development the verification code is printed in the server log) → `AppShell`.
- `AppShell` shows `ProfileScreen` for onboarding until a profile exists, then a `NavigationBar` with Trip, Contacts, History and Alerts tabs, plus an account menu (edit profile, sign out).
- `TripScreen` starts trips and shows the active trip only from a server response, with a countdown based on server time and a large "I'm safe" button. `app_events.dart` (`notifyDataChanged`) tells other tabs to reload.
- `util/errors.dart` maps server errors to friendly text; `widgets/state_views.dart` holds the loading/empty/error views; `widgets/demo_notice.dart` holds the demo label and banner.

### Tests

`safecheck_server/test/integration/`: `profile_and_contacts_test.dart`, `trip_test.dart` (ownership, check-in, missed deadlines, repeated future-call execution, contact snapshots) and `concurrency_test.dart` (runs with `RollbackDatabase.disabled` so requests really race; it cleans up its own rows). `safecheck_flutter/test/widget_test.dart` covers formatting helpers and the demo label.
