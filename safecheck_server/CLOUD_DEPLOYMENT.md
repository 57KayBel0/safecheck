# SafeCheck on Serverpod Cloud

The project is linked as `safecheck` in `scloud.yaml`. This document describes
configuration to review privately; editing the repository does not deploy it
or confirm the current Cloud password/variable inventory.

## Release web build

The Cloud `pre_deploy` hook is registered from the `flutter_build` script in
`pubspec.yaml` when `serverpod cloud launch` creates `scloud.yaml`. It builds a
release Flutter web app and copies it into `web/app`, which the server serves
with `FlutterRoute`. The script also checks that `auth.html` is in the build.

The release build defaults to `https://safecheck.serverpod.space` and keeps the
existing callback at `https://safecheck.serverpod.space/auth.html`. It refuses
localhost release origins. Google readiness is discovered at runtime through
the public `googleIdp.getConfiguration` endpoint: only the public client ID,
registered callback URLs and web origin are returned. Credential JSON and
tokens stay server-side. If server configuration is absent, invalid, mismatched
or unavailable, the Google button stays unavailable and email login remains.

These non-secret build overrides are optional:

- `SAFE_CHECK_GOOGLE_CLIENT_ID`: Web OAuth client ID; if supplied, it must match
  the server's client ID. It is no longer required to enable Google.
- `SAFE_CHECK_WEB_ORIGIN`: another exact public HTTPS origin without a trailing
  slash or path. Set the corresponding server public web origin as well.

The callback is derived as `<SAFE_CHECK_WEB_ORIGIN>/auth.html`. Development
companion defines remain separate, including `http://localhost:55267/auth.html`.

For the default Serverpod Cloud domains, after the project ID is known, register
the matching web origin `https://<project-id>.serverpod.space` and redirect URI
`https://<project-id>.serverpod.space/auth.html` in the Google Web OAuth client.
If using a custom web domain, register that exact HTTPS origin and callback
instead. Store the downloaded Web OAuth client JSON (not just its raw
`client_secret` field) with
`serverpod cloud password set googleClientSecret --from-file <private-file>`;
the server reads it through Serverpod password configuration. The JSON needs a
`web` section with `client_id`, `client_secret` and `redirect_uris`, including
the exact deployed callback. Never pass the JSON/client secret as a Flutter
define or commit it. Confirm the setting privately in Cloud; a build flag is
not evidence that this password is present. Google Console registration must
match the JSON; the app cannot verify Console changes automatically.

## Privacy policy and Google Console review

The public policy is served by Serverpod at `/privacy`, before the Flutter
fallback route, without authentication. Its production URL will be
`https://safecheck.serverpod.space/privacy` after an authorised deployment.
See `PRIVACY_POLICY_REVIEW.md` for unresolved facts. Do not publish the draft
as a final policy until the operator/support contact and remaining facts are
confirmed. No licence change is part of this work.

In Google Auth Platform, use a Web application client with origin
`https://safecheck.serverpod.space` and redirect
`https://safecheck.serverpod.space/auth.html`. Set Branding to SafeCheck with
the public home and privacy-policy links, support/developer emails, and the
verified authorised domain. Use External audience for public users. Declare
only `openid`, `https://www.googleapis.com/auth/userinfo.email`, and
`https://www.googleapis.com/auth/userinfo.profile` in Data Access. Resolve domain
ownership with Serverpod or a domain you control; control of a provider-hosted
subdomain alone is not confirmation of Google's top-private-domain ownership
requirement. Complete branding verification/publishing as applicable. These
basic scopes do not require sensitive/restricted-scope review.

## Public URLs and API configuration

For a Flutter web app served by this Serverpod server, `AppConfigRoute` serves
`/assets/assets/config.json` from the running server's `apiServer` public URL.
The browser app therefore does not need a compile-time API URL. Tracking links
use the configured `webServer` public URL. The current `production.yaml` hosts
are example placeholders, so set the Cloud variables below to the actual
project domains (or custom domains) before the first deployment. Serverpod
configuration environment variables override the example YAML values:

```powershell
serverpod cloud variable set SERVERPOD_API_SERVER_PUBLIC_HOST <api-host>
serverpod cloud variable set SERVERPOD_API_SERVER_PUBLIC_PORT 443
serverpod cloud variable set SERVERPOD_API_SERVER_PUBLIC_SCHEME https
serverpod cloud variable set SERVERPOD_WEB_SERVER_PUBLIC_HOST <web-host>
serverpod cloud variable set SERVERPOD_WEB_SERVER_PUBLIC_PORT 443
serverpod cloud variable set SERVERPOD_WEB_SERVER_PUBLIC_SCHEME https
serverpod cloud variable set SERVERPOD_INSIGHTS_SERVER_PUBLIC_HOST <insights-host>
serverpod cloud variable set SERVERPOD_INSIGHTS_SERVER_PUBLIC_PORT 443
serverpod cloud variable set SERVERPOD_INSIGHTS_SERVER_PUBLIC_SCHEME https
```

For the default Cloud domains, `<api-host>` is
`<project-id>.api.serverpod.space`, `<web-host>` is
`<project-id>.serverpod.space`, and `<insights-host>` is
`<project-id>.insights.serverpod.space`. The database host and credentials are
injected by Cloud; do not copy the local development database into Cloud.

The existing routes serve `/t/<token>` as tracking HTML and
`/t/<token>/data` as tracking JSON. Tracking data still comes from the private
server-side token lookup and existing validation/expiry rules.

## Demo messaging and package exclusions

BulkSMS readiness may be prepared with fresh replacement credentials while
keeping `bulkSmsMode` explicitly set to `demo`. Never reuse previously exposed
credentials or import BulkSMS values from the local passwords file. Have the
owner create a replacement API token and keep its ID and secret in separate
private UTF-8 files outside the repository. Do not paste them into chat, CLI
arguments or logs.

The supported password workflow for project `safecheck` is:

```powershell
scloud --no-auto-cli-upgrade --no-analytics password set bulkSmsMode --value demo --project safecheck
scloud --no-auto-cli-upgrade --no-analytics password set bulkSmsTokenId --from-file 'C:\private\fresh-bulksms-token-id.txt' --project safecheck
scloud --no-auto-cli-upgrade --no-analytics password set bulkSmsTokenSecret --from-file 'C:\private\fresh-bulksms-token-secret.txt' --project safecheck
scloud --no-auto-cli-upgrade --no-analytics password list --project safecheck
```

Replace the example paths with the actual private files. Stop after any failed
command. Password listing shows names and statuses, not secret values; expect
`SET (User)` for these three names and preserve `googleClientSecret` and all
platform-managed authentication passwords. Listing cannot reveal or prove the
saved mode value. Successful setting of `demo` establishes the stored value;
it does not prove which configuration the running deployment loaded.

`lib/server.dart` reads these names via `pod.getPassword()` at startup.
Cloud injects passwords with the `SERVERPOD_PASSWORD_` prefix; do not add the
prefix to the names passed to `password set`. Only `live` with both nonempty
credentials selects the real sender. `demo`, missing credentials or missing
mode selects `DemoMessageSender`. Do not change to live, deploy, restart Cloud,
dispatch pending alerts or test real delivery as part of this preparation.

On 13 October 2026, attempts to set `bulkSmsMode=demo` and list password
statuses failed with socket error `errno 10057` at `api.serverpod.dev`.
No Cloud update or independent password-status verification was completed.
Fresh replacement credentials were not available to the agent.

The `.scloudignore` and root `.dockerignore` exclude
`passwords.yaml`, local database files, and `.serverpod` data. `.scloudignore` explicitly includes the
generated `web/app` release build despite the server package's `.gitignore`.
