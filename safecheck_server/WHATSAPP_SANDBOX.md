# Twilio WhatsApp Sandbox

Sandbox sending is disabled by default. Configure these private Serverpod
password names in the existing local run-mode section; preserve all other keys:

| Name | Value |
| --- | --- |
| `twilioWhatsAppMode` | `sandbox` to opt in; omit for simulation |
| `twilioAccountSid` | Your private Twilio account SID |
| `twilioAuthToken` | Your private Twilio auth token |
| `twilioWhatsAppFrom` | Sandbox number in `+E.164` format, without `whatsapp:` |
| `twilioWhatsAppSandboxRecipients` | Comma-separated South African phone allowlist |

Restart through Serverpod MCP after changing startup configuration. No keys
belong in Flutter or source control. The sender never logs provider bodies or
copies them into failure reasons. BulkSMS mode is configured independently.

Each allowlisted recipient must join your Sandbox using its Twilio join code.
The contact must also enable WhatsApp in SafeCheck. This implementation sends
the exact stored alert body as a free-form message: the recipient must have
messaged the Sandbox within the previous 24 hours. Outside that window Twilio
requires an approved template; template sending is not implemented here.
Sandbox messages can incur charges.

Only newly created messages after sender startup, at most 15 minutes old, are
eligible. Pre-existing pending alerts are not replayed. Provider acceptance maps
to the existing `sent` state, which does not establish delivery. Delivery status
callbacks are not implemented. Ambiguous submissions are marked failed with an
unknown-outcome explanation and are not automatically retried; SMS fallback may
still be attempted according to its own configuration. A process crash after
submission can still cause a duplicate when the existing outbox recovers.

Unit tests use a fake transport and send nothing. To test manually, join the
Sandbox and open its conversation window, enable only your own test number,
create a fresh trip with that accepted contact and trigger an alert. Check the
Twilio console as well as SafeCheck. Do not infer delivery from a queued status.

The opt-in `test/manual/whatsapp_sandbox_live_test.dart` automates one fictional
missed-check-in submission to exactly one configured recipient, after checking
recent inbound conversation activity. It uses an isolated test database, disables
SMS and polls the provider for `delivered`/`read`. See
[the demo runbook](../HACKATHON_DEMO.md) for the explicit command. Ordinary tests
skip this real submission. The test reads private local development entries; it
does not copy credentials into source or replace authentication keys.

Reference: [Twilio Sandbox documentation](https://www.twilio.com/docs/whatsapp/sandbox).
# Limited Trial compatibility update — 4 November 2026

Set the non-secret `twilioWhatsAppMode` to `limited-trial` for the newer
restricted trial. This blocks free-form WhatsApp safety-alert submissions
locally while preserving enabled SMS fallback, stored facts and duplicate
protection. `sandbox` and `legacy-sandbox` are for the traditional Sandbox only.
Do not change mode to bypass trial limitations.

The separate `TwilioTrialProbe` uses the existing account credentials and only
the Console reference's exact `From`, `To` and approved `ContentSid`. It sends
neither `Body` nor `ContentVariables`; it is not an outbox sender, creates no
incident/message rows and never reports safety-alert delivery. Accepted is not
delivered. It attempts at most once per instance and never retries uncertain
submissions. Sanitized diagnostics retain only HTTP status, a validated numeric
Twilio code and a fixed reason; provider descriptions can contain private data
and are discarded.

Save only those three reference fields privately in the gitignored root
`.dart_tool/twilio_trial_reference.json`. Obtain them from the existing Console
example without clicking Send. From the server directory,
`dart run tool/twilio_trial_probe.dart` performs a local dry run with zero network
requests and verifies sender identity and recipient allowlisting. The explicit
`--approve-real-send` flag is reserved for a separately approved controlled
test. **No new real WhatsApp send is currently authorized.**

Official trial request: https://www.twilio.com/docs/usage/trials/try-out-whatsapp
The original HTTP 400 capture lacks the response body/numeric code; its exact
code cannot be recovered or inferred. New diagnostics will capture numeric
codes safely for future approved requests.
