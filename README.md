# SafeCheck

SafeCheck is a personal safety prototype for people travelling in South Africa
who want a check-in deadline and a small circle of trusted contacts. Start a
trip, choose when you expect to arrive, and tap **I'm safe** before the deadline.
If the deadline is missed, the backend creates an alert and queues messages for
the contacts saved with that trip.

- **Deployed app:** https://safecheck.serverpod.space/
- **Demo video:** **TODO — replace with the demo video URL before submission.**
- **Created and operated by:** Kabelo Motshabi Makgae
- **Support, feedback and privacy requests:**
  [kabelo.6a8fbeb6546d3829dedadcf7@gmail.com](mailto:kabelo.6a8fbeb6546d3829dedadcf7@gmail.com)

This repository describes current source. The deployed app may be an older
build; its current OAuth configuration, SMS mode and background job execution
have not been independently verified. SafeCheck is not an emergency service
and cannot guarantee safety, message delivery or an emergency response.

## Implemented features

- Serverpod email registration, verification, sign-in and password recovery;
  Google sign-in when the server and OAuth configuration are ready.
- Optional remembered login and a profile with display name and South African
  phone number.
- Up to five trusted contacts, phone validation and duplicate/own-number
  checks. Supported phone/browser contact selection includes review before
  saving; manual entry remains available.
- Contact invitation links with acceptance/decline and channel preferences.
- Trip types, descriptions, deadlines, countdowns, check-in, history, alerts
  and message status. Each trip snapshots its contacts. A review step refreshes
  contacts and shows the trip, timing and privacy choices before confirmation.
- Persistent server deadline calls, a recurring overdue sweep and idempotent
  alert processing. One active trip per user and ownership checks are enforced
  on the backend.
- Location sharing off by default, live, or visible after a missed check-in. Location
  permission guidance, retry, bounded GPS/upload waits and an explicit option
  to continue without location keep check-in available when tracking fails.
- Recorded-route maps and per-contact tracking links. A safe check-in hides
  location; missed-trip location visibility ends after 48 hours.
- Foreground check-in reminders with optional supported sound/vibration.
- About, third-party licence notices and a public privacy-policy draft linked
  from sign-in and About. Remaining privacy review items are documented.

## Architecture and directories

Flutter is the frontend. The backend uses **Serverpod 4.0.3**, its built-in
authentication and PostgreSQL. The generated Dart client connects the two.
Database transactions, per-user advisory locks and unique constraints protect
trip/alert invariants. BulkSMS integration runs on the server, never in Flutter.

| Path | Purpose |
| --- | --- |
| `safecheck_flutter/` | Flutter UI, authentication, contacts, trips, location and widget tests |
| `safecheck_server/lib/server.dart` | Backend initialization, authentication, storage and recurring sweep |
| `safecheck_server/lib/src/` | Endpoints, `.spy.yaml` models and application services |
| `safecheck_server/migrations/` | Versioned database migrations |
| `safecheck_server/test/` | Unit, mocked-provider and integration tests |
| `safecheck_server/web/` | Public privacy, invitation/tracking pages and web assets |
| `safecheck_server/scripts/` | Windows/POSIX Flutter release-build scripts |
| `safecheck_client/` | Generated Serverpod client; do not edit manually |
| `safecheck_server/CLOUD_DEPLOYMENT.md` | Cloud configuration and readiness notes |
| `safecheck_server/PRIVACY_POLICY_REVIEW.md` | Confirmed facts and outstanding policy review |

Generated server code in `lib/src/generated/` is also maintained by Serverpod.
Change models/endpoints and let the existing workflow regenerate it.

## Prerequisites and local setup

- Git, a Flutter SDK satisfying `^3.44.4`, and its Dart SDK satisfying `^3.12.2`.
- The Serverpod CLI compatible with the pinned 4.0.3 packages.
- Internet access for initial dependency and managed test/development database
  downloads; device/browser location permission for location-enabled trips.

From the repository root, install the locked dependencies:

Before the first start of a fresh clone, privately create
`safecheck_server/config/passwords.yaml` with a `development:` mapping and
the authentication keys listed below. Use newly generated, sufficiently strong
values; placeholders are documentation only. An existing local installation
should retain its authentication keys. Google and BulkSMS entries can be
omitted; email/JWT authentication still needs its private keys.

```powershell
flutter pub get
Set-Location safecheck_server
serverpod start
```

`serverpod start` runs the backend and the declared companion Flutter app,
watches changes, generates code incrementally and reloads the app. Keep this
single development process running. The configured Flutter target is
`lib/driver.dart` at `http://localhost:55267`; the local API/web ports are 8080
and 8082. Use the URLs printed by the running tool if settings differ.

Development and test configuration use Serverpod-managed database data paths
under `.serverpod/`; Docker is not required for this workflow. The optional
Docker Compose file uses environment variables for passwords and is not the
test database. Do not commit local database files.

Review `AGENTS.md` for the project workflow. Use Serverpod MCP for logs,
reload/restart and migrations; do not start a second development server.
Private configuration belongs in the existing run-mode section of
`safecheck_server/config/passwords.yaml` or in Serverpod Cloud passwords,
not in source. Preserve existing authentication keys. Local development email
verification/recovery codes are written to server logs; keep those logs private.

## Configuration (names and placeholders only)

| Name | Purpose |
| --- | --- |
| `jwtHmacSha512PrivateKey` | `<private JWT signing key>` required by the configured JWT token manager |
| `jwtRefreshTokenHashPepper` | `<private refresh-token hash pepper>` required by the JWT token manager |
| `emailSecretHashPepper` | `<private email authentication hash pepper>` required by email sign-in |
| `database` | `<private database password>` when required by the selected PostgreSQL configuration |
| `googleClientSecret` | `<private Google Web OAuth client JSON>` with its registered redirect URIs |
| `bulkSmsMode` | `demo` for simulation; real sending requires deliberate `live` configuration |
| `bulkSmsTokenId` | `<fresh BulkSMS API token ID>` |
| `bulkSmsTokenSecret` | `<fresh BulkSMS API token secret>` |
| `SERVERPOD_WEB_SERVER_PUBLIC_HOST` | `<public hostname for this deployment>` |
| `SERVERPOD_WEB_SERVER_PUBLIC_SCHEME` | `https` in production |
| `SERVERPOD_WEB_SERVER_PUBLIC_PORT` | `443` for the default HTTPS origin |
| `SERVERPOD_API_SERVER_PUBLIC_HOST` | `<public API hostname>` |
| `SERVERPOD_API_SERVER_PUBLIC_SCHEME` / `SERVERPOD_API_SERVER_PUBLIC_PORT` | `https` / `443` in production |
| `SERVERPOD_INSIGHTS_SERVER_PUBLIC_HOST` | `<public Insights hostname>` |
| `SAFE_CHECK_WEB_ORIGIN` | Optional release-script override: `<public HTTPS app origin>` |
| `SAFE_CHECK_GOOGLE_CLIENT_ID` | Optional public OAuth client-ID override, matching the server configuration |
| `GOOGLE_CLIENT_ID`, `GOOGLE_SERVER_CLIENT_ID`, `GOOGLE_IDP_CONFIGURED`, `GOOGLE_WEB_REDIRECT_URI` | Development/native authentication defines; see source and deployment notes |

The web app discovers Google readiness from the server; a build flag alone
does not establish that Google login works. The production callback is
`https://safecheck.serverpod.space/auth.html`. OAuth secrets stay server-side.
Cloud provisions platform-managed database, JWT and email authentication
passwords; do not replace them with sample values. Use the supported password
`--from-file` workflow described in `CLOUD_DEPLOYMENT.md` for private imports.
Never reuse exposed API credentials or paste secrets into command arguments.

Tracking links must use the origin of the server/database containing their
token. Production URL generation rejects local/non-HTTPS origins. A local
`localhost` token cannot be fixed by replacing its hostname with the Cloud
hostname. Existing tokens and persisted messages are not automatically rewritten.

## Demo and real messaging

The default sender simulates delivery. The UI labels simulated SMS exactly
**Demo — SMS not sent**. An alert or simulated message does not mean a contact
was notified. **WhatsApp remains simulated**, including with live SMS enabled.

Real BulkSMS submission requires `bulkSmsMode: live` and both nonempty API
credentials on the server. Credentials alone do not enable it. Keep mode
`demo` for demonstrations and tests. Mocked tests use fake transport and send
no real messages. A provider-accepted submission is not a delivery guarantee;
asynchronous delivery reports are not implemented. The sender includes guards
against submitting old pending messages after live mode is activated.

## Analysis and tests

From the root:

```powershell
dart analyze
dart format --output=none --set-exit-if-changed safecheck_server/lib safecheck_server/test safecheck_flutter/lib safecheck_flutter/test
```

Backend tests use Serverpod's managed test database, not Docker:

```powershell
Set-Location safecheck_server
dart test
dart test test/public_links_test.dart test/bulk_sms_message_sender_test.dart test/integration/tracking_test.dart
```

Flutter tests:

```powershell
Set-Location safecheck_flutter
flutter test
flutter test test/trip_review_test.dart
flutter test test/trip_location_controller_test.dart test/trip_location_status_test.dart
```

GitHub Actions checks backend analysis, formatting and tests, plus Flutter
analysis and widget tests. A blocked check is not a pass. Widget tests do not
establish that the deployed build matches source or that real messages arrive.
Android SMS link detection and browser permission behavior require device
testing through the existing Serverpod MCP workflow.

## Known limitations and privacy

- Web GPS sampling depends on the app remaining active, permission, device
  location services and connectivity. There is no guaranteed background tracking.
- PINs, duress mode, photos, escalation and emergency assistance are not implemented.
- Tracking links grant access to anyone holding or receiving a forwarded link.
  Permission granted does not prove an upload; UI success requires server confirmation.
- The 48-hour location visibility rule is not data deletion. The sweep deletes
  GPS rows older than 30 days only when it runs successfully; it does not purge
  trips, snapshots, alerts, messages or links, or establish backup deletion.
- There is no complete user-facing account/history deletion workflow or general
  recipient SMS opt-out. Access/correction/deletion requests can be emailed to
  the public contact; procedures and response times are not promised.
- Effective production SMS mode, Google readiness, sweep/cleanup execution,
  backups/log retention and other provider details remain unverified or under
  review. The public privacy policy is a draft, not a compliance guarantee.

## Hackathon submission

See [HACKATHON_NOTES.md](HACKATHON_NOTES.md) for the scope of the current
improvements and outstanding Meta-model integration and submission work.

Replace the demo-video placeholder, confirm the deployed build and required
judge flows, and supply the repository URL. The Meta hackathon participant
guide requires a public repository. Review the repository contents, visibility
and licensing before publication, and verify that judges can open both the
repository and video links.
