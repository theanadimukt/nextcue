# ADR-003: Use Flutter Provisionally, Gated by a Share-Capture Spike

## Status

Accepted — provisional pending spike

## Date

2026-09-14

## Context

NextCue must run on iOS and Android. Its central technical risk is not ordinary application UI; it is receiving inconsistent Instagram share payloads, durably transferring them across platform process boundaries, and making capture reliable during cold start and failure.

The founder is highly experienced with React and TypeScript, has older Ionic experience, and has no current Flutter, Swift, Kotlin, or React Native experience. Flutter would introduce Dart and Flutter learning cost. React Native would reuse existing language skills, but incoming-share integration still crosses native boundaries. As of this decision, Expo documents incoming sharing as experimental and notes an iOS approach that is not officially supported by Apple.

No application code exists, so the framework remains inexpensive to reconsider.

## Decision

Use Flutter provisionally for shared UI, application logic, and domain behavior. Use small Swift and Kotlin adapters for platform share receipt and durable transfer.

Do not begin production screen development until a time-boxed spike proves this path with real Instagram payloads:

1. Receive a shared Reel on iOS in release mode on a physical device.
2. Persist it durably through an App Group or supported shared resource.
3. Display the Unassigned Capture after app cold start.
4. Repeat the normalized contract on Android across cold start, warm start, duplicate delivery, and activity recreation.
5. Demonstrate that failed optional cue or metadata work cannot lose the saved Capture.

Implement the iOS vertical slice first because its extension process and shared-resource boundary carry greater risk. Both platforms must pass before the ten-person pilot.

## Alternatives considered

### React Native with Expo

- Reuses React and TypeScript experience and supports native extension through custom native work.
- The simplest documented incoming-share path is experimental, and the central feature cannot depend on behavior documented as potentially unstable on iOS.
- Not selected initially; reconsider if the Flutter spike exposes unacceptable learning or integration cost.

### Bare React Native with custom native modules

- Reuses TypeScript for most product code and permits explicit native integration.
- Still requires Swift/Kotlin work and a custom cross-platform boundary for the product's riskiest feature.
- Retained as the primary fallback.

### Separate native Swift and Kotlin applications

- Provides direct access to each platform and the clearest native extension model.
- Duplicates UI, domain behavior, persistence rules, and test work for a solo developer.
- Rejected for the pilot unless cross-platform frameworks fail the spike.

### Ionic/Capacitor

- Reuses web experience.
- The product is centered on native sharing and notifications rather than web content, so a web-view-first architecture does not remove the important native work.
- Rejected as the default path.

## Consequences

- Flutter is not considered final merely because it appears in product documentation.
- The spike is production-risk discovery and may be discarded.
- The founder must learn enough Swift and Kotlin to own the native adapters regardless of cross-platform framework.
- The shared domain must not depend on Flutter widgets or a particular storage plugin.
- Plugin selection requires maintenance, privacy, licensing, platform, and edge-case review.
- Failure of the spike triggers an explicit Flutter-versus-bare-React-Native comparison and a superseding ADR if the choice changes.

## References

- Flutter app extensions: https://docs.flutter.dev/platform-integration/ios/app-extensions
- Flutter platform channels: https://docs.flutter.dev/platform-integration/platform-channels
- React Native native modules: https://reactnative.dev/docs/turbo-native-modules-introduction
- Expo Sharing: https://docs.expo.dev/versions/v55.0.0/sdk/sharing/
