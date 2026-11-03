# Privacy policy review before publication

## Read-only technical review: 12 October 2026

Resolved by owner confirmation: operator Kabelo Motshabi Makgae; public
support/feedback/privacy email `kabelo.6a8fbeb6546d3829dedadcf7@gmail.com`;
Serverpod Cloud project region Europe; public and private object-storage
regions Europe. These confirmations do not resolve database/backup location,
provider retention, request-handling procedures or deployed job/SMS settings.

Cloud project metadata, backup schedule and storage-list requests were attempted
using the existing `scloud` login for project `safecheck`, without deploying or
changing settings. All failed with `ServerpodClientNetworkException`, socket
error `errno = 10057`, connecting to `api.serverpod.dev`. Database/backup
location, actual backup retention, effective session-log
settings, deployed sweep/cleanup execution and active SMS mode remain
unverified. Local Serverpod MCP logs contain sweep operations; these are not
production evidence. No secret values or user records were inspected.

The production YAML has `sessionLogs.consoleEnabled: false` but no explicit
cleanup interval, retention period or retention count. Cloud environment
overrides must be checked before describing effective production logging.
Official Cloud logging documentation describes console logging enabled and
persistent logging disabled by default; this does not establish this project's
settings or Cloud platform log retention.

Confirmed from installed Serverpod 4.0.3 and application source: Google account
identifier/email are stored; name/email and a downloaded profile image can be
used in the authentication profile. Email verification status is processed.
Web scopes are `openid`, `https://www.googleapis.com/auth/userinfo.email` and
`https://www.googleapis.com/auth/userinfo.profile`. No Google Contacts, Gmail
or Drive scope is requested. The current public tracking page loads Leaflet
from `cdnjs.cloudflare.com`, not unpkg; the policy draft now matches this.
The live sender sends recipient numbers, message content and a message-ID
deduplication parameter to BulkSMS only with mode `live` and both nonempty
credentials; otherwise it selects simulation. WhatsApp remains simulated.

Official sources consulted (provider statements, not production observations):

- https://docs.serverpod.dev/cloud/concepts/database-backups — inspect the
  actual schedule; current default is 35 days, older schedules may retain
  only 24 hours, and manual backups without expiry remain until deletion.
- https://docs.serverpod.dev/cloud/reference/logging — Cloud logging defaults.
- https://docs.serverpod.dev/concepts/operations/logging — session-log
  retention requires effective settings; not equivalent to platform logs.
- https://docs.serverpod.dev/cloud/concepts/storage — public/private Cloud
  storage and local database fallback; not project-specific regional evidence.
- https://docs.serverpod.dev/concepts/authentication/providers/email/setup —
  Cloud verification/recovery email in production; downstream provider and
  retention still need confirmation.
- https://developers.google.com/identity/openid-connect/openid-connect —
  identity claims; https://policies.google.com/privacy — provider-specific
  retention varies and processing can occur internationally.
- https://www.bulksms.com/company/bulksms-and-data-protection.htm — provider
  states Message Data retention of two years and Client Data deletion seven
  years after service termination; EU hosting with possible South African
  support access. Confirm applicable account terms before publication.
- https://osmfoundation.org/wiki/Privacy_Policy and
  https://operations.osmfoundation.org/policies/tiles/ — tile requests expose
  connection/request information; do not generalize analytics retention to
  every tile/CDN log.
- https://www.cloudflare.com/privacypolicy/ — asset-provider privacy source;
  https://cdnjs.com/privacy was inaccessible through the browser tool. A
  project-specific retention guarantee has not been established.

The request-handling process,
Cloud subprocessors and infrastructure analytics remain unresolved. Keep the
draft-review notice until these facts and production settings are confirmed.

The draft is `web/pages/privacy.html`, served without login at `/privacy` and
linked from sign-in and About. Nothing has been deployed by this change.

Confirm these facts before publishing or submitting Google branding:

- Database/backup location and actual infrastructure operators or subprocessors;
  backup and log retention, access and deletion procedures. Project and public/
  private object-storage regions are confirmed as Europe by the owner.
- Current production sender mode: default simulation versus explicitly enabled
  BulkSMS live SMS. Do not imply delivery merely because an alert exists.
- Provider-specific retention and handling for Cloud email, Google, BulkSMS,
  map tiles and third-party assets. The code does not establish their policies.
- The manual process, contact and response expectations for account/data
  requests. No complete account/history deletion flow exists in the app.
- Whether any infrastructure analytics/logging outside this repository needs
  additional disclosure. Do not claim that no data is logged or tracked.
- Final policy text and effective date; remove the draft-review notice only
  after the missing details have actually been resolved.

Code-derived retention facts:

- `TrackingService.view`: location visibility ends 48 hours after a missed
  check-in, and is hidden after a safe check-in. Link/trip records are not
  deleted by this access rule.
- `TrackingService.deleteExpiredLocations` deletes GPS rows by `receivedAt`
  older than 30 days. It is called by `TripService.sweepOverdue`, registered
  every minute in `server.dart`. Execution depends on the running server and
  successful sweep; this makes no backup-deletion promise.
- `ContactEndpoint.remove` removes the current contact row. Prior trip contact
  snapshots, alerts, message rows and tracking-link rows remain.
- There is no application purge schedule for profiles, trips, contact snapshots,
  alerts/messages or tracking links, and no user-facing account deletion flow.
- Sign-out clears credentials, not server history. The remembered email can
  remain after sign-out; selecting Remember me off removes it.

Google identity facts were checked against installed Serverpod 4.0.3: Google
account identifier and verified email are stored; auth profiles can include
name and a downloaded profile image. This differs from the separate SafeCheck
display-name/phone profile. The app requests identity scopes only.

Contact invite acceptance is implemented, but it is not a general SMS opt-out:
SMS preference may remain enabled for contacts who have not accepted WhatsApp.
Existing trip snapshots also remain unchanged by later contact edits/responses.


## Companion changes reviewed from source, 3 November 2026

The policy draft now describes optional Meta safety plans and incident briefs,
per-journey selection/grace/help/extensions, stored plan/brief/resolution records,
and private incident links. Incident access lasts 48 hours and its access-table
row stores a hash; full bearer links remain in saved alert-message content.
Accepted contacts get resolution permission only after a separate per-journey
traveller opt-in. Resolution stops pending notifications, not claimed/provider
submissions. Contact links and their permissions must be treated as private.
The existing sweep deletes expired incident-access rows. This does not erase
saved incident/message content or establish backup deletion. Live Meta access,
provider retention and deployed settings still require verification.
