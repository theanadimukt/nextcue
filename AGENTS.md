# NextCue Agent Instructions

Applies repository-wide. Nested `AGENTS.md` files may add instructions but cannot weaken the binding constraints below.

NextCue Version 1 is a private ten-person iOS/Android pilot for capturing Instagram Reels, resurfacing them with a Cue, and recording explicit outcomes.

## Required reading

Before planning or implementing, read in order and follow:

1. [Product definition](docs/product/PRODUCT.md) — approved behavior, scope, and validation.
2. [Constraints](docs/product/CONSTRAINTS.md) — binding platform, architecture, privacy, reliability, accessibility, and delivery limits.
3. [Domain glossary](docs/domain/GLOSSARY.md) — exact terminology, transitions, and invariants for code, tests, analytics, and documentation. Friendlier UI copy must preserve these meanings.
4. Relevant [accepted ADRs](docs/decisions/) — decisions governing the work.

If these sources conflict, stop and reconcile the documentation. Reversing an accepted ADR requires a superseding ADR. Scope changes require an explicit product decision.

Use `docs/discovery/` only for historical context and `docs/future/` only for deferred ideas; neither supplies Version 1 requirements.

## Implementation gate and commands

A disposable Flutter iOS scaffold now supports the [ADR-003 share-capture spike](docs/decisions/0003-provisional-flutter-architecture.md); it is not a production scaffold. Flutter remains provisional until the spike passes on physical iOS and Android devices and the framework decision is recorded. Production screen development is blocked until then.

Run provisional Phase 0 commands from the repository root:

```sh
make lint
flutter test
(cd ios/SharePayloadKit && swift test)
tool/check_ios_harness.sh
flutter build ios --simulator
flutter build ios --release --no-codesign
flutter run --release
```

The final command requires signed physical-device configuration. Replace these commands when Phase 0 establishes the production scaffold.

## Workflow

- Use GitHub Issues as the implementation task system. The [issue catalog](docs/plan/V1_ISSUE_CATALOG.md) maps planning IDs to published issues; `docs/plan/` remains planning material.
- Before an implementation slice, read its issue and the relevant phase, architecture guidance, verification strategy, and Definition of Done in the [development plan](docs/plan/V1_DEVELOPMENT_PLAN.md).
- Work in small, independently verifiable vertical slices. Use short-lived branches and focused, atomic conventional commits; keep the default branch green.
- Preserve existing user changes. Exclude unrelated edits, generated build output, secrets, signing material, participant rosters, and private user fixtures from commits.
- Follow existing patterns and add dependencies or architecture layers only for a concrete approved Version 1 need.
- Record durable decisions in `docs/decisions/` and update affected product/domain documents in the same change.
- For time-dependent behavior, use an injectable clock/timezone boundary and deterministic tests.

## Issues and completion

When creating or updating issues, follow the development plan's [GitHub issue model](docs/plan/V1_DEVELOPMENT_PLAN.md#github-issue-model) and the issue catalog's brief structure. Stories need a plain-language explanation of behavior and user value. Tasks must stand alone with an objective, implementation guidance, constraints/non-goals, task-specific Definition of Done, testable acceptance criteria, verification evidence, and blockers. Preserve acceptance criteria when rewriting a brief.

A task is complete only when every acceptance criterion and verification step passes, relevant automated/build checks are green, and required platform, accessibility, and privacy evidence is attached to the issue or pull request. Apply the plan's [verification strategy](docs/plan/V1_DEVELOPMENT_PLAN.md#verification-strategy) and [Definition of Done](docs/plan/V1_DEVELOPMENT_PLAN.md#definition-of-done-for-every-leaf-task); one platform's evidence never proves the other.

Parent/child links express scope; `Blocked by` expresses execution order. Close a parent only after all child acceptance criteria and its phase checkpoint pass.
