# NextCue Version 1 GitHub Issue Catalog

## How to use this catalog

This catalog is published to GitHub Issues. Phase epics and user stories use `feature`, leaf work uses `task`, and each child is attached using native GitHub sub-issues. The repository label `bug` remains available for defects discovered later. Symbolic IDs are stable planning identifiers linked to their published issues below.

Each story is a thin, demonstrable slice. `AFK` means it can be implemented after its blockers without a product decision. `HITL` means a named human review or decision is required to close it.

## P0 — Prove the cross-platform capture architecture

**GitHub:** [#2](https://github.com/theanadimukt/nextcue/issues/2)

**Type:** Epic / HITL
**Label:** `feature`
**Blocked by:** None
**Outcome:** Decide the Version 1 client architecture from real release-mode capture evidence before production UI begins.

**Epic acceptance criteria:**

- [ ] Real Instagram Reel shares are durably recovered on physical iOS and Android devices across required lifecycle cases.
- [ ] Failed optional cue/metadata work cannot remove the saved Capture.
- [ ] An ADR confirms Flutter or supersedes it with the approved fallback and records evidence.

### P0-US1 — Prove durable iOS share capture

**GitHub:** [#3](https://github.com/theanadimukt/nextcue/issues/3)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** None
**Story:** As a pilot user, I can share a Reel from Instagram while NextCue is not running and find it safely stored when I later open the app.

**Acceptance criteria:**

- [ ] A release-mode iOS Share Extension accepts a real supported payload and durably transfers it through an App Group or supported shared resource.
- [ ] The containing app imports the item after cold start without relying on the extension to open it.
- [ ] Repeated delivery is idempotent and invalid input creates no Capture.

#### P0-T1 — Build the minimal iOS extension harness

**GitHub:** [#4](https://github.com/theanadimukt/nextcue/issues/4)

**Label:** `task`
**Blocked by:** None
**What to build:** A disposable, minimal client plus iOS Share Extension that records sanitized payload shape and lifecycle evidence without implementing production screens or metadata fetching.

**Acceptance criteria:**

- [ ] Runner and extension deployment targets, signing capabilities, and App Group access align.
- [ ] The extension handles supported text/URL inputs within extension limits and rejects unsupported input safely.
- [ ] No credentials, user content fixtures, or provisioning material enter Git.

**Verification:** Release build on a physical iPhone; capture evidence for app terminated/background/foreground; static analysis/build checks pass.

#### P0-T2 — Prove durable import and failure isolation on iOS

**GitHub:** [#5](https://github.com/theanadimukt/nextcue/issues/5)

**Label:** `task`
**Blocked by:** P0-T1
**What to build:** A durable handoff queue and minimal import path that acknowledges only persisted work, imports after cold start, and keeps capture independent from optional operations.

**Acceptance criteria:**

- [ ] Process termination between extension completion and app launch does not lose an accepted item.
- [ ] Duplicate import produces one logical record.
- [ ] Simulated cue/metadata failure leaves the record recoverable as Unassigned.

**Verification:** Physical-device kill/restart and duplicate-delivery matrix; automated queue/repository tests; release build.

### P0-US2 — Prove durable Android share capture

**GitHub:** [#6](https://github.com/theanadimukt/nextcue/issues/6)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P0-US1 (normalized contract learned on iOS)
**Story:** As a pilot user, I can share a Reel to NextCue on Android and get one durable Capture regardless of the app/activity lifecycle.

**Acceptance criteria:**

- [ ] A release-mode Android share target accepts supported `ACTION_SEND` text from Instagram.
- [ ] Cold start, warm start, duplicate intent, activity recreation, and process death converge on one durable item.
- [ ] The produced normalized input matches the source-neutral contract used by iOS.

#### P0-T3 — Build the minimal Android share-target harness

**GitHub:** [#7](https://github.com/theanadimukt/nextcue/issues/7)

**Label:** `task`
**Blocked by:** P0-US1
**What to build:** A disposable Android share receiver that normalizes supported intent data and hands it to the minimal shared import path.

**Acceptance criteria:**

- [ ] Manifest intent filters accept only the intended text sharing path.
- [ ] Candidate URLs, receipt time, and source hint are normalized without validating product rules natively.
- [ ] Unsupported or malformed intents fail safely and do not persist arbitrary text.

**Verification:** Release build and real Instagram share on a physical Android device; focused adapter tests.

#### P0-T4 — Prove Android lifecycle and duplicate resilience

**GitHub:** [#8](https://github.com/theanadimukt/nextcue/issues/8)

**Label:** `task`
**Blocked by:** P0-T3
**What to build:** The smallest durable delivery mechanism needed to replay/import pending shares safely after lifecycle interruption.

**Acceptance criteria:**

- [ ] Cold/warm start and activity recreation each import the same normalized contract.
- [ ] Repeated intents and process restart do not create duplicate logical records.
- [ ] Optional work failure cannot roll back durable capture.

**Verification:** Physical-device lifecycle matrix, automated duplicate/replay tests, release build.

### P0-US3 — Decide and bootstrap the production client architecture

**GitHub:** [#9](https://github.com/theanadimukt/nextcue/issues/9)

**Type:** User story / HITL
**Label:** `feature`
**Blocked by:** P0-US1, P0-US2
**Story:** As the product owner, I can choose the Version 1 client architecture from documented reliability and ownership evidence rather than preference.

**Acceptance criteria:**

- [ ] Evidence compares reliability, native complexity, testability, learning cost, and delivery risk.
- [ ] ADR-003 is confirmed or superseded; no ambiguous provisional status remains.
- [ ] The approved project scaffold builds/tests on both platforms before feature work starts.

#### P0-T5 — Run the framework decision review

**GitHub:** [#10](https://github.com/theanadimukt/nextcue/issues/10)

**Label:** `task`
**Blocked by:** P0-T2, P0-T4
**What to build:** A concise evidence report and decision matrix comparing the proven Flutter path with the bare React Native fallback only if spike evidence exposes unacceptable risk.

**Acceptance criteria:**

- [ ] The report cites device scenarios, failures, native code surface, and unresolved risks.
- [ ] The owner records a go/no-go decision and minimum supported OS/device matrix.
- [ ] A superseding ADR is created if the framework or boundary changes.

**Verification:** Human approval recorded in the ADR/issue; all evidence artifacts are reproducible and content-safe.

#### P0-T6 — Bootstrap production quality gates

**GitHub:** [#11](https://github.com/theanadimukt/nextcue/issues/11)

**Label:** `task`
**Blocked by:** P0-T5
**What to build:** The approved client scaffold with formatting, lint/static analysis, unit/widget test commands, debug/release builds, secret exclusions, and CI-ready scripts.

**Acceptance criteria:**

- [ ] A clean checkout can run the documented checks and build both platforms with local signing assumptions clearly separated.
- [ ] Domain code can be tested without widgets or native adapters.
- [ ] Generated output, secrets, signing files, and local environment files are ignored.

**Verification:** Clean-build rehearsal; all baseline checks pass; no product screen implementation is included.

## P1 — Establish the local-first domain foundation

**GitHub:** [#12](https://github.com/theanadimukt/nextcue/issues/12)

**Type:** Epic / AFK
**Label:** `feature`
**Blocked by:** P0
**Outcome:** Make the authoritative lifecycle, local data, URL rules, derived views, and app shell executable and testable.

**Epic acceptance criteria:**

- [ ] Every glossary transition and invariant has automated acceptance evidence.
- [ ] Restart/migration tests preserve authoritative local data.
- [ ] The application contains no backend, auth, sync, or cloud-storage abstraction.

### P1-US1 — Persist Captures and enforce lifecycle invariants

**GitHub:** [#13](https://github.com/theanadimukt/nextcue/issues/13)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P0-US3
**Story:** As a pilot user, my accepted URL, Purpose, Cue, note, status, and content-free history remain correct across app restarts.

**Acceptance criteria:**

- [ ] The local schema represents Capture, optional active Cue, optional user fields, settings, metadata decoration, and content-free transition history.
- [ ] Domain transitions enforce one active Cue, explicit Applied, reversible Archive, and permanent Delete.
- [ ] Due and Stale are derived from a controllable clock rather than stored statuses.

#### P1-T1 — Implement the local schema and repository contract

**GitHub:** [#14](https://github.com/theanadimukt/nextcue/issues/14)

**Label:** `task`
**Blocked by:** P0-T6
**What to build:** A migration-capable local store and repository API for atomic capture, retrieval, update, cue replacement, history, settings, and deletion.

**Acceptance criteria:**

- [ ] Stable identifiers, timestamps, original/canonical URL, source type, status, optional fields, and cue scheduling identifiers are represented.
- [ ] Capture persistence is atomic and independent from optional follow-up writes.
- [ ] Migration/restart tests preserve user-authored fields and uniqueness.

**Verification:** Repository integration tests against the real local store; restart and migration fixture tests; static analysis.

#### P1-T2 — Implement and test the lifecycle transition service

**GitHub:** [#15](https://github.com/theanadimukt/nextcue/issues/15)

**Label:** `task`
**Blocked by:** P1-T1
**What to build:** Shared domain commands/policies for Add cue, Use later, Skip, Archive/Not useful, Restore, Applied, Reschedule, and Delete.

**Acceptance criteria:**

- [ ] Every allowed glossary transition has a passing test and every invalid transition fails without partial state.
- [ ] Applied is never inferred from opening; Applied and Archived remain mutually exclusive.
- [ ] Cue replacement/history behavior is content-free and transactional.

**Verification:** Table-driven transition suite and invariant tests; no UI/native dependency in the domain package.

### P1-US2 — Recognize supported Reel URLs and handle duplicates

**GitHub:** [#16](https://github.com/theanadimukt/nextcue/issues/16)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P1-US1
**Story:** As a pilot user, only a supported Instagram Reel URL becomes a Capture, and sharing the same Reel never creates a confusing duplicate.

**Acceptance criteria:**

- [ ] Untrusted text yields candidate HTTP(S) URLs and accepts only approved Reel patterns.
- [ ] Original URL is preserved while a canonical value enforces uniqueness.
- [ ] Active duplicates reopen; Archived duplicates restore to Unassigned; invalid input creates no record.

#### P1-T3 — Implement defensive URL extraction and canonicalization

**GitHub:** [#17](https://github.com/theanadimukt/nextcue/issues/17)

**Label:** `task`
**Blocked by:** P1-T1
**What to build:** Shared parsing/recognition that handles common surrounding text, URL variants, fragments/query parameters, and safe rejection.

**Acceptance criteria:**

- [ ] Only HTTP(S) Instagram Reel patterns are accepted; arbitrary schemes/domains/text are rejected.
- [ ] Canonicalization is deterministic and preserves the original accepted URL separately.
- [ ] A fixture table documents supported and rejected shapes without private user data.

**Verification:** Table/property tests for extraction, canonicalization, adversarial schemes, malformed input, and multiple candidates.

#### P1-T4 — Implement idempotent capture and duplicate recovery policy

**GitHub:** [#18](https://github.com/theanadimukt/nextcue/issues/18)

**Label:** `task`
**Blocked by:** P1-T2, P1-T3
**What to build:** One repository/domain operation that creates a unique Capture or returns/restores the existing Capture according to status.

**Acceptance criteria:**

- [ ] Concurrent/repeated delivery of the same canonical URL yields one Capture.
- [ ] Active duplicate returns the existing record without losing Purpose/Cue/note.
- [ ] Archived duplicate restores to Unassigned with no active Cue and records content-free history.

**Verification:** Concurrency/idempotency integration tests and transition assertions.

### P1-US3 — Navigate an accessible, clock-driven app shell

**GitHub:** [#19](https://github.com/theanadimukt/nextcue/issues/19)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P1-US1
**Story:** As a pilot user, I can reach Today, Unassigned, Stale, Applied, Archived, and Settings through an accessible shell whose time-based views are deterministic.

**Acceptance criteria:**

- [ ] Navigation exposes all approved views without inventing extra product scope.
- [ ] View queries use injected clock/timezone behavior.
- [ ] Critical shell controls support screen readers, dynamic text, reduced motion, contrast, and touch targets.

#### P1-T5 — Build the app shell and empty/loading/error states

**GitHub:** [#20](https://github.com/theanadimukt/nextcue/issues/20)

**Label:** `task`
**Blocked by:** P0-T6, P1-T1
**What to build:** Minimal navigation and view containers for the approved focused views and Settings, including honest empty and recoverable error states.

**Acceptance criteria:**

- [ ] Every approved destination is reachable and deep-linkable by an internal route contract.
- [ ] Empty/loading/error states do not imply sync, backup, or unavailable features.
- [ ] Dynamic text and screen-reader traversal preserve access to all destinations.

**Verification:** Widget/navigation tests plus VoiceOver/TalkBack shell smoke checks.

#### P1-T6 — Add deterministic clock, query, and accessibility test harnesses

**GitHub:** [#21](https://github.com/theanadimukt/nextcue/issues/21)

**Label:** `task`
**Blocked by:** P1-T2, P1-T5
**What to build:** Test utilities for clock/timezone control, seeded repositories, lifecycle fixtures, semantic labels, and repeatable view snapshots/assertions.

**Acceptance criteria:**

- [ ] Tests can cross Due, Stale, skip, weekend, quiet-hour, and DST boundaries without wall-clock waits.
- [ ] Shared fixtures use domain glossary language.
- [ ] Accessibility checks are runnable in focused CI/test commands.

**Verification:** Example tests prove boundary control on at least Due and Stale; documented commands pass.

## P2 — Deliver durable instant capture

**GitHub:** [#22](https://github.com/theanadimukt/nextcue/issues/22)

**Type:** Epic / AFK
**Label:** `feature`
**Blocked by:** P1
**Outcome:** Make real iOS/Android sharing and paste fallback converge on one durable zero-form capture path.

**Epic acceptance criteria:**

- [ ] Real supported shares on both platforms persist before optional UI/network work.
- [ ] Invalid input creates no record and offers paste fallback.
- [ ] Metadata and optional cue failures never remove authoritative data.

### P2-US1 — Capture a Reel from the iOS Share Extension

**GitHub:** [#23](https://github.com/theanadimukt/nextcue/issues/23)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P1-US2
**Story:** As an iPhone pilot user, I see Saved quickly after sharing a supported Reel and may close immediately without losing it.

**Acceptance criteria:**

- [ ] Production extension durably hands off a normalized SharedCapture before acknowledging Saved.
- [ ] Saved offers Add cue, while dismissal leaves the Capture Unassigned.
- [ ] Invalid input explains failure and directs the user to paste fallback without creating a record.

#### P2-T1 — Productionize the iOS native adapter and durable queue

**GitHub:** [#24](https://github.com/theanadimukt/nextcue/issues/24)

**Label:** `task`
**Blocked by:** P0-T2, P1-T4
**What to build:** Replace/discard spike shortcuts with a small production Swift adapter, supported shared resource, acknowledgement/replay semantics, and content-safe diagnostics.

**Acceptance criteria:**

- [ ] Adapter only receives/transfers platform input; product URL/duplicate/lifecycle rules stay shared.
- [ ] Queue items are acknowledged only after successful durable import and safely retried after interruption.
- [ ] Diagnostics contain identifiers/states only, never raw URLs/shared text.

**Verification:** Adapter/integration tests and the iOS release-device lifecycle matrix.

#### P2-T2 — Build the iOS Saved/Add cue and invalid-input surfaces

**GitHub:** [#25](https://github.com/theanadimukt/nextcue/issues/25)

**Label:** `task`
**Blocked by:** P2-T1
**What to build:** Minimal extension confirmation and error UI that asks no required questions after a valid save.

**Acceptance criteria:**

- [ ] Valid capture shows Saved only after persistence and presents optional Add cue.
- [ ] Closing leaves the new record Unassigned.
- [ ] Invalid/unsupported input states that nothing was saved and explains the in-app paste fallback.

**Verification:** UI tests where feasible; physical-device timing, dismissal, VoiceOver, dynamic-text, and failure checks.

### P2-US2 — Capture a Reel from Android sharing

**GitHub:** [#26](https://github.com/theanadimukt/nextcue/issues/26)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P1-US2
**Story:** As an Android pilot user, sharing a supported Reel creates one durable Capture and lets me continue without mandatory organization.

**Acceptance criteria:**

- [ ] Production adapter handles cold/warm start, recreation, duplicate intents, and process restart.
- [ ] The shared capture result offers optional Add cue and otherwise remains Unassigned.
- [ ] Invalid input creates no record and explains paste fallback.

#### P2-T3 — Productionize the Android adapter and replay path

**GitHub:** [#27](https://github.com/theanadimukt/nextcue/issues/27)

**Label:** `task`
**Blocked by:** P0-T4, P1-T4
**What to build:** Replace/discard spike shortcuts with a small production Kotlin adapter and lifecycle-safe delivery/replay contract.

**Acceptance criteria:**

- [ ] Product validation remains shared; native code normalizes and transfers only.
- [ ] Lifecycle interruption and repeated intent converge on one imported Capture.
- [ ] Diagnostics do not contain raw shared content or accepted URLs.

**Verification:** Adapter/integration tests and Android release-device lifecycle matrix.

#### P2-T4 — Build Android capture confirmation and invalid-input recovery

**GitHub:** [#28](https://github.com/theanadimukt/nextcue/issues/28)

**Label:** `task`
**Blocked by:** P2-T3
**What to build:** Fast confirmation/error presentation appropriate to Android lifecycle entry, with optional Add cue and paste-fallback guidance.

**Acceptance criteria:**

- [ ] Saved is never shown before durable import.
- [ ] Dismissal leaves the Capture Unassigned and does not loop on relaunch.
- [ ] Unsupported input produces no record and a recoverable next step.

**Verification:** UI/integration checks across cold/warm entry; TalkBack and dynamic-text manual evidence.

### P2-US3 — Capture by paste and survive duplicate or unavailable content

**GitHub:** [#29](https://github.com/theanadimukt/nextcue/issues/29)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P1-US2, P1-US3
**Story:** As a pilot user, I can paste a Reel link when sharing fails, and existing or unavailable Reels remain manageable without losing my context.

**Acceptance criteria:**

- [ ] Paste uses the same validation/idempotency path as native shares.
- [ ] Active duplicate opens the existing Capture; Archived duplicate restores it.
- [ ] Optional metadata failure leaves a fallback card with Open, replace URL, Archive, and Delete.

#### P2-T5 — Build the in-app paste fallback and duplicate routing

**GitHub:** [#30](https://github.com/theanadimukt/nextcue/issues/30)

**Label:** `task`
**Blocked by:** P1-T4, P1-T5
**What to build:** An accessible paste form and result routing for new, active duplicate, restored duplicate, and invalid outcomes.

**Acceptance criteria:**

- [ ] Input is trimmed/validated without persisting arbitrary text.
- [ ] Each capture outcome has accurate confirmation and opens the correct record.
- [ ] Paste cannot create a second record for an existing canonical URL.

**Verification:** Widget/integration tests for all outcomes; screen-reader and clipboard-denied checks.

#### P2-T6 — Add failure-tolerant metadata and fallback cards

**GitHub:** [#31](https://github.com/theanadimukt/nextcue/issues/31)

**Label:** `task`
**Blocked by:** P2-T5
**What to build:** Optional post-persistence public metadata enrichment with strict safety limits plus a URL-first fallback card and replace-URL flow.

**Acceptance criteria:**

- [ ] Fetch runs after durable capture with timeout, size, redirect, scheme, and content handling limits.
- [ ] Failure/private/deleted content preserves URL, Purpose, Cue, note, and lifecycle.
- [ ] Remote HTML is never executed/rendered unsanitized and metadata never enters telemetry.

**Verification:** Unit/integration tests for timeout, redirect loop, oversized response, malformed metadata, offline use, and replacement uniqueness.

## P3 — Schedule Cues and focus Due work

**GitHub:** [#32](https://github.com/theanadimukt/nextcue/issues/32)

**Type:** Epic / AFK
**Label:** `feature`
**Blocked by:** P2
**Outcome:** Let users attach one future Cue, receive one private local reminder, and access every Due commitment.

**Epic acceptance criteria:**

- [ ] One Capture has at most one active Cue and one automatic notification.
- [ ] Permission/delivery failure does not alter Scheduled state or hide Due work.
- [ ] Today shows at most three Due items and View all exposes the rest.

### P3-US1 — Add or replace a Cue with optional Purpose

**GitHub:** [#33](https://github.com/theanadimukt/nextcue/issues/33)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P2
**Story:** As a pilot user, I can describe what a Reel is for and choose when it should return, without Purpose being required.

**Acceptance criteria:**

- [ ] Later today, Tomorrow, This weekend, and custom date/time resolve predictably in local time.
- [ ] Saving creates/replaces exactly one active Cue and moves the Capture to Scheduled.
- [ ] Closing/cancelling optional entry never rolls back the existing Capture.

#### P3-T1 — Define reminder time and timezone semantics

**GitHub:** [#34](https://github.com/theanadimukt/nextcue/issues/34)

**Label:** `task`
**Blocked by:** P1-T6
**What to build:** A documented/tested Cue time contract for presets, custom input, weekend setting, timezone changes, DST gaps/folds, and past-time validation.

**Acceptance criteria:**

- [ ] Each preset has deterministic rules and accessible user-facing resolution.
- [ ] DST/timezone behavior and quiet-hours interaction are explicitly decided.
- [ ] Invalid/past selections fail without changing an existing Cue.

**Verification:** Clock/timezone table tests covering boundaries and owner approval of semantics.

#### P3-T2 — Build Add cue and atomic Cue replacement

**GitHub:** [#35](https://github.com/theanadimukt/nextcue/issues/35)

**Label:** `task`
**Blocked by:** P3-T1, P1-T2
**What to build:** Shared command plus accessible UI for optional Purpose and required reminder time, used after capture and from existing Capture detail.

**Acceptance criteria:**

- [ ] Purpose alone never assigns; a valid time is required.
- [ ] Replacement removes the prior active Cue, preserves content-free history, and never duplicates notifications.
- [ ] Persistence failure leaves the prior valid state intact and explains recovery.

**Verification:** Domain/repository/widget tests plus restart and rapid-double-submit checks.

### P3-US2 — Receive private, controllable local reminders

**GitHub:** [#36](https://github.com/theanadimukt/nextcue/issues/36)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P3-US1
**Story:** As a pilot user, I receive at most one useful reminder per Cue, with private content by default and controls that do not affect saved scheduling state.

**Acceptance criteria:**

- [ ] Local scheduling/cancellation follows Cue changes and terminal outcomes.
- [ ] Purpose is hidden by default; explicit setting enables preview.
- [ ] Scheduled-reminder control, quiet hours, denial, and delivery failure never delete or unschedule the Cue.

#### P3-T3 — Implement the local notification scheduling port

**GitHub:** [#37](https://github.com/theanadimukt/nextcue/issues/37)

**Label:** `task`
**Blocked by:** P3-T2
**What to build:** Shared notification intents plus iOS/Android adapters for idempotent schedule, replace, cancel, and deep-link identifiers.

**Acceptance criteria:**

- [ ] One deterministic notification identifier maps to the active Cue.
- [ ] Replacement/cancel are idempotent and reconcile after app restart.
- [ ] Permission denial/error is observable without changing domain state.

**Verification:** Adapter tests, restart reconciliation tests, and physical-device schedule/replace/cancel/deny evidence on both platforms.

#### P3-T4 — Implement privacy preview, quiet hours, and reminder controls

**GitHub:** [#38](https://github.com/theanadimukt/nextcue/issues/38)

**Label:** `task`
**Blocked by:** P3-T1, P3-T3
**What to build:** Settings and scheduling policy for purpose preview opt-in, weekend time, quiet hours, and scheduled-reminder enable/disable independent from triage.

**Acceptance criteria:**

- [ ] Default notification text contains no Purpose or other private content.
- [ ] Quiet-hour handling follows the approved deterministic rule and avoids duplicate notifications.
- [ ] Disabling notifications preserves active Cues and Due visibility.

**Verification:** Policy/widget tests plus lock-screen previews and permission/control checks on both platforms.

### P3-US3 — Focus Today without hiding overdue work

**GitHub:** [#39](https://github.com/theanadimukt/nextcue/issues/39)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P3-US1
**Story:** As a pilot user, I see a manageable set of up to three Due Captures today and can always reach every additional Due Capture.

**Acceptance criteria:**

- [ ] Due is derived from active Cue time and Today shows a deterministic maximum of three.
- [ ] View all exposes every remaining Due Capture with no destructive prioritization.
- [ ] Notification taps open the intended Capture or a safe Due fallback.

#### P3-T5 — Build Today and View all queries and screens

**GitHub:** [#40](https://github.com/theanadimukt/nextcue/issues/40)

**Label:** `task`
**Blocked by:** P3-T2, P1-T6
**What to build:** Clock-driven ordering and accessible presentation for focused Today cards and the complete Due list.

**Acceptance criteria:**

- [ ] Today never renders more than three Due cards and uses stable documented ordering.
- [ ] View all contains all Due items and remains reachable at large text sizes.
- [ ] Empty states distinguish no Due work from notification permission state.

**Verification:** Query/widget tests at 0/1/3/4/many items, timezone boundary, dynamic text, VoiceOver/TalkBack.

#### P3-T6 — Route reminder taps and preserve return context

**GitHub:** [#41](https://github.com/theanadimukt/nextcue/issues/41)

**Label:** `task`
**Blocked by:** P3-T3, P3-T5
**What to build:** Robust notification deep-link routing for cold/warm app entry, missing/deleted targets, and Cue replacement.

**Acceptance criteria:**

- [ ] Valid tap opens the intended current Capture without marking an outcome.
- [ ] Stale identifiers route to a safe current view without crash or data mutation.
- [ ] Cold/warm routes are idempotent and accessible.

**Verification:** Integration tests and physical-device notification-tap matrix on iOS/Android.

## P4 — Guide delayed triage

**GitHub:** [#42](https://github.com/theanadimukt/nextcue/issues/42)

**Type:** Epic / AFK
**Label:** `feature`
**Blocked by:** P3
**Outcome:** Prompt and support one-at-a-time decisions for eligible Unassigned Captures without guilt, repetition, or hidden commitments.

**Epic acceptance criteria:**

- [ ] Permission is requested only in the contextual first-Unassigned flow.
- [ ] Daily cue, eligibility, skip cooldown, three-decision maximum, and Due-day suppression work deterministically.
- [ ] Stale items remain visible and are never silently archived/deleted.

### P4-US1 — Enable daily triage in context

**GitHub:** [#43](https://github.com/theanadimukt/nextcue/issues/43)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P2, P3-US2
**Story:** As a pilot user with my first Unassigned Capture, I understand daily triage, choose a time, and decide whether to grant notification permission.

**Acceptance criteria:**

- [ ] Education appears after the first Unassigned Capture rather than at generic launch.
- [ ] The user chooses time/enabled state before the contextual OS permission request.
- [ ] Declining or disabling triage leaves full capture, Cue, and in-app triage functionality.

#### P4-T1 — Build first-Unassigned triage education and settings

**GitHub:** [#44](https://github.com/theanadimukt/nextcue/issues/44)

**Label:** `task`
**Blocked by:** P2, P1-T5
**What to build:** One-time contextual explanation, daily time selection, enabled state, and later Settings controls.

**Acceptance criteria:**

- [ ] Trigger is based on first durable Unassigned Capture and is not repeated after a recorded decision.
- [ ] Copy says Review one Reel and does not expose backlog size or imply obligation.
- [ ] Settings can change/disable triage independently from scheduled reminders.

**Verification:** State/widget tests for first/repeat/dismiss/change/disable and accessibility checks.

#### P4-T2 — Schedule and suppress the daily triage cue

**GitHub:** [#45](https://github.com/theanadimukt/nextcue/issues/45)

**Label:** `task`
**Blocked by:** P4-T1, P3-T3
**What to build:** A local daily triage scheduler that requests permission contextually, avoids content previews, and suppresses days containing Due work.

**Acceptance criteria:**

- [ ] Permission is requested only after explanation and chosen time.
- [ ] No cue is sent when disabled, no eligible item exists, or at least one scheduled Capture is Due that day.
- [ ] Denial/delivery failure is reflected in Settings without hiding in-app triage.

**Verification:** Clock/scheduler tests and physical-device permission/suppression checks on both platforms.

### P4-US2 — Triage up to three eligible Captures

**GitHub:** [#46](https://github.com/theanadimukt/nextcue/issues/46)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P4-US1, P3-US1
**Story:** As a pilot user, I review the oldest eligible Unassigned Capture and make one clear decision at a time, with an optional invitation to continue up to three.

**Acceptance criteria:**

- [ ] Selection excludes Stale and seven-day skipped items and orders oldest first.
- [ ] Use later creates one Cue; Not useful Archives; Skip preserves Unassigned and sets cooldown.
- [ ] A session ends after three decisions and never traps access to remaining Captures elsewhere.

#### P4-T3 — Implement triage eligibility and session policy

**GitHub:** [#47](https://github.com/theanadimukt/nextcue/issues/47)

**Label:** `task`
**Blocked by:** P1-T2, P1-T6
**What to build:** Shared query/session rules for oldest eligible selection, skip timestamp/cooldown, continuation, and maximum three decisions.

**Acceptance criteria:**

- [ ] Eligibility exactly matches Unassigned, non-Stale, outside seven-day cooldown.
- [ ] Skip does not change capture time or reset Stale age.
- [ ] Session count is ephemeral/persisted only as needed for interruption safety and cannot exceed three decisions.

**Verification:** Clock-controlled table tests at cooldown/Stale boundaries and interrupted-session tests.

#### P4-T4 — Build the one-item triage decision flow

**GitHub:** [#48](https://github.com/theanadimukt/nextcue/issues/48)

**Label:** `task`
**Blocked by:** P4-T3, P3-T2
**What to build:** Accessible one-Capture presentation with Use later, Not useful, Skip for now, and optional continue/finish behavior.

**Acceptance criteria:**

- [ ] Use later reuses the Cue UI with optional Purpose.
- [ ] Not useful clearly maps to reversible Archive; Skip explains seven-day effect.
- [ ] After each successful decision the next item is offered until the limit or exhaustion.

**Verification:** Widget/integration tests for every decision, failure rollback, 1/2/3 limits, and screen-reader focus.

### P4-US3 — Review Stale Captures transparently

**GitHub:** [#49](https://github.com/theanadimukt/nextcue/issues/49)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P4-US2
**Story:** As a pilot user, I can find Unassigned Captures that are at least 30 days old and choose what to do without the app silently discarding them.

**Acceptance criteria:**

- [ ] Stale is derived at 30 days from capture time and does not mutate persisted status.
- [ ] Stale items are excluded from active triage but visible in their own view.
- [ ] The user can Add cue, Archive, open, or delete from the Stale path.

#### P4-T5 — Implement Stale derivation and boundary-safe queries

**GitHub:** [#50](https://github.com/theanadimukt/nextcue/issues/50)

**Label:** `task`
**Blocked by:** P1-T6, P4-T3
**What to build:** Repository/domain queries that classify Unassigned items at the exact 30-day boundary while preserving skip semantics.

**Acceptance criteria:**

- [ ] 30-day threshold and timezone behavior are deterministic.
- [ ] Scheduled, Applied, and Archived items never appear as Stale.
- [ ] Skip has no effect on capture age or Stale classification.

**Verification:** Clock-controlled boundary and status matrix tests.

#### P4-T6 — Build the Stale view and actions

**GitHub:** [#51](https://github.com/theanadimukt/nextcue/issues/51)

**Label:** `task`
**Blocked by:** P4-T5, P3-T2
**What to build:** Accessible Stale list/detail behavior using existing Open, Add cue, Archive, and Delete actions.

**Acceptance criteria:**

- [ ] View explains why items are present without guilt or deletion threat.
- [ ] Actions reuse authoritative commands and update the list immediately.
- [ ] Large lists and dynamic text do not hide access or destructive confirmations.

**Verification:** Widget/integration tests and VoiceOver/TalkBack checks.

## P5 — Record outcomes and guarantee data ownership

**GitHub:** [#52](https://github.com/theanadimukt/nextcue/issues/52)

**Type:** Epic / AFK
**Label:** `feature`
**Blocked by:** P3; integrates with P4 navigation
**Outcome:** Complete the Apply-or-close loop and make Archive, restore, individual deletion, and total deletion trustworthy.

**Epic acceptance criteria:**

- [ ] Opening a Reel never implies Applied.
- [ ] Applied, Reschedule, and Archive transitions/cancellation are correct after app return.
- [ ] Archive is reversible and permanent deletion removes all associated local data.

### P5-US1 — Open a Reel and request an explicit outcome

**GitHub:** [#53](https://github.com/theanadimukt/nextcue/issues/53)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P3-US3, P2-US3
**Story:** As a pilot user, I can open the original Reel and, when I return, decide what happened without NextCue guessing.

**Acceptance criteria:**

- [ ] Only validated HTTP(S) original/replacement URLs are launched in Instagram or browser.
- [ ] App lifecycle return offers Applied, Reschedule, and Archive for the intended Capture.
- [ ] Dismissal, app kill, or launch failure does not change lifecycle state.

#### P5-T1 — Implement safe external opening and return context

**GitHub:** [#54](https://github.com/theanadimukt/nextcue/issues/54)

**Label:** `task`
**Blocked by:** P2-T6, P3-T6
**What to build:** A safe URL launch port and local pending-return context that survives normal lifecycle changes without claiming completion.

**Acceptance criteria:**

- [ ] Arbitrary schemes and invalid/replaced URLs are rejected with recovery options.
- [ ] Return context identifies the Capture but never mutates status automatically.
- [ ] Missing/deleted context fails safely and does not show an outcome sheet for the wrong Capture.

**Verification:** Adapter/integration tests and physical-device open/return/cancel/failure matrix.

#### P5-T2 — Build the explicit outcome prompt

**GitHub:** [#55](https://github.com/theanadimukt/nextcue/issues/55)

**Label:** `task`
**Blocked by:** P5-T1
**What to build:** Accessible return prompt/detail state with Applied, Reschedule, Archive, and dismiss-later behavior.

**Acceptance criteria:**

- [ ] No option is preselected and copy does not imply that opening equals watching/applying.
- [ ] Reschedule reuses Cue replacement; Archive explains reversible removal.
- [ ] Dismissal leaves the Capture Due/Scheduled and accessible.

**Verification:** Widget/integration tests for every choice and interruption; screen-reader focus/manual checks.

### P5-US2 — Apply, reschedule, or archive a Due Capture

**GitHub:** [#56](https://github.com/theanadimukt/nextcue/issues/56)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P5-US1, P3-US1
**Story:** As a pilot user, I can explicitly record success with an optional private note, choose a new Cue, or remove the Capture from active work without claiming success.

**Acceptance criteria:**

- [ ] Applied is one explicit action with optional note and no active Cue/notification afterward.
- [ ] Reschedule atomically replaces the active Cue and records content-free history.
- [ ] Archive cancels active notification and remains distinct from Applied.

#### P5-T3 — Implement Applied and optional private note

**GitHub:** [#57](https://github.com/theanadimukt/nextcue/issues/57)

**Label:** `task`
**Blocked by:** P5-T2, P3-T3
**What to build:** Applied command/UI, optional note entry, notification cancellation, and Applied view update.

**Acceptance criteria:**

- [ ] One tap can mark Applied without requiring a note.
- [ ] Note stays local and never appears in notifications, logs, crash context, or analytics.
- [ ] Failure is transactional and does not lose the active Cue until transition succeeds.

**Verification:** Domain/repository/widget tests, restart check, and privacy inspection.

#### P5-T4 — Complete Reschedule and Archive outcomes

**GitHub:** [#58](https://github.com/theanadimukt/nextcue/issues/58)

**Label:** `task`
**Blocked by:** P5-T2, P3-T2, P3-T3
**What to build:** Outcome wiring that reuses atomic Cue replacement and reversible Archive, with idempotent notification effects.

**Acceptance criteria:**

- [ ] Reschedule returns Scheduled with one active Cue and preserves history.
- [ ] Archive removes active Cue/cancels notification and never records Applied.
- [ ] Repeated taps/retries cannot duplicate history or effects.

**Verification:** Transition/integration/widget tests and notification reconciliation checks.

### P5-US3 — Restore, delete, or erase local data

**GitHub:** [#59](https://github.com/theanadimukt/nextcue/issues/59)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P5-US2, P4-US3
**Story:** As a pilot user, I can reverse Archive, permanently remove one Capture, or erase all local product data with clear consequences.

**Acceptance criteria:**

- [ ] Archived view supports Restore to Unassigned with no active Cue.
- [ ] Individual deletion removes Capture, Cue, history, metadata, Purpose, and note after confirmation.
- [ ] Delete all local data clears product/analytics identifiers and notifications as defined, then returns to a safe onboarding state.

#### P5-T5 — Build Archived view, Restore, and individual Delete

**GitHub:** [#60](https://github.com/theanadimukt/nextcue/issues/60)

**Label:** `task`
**Blocked by:** P5-T4, P2-T6
**What to build:** Archived list/detail, restore action, and destructive individual-delete confirmation shared by fallback/Stale/terminal views.

**Acceptance criteria:**

- [ ] Restore yields Unassigned/no Cue and duplicate recapture produces the same result.
- [ ] Delete confirmation distinguishes permanent deletion from Archive.
- [ ] Delete cancels effects and removes all associated rows/data atomically.

**Verification:** Repository/widget/integration tests, restart check, and accessibility check for confirmation/focus.

#### P5-T6 — Build Settings data disclosure and Delete all local data

**GitHub:** [#61](https://github.com/theanadimukt/nextcue/issues/61)

**Label:** `task`
**Blocked by:** P5-T5, P4-T1
**What to build:** Settings disclosure that uninstall loses pilot data plus a strongly confirmed total local erasure operation and notification cleanup.

**Acceptance criteria:**

- [ ] Disclosure is visible in onboarding and Settings without implying cloud backup.
- [ ] Delete all requires deliberate confirmation, handles partial-effect retry safely, and clears all product records/settings as specified.
- [ ] After completion, no scheduled app notifications or user-authored content remain locally.

**Verification:** Full-store integration test, notification cleanup test, restart/onboarding check, and manual destructive-flow review.

## P6 — Instrument, harden, and run the private pilot

**GitHub:** [#62](https://github.com/theanadimukt/nextcue/issues/62)

**Type:** Epic / HITL
**Label:** `feature`
**Blocked by:** P2-P5
**Outcome:** Produce privacy-safe pilot evidence and controlled release builds that can support the four-week continuation decision.

**Epic acceptance criteria:**

- [ ] Participant identity and analytics consent remain separate and local product behavior is unchanged when analytics is off.
- [ ] Only approved content-free events/properties can leave the device.
- [ ] Both release builds pass reliability, privacy, accessibility, distribution, and operator-readiness gates.

### P6-US1 — Onboard a private-pilot participant

**GitHub:** [#63](https://github.com/theanadimukt/nextcue/issues/63)

**Type:** User story / AFK
**Label:** `feature`
**Blocked by:** P1-US3; may proceed alongside P3-P5
**Story:** As an accepted tester, I can enter my participant code, understand local-only storage, and separately choose analytics consent without creating an account.

**Acceptance criteria:**

- [ ] Participant code is format-validated locally and is never presented as authentication/authorization.
- [ ] Pilot participation and analytics consent are distinct decisions.
- [ ] Declining analytics preserves every product capability.

#### P6-T1 — Build local participant-code onboarding

**GitHub:** [#64](https://github.com/theanadimukt/nextcue/issues/64)

**Label:** `task`
**Blocked by:** P1-T5
**What to build:** Accessible pilot onboarding with local format validation, research-code storage, local-data-loss disclosure, and no server validation.

**Acceptance criteria:**

- [ ] Valid format proceeds offline; invalid format is explained without network access.
- [ ] Copy distinguishes participant identification from account/login security.
- [ ] Uninstall data loss and private-pilot expectations are acknowledged.

**Verification:** Widget/integration tests offline; dynamic-text/screen-reader review; network inspection confirms no validation call.

#### P6-T2 — Implement separate analytics consent and revocation

**GitHub:** [#65](https://github.com/theanadimukt/nextcue/issues/65)

**Label:** `task`
**Blocked by:** P6-T1
**What to build:** A separate, plain-language consent decision and Settings control that can revoke collection without disabling features.

**Acceptance criteria:**

- [ ] Default behavior before an affirmative decision sends no analytics.
- [ ] Revoke stops future transmission and follows the provider-approved identifier/deletion policy.
- [ ] Product flows and local data remain unchanged when consent is declined/revoked.

**Verification:** Consent state tests, offline/product parity tests, and network inspection with consent off/on/revoked.

### P6-US2 — Collect only consented, content-free lifecycle evidence

**GitHub:** [#66](https://github.com/theanadimukt/nextcue/issues/66)

**Type:** User story / HITL
**Label:** `feature`
**Blocked by:** P6-US1 and product event points from P2-P5
**Story:** As the pilot operator, I can measure the approved funnel without receiving URLs, metadata, Purposes, notes, or other user content.

**Acceptance criteria:**

- [ ] A managed provider is approved against privacy, retention/deletion, region, SDK, offline, schema, and cost criteria.
- [ ] A closed event schema covers the north-star and supporting funnel with only approved identifiers, timestamps, state, and counters.
- [ ] Consent off/revoked emits nothing and cannot reduce functionality.

#### P6-T3 — Approve provider, event schema, and privacy configuration

**GitHub:** [#67](https://github.com/theanadimukt/nextcue/issues/67)

**Label:** `task`
**Blocked by:** P6-T2
**What to build:** A decision record comparing managed analytics options plus the exact event/property allow-list, retention/deletion configuration, environments, and operator access model.

**Acceptance criteria:**

- [ ] Provider decision addresses UK/EU handling, consent, deletion/revocation, SDK behavior, access, retention, cost, and data-processing terms.
- [ ] Schema includes `capture_marked_applied` and approved funnel events but has no free-form/content fields.
- [ ] Human privacy/product approval is recorded before an SDK is integrated.

**Verification:** HITL sign-off, schema threat review, and test payload review with synthetic identifiers only.

#### P6-T4 — Integrate the analytics allow-list and privacy tests

**GitHub:** [#68](https://github.com/theanadimukt/nextcue/issues/68)

**Label:** `task`
**Blocked by:** P6-T3
**What to build:** A narrow analytics port/provider adapter that accepts typed allow-listed events, queues appropriately, respects consent, and cannot accept arbitrary properties.

**Acceptance criteria:**

- [ ] URLs, titles, thumbnails, Purpose, notes, raw errors, and arbitrary strings are unrepresentable/rejected.
- [ ] Participant code, installation identifier, event, timestamp, lifecycle state, and content-free counters follow the approved schema only.
- [ ] Dev/test/prod separation and opt-out/revocation work without changing domain flow.

**Verification:** Contract/redaction tests, network capture, consent matrix, provider dashboard inspection, and failure/offline tests.

### P6-US3 — Release and operate a trustworthy ten-person pilot

**GitHub:** [#69](https://github.com/theanadimukt/nextcue/issues/69)

**Type:** User story / HITL
**Label:** `feature`
**Blocked by:** P2-P5, P6-US2
**Story:** As the product owner, I can distribute controlled iOS/Android builds, support participants, and evaluate the approved four-week threshold from reproducible evidence.

**Acceptance criteria:**

- [ ] Release candidates pass the cross-platform device, lifecycle, notification, offline, accessibility, privacy, and deletion matrix.
- [ ] Closed TestFlight/Google Play access, signing/secrets, crash handling, support, and rollback are documented.
- [ ] Operator runbook maps weekly interviews and approved events to the 6-of-10 continuation threshold.

#### P6-T5 — Run the release hardening and accessibility matrix

**GitHub:** [#70](https://github.com/theanadimukt/nextcue/issues/70)

**Label:** `task`
**Blocked by:** All product stories, P6-T4
**What to build:** A reproducible release checklist and evidence bundle covering end-to-end flows, lifecycle interruption, offline behavior, URL safety, notification cases, local deletion, analytics privacy, and accessibility on each supported platform/device.

**Acceptance criteria:**

- [ ] Each platform is independently marked pass/fail; one platform cannot waive the other.
- [ ] Critical flows pass VoiceOver/TalkBack, dynamic text, reduced motion, contrast, and touch-target checks.
- [ ] No prohibited data appears in logs, crash context, notification defaults, or analytics network payloads.

**Verification:** Signed release-candidate builds, completed evidence matrix, focused automated suite, and owner review of all failures/waivers.

#### P6-T6 — Prepare controlled distribution and pilot operations

**GitHub:** [#71](https://github.com/theanadimukt/nextcue/issues/71)

**Label:** `task`
**Blocked by:** P6-T5
**What to build:** TestFlight/Google Play closed-test release steps and an operator runbook for roster separation, invitations, participant code handling, weekly interviews, support, incident response, build rollback, and final evaluation.

**Acceptance criteria:**

- [ ] Personal roster remains outside the product/repository/analytics and access is least-privilege.
- [ ] Runbook defines support and privacy incident paths plus build pause/rollback criteria.
- [ ] Evaluation template measures repeated capture, triage, two Applied outcomes, concrete application, and disappointment threshold for each participant/category.

**Verification:** Dry run with synthetic participants, store-access review, release/install rehearsal on both platforms, and owner go/no-go approval.

## Publication checklist

- [x] Confirm the granularity, dependency links, and HITL/AFK classification with the owner.
- [x] Ensure labels `feature`, `task`, and `bug` exist with distinct descriptions/colors.
- [x] Create epics P0-P6 in order.
- [x] Create each user story and attach it as a sub-issue of its phase epic.
- [x] Create each task and attach it as a sub-issue of its user story.
- [x] Replace symbolic blockers in GitHub bodies with actual issue links/numbers.
- [x] Add resulting links beside symbolic IDs in this catalog and the roadmap plan.
- [x] Verify every parent shows the expected child count and no issue is orphaned.
