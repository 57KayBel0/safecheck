# SafeCheck: current improvements and submission gaps

## What changed in this iteration

The existing SafeCheck prototype is the baseline, at commit
`2d7a2e2c5c719b6973f3c9c17b3271de1e274ea4`. Its trip scheduling,
authentication, tracking, invitations and messaging infrastructure predate
this iteration. Identify them as existing work in a hackathon submission.

New work in this iteration:

- A review step before starting a trip, showing description, trip type,
  duration, estimated check-in time, contacts, reminder and location choice.
- A fresh contact-list read before review. A failed refresh or an empty list
  prevents confirmation; opening, editing or dismissing a draft starts no trip.
- Location sharing starts **off**. Live or after-alert sharing requires a
  deliberate choice, with an explanation in the review.
- Trip outcomes use mode-independent wording. The missed-trip notice links
  directly to Alerts, where individual message statuses are displayed.
- Regression tests for the review/confirmation boundary, loading failures,
  privacy defaults, draft preservation and narrow-screen accessibility.
- A Flutter CI job that analyzes the frontend and runs its widget tests.
- A Meta AI trip-planning workflow in Flutter and an authenticated endpoint:
  describe a trip, clarify missing information, revise, review and confirm.
  The adapter uses a strict schema, server UTC/SAST context, bounded requests
  and safe provider errors. Live model interpretation still needs verification.
- Durable per-owner AI request quotas, including concurrent reservations.
- A separate confirmation endpoint that preserves the approved exact deadline
  and rejects stale drafts against the current server clock.
- AI/privacy information in the app and the draft privacy policy; manual setup
  remains available when the provider or its configuration is unavailable.

The companion journey form preserves the exact check-in time approved in review,
displayed in SAST, whether entered manually or interpreted by AI. Legacy clients
can still use the original duration-based endpoint.
The server response remains authoritative. Contacts are re-read by the backend
at start; review does not lock them against concurrent edits on another device.

## Companion expansion on 3 November 2026

- Selected-contact snapshots, exact SAST time selection and configurable grace.
- Personalized safety plans with honest standard fallback and stored reviewed plans.
- Owner-authorized extensions, explicit help requests and check-in during grace.
- Deterministic incident facts and optional Meta organization after dispatch;
  AI output is limited to fact indexes and allowed action codes.
- Private 48-hour incident pages; separate opt-in grants accepted contacts
  resolution permission. Owner resolution and pending-notification cancellation.
- AI controls remain visible with retry/status feedback after failed availability
  checks. Configuration detection is not a successful provider request.
- Additive migration and regenerated protocol/client/test tooling.

The full companion flow is new in this expansion. The earlier scheduler,
authentication, delivery integration and tracking remain existing infrastructure.

## Required before a Meta hackathon submission

- Verify a real Meta request and its interpretation using fictional trip data.
  **Mocked tests do not establish live Meta access or interpretation quality.**
  Show a clarification, review and confirmed exact deadline in the live app.
- Keep API credentials private on the backend. Apply the generated quota
  migration and verify the deployed build before recording the submission.
- Generate server/client/test-tool changes with Serverpod; generated files are
  not hand-edited. This integration was generated with Serverpod CLI 4.0.3.
- Clearly identify work built during the event, and check the rules governing
  reuse of an existing indie project before presenting the earlier prototype.
- Make the submission repository public as required by the participant guide,
  after reviewing its contents. A private URL does not give judges access.
- Replace the README's demo-video placeholder with the new three-minute demo.
- Verify the deployed build and actual messaging mode. Retain
  **Demo — SMS not sent** for simulated messages; provider acceptance is not
  confirmed delivery.

## Demonstration evidence to collect

Show a draft being edited or dismissed without an active trip, then a
confirmed trip with its server deadline. Demonstrate location off by default
and an explicit sharing choice. Show an actual message status in Alerts after
a missed check-in, distinguishing a simulation from a provider submission.
For the AI portion, demonstrate a real Meta request, a clarification and a
user-reviewed draft. Present simulated messages with their actual status.

The organizer's 28 October reply confirms pivots are allowed without updating
the application or notifying anyone. It does not resolve reuse rules for an
existing indie prototype. The participant guide explicitly describes reuse for
startups; confirm the indie case before presenting earlier work. Use the
Build for Your World theme and the Indie track if applying as a solo builder.
Submit one public repository, accessible live product and new three-minute demo
by 4 November 2026 at 21:00 ET (5 November at 04:00 SAST).

Ask three to five people to try setup and contact review. Record completion
time, errors and confusing steps, then report actual observations. Previous
BuilderDev category ratings identify priorities; they are not written judge
comments or a prediction of a future rank.

## Focused verification

```sh
flutter pub get
cd safecheck_flutter
dart analyze --fatal-infos
flutter test test/trip_review_test.dart
flutter test
```

Verification on 2 November 2026 uses Flutter 3.44.4 / Dart 3.12.2. The first
integration revision passed all four CI workflows, including all 113 backend
tests against embedded PostgreSQL. The Flutter suite covers AI/manual review,
generated-client wiring, lost-start-reply reconciliation and narrow screens with
enlarged text. A release web build also succeeded. See the integration pull
request for results at its latest revision.

Local database verification cannot initialize PostgreSQL under this execution
environment's root-only process restrictions; CI runs those checks as a normal
user. Unit/widget tests do not establish live model quality, production SMS
delivery or background tracking behavior.
