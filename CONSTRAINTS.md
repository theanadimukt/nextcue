# NextCue Constraints

## Binding Version 1 constraints

| Area | Constraint |
|---|---|
| Platforms | Ship Flutter applications for iOS and Android. |
| Content source | Support Instagram Reel links only. |
| Capture | Use the native system share flow plus an in-app paste fallback. |
| Platform APIs | Do not use Meta, Instagram, TikTok, or other social-platform APIs. |
| Media | Do not download, copy, transcribe, proxy, cache, or re-host Reel video/audio. |
| Preview | Treat title, thumbnail, and other metadata as optional and failure-prone. |
| Storage | Local-first. Add account-based sync only after validation and a separate privacy/security design. |
| AI | No generative AI or automatic transcription in Version 1. |
| Monetization | No subscription paywall until the core action-completion behavior is validated. |
| Scope | Prefer the smallest coherent capture → commitment → reminder → action → completion loop. |

## Platform integration constraints

### iOS

- Implement an iOS Share Extension.
- The extension and containing app do not communicate directly and the app may not be running.
- Use an App Group or another officially supported shared-resource mechanism when transferring captured input.
- Match the deployment target between the Runner and Share Extension targets.
- Keep extension execution short and resilient; do not depend on network metadata before completing capture.
- Validate actual Instagram payloads on physical devices and supported iOS/Instagram versions.

### Android

- Register a share target for supported `ACTION_SEND` text payloads.
- Handle cold start, warm start, duplicate intents, and activity recreation.
- Validate actual Instagram payloads on physical devices and supported Android/Instagram versions.

### Shared Flutter layer

- Normalize platform payloads into an explicit source-neutral contract, for example:

```text
SharedCapture {
  rawText
  candidateUrls
  receivedAt
  sourceHint
}
```

- Parsing, source recognition, duplicate policy, and capture status belong in testable Dart domain code.
- Native Swift/Kotlin code should only receive and safely transfer platform data.
- Do not rely on a Flutter plugin until its maintenance, platform implementation, privacy behavior, licensing, and edge cases have been reviewed.

## URL and metadata constraints

- Treat all shared text, URLs, redirects, and fetched metadata as untrusted input.
- Accept only HTTP(S) URLs in Version 1.
- Recognize supported Instagram Reel URL patterns, but preserve the original input and fail safely when patterns change.
- Do not execute arbitrary schemes or render unsanitized remote HTML.
- Enforce request timeouts, response-size limits, redirect limits, and safe content handling for any metadata fetch.
- Metadata failure must never lose the URL or block manual capture.
- A Reel can be private, deleted, region-blocked, age-restricted, or inaccessible; the user must still retain their own note and action.

## Privacy and security constraints

- Do not collect social account credentials.
- Do not require Instagram login.
- Do not include private URLs, notes, takeaways, or action text in analytics, logs, crash reports, or notifications by default.
- Store only data needed for the product loop and provide local deletion.
- Never commit credentials, signing keys, provisioning profiles, tokens, or environment secrets.
- Use least-privilege repository credentials and platform permissions.
- Request notification permission contextually, after the user first schedules a reminder.

## Reliability and accessibility constraints

- The saved URL and user-entered fields are the system of record; metadata is decoration.
- Notification denial or delivery failure must not hide due work from the app.
- All critical flows must work with screen readers, dynamic text, reduced motion, sufficient contrast, and touch targets appropriate to each platform.
- App state transitions must be deterministic and covered by unit tests.
- Capture operations must be idempotent enough to prevent duplicate records from repeated platform delivery.

## Version 1 exclusions

- TikTok, YouTube Shorts, articles, podcasts, and screenshots.
- Instagram Saved-library synchronization.
- Embedded or offline Reel playback.
- Automatic transcription or summarization.
- AI-generated plans.
- Calendar and task-manager integrations.
- Web, desktop, and browser-extension clients.
- Folders, knowledge graphs, semantic search, and complex tagging.
- Multiple actions per captured item.
- Social feeds, public profiles, accountability groups, streaks, points, or leaderboards.
- Paid subscriptions.

## Delivery constraints

- Build in small vertical slices with a green main branch.
- Every slice has automated acceptance evidence plus platform-specific manual evidence when OS integration is involved.
- Android can be built on Linux; iOS changes require verification on macOS/Xcode and final share behavior requires a physical iOS device.
- Do not claim cross-platform completion based on one platform’s successful test.

## Official references

- Flutter, Adding iOS app extensions: https://docs.flutter.dev/platform-integration/ios/app-extensions
- Flutter, Writing custom platform-specific code: https://docs.flutter.dev/platform-integration/platform-channels
- Android, Receive simple data from other apps: https://developer.android.com/develop/ui/compose/sharing/receive
- Apple, Share extensions: https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html
- Apple, Link metadata: https://developer.apple.com/documentation/linkpresentation/lpmetadataprovider
- Meta, Instagram Platform overview: https://developers.facebook.com/documentation/instagram-platform/overview
