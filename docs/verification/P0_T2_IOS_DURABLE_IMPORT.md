# P0-T2 iOS durable import verification

## Scope

This disposable spike implements issue #5. It proves that a supported iOS share can cross the
Share Extension/Runner process boundary without depending on Runner being active.

It does not implement production URL recognition, canonical Reel duplicate policy, metadata,
Cues, notifications, a production repository, Android, backend services, or synchronization.
Flutter remains provisional.

## Durable sequence

```text
Share Extension
  -> validate and bound shared input
  -> write one versioned envelope to the App Group queue
  -> report Saved and complete the extension request
  -> Runner imports after cold launch or foreground entry
  -> atomically persist one Unassigned spike record
  -> acknowledge the queue file
  -> run optional work
```

Queue acknowledgement occurs only after repository persistence. A crash before acknowledgement
leaves the envelope available for replay. Replay returns the existing record by payload
fingerprint, then retries acknowledgement. Optional-work failure occurs after base persistence and
cannot remove or reclassify the Unassigned record.

## Spike contracts

`SharedCaptureEnvelope` is schema version 1. It contains a handoff UUID, receipt time, source hint,
optional bounded raw text, and at most four bounded HTTP(S) candidate URLs. The queue accepts at
most 32 KiB per envelope and processes at most 100 entries per scan. Unknown, corrupt, oversized,
misnamed, non-regular, and symbolic-link entries remain unacknowledged.

`SpikeCapture` contains a local UUID, temporary SHA-256 payload fingerprint, original handoff UUID,
capture time, and `unassigned` status. Fingerprint deduplication is spike-only. Production duplicate
behavior must use canonical Reel URLs in shared domain code.

Runner exposes only allow-listed counts and status codes to Flutter. Logs and evidence must never
contain raw text, URLs, fingerprints, queue paths, account names, device identifiers, or signing
material.

## Automated verification

Run from repository root:

```sh
make lint
flutter test
(cd ios/SharePayloadKit && swift test)
tool/check_ios_harness.sh
flutter build ios --simulator
flutter build ios --release --no-codesign
```

Swift tests cover queue reconstruction, failed writes, bounded input, replay after persistence,
identical-payload deduplication, repository failure, optional failure, corrupt input, unsupported
schema, acknowledgement, and content-free diagnostics. Flutter tests cover status rendering and
manual retry. The harness checker verifies matching deployment targets and App Groups, extension
embedding and safe APIs, shared source membership, enqueue-before-completion ordering, and Runner
cold/foreground import controls.

## Physical iPhone release matrix

Use a signed release build and a real Instagram Reel. Record counts, status codes, timestamps, and
result only. Do not capture screenshots containing private content.

| Scenario | iOS version | Instagram version | Expected content-free result | Result |
|---|---|---|---|---|
| Runner terminated before share; launch later | | | `captureCount` increases once; `pendingCount` becomes 0 | Untested |
| Runner backgrounded during share | | | Foreground import succeeds once | Untested |
| Runner foreground during share | | | Retry or next foreground imports once | Untested |
| Extension completion followed by delayed launch | | | Queue survives delay | Untested |
| Force-quit after share, then relaunch | | | Queue survives termination | Untested |
| Share identical payload twice before launch | | | One logical record; duplicate count recorded | Untested |
| Import same pending handoff twice | | | One logical record; acknowledgement succeeds | Untested |
| Tap **Simulate optional failure** after a new share | | | `saved_optional_failed`; record stays Unassigned | Untested |
| Cause import failure, restore storage, tap **Retry import** | | | Pending item imports and is acknowledged | Untested |
| Unsigned release build plus signed device run | | | Both builds pass | Untested |

Attach the sanitized completed matrix to issue #5 or its pull request. Issue #5 remains open until
all three acceptance criteria, automated commands, release build, and applicable physical rows pass.

## Later adapter contracts

- Android must provide the same versioned, bounded `SharedCapture` fields; persist before success;
  replay after process death; deduplicate repeated delivery; and acknowledge only after base save.
- Production iOS code must move URL validation and canonical duplicate policy into shared domain
  code, replace the spike repository, preserve the write/import/acknowledge ordering, and remove the
  temporary payload fingerprint.
- Neither adapter may make metadata, Cue work, networking, or notification delivery part of the
  capture transaction.

## Official sources

- Flutter, [Adding iOS app extensions](https://docs.flutter.dev/platform-integration/ios/app-extensions)
- Flutter, [Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)
- Apple, [Share](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html)
- Apple, [Handling Common Scenarios](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html)
- Apple, [Creating an App Extension](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionCreation.html)
- Apple, [Configuring App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)
- Apple, [`UIApplication.willEnterForegroundNotification`](https://developer.apple.com/documentation/uikit/uiapplication/willenterforegroundnotification)
