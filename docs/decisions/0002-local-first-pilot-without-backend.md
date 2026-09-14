# ADR-002: Run the Pilot Local-First Without a Product Backend

## Status

Accepted

## Date

2026-09-14

## Context

The private pilot tests whether contextual resurfacing causes useful Reels to be applied. Its approved workflow requires durable capture, local views, local notifications, and explicit outcomes on one device.

A custom backend would add authentication, synchronization, data-retention, security, operational, and privacy work before any of those capabilities are necessary for the core behavioral test.

Pilot operators still need to recruit testers, associate interviews with participants, and observe content-free funnel events.

## Decision

Store all product content locally and use local notifications. Do not build a product backend, accounts, authentication, cloud backup, or synchronization for Version 1.

Recruit testers through an external form and maintain personal details in a separate private roster. Give accepted testers a participant code entered during onboarding. The code is a research identifier, not authentication. Closed TestFlight and Google Play distribution controls access.

Use a managed analytics service only for separately consented, content-free lifecycle events. Provider selection is deferred to implementation planning.

## Alternatives considered

### Build accounts and synchronization before the pilot

- Supports backup, reinstall recovery, and multi-device use.
- Greatly expands scope and private-data exposure without testing the central value proposition.
- Rejected until validated behavior demonstrates a need.

### Use a small custom analytics backend

- Provides complete control of event storage.
- Creates infrastructure, security, deletion, and operational responsibilities for ten users.
- Rejected in favor of a managed, privacy-configured analytics service.

### Collect evidence through interviews only

- Avoids remote telemetry.
- Relies on memory and cannot measure funnel drop-off reliably.
- Rejected as the sole method; interviews remain necessary alongside opt-in events.

## Consequences

- Uninstalling the app loses local product data during the pilot and must be disclosed.
- Cross-device use, backup, and restore are unavailable.
- Participant-code validation is local format validation, not remote authorization.
- Users who decline analytics retain full product functionality.
- URLs, metadata, Purposes, and notes never enter remote analytics.
- A future backend requires a new decision covering authentication, sync conflict behavior, privacy, deletion, migration, and operating cost.

## Reconsider when

Revisit this decision only when validated users require accounts, multi-device synchronization, backup, paid entitlements, collaboration, server-side processing, or remote push behavior that local architecture cannot provide.
