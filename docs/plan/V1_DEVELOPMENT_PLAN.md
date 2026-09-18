# NextCue Version 1 Development Plan

## Status

Approved and published to GitHub Issues. This plan covers the private ten-person pilot defined by the authoritative product documents. GitHub Issues is the implementation task system; `docs/plan/V1_ISSUE_CATALOG.md` maps every stable planning ID to its published issue.

## Outcome

Deliver a local-first iOS and Android application that lets a pilot participant capture an Instagram Reel with minimal interruption, optionally attach a Purpose and one Cue, triage unassigned Captures, receive one privacy-preserving local reminder, and explicitly mark the Capture Applied, reschedule it, or Archive it. The pilot must produce trustworthy content-free evidence without sending URLs, metadata, Purposes, or notes off-device.

The plan deliberately excludes a backend, accounts, synchronization, cloud backup, AI, media retrieval, additional content sources, projects, payments, and social features.

## Source of truth

Planning precedence follows `docs/README.md`:

1. `docs/product/PRODUCT.md` defines Version 1 behavior and validation.
2. `docs/product/CONSTRAINTS.md` defines binding delivery, privacy, platform, and reliability boundaries.
3. `docs/domain/GLOSSARY.md` defines lifecycle language, transitions, and invariants.
4. ADR-001 through ADR-003 govern accepted decisions.
5. Discovery material is context only; `docs/future/AI.md` is explicitly out of scope.

No conflicts were found among the authoritative documents.

## Planning principles

- Start with the ADR-003 risk spike. Production screen work is blocked until real Instagram payloads pass on physical iOS and Android devices.
- Deliver thin end-to-end slices that include domain behavior, persistence, UI, automated evidence, and platform evidence where applicable.
- Persist a valid Capture before metadata, Purpose, or Cue work.
- Keep native Swift and Kotlin adapters small. URL recognition, duplicate behavior, lifecycle rules, and derived views belong in shared, testable domain code.
- Keep product content local. Remote analytics is optional, separately consented, and content-free.
- Treat Due and Stale as derived views, not persisted statuses.
- Keep every leaf task small enough for one focused implementation session. Split a task before work begins if it is likely to exceed five files or two hours.
- Keep the default branch green. Merge only slices that meet the Definition of Done.

## Proposed architecture after the spike

This is provisional until Phase 0 passes.

```text
iOS Share Extension / Android ACTION_SEND target
                         │
                         ▼
          durable native handoff queue/resource
                         │
                         ▼
         normalized, untrusted SharedCapture input
                         │
                         ▼
       shared domain services and transition policies
            │                 │                │
            ▼                 ▼                ▼
     local repository   notification port   analytics port
            │                 │                │
            └──────────── Flutter UI ──────────┘
```

Boundary decisions:

- `SharedCapture` contains raw shared input and receipt context, not a validated Capture.
- The local repository is the system of record for accepted URLs and user-authored data.
- Notification scheduling is an effect of Cue changes, not the source of scheduling state.
- Analytics receives an allow-listed event DTO that cannot represent product content.
- Metadata enrichment runs after persistence and may fail without changing lifecycle state.
- A clock abstraction drives Due, Stale, skip cooldown, reminder presets, and deterministic tests.

## Phase roadmap

| Phase | Epic outcome | Entry condition | Exit gate | Mode |
|---|---|---|---|---|
| 0 | Prove or reject the provisional Flutter architecture | Approved documents only | Physical-device iOS and Android evidence plus recorded framework decision | HITL gate |
| 1 | Establish domain, persistence, URL, and app foundations | Phase 0 selects the client architecture | Lifecycle invariants and core repository behavior pass automated tests | AFK |
| 2 | Ship durable instant capture on both platforms | Phase 1 foundation | Real shares and paste fallback create/reopen exactly one durable Capture | AFK with device evidence |
| 3 | Add Purpose, Cue, local reminders, and Due focus | Phase 2 capture path | One active Cue, privacy defaults, Today limit, and View all work offline | AFK with device evidence |
| 4 | Add delayed triage and Stale handling | Phase 3 scheduling | Daily cue and one-at-a-time triage follow eligibility, cooldown, and suppression rules | AFK |
| 5 | Complete outcomes and local-data ownership | Phase 3 reminder path; Phase 4 for full navigation | Applied/Reschedule/Archive and restore/delete flows preserve all invariants | AFK |
| 6 | Instrument, harden, distribute, and operate the pilot | Product loop complete | Both platforms pass release matrix and pilot readiness review | HITL release gate |

## Dependency graph

```text
P0 share-capture spike and framework decision
  └─ P1 domain + persistence + URL + shell
       └─ P2 production capture
            ├─ P3 cues + notifications + Due views
            │    ├─ P4 delayed triage
            │    └─ P5 explicit outcomes + data ownership
            └─ P6 onboarding/consent foundations
                 └─ P6 analytics + hardening + pilot distribution
```

Phase 4 and most of Phase 5 may proceed in parallel after Phase 3 contracts are stable. Analytics provider integration must not begin until its privacy gate is approved. Release hardening waits for all product-loop phases.

## Phase details

### Phase 0 — Architecture risk gate

**Goal:** Obtain the earliest reliable evidence for the highest-risk behavior before investing in production UI.

**User stories:**

- P0-US1: Prove a real iOS Instagram share can be durably captured across extension and app process boundaries.
- P0-US2: Prove the normalized Android path across cold start, warm start, duplicate delivery, and activity recreation.
- P0-US3: Use evidence to confirm Flutter or approve the bare React Native fallback in a superseding ADR.

**Checkpoint:** Both platforms have release-mode physical-device evidence. A failed optional action cannot remove the saved record. The chosen framework, boundary, risks, and discarded spike code are recorded before Phase 1.

### Phase 1 — Domain and local-first foundation

**Goal:** Make the authoritative lifecycle executable and testable without depending on Flutter widgets, native adapters, or a remote service.

**User stories:**

- P1-US1: Persist Captures, a single active Cue, content-free transition history, Purpose, notes, and settings locally.
- P1-US2: Accept only supported Instagram Reel HTTP(S) URLs and apply canonical duplicate/restore behavior.
- P1-US3: Provide an accessible app shell, clock-driven derived views, and repeatable automated test harness.

**Checkpoint:** The glossary transition matrix and invariants pass repository/domain tests; migrations and restart recovery are verified; no backend or sync abstractions exist.

### Phase 2 — Instant capture

**Goal:** Make zero-form durable capture reliable from iOS, Android, and paste fallback.

**User stories:**

- P2-US1: Capture from the iOS Share Extension and acknowledge only after durable handoff.
- P2-US2: Capture Android `ACTION_SEND` inputs idempotently across all supported lifecycle paths.
- P2-US3: Paste a link in-app, reopen active duplicates, restore Archived duplicates, and retain usable fallback cards when metadata fails.

**Checkpoint:** A real Reel share on each platform produces exactly one recoverable Capture. Invalid input produces no record and offers paste fallback. Metadata failure cannot block or roll back capture.

### Phase 3 — Cues, reminders, and Due focus

**Goal:** Turn a Capture into one manageable future commitment without making notification delivery authoritative.

**User stories:**

- P3-US1: Add or replace a Cue using reminder presets or a custom time, with optional Purpose.
- P3-US2: Schedule one privacy-preserving local notification while respecting denial, quiet hours, and independent reminder controls.
- P3-US3: Focus Today on at most three Due Captures while keeping every Due Capture accessible in View all.

**Checkpoint:** Cue state survives restart and timezone changes; one Capture has at most one active Cue and automatic notification; denial or delivery failure does not hide Scheduled/Due work.

### Phase 4 — Delayed triage

**Goal:** Help users make a small number of deliberate backlog decisions without guilt or silent data loss.

**User stories:**

- P4-US1: Explain triage after the first Unassigned Capture and request permission only in the approved context.
- P4-US2: Review the oldest eligible Capture and choose Use later, Not useful, or Skip for now, up to three decisions per session.
- P4-US3: Move 30-day-old Unassigned Captures into a transparent Stale view without deleting or archiving them.

**Checkpoint:** Eligibility, seven-day skip cooldown, three-item limit, Stale derivation, and suppression on days with Due work pass clock-controlled tests.

### Phase 5 — Outcomes and data ownership

**Goal:** Close the product loop with explicit outcomes and make all local data controllable by the user.

**User stories:**

- P5-US1: Open the original Reel and ask for an explicit outcome after returning to NextCue.
- P5-US2: Mark Applied with an optional note, Reschedule, or Archive without conflating opening with application.
- P5-US3: Restore Archived Captures, permanently delete individual Captures, and delete all local data with clear confirmation.

**Checkpoint:** Every glossary transition is covered; notification cancellation follows transitions; Archive remains reversible; deletion removes Capture, Cue, history, metadata, Purpose, and note.

### Phase 6 — Pilot evidence, hardening, and release

**Goal:** Run a privacy-respecting ten-person pilot whose technical and behavioral evidence can support a continuation decision.

**User stories:**

- P6-US1: Onboard a participant with locally validated research code, separate pilot/analytics consent, and local-data-loss disclosure.
- P6-US2: Select and integrate a managed analytics provider using only an allow-listed, content-free event contract.
- P6-US3: Pass cross-platform reliability/accessibility/privacy checks and distribute controlled TestFlight and Google Play builds with an operator runbook.

**Checkpoint:** Release builds pass the device matrix, analytics opt-out preserves functionality, prohibited content cannot enter telemetry/logs/crash reports, and pilot operators can recruit, support, interview, and evaluate the four-week threshold.

## Verification strategy

### Automated evidence

- Domain unit tests cover every transition and invariant in `GLOSSARY.md`.
- Property/table tests cover URL extraction, canonicalization, duplicate delivery, and unsupported input.
- Repository tests cover atomic capture, one active Cue, migration, deletion, and restart recovery.
- Clock-controlled tests cover Due, Stale, skip cooldown, weekend presets, quiet hours, and daily-triage suppression.
- Widget/integration tests cover the capture confirmation, add-cue, triage, Today/View all, outcome, Archive, Settings, and destructive confirmations.
- Analytics contract tests reject URLs, metadata, Purpose, notes, arbitrary properties, and events without consent.

### Platform evidence

- iOS release build on physical devices: share extension cold start, app terminated/background/foreground, duplicate platform delivery, extension timeout/failure, notification denial, notification tap, and return from Instagram/browser.
- Android release build on physical devices: cold/warm share, activity recreation, duplicate intents, process death, notification denial/tap, and return from Instagram/browser.
- Evidence is platform-specific. Passing one platform never closes the other platform's task.

### Accessibility evidence

- VoiceOver and TalkBack labels/order for every critical flow.
- Dynamic text at the supported maximum without hidden decisions.
- Reduced-motion behavior, sufficient contrast, platform touch targets, and keyboard/focus sanity where applicable.
- Today's three-item focus never prevents access to View all.

## Definition of Done for every leaf task

- Acceptance criteria and focused automated tests pass.
- Relevant lint, formatting, static analysis, and release build checks pass.
- Platform work includes named device/OS/app-version manual evidence.
- Accessibility behavior is checked for any changed critical UI.
- Logs, crash context, notifications, and analytics contain no prohibited content.
- Documentation/ADR is updated when a durable decision changes.
- No out-of-scope backend, sync, AI, media, or additional-source abstraction is introduced.
- The branch is reviewable, contains no secrets or signing material, and leaves the application buildable.

## GitHub issue model

- **Phase epic:** one issue per phase, labeled `feature`; contains the phase outcome, entry/exit gates, and child user stories.
- **User story:** one sub-issue per user-visible or enabling outcome, labeled `feature`; contains a short plain-language explanation, end-to-end acceptance criteria, dependencies, and child tasks.
- **Task:** one leaf sub-issue per focused implementation session, labeled `task`; contains an AI-executable brief with objective, implementation guidance, constraints/non-goals, task-specific Definition of Done, concrete acceptance criteria, and verification evidence.
- **Bug:** reserved for defects discovered during implementation or pilot validation; labeled `bug` and linked to the affected story/epic.
- Dependencies are expressed in each body as `Blocked by`. Sub-issue linkage expresses ownership, not execution order.

The exact issue bodies, links, and hierarchy are in `docs/plan/V1_ISSUE_CATALOG.md`.

## GitHub tracker index

| Phase | Epic |
|---|---|
| P0 — Architecture risk gate | [#2](https://github.com/theanadimukt/nextcue/issues/2) |
| P1 — Domain and local-first foundation | [#12](https://github.com/theanadimukt/nextcue/issues/12) |
| P2 — Instant capture | [#22](https://github.com/theanadimukt/nextcue/issues/22) |
| P3 — Cues, reminders, and Due focus | [#32](https://github.com/theanadimukt/nextcue/issues/32) |
| P4 — Delayed triage | [#42](https://github.com/theanadimukt/nextcue/issues/42) |
| P5 — Outcomes and data ownership | [#52](https://github.com/theanadimukt/nextcue/issues/52) |
| P6 — Pilot evidence, hardening, and release | [#62](https://github.com/theanadimukt/nextcue/issues/62) |

## Risks and mitigations

| Risk | Impact | Mitigation / earliest evidence |
|---|---|---|
| iOS extension cannot meet reliable durable handoff requirements with Flutter | High | Phase 0 iOS-first release-device spike; retain bare React Native fallback and require an explicit ADR decision |
| Instagram share payloads vary by app/platform/version | High | Capture raw fixtures without private content, parse defensively in shared code, keep paste fallback, maintain a device/app-version matrix |
| Duplicate delivery creates inconsistent records | High | Canonical uniqueness, idempotent repository operation, native delivery identifier where available, restart/duplicate tests |
| Local notifications are denied or dropped | Medium | Keep Cue state local and authoritative; show Due in-app; test denial; never infer delivery |
| Daily triage becomes guilt-inducing | Medium | One-item copy, maximum three decisions, no backlog count in notification, qualitative pilot interviews |
| Metadata becomes unavailable or unsafe | Medium | Persist first, apply strict time/size/redirect/content limits, render fallback cards, never store untrusted HTML |
| Telemetry leaks content | High | Separate consent, closed event/property schema, privacy tests, provider configuration review, opt-out parity |
| Local-only storage causes unexpected loss | Medium | Clear onboarding/Settings disclosure and delete controls; do not imply backup |
| Solo-developer Flutter/Swift/Kotlin learning cost threatens schedule | Medium | Spike before product work, small native boundary, decision gate with an explicit fallback |
| Pilot evidence is too weak for a continuation decision | High | Define events/interview cadence before distribution and rehearse the evaluation report with test data |

## Decisions required during execution

1. **Framework gate after Phase 0:** confirm Flutter or write a superseding ADR selecting bare React Native.
2. **Supported OS/device matrix:** set minimum iOS/Android versions from pilot devices before production adapter work closes.
3. **Local database and notification libraries:** select only after the framework gate using maintenance, privacy, license, platform, and edge-case evidence.
4. **Analytics provider gate:** compare managed providers against consent, deletion, EU/UK data handling, schema control, SDK size, offline behavior, and cost; approve before integration.
5. **Reminder semantics:** define exact timezone/DST behavior and quiet-hours deferral in the Cue contract before Phase 3 implementation.
6. **Metadata policy:** decide whether Version 1 enables opportunistic public metadata by default or ships URL-only cards first; capture remains independent either way.

## Release sequence

1. Internal spike evidence build (not pilot-distributed).
2. Internal alpha completing capture → Cue → Due → explicit outcome on both platforms.
3. Privacy and accessibility review build with analytics disabled by default.
4. Closed pilot release candidate with consented analytics and operator rehearsal.
5. Ten-person TestFlight/Google Play pilot with weekly interviews.
6. Four-week continuation review against the approved 6-of-10 behavioral threshold.

## Plan acceptance checklist

- [x] Every planned story maps to approved Version 1 behavior or a required delivery enabler.
- [x] Dependencies are ordered around the ADR-003 gate and local-first architecture.
- [x] Every leaf task in the issue catalog has acceptance and verification evidence.
- [x] Phase checkpoints prevent cross-platform or privacy work from being inferred complete.
- [x] Deferred AI and other explicit exclusions do not appear in implementation scope.
- [x] User approves issue granularity, dependencies, and HITL gates.
- [x] GitHub labels and epic → story → task hierarchy are published.
- [x] GitHub issue links replace symbolic-only tracker references.
