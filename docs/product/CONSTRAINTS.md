# NextCue Version 1 Constraints

## Status

**Binding for Version 1 and the private pilot.** Changes require an explicit product decision and, where consequential, a superseding ADR.

## Scope constraints

| Area | Constraint |
|---|---|
| Platforms | Deliver iOS and Android before the pilot; implement the iOS vertical slice first. |
| Client framework | Flutter is provisional until the ADR-003 share-capture spike passes on both platforms. |
| Content source | Accept Instagram Reel HTTP(S) URLs only. |
| Capture | Use native system sharing plus an in-app paste fallback. Durable capture precedes optional cue entry. |
| Platform APIs | Do not use Meta, Instagram, TikTok, or other social-platform APIs. |
| Media | Do not download, transcribe, proxy, cache, copy, or re-host Reel video or audio. |
| Metadata | Treat title, thumbnail, and other public link metadata as optional and failure-prone. |
| Persistence | Store product data locally. No product backend, accounts, backup, or sync. |
| Notifications | Use local notifications. Scheduling state cannot depend on notification delivery. |
| Analytics | Collect only consented, content-free lifecycle events. |
| AI | No generative AI or automatic transcription. |
| Monetization | No payment collection or subscription paywall during the pilot. |

## Architecture boundary

The intended boundary, if the Flutter spike passes, is:

```text
iOS Share Extension / Android share target
                    ↓
       normalized SharedCapture contract
                    ↓
          Dart application and domain
                    ↓
             local repository
              ↙           ↘
      local notifications   Flutter UI
```

Native Swift and Kotlin code receives, durably transfers, and acknowledges platform input. URL parsing, source recognition, duplicate policy, lifecycle transitions, and product rules belong in testable shared domain code.

The source-neutral transfer contract should remain small:

```text
SharedCapture {
  rawText
  candidateUrls
  receivedAt
  sourceHint
  optionalPurpose
  optionalReminder
}
```

This contract does not authorize additional content sources in Version 1.

## iOS constraints

- Use an iOS Share Extension.
- Treat the extension and containing application as separate processes; the app may not be running.
- Use an App Group or another officially supported shared-resource mechanism.
- Match deployment targets between the Runner and Share Extension.
- Complete durable capture before network work or optional cue entry.
- Keep extension execution and UI small enough for extension resource limits.
- Validate real Instagram payloads in release mode on physical devices.
- Do not depend on opening the containing app from the extension.

## Android constraints

- Register a share target for supported `ACTION_SEND` text payloads.
- Handle cold start, warm start, duplicate intents, and activity recreation.
- Complete durable capture before network work or optional cue entry.
- Validate real Instagram payloads on physical devices and supported Android/Instagram versions.

## URL and metadata constraints

- Treat shared text, URLs, redirects, and fetched metadata as untrusted input.
- Accept only HTTP(S) URLs matching supported Instagram Reel patterns.
- Preserve the original accepted URL and fail safely when URL patterns change.
- Do not execute arbitrary schemes or render unsanitized remote HTML.
- Enforce request timeouts, response-size limits, redirect limits, and safe content handling.
- Fetch metadata opportunistically after durable capture; it must never block saving.
- Never lose user-authored fields when metadata or source access fails.
- Do not store arbitrary shared text when no supported Reel URL is present.

## Data and privacy constraints

- Do not collect social-platform credentials or require Instagram login.
- Do not include URLs, titles, thumbnails, purposes, notes, or other content in analytics, logs, crash reports, or notifications by default.
- Store only data required for the approved product loop.
- Archive must be reversible and distinct from permanent deletion.
- Permanent deletion removes the Capture, Cue, history, and notes after confirmation.
- Provide complete local-data deletion in Settings.
- Explain that uninstalling loses local pilot data.
- Never commit credentials, signing keys, provisioning profiles, participant rosters, tokens, or environment secrets.
- Use least-privilege repository credentials and platform permissions.

## Notification constraints

- Request notification permission only after the first Unassigned Capture, after explaining daily triage and asking the user to choose a time.
- Let users control triage separately from scheduled Reel reminders.
- Hide purpose text on the lock screen by default.
- Send at most one automatic notification per Cue.
- Do not repeat missed reminders automatically.
- Suppress the daily triage cue on a day with a Due scheduled Capture.
- Notification denial or delivery failure must not hide Scheduled or Due work inside the app.

## Pilot identity and analytics constraints

- Registration and personal details live outside the product in a private pilot roster.
- Participant codes identify research participants but do not authenticate or authorize them.
- The app validates participant-code format locally and does not call a validation backend.
- Closed TestFlight and Google Play distribution control pilot access.
- Pilot participation and analytics consent are separate.
- Analytics opt-out cannot reduce product functionality.
- Remote events may include participant code, installation identifier, event name, timestamp, lifecycle state, and content-free counters only.
- Select the analytics provider during implementation planning; no provider is approved by this document.

## Reliability constraints

- The accepted URL and user-authored fields are the system of record; metadata is decoration.
- Capture must be idempotent enough to prevent repeated platform delivery from creating duplicate records.
- One canonical URL maps to one Capture in Version 1.
- Each Capture has at most one active Cue.
- Persisted transitions must follow `domain/GLOSSARY.md`.
- A Capture remains Scheduled when notification permission is absent.
- Stale and Due are derived from timestamps rather than independently mutable statuses.
- A failed optional step cannot roll back durable capture.

## Accessibility constraints

All critical flows must support screen readers, dynamic text, reduced motion, sufficient contrast, and platform-appropriate touch targets. Focus limits must not make additional Due Captures inaccessible.

## Delivery constraints

- Build small vertical slices and keep the main branch green.
- Every slice requires automated acceptance evidence plus platform-specific manual evidence when operating-system integration is involved.
- Do not claim cross-platform completion from one platform's tests.
- The first implementation work is the ADR-003 share-capture spike, not production screen development.
- Do not create backend abstractions, provider adapters, or sync schemas without an approved requirement.

## Official references

- Flutter, Adding iOS app extensions: https://docs.flutter.dev/platform-integration/ios/app-extensions
- Flutter, Writing custom platform-specific code: https://docs.flutter.dev/platform-integration/platform-channels
- Android, Receive simple data from other apps: https://developer.android.com/training/sharing/receive
- Apple, Share extensions: https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html
- Apple, Link metadata: https://developer.apple.com/documentation/linkpresentation/lpmetadataprovider
- Meta, Instagram Platform overview: https://developers.facebook.com/docs/instagram-platform/overview
