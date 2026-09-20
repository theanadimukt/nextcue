# P0-T1 iOS Share Extension harness

## Scope and assumptions

This disposable harness tests the iOS extension boundary for issue #4. It does not create a Capture, validate Instagram Reel patterns, fetch metadata, open the containing app, or implement issue #5 durable import behavior.

The checked-in bundle identifiers and App Group identifier are provisional:

- Runner: `app.nextcue.nextcue`
- Share Extension: `app.nextcue.nextcue.ShareExtension`
- App Group: `group.app.nextcue.share-spike`

An Apple Developer account must register these identifiers, or replace all occurrences with available identifiers, before device signing. No Apple Team identifier, signing certificate, provisioning profile, device identifier, or shared payload belongs in Git.

## Boundary and recorded data

The host application supplies untrusted `NSExtensionItem` and `NSItemProvider` values. The extension accepts one input item, inspects at most four attachments, caps plain text at 4,096 characters, and accepts only HTTP(S) URLs. Unsupported schemes, oversized text, missing HTTP(S) URLs, unsupported representations, and excessive input are rejected.

The extension writes only this allow-listed structural evidence to App Group `UserDefaults`:

- schema version;
- supported/unsupported representation result;
- source representation (`text`, `url`, or `unsupported`);
- character count;
- HTTP(S) URL count;
- host category (`instagram`, `other`, or `none`);
- content-free rejection reason; and
- receipt timestamp.

It never writes or logs shared text, full URLs, URL paths, query strings, credentials, or device identifiers. Runner reads this evidence through a narrow Flutter method channel and displays it in the disposable harness.

`representationSupported: true` means the host supplied bounded plain text or an HTTP(S) URL. It does not mean the URL is an Instagram Reel and does not create a Capture. Reel recognition and durable import remain outside issue #4.

## Limitations for issue #5

- The extension and Runner are separate processes and cannot communicate directly. Runner must import from the App Group after launch or resume; the extension must never depend on opening Runner.
- `UserDefaults` readback proves this harness can write sanitized evidence. It is not the atomic, idempotent, crash-recoverable queue required for durable Capture import.
- Host applications can expose the same share as URL, plain text, attributed text, or multiple providers. Durable import must test real Instagram versions and continue across rejected representations.
- App Group access depends on registered identifiers, matching entitlements, and valid profiles for both targets. A compile-only or simulator build does not prove device access.
- Extension lifetime and memory are constrained. Durable import must finish its local handoff before completing the request and defer Flutter startup, network work, metadata, and optional UI.

## Automated verification

Run from the repository root:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
(cd ios/SharePayloadKit && swift test)
tool/check_ios_harness.sh
flutter build ios --simulator
flutter build ios --release --no-codesign
```

The Swift tests cover supported URL and text shapes, unsupported schemes and representations, text bounds, missing URLs, later valid representations, rejection evidence preservation, and content minimization. `check_ios_harness.sh` verifies matching iOS 15 deployment targets, matching App Group entitlements, extension-safe API enforcement, and extension embedding.

On 20 September 2026, formatting, Flutter analysis, Flutter widget tests, Swift tests, configuration/property-list validation, direct Runner and Share Extension type-checking against the iPhoneOS 27.0 SDK, a Flutter iOS simulator build, and an unsigned release-device build passed. Both built Runner bundles contained `PlugIns/ShareExtension.appex`; Runner and extension reported an iOS 15.0 minimum deployment target, and the extension contained the expected share-services activation rule. No simulator runtime interaction or physical-device acceptance evidence has been recorded.

## Physical iPhone release procedure

1. In Apple Developer Certificates, Identifiers & Profiles, register the Runner App ID, Share Extension App ID, and App Group above. Associate both App IDs with the App Group.
2. Open `ios/Runner.xcworkspace` in Xcode. Select the same Apple Team for Runner and ShareExtension. Confirm both targets show the App Groups capability with `group.app.nextcue.share-spike`, use iOS 15.0, and have valid automatic-signing profiles.
3. Connect a physical iPhone, enable Developer Mode if required, and install Runner in release mode with `flutter run --release`. Do not save the device identifier in the repository or evidence.
4. For each state below, share a real Instagram Reel to NextCue. Confirm the extension reports a supported share, tap **Done**, then open or return to Runner and tap **Refresh evidence**. Confirm evidence contains only the allow-listed fields above.
5. From Notes or another host, share plain text without an HTTP(S) URL. Confirm the extension rejects it and Runner shows only content-free rejection evidence. Confirm photo/file-only sharing does not expose the extension or is rejected if a host invokes it.
6. Capture the evidence table below without URLs, shared text, account names, device identifiers, screenshots containing private content, signing material, or provisioning data. Attach sanitized evidence to issue #4 or its pull request.

| App state | iOS version | Instagram version | Supported share | Runner evidence | Result |
|---|---|---|---|---|---|
| Terminated | | | | | Untested |
| Background | | | | | Untested |
| Foreground | | | | | Untested |
| Unsupported text | | N/A | Rejected | Content-free only | Untested |

Issue #4 must remain open until all three real Instagram lifecycle rows pass on a physical iPhone in release mode.

## Official sources

- Flutter, [Adding iOS app extensions](https://docs.flutter.dev/platform-integration/ios/app-extensions): matching deployment targets, extension embedding order, App Groups, separate processes, and release-mode physical-device testing.
- Apple, [Share](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/Share.html): extension context input, validation, completion, and cancellation.
- Apple, [Handling Common Scenarios](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html): separate containers and App Group shared resources.
- Apple, [Creating an App Extension](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionCreation.html): lifecycle, fast launch, constrained memory, and focused extension UI.
- Apple, [Configuring App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups): App Group registration and target capability setup.
