# Twilio Limited Trial compatibility review

The owner approved this proposal on 4 November 2026. The separate template
probe and restricted outbox mode are now implemented, with mocked verification.
The local non-secret mode is `limited-trial`; credential values are preserved.
No new real WhatsApp submission, upgrade, deployment or merge is authorized.

## Evidence and limits

- The retained live-test report contains HTTP 400. It contains no numeric
  Twilio error code, response body or error description. The original recorder
  extracted status and a possible message SID; its runner discarded stdout and
  stderr. The later safe-code logger was added after the attempt. Therefore the
  exact code and wording cannot be recovered from these artifacts.
- The configured sender is valid E.164 and differs from the traditional shared
  Sandbox sender. The earlier authenticated read matched that sender and the
  configured recipient to recent inbound WhatsApp activity. This proves the
  inbound pairing, not that it equals the outbound sender selected by the
  recipient-specific trial Console request.
- The owner identifies this account as Limited Trial and uses Try out WhatsApp.
  That identifies the newer trial workflow. The local mode name `sandbox` does
  not grant the account the legacy Sandbox's free-form messaging permissions.
- An exact outbound sender/recipient comparison is pending a local copy of
  `From`, `To` and `ContentSid` from the Console-generated trial request. The
  ignored `.dart_tool/twilio_trial_reference.json` can hold that reference
  without authentication fields. Comparison reports booleans only.

## Official request contract versus SafeCheck

Twilio's [Try out WhatsApp documentation](https://www.twilio.com/docs/usage/trials/try-out-whatsapp)
restricts the trial request to the selected sender, verified recipient,
provider-supplied template and optional status callback. Its sender can vary
by product and recipient. The [legacy Sandbox documentation](https://www.twilio.com/docs/whatsapp/sandbox)
separately permits free-form replies during an open customer-service window.
An open window does not remove the newer trial's documented restrictions.

| Field | Current SafeCheck sender | Newer trial contract |
| --- | --- | --- |
| Endpoint | Messages REST API | Same endpoint |
| Authentication | Server-side account credentials | Same authentication mechanism |
| `From` | Configured WhatsApp sender | Sender from this recipient's trial request |
| `To` | Allowlisted WhatsApp recipient | Verified trial recipient |
| `Body` | Exact saved safety alert and incident link | Arbitrary text is not supported |
| `ContentSid` | Missing | Required; select a Twilio-provided trial template |
| `ContentVariables` | Absent | Not among the trial's documented editable parameters |
| `StatusCallback` | Absent | Optional |

The current form is built in
`lib/src/messaging/twilio_whatsapp_message_sender.dart`: it sends `From`, `To`
and `Body`. This is a documented incompatibility and a strong explanation for
the rejection, but it does not establish the missing historical numeric code.
For example, the general [21654 documentation](https://www.twilio.com/docs/api/errors/21654)
describes missing ContentSid when ContentVariables are supplied. SafeCheck did
not supply ContentVariables, so assigning that code to this attempt would be
guessing.

The compatible trial connectivity request would be form-encoded as follows;
the placeholders are not usable values and no request should be executed yet:

```text
POST /2010-04-01/Accounts/{AccountSid}/Messages.json
Content-Type: application/x-www-form-urlencoded

From=<Console-selected WhatsApp sender>
To=<Console-verified WhatsApp recipient>
ContentSid=<Console-provided Content Template SID>
```

Omit Body and ContentVariables. Do not invent a template SID or substitute the
legacy shared sender for the sender selected by the account's trial flow.

## Smallest safe compatible change

1. Add a trial-template connectivity probe to the opt-in verification tooling.
   Reuse the existing transport, authentication, recipient allowlist and timeout
   bounds. Accept the Console's selected ContentSid and construct only the
   allowed trial fields. Validate the configured sender/recipient against the
   Console reference locally, without printing values. Keep its result separate
   from the safety-alert outbox. A real probe remains approval-gated.
2. Explicitly distinguish newer trial-template capability from legacy free-form
   Sandbox capability. For actual SafetyAlert messages on the restricted trial,
   fail closed with a sanitized unsupported-content reason, allowing the
   existing dispatcher to consider SMS when the contact enabled it. Do not
   change SMS mode, credentials or contact permissions.
3. Preserve the alert's exact body, incident link, contact snapshot, database
   transaction, deadline processing and idempotent claims. No model, migration,
   authentication or trip-lifecycle change is required.
4. Retain HTTP status and a validated numeric Twilio code on future failures.
   Support documented five- and six-digit codes. Use a fixed reason category or
   public error-dictionary description; do not log raw response text, request
   bodies, authorization, account identifiers or phone numbers. Do not retry an
   uncertain submission automatically.

Simply replacing Body with a generic trial template in the existing alert
sender is unsafe. `MessageDispatcher` treats `sent`/`delivered` as success and
skips the SMS fallback. A generic template receipt would then suppress the
message containing the actual safety alert and incident link. The trial's
documented request does not allow injecting that content through variables.

Thus the smallest trial-compatible **connectivity** fix is the separate template
probe; it does not establish delivery of a SafeCheck safety alert. Full alert
content remains in the existing outbox/SMS path and must retain honest status
labels. No upgrade is proposed as an automatic action.

## Mock verification before any further real send

- Trial probe contains ContentSid and omits Body/ContentVariables.
- Missing or malformed template, sender-reference mismatch and unverified
  recipient conditions make no POST.
- Trial-template acceptance never marks a SafetyAlert notification successful
  or suppresses its SMS fallback.
- Failed/unsupported trial WhatsApp proceeds to SMS only for an enabled snapshot
  channel, with SMS's existing demo/live configuration untouched.
- Legacy free-form mode retains the exact stored message text.
- Five-/six-digit error codes are retained safely; raw provider text is absent.
- Repeated deadline/dispatch calls remain idempotent; ambiguous submissions are
  not automatically retried.

The probe CLI defaults to a local dry run. An exact Console reference remains
necessary before confirming outbound sender identity. Twelve probe/legacy
adapter unit tests passed; the full suite also exercises SMS fallback and
duplicate protection. Further real sends, credential changes, upgrades,
deployment and merging remain subject to the owner's approval.
