# NextCue Agent Instructions

## Scope

These instructions apply to the entire repository. More deeply nested `AGENTS.md` files may add narrower instructions for their subtree but must not silently weaken the product, privacy, reliability, or delivery constraints defined here and in the authoritative documents.

NextCue Version 1 is a private ten-person iOS/Android pilot. It helps users capture useful Instagram Reels, optionally attach a Purpose and one Cue, resurface them at a useful time, and explicitly record an outcome. It is not a general bookmark manager, task manager, or knowledge-management system.

## Required reading and authority

Before planning or implementing work, read these sources in order:

1. `docs/product/PRODUCT.md` — approved Version 1 behavior, scope, and validation.
2. `docs/product/CONSTRAINTS.md` — binding platform, privacy, reliability, accessibility, and delivery limits.
3. `docs/domain/GLOSSARY.md` — authoritative domain language, statuses, derived views, transitions, and invariants.
4. Relevant records in `docs/decisions/` — accepted architectural and product decisions.
5. `docs/discovery/` for historical context only.
6. `docs/future/` for explicitly deferred ideas only.

If authoritative documents conflict, stop and reconcile the documentation. Do not choose an interpretation silently. Reversing an accepted ADR requires a new superseding ADR.

## Current repository state

- Product requirements and ADRs exist; application code has not yet been created.
- Flutter is provisional, not final.
- The first implementation work must be the ADR-003 cross-platform share-capture spike.
- Do not begin production screen development until the spike passes on physical iOS and Android devices and the framework decision is recorded.
- Do not invent build, test, lint, or release commands before the selected framework scaffold defines them. Once commands exist, document them here in the same change.

## Version 1 boundaries

Build only the approved pilot loop:

- Instagram Reel HTTP(S) URLs only.
- Native iOS Share Extension and Android share target, plus in-app paste fallback.
- Durable local capture before optional Purpose, Cue, metadata, or network work.
- One optional Purpose and at most one active Cue per Capture.
- Unassigned, Today, Stale, Applied, and Archived views.
- Daily triage and local scheduled notifications.
- Explicit Applied, Reschedule, or Archive outcomes.
- Optional failure-tolerant public link metadata.
- Individual deletion and Delete all local data.
- Separately consented, content-free pilot analytics.

Do not introduce any of the following without an approved product change and, where appropriate, a superseding ADR:

- Accounts, authentication, backend APIs, synchronization, cloud backup, or remote push behavior.
- AI, transcription, media download, proxying, caching, copying, or re-hosting.
- Additional content sources, embedded playback, projects, folders, tags, or multiple active Cues.
- Calendar/task-manager integrations, collaboration, social mechanics, payments, or subscriptions.
- Meta/Instagram platform APIs or social-platform credentials.
- Premature provider abstractions for hypothetical backends, sync, AI, or additional sources.

## Domain language and invariants

Use the exact meanings in `docs/domain/GLOSSARY.md` in implementation, tests, analytics, and technical documentation. User-facing copy may be friendlier but must not change semantics.

Preserve these invariants:

- A durable Capture exists before optional Purpose or Cue entry begins.
- One canonical Reel URL maps to at most one Capture.
- A Capture has at most one active Cue.
- Purpose alone does not assign a Capture; an active Cue does.
- Applied requires explicit user input and is never inferred from opening a Reel.
- Applied and Archived are distinct, mutually exclusive terminal statuses.
- Archive is reversible; Delete is permanent.
- Due and Stale are derived from time and are never independently persisted statuses.
- Skip for now does not reset Capture age.
- Metadata failure cannot remove an accepted URL or user-authored data.
- Notification permission or delivery failure cannot change Scheduled state or hide Due work.

## Architecture boundary

If the ADR-003 spike confirms Flutter, keep this boundary:

```text
iOS Share Extension / Android share target
                    ↓
       normalized SharedCapture contract
                    ↓
          shared application/domain code
                    ↓
             local repository
              ↙           ↘
      local notifications   Flutter UI
```

- Native Swift/Kotlin code receives, durably transfers, and acknowledges platform input.
- Shared code owns URL recognition, source validation, duplicate policy, lifecycle transitions, and derived views.
- The local repository is authoritative; notification scheduling and analytics are effects, not sources of truth.
- Keep `SharedCapture` small, source-neutral, and untrusted until shared validation succeeds.
- Use an injectable clock/timezone boundary for Due, Stale, skip cooldown, reminder presets, quiet hours, and deterministic tests.

If the spike fails, compare Flutter with bare React Native using actual spike evidence and write a superseding ADR before restructuring the production architecture.

## Privacy and security

- Treat shared text, URLs, redirects, metadata, and external content as untrusted input.
- Accept only supported HTTP(S) Instagram Reel patterns; never execute arbitrary schemes or render unsanitized remote HTML.
- Metadata fetching must use strict timeouts, response-size limits, redirect limits, and safe content handling, and must occur after durable capture.
- Product content stays local. URLs, titles, thumbnails, Purposes, notes, and raw shared text must not enter analytics, logs, crash reports, or notifications by default.
- Analytics must be separately consented, content-free, schema-restricted, and optional without feature loss.
- Participant codes are research identifiers, not authentication or authorization.
- Never commit credentials, signing keys, provisioning profiles, participant rosters, tokens, secrets, or private user fixtures.
- Store the personal pilot roster outside the product and repository with least-privilege access.

## Implementation workflow

- Work in small vertical slices that are independently demonstrable and verifiable.
- Keep the default branch green. Use short-lived branches and atomic commits with descriptive conventional messages.
- Do not mix unrelated refactors, formatting, feature work, or planning changes in one commit.
- Preserve user changes and unrelated work already present in the worktree.
- Prefer existing patterns once the scaffold exists; do not add dependencies or architecture layers without a concrete Version 1 need.
- Record durable design decisions in `docs/decisions/` and update affected product/domain documents in the same change.
- Treat `docs/plan/` as planning material. GitHub Issues are the implementation task system after the plan is published.

## GitHub issue conventions

- Phase epics use the `feature` label.
- User stories use the `feature` label and are attached as sub-issues of their phase epic.
- Focused implementation tasks use the `task` label and are attached as sub-issues of their user story.
- Defects use the `bug` label and link to the affected story or epic.
- Every user story must include a short, plain-language explanation of the behavior and user value without duplicating implementation detail.
- Every implementation task must be usable as a standalone AI development brief: state the objective, implementation guidance, constraints/non-goals, task-specific Definition of Done, unchanged testable acceptance criteria, verification evidence, and blockers.
- A task's Definition of Done must require every acceptance criterion and verification step to pass, relevant automated/build checks to be green, and applicable platform, accessibility, or privacy evidence to be attached to the issue or pull request.
- Parent/child linkage expresses scope ownership; `Blocked by` expresses execution order.
- Do not close a parent until all child acceptance criteria and its phase checkpoint pass.

## Testing and evidence

Every implementation slice requires automated acceptance evidence. Platform integration also requires platform-specific manual evidence; one platform's result never proves the other.

At minimum, cover:

- Every transition and invariant in the domain glossary.
- URL extraction/canonicalization, unsupported input, repeated delivery, and duplicate concurrency.
- Atomic persistence, migrations, restart recovery, one active Cue, and permanent deletion.
- Clock/timezone boundaries for Due, Stale, skip cooldown, weekend presets, quiet hours, and triage suppression.
- Notification permission denial, scheduling, replacement, cancellation, tap routing, and delivery-independent state.
- Consent off/on/revoked and rejection of prohibited analytics properties.
- iOS release-mode physical-device capture with the app terminated, backgrounded, and foregrounded.
- Android release-mode physical-device capture across cold/warm start, duplicate intent, activity recreation, and process death.

Critical flows must be checked with VoiceOver and TalkBack, dynamic text, reduced motion, sufficient contrast, and platform-appropriate touch targets. Today's three-item focus must never make additional Due Captures inaccessible.

## Definition of Done

A change is complete only when:

- Its issue acceptance criteria and focused automated tests pass.
- Relevant formatting, lint/static analysis, test, and build commands pass.
- Required physical-device/platform evidence is recorded.
- Accessibility is verified for changed critical UI.
- No prohibited content appears in logs, crash context, notifications, or analytics.
- Documentation and ADRs match the delivered behavior.
- No out-of-scope abstraction or feature was introduced.
- The diff contains no secrets, signing material, generated build output, or unrelated edits.

## Project commands

No application scaffold exists yet, so there are currently no approved build, test, lint, or run commands. Add the canonical commands here immediately after the Phase 0 architecture decision and production scaffold are committed.
