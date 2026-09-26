# Batched device verification session

One session clears many rows in [`DEFERRED_EVIDENCE.md`](DEFERRED_EVIDENCE.md) instead of one
session per task. Before a phase gate, run the procedure for every open row assigned to that gate
and attach sanitized results to the owning issues.

## Before the session

1. List the open rows for the gate: filter `DEFERRED_EVIDENCE.md` by gate and status.
2. Confirm each owning issue is labeled `verification-debt` and is still open.
3. Confirm signing identifiers are registered and both platforms sign: Runner, Share Extension,
   App Group, and Android application ID. Never commit signing material.
4. Prepare a scratch Instagram account state if needed. Do not record account names.

## iOS

Build and install a signed release build on a physical iPhone (`flutter run --release`). For each
row, run the procedure in the referenced document and record counts, status codes, app versions, and
results only.

| Step | Evidence |
|---|---|
| Real Reel shared with Runner terminated, then launched | `captureCount` increases once, `pendingCount` returns to 0 |
| Same, Runner backgrounded | import succeeds once on foreground |
| Same, Runner foregrounded | one logical record, no duplicate |
| Force-quit between share and launch | queue survives; import on next launch |
| Identical payload shared twice before launch | one logical record, duplicate counted |
| Optional step made to fail | record remains Unassigned, optional failure counted |
| Storage failure caused, then restored | retry imports and acknowledges pending work |
| Unsupported plain text shared | content-free rejection only |
| Simulator interactive share | extension appears in the share sheet; App Group readback visible |
| Unsigned release build plus signed install | both succeed |

## Android

Build and install a signed release build on a physical device (`flutter build apk --release`). Cover
cold start, warm start, duplicate `ACTION_SEND` delivery, activity recreation, process death, and
return from Instagram or the browser.

## Accessibility

With VoiceOver and TalkBack enabled, walk each critical flow at the maximum supported dynamic text
size with reduced motion enabled. Record only pass/fail, flow name, platform, and OS version.

## After the session

1. Attach sanitized evidence to each owning issue: a completed matrix, not screenshots with private
   content.
2. Mark rows `Cleared (date, link)` in `DEFERRED_EVIDENCE.md`.
3. Remove the `verification-debt` label and close an issue once all of its rows are cleared.
4. Record any refuted expectation as a defect issue rather than adjusting the matrix in place.

## Never record

Shared text, full URLs, URL paths or query strings, queue paths, payload fingerprints, account
names, device identifiers, screenshots containing private content, signing certificates, or
provisioning profiles.
