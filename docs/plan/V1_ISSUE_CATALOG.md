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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story proves that an iPhone user can share a Reel even when NextCue is closed and still find it later. It focuses on reliable transfer between the iOS Share Extension and the main app before any production interface is built.

**Acceptance criteria:**

- [ ] A release-mode iOS Share Extension accepts a real supported payload and durably transfers it through an App Group or supported shared resource.
- [ ] The containing app imports the item after cold start without relying on the extension to open it.
- [ ] Repeated delivery is idempotent and invalid input creates no Capture.

#### P0-T1 — Build the minimal iOS extension harness

**GitHub:** [#4](https://github.com/theanadimukt/nextcue/issues/4)

**Label:** `task`
**Blocked by:** None
**What to build:** A disposable, minimal client plus iOS Share Extension that records sanitized payload shape and lifecycle evidence without implementing production screens or metadata fetching.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The iOS extension boundary is the largest early technical risk. A small harness reveals platform and signing problems before production UI or storage choices make the experiment expensive to change.
- **Implementation guidance:** Create only enough app and Share Extension structure to receive real Instagram share payloads, inspect their safe structural shape, and exercise the shared App Group boundary. Record lifecycle observations without storing private test content in the repository.
- **Constraints and non-goals:** Keep this disposable and narrow. Do not add production screens, metadata calls, product lifecycle rules, or assumptions that the extension can launch the containing app.
- **Definition of done:** Provide a reproducible release-device test procedure, sanitized evidence for each app state, and a short list of platform limitations for the durable-import task. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** A Saved message is trustworthy only when the shared item can survive extension termination and delayed app launch. This task proves the durable boundary and separates capture success from optional follow-up work.
- **Implementation guidance:** Implement a minimal queue or shared-resource record with clear write, import, acknowledgement, and retry behavior. Exercise interruption between each step, repeated delivery, cold start, and simulated failure after the base record is saved.
- **Constraints and non-goals:** Do not treat metadata or Cue creation as part of the durable transaction. Avoid raw URL or shared-text diagnostics, and do not acknowledge an item until the receiving side has safely persisted it.
- **Definition of done:** Deliver automated queue/import tests plus a completed physical-device matrix that identifies the contract Android and the later production adapter must match. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story proves the same reliable capture behavior on Android. It checks the different ways Android may start, resume, recreate, or redeliver the share so the user still gets one saved Capture.

**Acceptance criteria:**

- [ ] A release-mode Android share target accepts supported `ACTION_SEND` text from Instagram.
- [ ] Cold start, warm start, duplicate intent, activity recreation, and process death converge on one durable item.
- [ ] The produced normalized input matches the source-neutral contract used by iOS.

#### P0-T3 — Build the minimal Android share-target harness

**GitHub:** [#7](https://github.com/theanadimukt/nextcue/issues/7)

**Label:** `task`
**Blocked by:** P0-US1
**What to build:** A disposable Android share receiver that normalizes supported intent data and hands it to the minimal shared import path.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Android shares arrive through lifecycle paths that differ from iOS and can be delivered more than once. A minimal receiver proves the platform input can be reduced to the same source-neutral contract.
- **Implementation guidance:** Register the narrow ACTION_SEND text path, read the supported intent fields, and normalize candidate URLs, receipt time, and source hint for the shared import boundary. Exercise real Instagram sharing rather than relying only on synthetic intents.
- **Constraints and non-goals:** Native Kotlin code should not decide whether a URL is a valid Reel or apply duplicate policy. Do not persist arbitrary shared text or request unrelated Android permissions.
- **Definition of done:** Provide the normalized payload examples, focused adapter tests, manifest configuration, and release-device evidence needed for lifecycle resilience work. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Android may recreate activities, restart processes, or redeliver intents, so a successful happy-path share is not enough. The import path must converge on one durable result under those conditions.
- **Implementation guidance:** Add the smallest replay-safe transfer mechanism and test cold start, warm start, recreation, process death, repeated intent, and failure after durable capture. Make acknowledgement and retry behavior explicit.
- **Constraints and non-goals:** Keep domain validation in shared code and optional work outside the capture transaction. Diagnostic data must describe state and identifiers rather than user content.
- **Definition of done:** Produce automated replay/idempotency evidence and a physical-device lifecycle matrix that can be compared directly with the iOS result. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story turns the spike results into a clear framework decision. The team should know whether Flutter is safe enough for Version 1 and have a working production scaffold before feature development begins.

**Acceptance criteria:**

- [ ] Evidence compares reliability, native complexity, testability, learning cost, and delivery risk.
- [ ] ADR-003 is confirmed or superseded; no ambiguous provisional status remains.
- [ ] The approved project scaffold builds/tests on both platforms before feature work starts.

#### P0-T5 — Run the framework decision review

**GitHub:** [#10](https://github.com/theanadimukt/nextcue/issues/10)

**Label:** `task`
**Blocked by:** P0-T2, P0-T4
**What to build:** A concise evidence report and decision matrix comparing the proven Flutter path with the bare React Native fallback only if spike evidence exposes unacceptable risk.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The framework choice should follow evidence from the product's riskiest integration, not language familiarity or prototype momentum. This decision controls every later task.
- **Implementation guidance:** Summarize both platform spike results and score reliability, native surface area, debugging ownership, testability, learning cost, build/release complexity, and known failure modes. Compare bare React Native only if Flutter evidence shows a material problem.
- **Constraints and non-goals:** Do not broaden the review into every possible framework. Separate demonstrated facts from estimates, and document any accepted risk or required mitigation.
- **Definition of done:** Record the owner-approved decision, supported OS/device assumptions, and either confirmation of ADR-003 or a superseding ADR that unblocks the production scaffold. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Feature work needs one repeatable project baseline so each later issue can be built and checked consistently. Establishing it now prevents every assignee from inventing different commands or structure.
- **Implementation guidance:** Create the selected production scaffold, isolate testable domain code from UI/native adapters, and define canonical formatting, analysis, test, debug-build, and release-build commands. Add standard exclusions and a minimal CI-ready entry point.
- **Constraints and non-goals:** Do not implement product screens or select speculative architecture layers. Keep signing secrets and machine-specific configuration outside Git.
- **Definition of done:** Update AGENTS.md with exact commands and provide a clean-checkout rehearsal showing both platform projects and baseline checks work. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story creates the local foundation that keeps a user's Capture, Cue, Purpose, note, status, and history correct. It also makes the lifecycle rules from the glossary enforceable instead of relying on individual screens to behave correctly.

**Acceptance criteria:**

- [ ] The local schema represents Capture, optional active Cue, optional user fields, settings, metadata decoration, and content-free transition history.
- [ ] Domain transitions enforce one active Cue, explicit Applied, reversible Archive, and permanent Delete.
- [ ] Due and Stale are derived from a controllable clock rather than stored statuses.

#### P1-T1 — Implement the local schema and repository contract

**GitHub:** [#14](https://github.com/theanadimukt/nextcue/issues/14)

**Label:** `task`
**Blocked by:** P0-T6
**What to build:** A migration-capable local store and repository API for atomic capture, retrieval, update, cue replacement, history, settings, and deletion.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** All user value depends on local data remaining correct across restarts and future schema changes. The repository must make the product's atomicity and ownership rules explicit.
- **Implementation guidance:** Model Capture, optional active Cue, optional user fields, optional metadata, content-free history, and settings. Define repository operations for atomic capture, retrieval, updates, Cue replacement, queries, migration, and deletion using the selected local store.
- **Constraints and non-goals:** Do not add accounts, remote identifiers for sync, backend DTOs, or provider-neutral storage layers without a current need. Optional writes must never roll back a valid Capture.
- **Definition of done:** Deliver the schema, migration strategy, repository contract, and integration tests that later domain and UI work can use without depending on storage details. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Lifecycle rules must be enforced in one shared place; otherwise screens and platform paths can create contradictory states. This service turns the glossary into executable behavior.
- **Implementation guidance:** Implement commands and validation for Add cue, Use later, Skip, Archive, Restore, Applied, Reschedule, and Delete. Define transaction boundaries, returned results, invalid-transition errors, and content-free history events.
- **Constraints and non-goals:** Do not infer Applied, persist Due or Stale, allow multiple active Cues, or mix notification delivery with domain truth. A failed command must leave the prior state intact.
- **Definition of done:** Provide a table-driven suite covering every allowed and rejected transition so feature assignees can reuse commands rather than duplicate rules. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story ensures that NextCue accepts only supported Instagram Reel links and treats repeated shares predictably. Users should never get duplicate records or lose existing context when the same Reel is shared again.

**Acceptance criteria:**

- [ ] Untrusted text yields candidate HTTP(S) URLs and accepts only approved Reel patterns.
- [ ] Original URL is preserved while a canonical value enforces uniqueness.
- [ ] Active duplicates reopen; Archived duplicates restore to Unassigned; invalid input creates no record.

#### P1-T3 — Implement defensive URL extraction and canonicalization

**GitHub:** [#17](https://github.com/theanadimukt/nextcue/issues/17)

**Label:** `task`
**Blocked by:** P1-T1
**What to build:** Shared parsing/recognition that handles common surrounding text, URL variants, fragments/query parameters, and safe rejection.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Shared payloads are untrusted and Instagram URLs may include surrounding text or tracking variations. Consistent parsing is required for both safety and duplicate matching.
- **Implementation guidance:** Extract candidate HTTP(S) URLs, recognize the approved Instagram Reel patterns, preserve the original accepted URL, and produce a deterministic canonical value. Build a sanitized fixture table for common, malformed, adversarial, and multi-URL inputs.
- **Constraints and non-goals:** Reject arbitrary schemes, domains, and non-Reel Instagram paths. Do not follow redirects or fetch metadata as part of validation, and do not store the surrounding shared text.
- **Definition of done:** Deliver a small shared parser API and comprehensive table/property tests usable by native share and paste flows. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Platform redelivery and intentional recapture should not create duplicate records or discard a user's context. One operation must own the uniqueness and restore policy.
- **Implementation guidance:** Combine canonical lookup, unique insertion, active-duplicate return, and Archived restoration in a transaction-safe repository/domain operation. Cover concurrent calls and retries, not only sequential reuse.
- **Constraints and non-goals:** Preserve Purpose, Cue, note, and metadata on active duplicates. Archived restoration must return to Unassigned with no active Cue and must not create a second Capture.
- **Definition of done:** Expose a clear result for new, existing, or restored outcomes and provide concurrency/idempotency tests for every status. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story provides the basic app structure and access to every approved Version 1 view. It also establishes predictable time-based behavior and accessibility support before feature screens become more complex.

**Acceptance criteria:**

- [ ] Navigation exposes all approved views without inventing extra product scope.
- [ ] View queries use injected clock/timezone behavior.
- [ ] Critical shell controls support screen readers, dynamic text, reduced motion, contrast, and touch targets.

#### P1-T5 — Build the app shell and empty/loading/error states

**GitHub:** [#20](https://github.com/theanadimukt/nextcue/issues/20)

**Label:** `task`
**Blocked by:** P0-T6, P1-T1
**What to build:** Minimal navigation and view containers for the approved focused views and Settings, including honest empty and recoverable error states.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** A stable shell gives all later features predictable navigation, honest system states, and an accessibility baseline. Building it early avoids retrofitting critical access after screens multiply.
- **Implementation guidance:** Create navigation containers and routes for Today, Unassigned, Stale, Applied, Archived, and Settings. Provide reusable empty, loading, and recoverable-error patterns with semantics and large-text behavior.
- **Constraints and non-goals:** Do not imply cloud sync, backup, or features outside Version 1. Empty/error copy must reflect local state accurately, and navigation must not hide secondary Due work.
- **Definition of done:** Provide widget/navigation tests and a documented route contract that capture, notification, triage, and outcome tasks can target. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Time-based rules are difficult to test reliably with the real clock, and accessibility regressions are easy to miss. Shared test tools make future acceptance evidence fast and repeatable.
- **Implementation guidance:** Add injectable clock/timezone helpers, seeded repository builders, domain fixtures, semantic-label helpers, and focused query/widget test utilities. Demonstrate boundary movement without sleeps or changing the machine clock.
- **Constraints and non-goals:** Fixtures should use glossary terms and synthetic content only. Avoid snapshot tests that hide behavior or tightly couple domain tests to UI implementation.
- **Definition of done:** Document the helpers and include representative Due, Stale, and accessibility tests that later tasks can copy. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story turns the iOS spike into the real zero-form capture experience. An iPhone user should receive an honest Saved confirmation quickly and be free to close the share surface without completing any optional fields.

**Acceptance criteria:**

- [ ] Production extension durably hands off a normalized SharedCapture before acknowledging Saved.
- [ ] Saved offers Add cue, while dismissal leaves the Capture Unassigned.
- [ ] Invalid input explains failure and directs the user to paste fallback without creating a record.

#### P2-T1 — Productionize the iOS native adapter and durable queue

**GitHub:** [#24](https://github.com/theanadimukt/nextcue/issues/24)

**Label:** `task`
**Blocked by:** P0-T2, P1-T4
**What to build:** Replace/discard spike shortcuts with a small production Swift adapter, supported shared resource, acknowledgement/replay semantics, and content-safe diagnostics.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The spike proves feasibility but may contain shortcuts. The production adapter must be supportable, privacy-safe, and reliable enough to own real user captures.
- **Implementation guidance:** Replace temporary Swift code with a narrow adapter and durable shared-resource queue, including versioned payload handling, acknowledgement, retry, cleanup, and safe operational diagnostics. Connect it to the shared idempotent import operation.
- **Constraints and non-goals:** Keep URL validation, duplicate decisions, and lifecycle transitions out of Swift. Never log raw payloads or URLs, and never block durable save on metadata or Cue work.
- **Definition of done:** Provide focused native/integration tests and an updated release-device matrix covering termination, retry, duplicate delivery, and failure recovery. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The share surface is the user's first trust signal. It must clearly distinguish a completed durable save from an unsupported payload while asking for no mandatory organization.
- **Implementation guidance:** Build the minimal Saved state, optional Add cue action, dismissal behavior, and invalid-input explanation within extension constraints. Ensure focus, text scaling, and error recovery work in the constrained surface.
- **Constraints and non-goals:** Never show Saved before durable import is confirmed. Do not require Purpose or reminder input, and do not imply that invalid text entered the inbox.
- **Definition of done:** Provide UI/physical-device evidence for success, dismissal, invalid payload, slow/failure conditions, VoiceOver, and dynamic text. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story delivers the production Android sharing experience. Regardless of how Android launches or resumes NextCue, the user should receive one durable Capture and a simple optional next step.

**Acceptance criteria:**

- [ ] Production adapter handles cold/warm start, recreation, duplicate intents, and process restart.
- [ ] The shared capture result offers optional Add cue and otherwise remains Unassigned.
- [ ] Invalid input creates no record and explains paste fallback.

#### P2-T3 — Productionize the Android adapter and replay path

**GitHub:** [#27](https://github.com/theanadimukt/nextcue/issues/27)

**Label:** `task`
**Blocked by:** P0-T4, P1-T4
**What to build:** Replace/discard spike shortcuts with a small production Kotlin adapter and lifecycle-safe delivery/replay contract.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The Android spike also needs production hardening so lifecycle quirks do not leak into shared product behavior. This adapter becomes the single supported bridge from intents to import.
- **Implementation guidance:** Replace temporary Kotlin code with a small normalized delivery/replay adapter, including lifecycle-safe handoff, acknowledgement, cleanup, and content-free diagnostics. Route every delivery to the shared idempotent capture operation.
- **Constraints and non-goals:** Do not duplicate parsing or domain rules natively, request unrelated permissions, or log shared content. Optional work remains outside the durable capture transaction.
- **Definition of done:** Provide adapter/integration tests and release-device evidence for cold/warm start, recreation, process death, repeat intents, and retry. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Android users need an immediate, accurate result regardless of whether sharing opens a new activity or resumes the app. The confirmation must not repeat or become stale after lifecycle changes.
- **Implementation guidance:** Present Saved, optional Add cue, dismissal, and unsupported-input recovery using the platform entry route. Handle resumed/recreated UI and consume the delivery result exactly once.
- **Constraints and non-goals:** Do not show success early, loop the confirmation on relaunch, or create a Capture for invalid input. Keep the interaction short and interruption-safe.
- **Definition of done:** Provide integration/manual evidence for cold and warm entry, rotation/recreation, repeated delivery, TalkBack, and large text. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story gives users a fallback when native sharing is unavailable and keeps existing Captures useful when content or metadata cannot be loaded. Paste, duplicate, restored, and unavailable-content paths should all lead to understandable outcomes.

**Acceptance criteria:**

- [ ] Paste uses the same validation/idempotency path as native shares.
- [ ] Active duplicate opens the existing Capture; Archived duplicate restores it.
- [ ] Optional metadata failure leaves a fallback card with Open, replace URL, Archive, and Delete.

#### P2-T5 — Build the in-app paste fallback and duplicate routing

**GitHub:** [#30](https://github.com/theanadimukt/nextcue/issues/30)

**Label:** `task`
**Blocked by:** P1-T4, P1-T5
**What to build:** An accessible paste form and result routing for new, active duplicate, restored duplicate, and invalid outcomes.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Paste is the promised recovery path when an operating-system share fails or is unavailable. It must behave exactly like native capture so users are not exposed to different validation or duplicate rules.
- **Implementation guidance:** Build an accessible paste form, pass input through the shared parser/idempotent capture operation, and route new, active duplicate, restored duplicate, and invalid results to clear destinations and messages.
- **Constraints and non-goals:** Do not persist clipboard text before validation, silently read the clipboard, or create a second record. Handle clipboard denial and multiple candidate URLs explicitly.
- **Definition of done:** Provide widget/integration coverage for every result and a reusable routing contract for future capture entry points. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Metadata can improve recognition but is unreliable and potentially hostile. The app must stay useful and safe when content is private, deleted, malformed, slow, or unavailable.
- **Implementation guidance:** Run enrichment after capture with strict network limits, parse only approved public metadata, store it as decoration, and build a URL-first fallback card with Open, replace URL, Archive, and Delete actions.
- **Constraints and non-goals:** Never execute remote HTML, download media, leak metadata to telemetry, or overwrite user-authored fields. Replacing a URL must respect validation and canonical uniqueness.
- **Definition of done:** Provide offline and adversarial integration tests plus a fallback UI that later outcome and data-management work can reuse. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story lets a user decide why a Reel matters and when it should return. Purpose remains optional, while a valid reminder time creates or replaces the single active Cue.

**Acceptance criteria:**

- [ ] Later today, Tomorrow, This weekend, and custom date/time resolve predictably in local time.
- [ ] Saving creates/replaces exactly one active Cue and moves the Capture to Scheduled.
- [ ] Closing/cancelling optional entry never rolls back the existing Capture.

#### P3-T1 — Define reminder time and timezone semantics

**GitHub:** [#34](https://github.com/theanadimukt/nextcue/issues/34)

**Label:** `task`
**Blocked by:** P1-T6
**What to build:** A documented/tested Cue time contract for presets, custom input, weekend setting, timezone changes, DST gaps/folds, and past-time validation.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Reminder labels such as Tomorrow or This weekend are ambiguous around timezone, daylight-saving, and quiet-hour boundaries. A shared contract prevents inconsistent scheduling and user surprises.
- **Implementation guidance:** Define how every preset resolves, how custom input is validated, how weekend time is chosen, and what happens across timezone changes, DST gaps/folds, past times, and quiet hours. Express the decisions as clock-controlled rules.
- **Constraints and non-goals:** Do not leave behavior to platform defaults or silently change an existing Cue on invalid input. Keep domain time separate from notification delivery.
- **Definition of done:** Produce an owner-approved semantics note and a boundary test table that UI and native scheduling adapters must follow. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Add cue is the point where a saved Reel becomes an active commitment. The operation must keep Purpose optional while changing Cue and history atomically.
- **Implementation guidance:** Build the shared command and accessible editor used after capture and from Capture detail. Support presets/custom time, edit/replacement, validation, loading, double-submit protection, and recoverable persistence errors.
- **Constraints and non-goals:** Purpose alone cannot assign a Capture. A replacement must leave exactly one active Cue, and a failed save must preserve the previous valid state.
- **Definition of done:** Provide domain, repository, and widget tests plus a reusable result that notification scheduling can reconcile idempotently. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story sends one private local reminder for a Cue while keeping the saved scheduling state independent from notification permission or delivery. Users remain in control of previews, quiet hours, and reminder settings.

**Acceptance criteria:**

- [ ] Local scheduling/cancellation follows Cue changes and terminal outcomes.
- [ ] Purpose is hidden by default; explicit setting enables preview.
- [ ] Scheduled-reminder control, quiet hours, denial, and delivery failure never delete or unschedule the Cue.

#### P3-T3 — Implement the local notification scheduling port

**GitHub:** [#37](https://github.com/theanadimukt/nextcue/issues/37)

**Label:** `task`
**Blocked by:** P3-T2
**What to build:** Shared notification intents plus iOS/Android adapters for idempotent schedule, replace, cancel, and deep-link identifiers.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Notification delivery is best-effort, while the Cue is authoritative. A narrow scheduling port lets both platforms perform effects without letting OS state corrupt product state.
- **Implementation guidance:** Define schedule, replace, cancel, reconcile, and tap-identifier operations, then implement iOS and Android adapters. Use deterministic identifiers and record content-free scheduling outcomes for recovery/support.
- **Constraints and non-goals:** Permission denial or OS errors must not unschedule the domain Cue. Avoid duplicate requests, private payload content, and platform-specific behavior leaking into domain commands.
- **Definition of done:** Provide adapter tests, restart reconciliation tests, and physical-device evidence for schedule, replacement, cancellation, denial, and error paths. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Users need reminders that respect privacy and personal timing without losing their saved commitments. Settings must alter delivery policy, not domain truth.
- **Implementation guidance:** Add explicit purpose-preview opt-in, weekend time, quiet-hours controls, and scheduled-reminder enablement separate from triage. Apply the approved deferral/suppression rules when generating notification requests.
- **Constraints and non-goals:** Purpose stays hidden by default. Disabling delivery must preserve Cues and Due views, and quiet-hour handling must not generate repeats or silently reschedule domain state.
- **Definition of done:** Provide policy/widget tests and lock-screen/device evidence on both platforms for defaults and each setting transition. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story keeps today's workload focused without hiding overdue commitments. Users see no more than three Due Captures in Today and can open View all whenever more items are waiting.

**Acceptance criteria:**

- [ ] Due is derived from active Cue time and Today shows a deterministic maximum of three.
- [ ] View all exposes every remaining Due Capture with no destructive prioritization.
- [ ] Notification taps open the intended Capture or a safe Due fallback.

#### P3-T5 — Build Today and View all queries and screens

**GitHub:** [#40](https://github.com/theanadimukt/nextcue/issues/40)

**Label:** `task`
**Blocked by:** P3-T2, P1-T6
**What to build:** Clock-driven ordering and accessible presentation for focused Today cards and the complete Due list.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Today should reduce cognitive load while preserving visibility of every overdue promise. Query and presentation rules must make the three-item limit transparent rather than destructive.
- **Implementation guidance:** Define stable Due ordering, build the maximum-three Today query/cards, and create View all for the complete Due set. Cover empty states, large lists, time boundaries, and transitions after outcomes.
- **Constraints and non-goals:** Do not persist a Today membership status or hide additional items. Notification permission state should not determine whether a Due Capture appears.
- **Definition of done:** Provide query/widget tests at key list sizes and accessible navigation evidence between Today, View all, and Capture detail. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** A notification may open a terminated app long after its Cue changed or Capture was deleted. Routing must resolve current truth safely and preserve context for the outcome flow.
- **Implementation guidance:** Handle cold and warm notification entry, resolve deterministic identifiers against current local data, open the intended Capture when valid, and provide safe fallback behavior for stale or missing targets.
- **Constraints and non-goals:** A tap must never mark Applied or recreate deleted data. Process repeated routing once and keep stale identifiers from crashing or mutating state.
- **Definition of done:** Provide integration tests and a two-platform device matrix covering current, replaced, archived, deleted, repeated, cold, and warm tap cases. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story introduces daily triage only after the user has something Unassigned to review. It explains the benefit, lets the user choose a time, and keeps notification permission contextual and optional.

**Acceptance criteria:**

- [ ] Education appears after the first Unassigned Capture rather than at generic launch.
- [ ] The user chooses time/enabled state before the contextual OS permission request.
- [ ] Declining or disabling triage leaves full capture, Cue, and in-app triage functionality.

#### P4-T1 — Build first-Unassigned triage education and settings

**GitHub:** [#44](https://github.com/theanadimukt/nextcue/issues/44)

**Label:** `task`
**Blocked by:** P2, P1-T5
**What to build:** One-time contextual explanation, daily time selection, enabled state, and later Settings controls.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Notification permission is more understandable after the user has an actual Unassigned Capture. This task makes triage an informed, manageable choice rather than a generic onboarding request.
- **Implementation guidance:** Trigger one-time education after the first durable Unassigned Capture, explain Review one Reel, collect the preferred daily time/enabled choice, and expose the same controls later in Settings.
- **Constraints and non-goals:** Do not show backlog counts, imply obligation, request OS permission before explanation, or repeat the education after the user's decision.
- **Definition of done:** Provide state/widget tests for first capture, dismissal, repeat launch, setting changes, and accessibility, plus a clear signal the scheduler can consume. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The daily cue should help only when there is eligible triage work and no more important Due commitment. Scheduling and suppression must remain predictable even if permission is denied.
- **Implementation guidance:** Implement the local daily schedule, contextual permission request, eligibility check, Due-day suppression, disable/reschedule behavior, and Settings status. Reconcile changes after restart and time-setting updates.
- **Constraints and non-goals:** Use private generic text, never include backlog size, and do not remove in-app triage when delivery is denied or unavailable.
- **Definition of done:** Provide clock/scheduler tests and physical-device evidence for allow, deny, disable, no-eligible-item, and Due-day suppression on both platforms. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story gives the user one clear triage decision at a time. The oldest eligible Capture is shown first, and the session stays manageable by stopping after at most three decisions.

**Acceptance criteria:**

- [ ] Selection excludes Stale and seven-day skipped items and orders oldest first.
- [ ] Use later creates one Cue; Not useful Archives; Skip preserves Unassigned and sets cooldown.
- [ ] A session ends after three decisions and never traps access to remaining Captures elsewhere.

#### P4-T3 — Implement triage eligibility and session policy

**GitHub:** [#47](https://github.com/theanadimukt/nextcue/issues/47)

**Label:** `task`
**Blocked by:** P1-T2, P1-T6
**What to build:** Shared query/session rules for oldest eligible selection, skip timestamp/cooldown, continuation, and maximum three decisions.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Triage selection and limits define the product's low-pressure behavior. Central policy prevents screens from accidentally surfacing skipped or Stale items or extending sessions indefinitely.
- **Implementation guidance:** Implement oldest-first eligibility, seven-day skip cooldown, Stale exclusion, continuation state, and the maximum-three decision rule. Decide how an interrupted session resumes without double-counting a decision.
- **Constraints and non-goals:** Skip must not change capture time or status, and session state must not become a hidden permanent lifecycle status. Remaining Captures stay accessible outside the session.
- **Definition of done:** Provide clock-controlled boundary, ordering, exhaustion, and interruption tests plus a simple API for the triage UI. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The triage interface must translate policy into one clear decision without presenting a guilt-inducing backlog. Each action should reuse authoritative domain operations.
- **Implementation guidance:** Build the single-Capture flow with Use later, Not useful, Skip for now, and continue/finish behavior. Reuse Add cue, explain reversible Archive and cooldown effects, and handle command failures without advancing incorrectly.
- **Constraints and non-goals:** Do not expose the full backlog count in the prompt, create custom transition logic in the screen, or exceed three successful decisions.
- **Definition of done:** Provide integration tests for every action, rollback, interruption, exhaustion, and session limit, plus screen-reader focus evidence. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story keeps older Unassigned Captures visible without letting them crowd daily triage. Users can review these Stale items separately and decide what to do without automatic deletion or archiving.

**Acceptance criteria:**

- [ ] Stale is derived at 30 days from capture time and does not mutate persisted status.
- [ ] Stale items are excluded from active triage but visible in their own view.
- [ ] The user can Add cue, Archive, open, or delete from the Stale path.

#### P4-T5 — Implement Stale derivation and boundary-safe queries

**GitHub:** [#50](https://github.com/theanadimukt/nextcue/issues/50)

**Label:** `task`
**Blocked by:** P1-T6, P4-T3
**What to build:** Repository/domain queries that classify Unassigned items at the exact 30-day boundary while preserving skip semantics.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Stale is a time-based view, not a lifecycle state. Correct boundary queries keep old items out of daily triage without mutating or losing them.
- **Implementation guidance:** Implement repository/domain queries for Unassigned Captures at the exact 30-day boundary using the shared clock/timezone rules. Cover combinations with skip timestamps and all other statuses.
- **Constraints and non-goals:** Do not persist Stale, reset age on Skip, or include Scheduled, Applied, or Archived records. Classification must change naturally as time advances.
- **Definition of done:** Provide a complete clock-controlled status/boundary test matrix and a query contract for the Stale screen and analytics counters. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Users need a calm place to review older saves and recover value without being threatened with cleanup. The view must reuse safe actions consistently.
- **Implementation guidance:** Build the Stale list/detail states, explanatory copy, and Open, Add cue, Archive, and Delete entry points. Keep the list current after transitions and usable with large data sets and large text.
- **Constraints and non-goals:** Do not auto-archive/delete, invent a separate Stale transition, or bypass existing confirmation/domain commands.
- **Definition of done:** Provide widget/integration tests for each action and state update, plus VoiceOver/TalkBack and dynamic-text evidence. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story opens the original Reel and remembers which Capture the user came from. When the user returns, NextCue asks what happened but never assumes that opening or watching means the Reel was applied.

**Acceptance criteria:**

- [ ] Only validated HTTP(S) original/replacement URLs are launched in Instagram or browser.
- [ ] App lifecycle return offers Applied, Reschedule, and Archive for the intended Capture.
- [ ] Dismissal, app kill, or launch failure does not change lifecycle state.

#### P5-T1 — Implement safe external opening and return context

**GitHub:** [#54](https://github.com/theanadimukt/nextcue/issues/54)

**Label:** `task`
**Blocked by:** P2-T6, P3-T6
**What to build:** A safe URL launch port and local pending-return context that survives normal lifecycle changes without claiming completion.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Opening external content crosses an untrusted URL and app-lifecycle boundary. NextCue must remember the intended Capture without treating the launch as a successful outcome.
- **Implementation guidance:** Create a safe URL-launch port, validate the current original/replacement URL, store minimal pending-return context, and resolve it on foreground return. Handle launch failure, app kill, deleted targets, and unrelated foreground events.
- **Constraints and non-goals:** Reject arbitrary schemes, do not mark Applied, and do not show an outcome prompt for a different or missing Capture.
- **Definition of done:** Provide adapter/integration tests and physical-device evidence for Instagram/browser open, cancel, failure, cold recovery, and stale context. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The return prompt is where the product distinguishes real application from simple viewing. It should ask clearly without forcing an answer or implying success.
- **Implementation guidance:** Build the accessible outcome prompt/detail state for Applied, Reschedule, Archive, and dismiss-later. Connect Reschedule to Add cue and keep focus/context correct through interruptions and errors.
- **Constraints and non-goals:** Do not preselect an outcome, infer viewing, or mutate state when dismissed. Archive language must remain distinct from Applied.
- **Definition of done:** Provide widget/integration tests for every option, dismissal, error, repeat foreground, and screen-reader focus behavior. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story records the user's explicit decision after a Reel becomes relevant. Applied represents real use, Reschedule creates a new Cue, and Archive removes the item from active work without claiming success.

**Acceptance criteria:**

- [ ] Applied is one explicit action with optional note and no active Cue/notification afterward.
- [ ] Reschedule atomically replaces the active Cue and records content-free history.
- [ ] Archive cancels active notification and remains distinct from Applied.

#### P5-T3 — Implement Applied and optional private note

**GitHub:** [#57](https://github.com/theanadimukt/nextcue/issues/57)

**Label:** `task`
**Blocked by:** P5-T2, P3-T3
**What to build:** Applied command/UI, optional note entry, notification cancellation, and Applied view update.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Applied is the north-star outcome and must represent an explicit user claim. The optional note is private user content that deserves stronger handling than analytics data.
- **Implementation guidance:** Implement the transactional Applied command, one-tap path, optional note editor, active notification cancellation, and Applied view update. Handle retries and persistence/effect reconciliation.
- **Constraints and non-goals:** Never require a note, infer Applied, expose note content in logs/notifications/analytics, or remove the Cue before the state transition succeeds.
- **Definition of done:** Provide domain, repository, widget, restart, cancellation, retry, and privacy-inspection evidence for the completed flow. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Reschedule and Archive close Due work in different ways and must remain idempotent under repeated taps or effect retries. Reusing authoritative commands protects lifecycle history.
- **Implementation guidance:** Wire the outcome UI to atomic Cue replacement and Archive commands, reconcile notification replacement/cancellation, update active views, and surface recoverable failures without duplicate history.
- **Constraints and non-goals:** Archive must never record Applied, Reschedule must leave one active Cue, and notification errors must not corrupt the successful domain transition.
- **Definition of done:** Provide transition/integration/widget tests plus notification-reconciliation evidence for rapid taps, retries, restart, and partial-effect failure. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story gives users control over all locally stored data. Archive can be reversed, while individual deletion and total deletion clearly explain and perform permanent removal.

**Acceptance criteria:**

- [ ] Archived view supports Restore to Unassigned with no active Cue.
- [ ] Individual deletion removes Capture, Cue, history, metadata, Purpose, and note after confirmation.
- [ ] Delete all local data clears product/analytics identifiers and notifications as defined, then returns to a safe onboarding state.

#### P5-T5 — Build Archived view, Restore, and individual Delete

**GitHub:** [#60](https://github.com/theanadimukt/nextcue/issues/60)

**Label:** `task`
**Blocked by:** P5-T4, P2-T6
**What to build:** Archived list/detail, restore action, and destructive individual-delete confirmation shared by fallback/Stale/terminal views.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Archive is intended to be reversible, while Delete permanently removes user data. Presenting both clearly protects users from accidental loss and supports duplicate restoration rules.
- **Implementation guidance:** Build Archived list/detail states, Restore, and a shared individual-delete confirmation. Make deletion atomically remove the Capture and all associated Cue, history, metadata, Purpose, and note data, then cancel effects.
- **Constraints and non-goals:** Do not describe Archive as deletion, restore an active Cue, or leave orphan rows/notifications. Repeated restore/delete actions should fail safely.
- **Definition of done:** Provide repository and UI tests, restart verification, orphan checks, duplicate-recapture behavior, and accessibility evidence for destructive confirmation. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Local-only storage and total deletion are important ownership promises. Users need an honest loss disclosure and one reliable way to erase everything the product controls.
- **Implementation guidance:** Add onboarding/Settings disclosure and a deliberate Delete all flow that clears product records, user-authored fields, local settings/identifiers as specified, and scheduled notifications. Define safe retry behavior for partial effect cleanup.
- **Constraints and non-goals:** Do not imply backup/recovery, silently preserve content, or perform deletion without strong confirmation. Keep participant roster data out of scope because it is not stored in the product.
- **Definition of done:** Provide full-store and notification-cleanup tests, restart/onboarding evidence, and a manual review of the confirmation and post-delete state. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story onboards accepted pilot participants without creating accounts. It explains local-only storage, validates the research code on the device, and keeps analytics consent as a separate choice.

**Acceptance criteria:**

- [ ] Participant code is format-validated locally and is never presented as authentication/authorization.
- [ ] Pilot participation and analytics consent are distinct decisions.
- [ ] Declining analytics preserves every product capability.

#### P6-T1 — Build local participant-code onboarding

**GitHub:** [#64](https://github.com/theanadimukt/nextcue/issues/64)

**Label:** `task`
**Blocked by:** P1-T5
**What to build:** Accessible pilot onboarding with local format validation, research-code storage, local-data-loss disclosure, and no server validation.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Pilot participants need identification for research without introducing accounts or a validation backend. Onboarding must set accurate expectations about local storage and access.
- **Implementation guidance:** Build accessible participant-code entry with local format validation, store the research identifier appropriately, show pilot/local-data-loss disclosures, and support correction before completion. Confirm the full path works offline.
- **Constraints and non-goals:** Do not call a server, present the code as authentication, store roster details, or couple this step to analytics consent.
- **Definition of done:** Provide offline widget/integration tests, network inspection, copy approval, and accessibility evidence that unblocks separate consent work. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Analytics is optional research collection, not a condition of using the pilot. Consent and revocation must be understandable and enforceable before any provider SDK can transmit events.
- **Implementation guidance:** Create a separate consent decision and Settings control, define pending/accepted/declined/revoked states, gate the analytics port, and specify identifier/deletion handling after revocation.
- **Constraints and non-goals:** Default to no transmission before affirmative consent. Do not disable features, delete product data, or merge pilot participation with analytics consent.
- **Definition of done:** Provide consent-state, product-parity, restart, and network-silence tests that the provider integration must continue to pass. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story gives the pilot operator useful lifecycle evidence without collecting private product content. The provider, event list, consent behavior, and privacy configuration must be approved before telemetry is enabled.

**Acceptance criteria:**

- [ ] A managed provider is approved against privacy, retention/deletion, region, SDK, offline, schema, and cost criteria.
- [ ] A closed event schema covers the north-star and supporting funnel with only approved identifiers, timestamps, state, and counters.
- [ ] Consent off/revoked emits nothing and cannot reduce functionality.

#### P6-T3 — Approve provider, event schema, and privacy configuration

**GitHub:** [#67](https://github.com/theanadimukt/nextcue/issues/67)

**Label:** `task`
**Blocked by:** P6-T2
**What to build:** A decision record comparing managed analytics options plus the exact event/property allow-list, retention/deletion configuration, environments, and operator access model.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** Choosing an analytics SDK creates privacy, legal, operational, and cost commitments. The event contract must be fixed before code makes accidental content collection possible.
- **Implementation guidance:** Compare managed providers on UK/EU handling, consent/deletion, retention, access controls, SDK/offline behavior, schema enforcement, cost, and data-processing terms. Define exact events, allowed properties, environments, retention, deletion, and operator roles.
- **Constraints and non-goals:** Use synthetic examples only, exclude free-form/content fields, and do not integrate an SDK until product/privacy approval is recorded.
- **Definition of done:** Deliver the signed decision record, event dictionary, configuration checklist, and threat review that P6-T4 can implement without open policy choices. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** A narrow, typed boundary is the technical control that keeps private content out of telemetry. Consent, offline queueing, and provider failures must not affect the product loop.
- **Implementation guidance:** Implement the approved analytics port and provider adapter, allow-listed event/property types, consent gate, environment separation, queue/failure behavior, and revocation handling. Instrument only the approved lifecycle points.
- **Constraints and non-goals:** Reject arbitrary properties and all URLs, metadata, Purpose, notes, shared text, and raw errors. Never let telemetry failure block or roll back a user action.
- **Definition of done:** Provide contract/redaction tests, consent matrix, offline/failure tests, network captures, and provider-dashboard evidence using synthetic identifiers. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**User story details:** This story prepares both mobile builds and the operating process for a trustworthy ten-person pilot. It covers release quality, controlled distribution, participant support, and the final continuation decision.

**Acceptance criteria:**

- [ ] Release candidates pass the cross-platform device, lifecycle, notification, offline, accessibility, privacy, and deletion matrix.
- [ ] Closed TestFlight/Google Play access, signing/secrets, crash handling, support, and rollback are documented.
- [ ] Operator runbook maps weekly interviews and approved events to the 6-of-10 continuation threshold.

#### P6-T5 — Run the release hardening and accessibility matrix

**GitHub:** [#70](https://github.com/theanadimukt/nextcue/issues/70)

**Label:** `task`
**Blocked by:** All product stories, P6-T4
**What to build:** A reproducible release checklist and evidence bundle covering end-to-end flows, lifecycle interruption, offline behavior, URL safety, notification cases, local deletion, analytics privacy, and accessibility on each supported platform/device.

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** The pilot relies on both platforms behaving reliably and privately in real conditions. A single consolidated matrix makes release risk and any waivers visible before distribution.
- **Implementation guidance:** Run the complete release suite across supported devices and OS versions: capture lifecycle, duplicates, offline/restart, URL safety, notifications, triage, outcomes, deletion, analytics consent/privacy, and critical accessibility flows. Record build and environment details with results.
- **Constraints and non-goals:** Do not infer one platform from the other, waive privacy/data-loss failures, or mark untested cells as passed. Any accepted limitation needs owner rationale and support guidance.
- **Definition of done:** Produce signed release candidates, the completed evidence matrix, defect links, resolved/accepted-risk summary, and owner readiness review. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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

<!-- nextcue-expanded-details-v1 -->
**AI-executable task details:**

- **Objective:** A technically sound build can still fail as a pilot without controlled access, support, interview cadence, incident handling, and a clear evaluation method. This task makes the experiment operable.
- **Implementation guidance:** Document and rehearse TestFlight/Google Play closed distribution, roster separation, invitations, participant-code handling, support, weekly interviews, privacy incidents, build pause/rollback, and four-week analysis. Prepare templates using synthetic participants.
- **Constraints and non-goals:** Keep personal roster data outside the app, analytics, and repository. Apply least privilege and do not change the approved continuation threshold after observing results.
- **Definition of done:** Deliver a dry-run-approved operator runbook, store/install evidence on both platforms, interview/evaluation templates, and the final owner go/no-go checklist. Do not mark this task complete until every acceptance criterion and verification step below passes, relevant automated/build checks are green, and required platform, accessibility, or privacy evidence is attached to the issue or pull request.

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
