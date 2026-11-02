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
- A backend-only Meta AI adapter using a strict draft schema, server time
  context, bounded requests, safe provider errors and validated draft times.
  Provider behavior is mocked in tests; app wiring and a live call are pending.

The estimated review time follows the server-adjusted clock, but the existing
API starts a duration-based countdown at confirmation. The exact deadline is
the deadline returned by the server. Contacts are re-read by the backend at
start; review does not lock them against concurrent edits on another device.

## Required before a Meta hackathon submission

- Complete and verify the Meta AI planning workflow. **The adapter is not yet
  connected to the app, and no live Meta request has been verified. The current
  changes alone do not establish a working Meta feature for the submission.**
- Have the model ask about ambiguous or missing trip details and produce a
  validated draft. Keep API credentials on the backend. Reuse the review
  step and require confirmation before creating a trip or scheduling alerts.
- Follow `AGENTS.md` for endpoint/model generation and app verification through
  Serverpod MCP. Do not hand-edit generated clients or server registration.
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
user-reviewed draft once that integration is implemented.

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

Verified on 2 November 2026 with Flutter 3.44.4 / Dart 3.12.2: Flutter static
analysis passed, changed Dart files passed formatting checks, all 14 focused
review tests passed, and the full Flutter suite passed all 73 tests. The
existing backend analysis, formatting and test workflows also passed on the
initial PR revision; check the latest PR checks after further changes.

Use the existing Serverpod MCP workflow for interactive app verification.
Unit/widget tests do not establish production SMS delivery or background
tracking behavior.
