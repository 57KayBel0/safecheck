# SafeCheck AI: three-minute demo

Use fictional journey details and a consenting test contact. Record the local
build on `codex/safecheck-trip-review-nov2`; do not imply the deployed build
contains these changes. Keep terminal secrets, authentication codes, personal
phone numbers and private incident URLs out of the recording.

## Recording script

| Time | Screen and action | Narration |
| --- | --- | --- |
| 0:00–0:20 | Trip tab, no active journey | “SafeCheck helps South African travellers agree a check-in time with their trusted contacts. It is not an emergency service.” |
| 0:20–0:50 | Describe with AI: “I'm walking from a demo library to my demo accommodation. Ask me what check-in time I want.” Answer its clarification with an exact future SAST time. | “Meta prepares a draft from my words. I clarify the time, and I remain in control of starting the journey.” |
| 0:50–1:20 | Prepare safety plan; show its actual source. Review selected contact, exact SAST deadline, zero grace and location off. Dismiss once, reopen, then confirm. | “Review starts nothing. Only confirmation starts monitoring. If Meta times out, this clearly labelled standard plan keeps setup available.” |
| 1:20–1:40 | Active journey and server countdown; point to check-in, extend and help controls, then tap I'm safe to end this journey | “The backend owns the deadline. I can check in, explicitly extend it, or request help.” |
| 1:40–2:00 | Separate two-minute journey, zero grace, location off; check **Use Meta for an incident brief**. Confirm; cut to the real expired deadline and Alerts. Show actual notification statuses. | “Missing check-in creates one incident independently of AI. WhatsApp is blocked by this Limited Trial. Demo SMS is not sent; this screen is not evidence of contact delivery.” |
| 2:00–2:35 | Show **Standard incident brief** immediately, then **AI-organized brief · facts from server records** only after genuine enrichment succeeds. Show uncertainties; resolve the incident. Caption any wait cut. | “The standard facts exist first. Genuine Muse Spark inference took 43 seconds in verification; this recording cuts the wait. The model organizes supplied facts and allowed actions. It cannot invent facts, alter timers or send messages. Missed check-in is not proof of danger.” |
| 2:35–3:00 | Show fallback/manual setup, then contribution slide or README attribution. | “When AI fails, standard guidance and monitoring remain. The original project supplied authentication, contacts, tracking and scheduling. This hackathon adds Meta planning and clarification, explicit review, companion controls, grounded incident briefs and resolution.” |

After checking in, start the separate short journey used for the missed-deadline
segment; only one journey can be active at a time. Allow at least five minutes
for the initial AI journey's exact deadline so clarification and review have time
to finish. Use recording cuts for waits; never accelerate the server clock or alter real
trip rows for a video. If Meta is unavailable, say so and record the standard
fallback honestly. Do not label a fallback as a live model response.

## Before recording

- Use a dedicated demo account and a short journey with zero grace. Keep GPS off.
- Confirm Serverpod MCP sees successful sweeps. Preserve the existing database.
- Confirm the chosen recipient accepted their SafeCheck invitation and enabled
  WhatsApp. The Sandbox allowlist alone is not contact consent.
- Keep the current `limited-trial` setting and SMS demo mode. Do not invoke any
  real-send test or probe. Real WhatsApp safety-alert delivery is unavailable.
- For a live Meta segment, privately configure `metaModelApiKey` or the server's
  `MODEL_API_KEY` and verify a real draft plus clarification. Availability only
  checks configuration.
- Run the automated tests. Keep their results separate from real-provider and
  device evidence. Dart MCP is needed for the driver-based UI walkthrough.
- Confirm the intended submission URL actually has Describe with AI, exact-time
  review, AI incident-summary opt-in and incident resolution after signing in.
  The existing hosted signed-out page renders, but its served JavaScript lacks
  the new companion RPC names. Do not call that build verified or deploy silently.
- Rehearse the whole sequence on that exact build with a dedicated demo account.
  The successful adapter inference is not proof of a genuine in-app summary.
  If the brief stays Standard/fallback, say so. Do not relabel it, inject a model
  response into the database, or present a mocked test as the browser flow.
- Record waits honestly. A caption such as “2-minute deadline elapsed; 43-second
  AI wait shortened” is appropriate only when those waits actually occurred in
  that take. A prior genuine response must be labelled previously recorded.

## Current provider evidence and restrictions (4 November)

The genuine `muse-spark-1.3` incident summary returned HTTP 200 in 43.303 seconds
using fictional data. Its validated organization preserved every supplied fact
and unknown. Incident enrichment now has a 45-second budget (formerly eight);
interactive safety plans retain 25 seconds. Neither success nor latency is
guaranteed. Record the source actually shown by the app.

This account uses the newer Twilio Limited Trial. Its approved generic template
is a connectivity probe, not a safety alert. The `limited-trial` outbox mode
fails WhatsApp locally and preserves permitted SMS fallback. Show the actual
failed/simulated status in the 1:40–2:20 segment; do not claim contact delivery.
No new real WhatsApp test is authorized. A template probe cannot verify
missed-check-in message delivery or the incident link.

## Run and record on Windows

If `serverpod start` is already running, keep that process and skip the start
command. Otherwise the owner starts the existing development environment:

```powershell
Set-Location 'C:\Users\KabeloMotshabi\safecheck\safecheck'
git branch --show-current
Set-Location safecheck_server
serverpod start
```

In a second terminal, open the local browser build:

```powershell
Start-Process msedge.exe 'http://localhost:55267/'
```

For the hosted submission, open the approved submission URL instead. A local
recording must be labelled local; localhost is not a judge-accessible live URL.
Use email sign-in and complete any verification privately before recording.
Use a dedicated demo account with fictional description and display name; hide
contact phone numbers and incident bearer URLs throughout.

Focus the browser and press **Win+Alt+R** to start/stop Xbox Game Bar recording
(enable its microphone first if using voiceover). If unavailable, use an
already configured screen recorder. Trim and join the timed segments to exactly
3:00 with visible wait-cut captions. Watch the exported file fully, upload it
with judge-accessible permissions and test the link signed out. Never record
passwords, codes, private terminals or provider consoles.

## Submission package

Provide the new three-minute video URL, repository URL and the actual live app
URL. The README video placeholder still needs the final recording. Describe
which infrastructure existed before the hackathon and which AI/review/companion
features were added. Confirm repository visibility, reuse eligibility and the
event submission rules with the organizer before publication. Publishing,
deployment and merging require the owner's approval.

## What was built during the hackathon

The original project already provided Serverpod authentication, profiles,
trusted contacts, trip lifecycle and deadline scheduling, plus the existing
tracking and messaging infrastructure. Baseline:
`2d7a2e2c5c719b6973f3c9c17b3271de1e274ea4`.

Hackathon work adds Meta journey interpretation and clarification, explicit
review before start, grounded safety plans with honest fallback, companion
controls and selected-contact/grace options, factual incident briefs with
optional bounded AI organization, consented private incident links and
resolution. This verification adds Limited Trial separation, safe provider
diagnostics and AI timeout hardening. Do not present the baseline as new work.

Remaining submission gates: final video and README link; confirmation of the
required public build and its parity with this local branch; repository access
and reuse eligibility; device walkthrough. Real WhatsApp safety-alert delivery
remains unavailable with this restricted trial. Deployment and merging remain
unapproved.
