# ADR-004: Implement Against Automated Evidence and Batch Device Evidence

## Status

Accepted — amends the ADR-003 Phase 0 gate and the per-task Definition of Done

## Date

2026-09-26

## Context

ADR-003 keeps Flutter provisional until a share-capture spike passes on physical iOS and Android
devices, and the repository's Definition of Done requires named device/OS/app-version evidence for
every platform task. `AGENTS.md` states that production screen development is blocked until the
spike passes on physical devices.

In practice this made device access a per-task blocker instead of a phase gate:

- Task #4 (P0-T1) merged its implementation and closed while its physical-device rows were still
  `Untested` in `docs/verification/P0_T1_IOS_EXTENSION_HARNESS.md`.
- Pull request #74 (P0-T2) is complete, mergeable, and green on every automated check, yet is held
  open solely on a ten-row physical-device matrix that can only be run on a signed release build on
  a physical iPhone with a real Instagram account.
- Only one machine in the project can run `swift test`, `plutil`-based configuration checks, and
  `flutter build ios`. That machine is the founder's Mac, so no automated evidence exists at all:
  the repository has no CI, and every check is manual and local.
- The result is a backlog of 60+ implementation tasks that are ready to code but that no scheduled
  session can finish, because finishing is defined in terms of hardware the session does not have.

The constraint that produced this ADR is not the device. It is that implementation completion,
merge, and evidence collection were defined as one indivisible step.

## Decision

Separate implementation from verification, and make verification a scheduled, batched activity
rather than a per-task prerequisite.

1. **Evidence classes.** Every task declares the evidence classes it needs: `A` automated-anywhere,
   `B` automated-Apple-toolchain, `C` simulator, `D` physical device, `E` accessibility. Classes A
   and B are produced by CI on every push. Classes C, D, and E are manual.
2. **Definition of Done becomes two levels.**
   - **Implemented** — every non-device acceptance criterion is met and classes A and B are green,
     locally (`make check`, `make check-apple` where a Mac is available) or in CI. An implemented
     change may merge to `main` and the issue receives the `verification-debt` label.
   - **Verified** — every deferred row registered for that issue is cleared with sanitized evidence.
     Only then does the issue close.
3. **Deferred evidence is registered, never implied.** Each deferral adds a row to
   `docs/verification/DEFERRED_EVIDENCE.md` naming the owning issue, the class, the exact procedure,
   and the gate that must clear it. An unregistered deferral is a defect.
4. **Device evidence is batched at phase gates.** Classes C, D, and E are collected in device
   sessions (`docs/verification/DEVICE_SESSION.md`) at P0 exit and before pilot entry, covering
   every open row at once. Per-task device matrices are replaced by one session matrix per phase.
5. **The phase gate remains absolute.** No claim of platform readiness, no pilot distribution, and
   no phase exit while rows for that phase are open. Unverified device behavior must be described as
   unverified in issues, pull requests, and release notes.
6. **Implementation is unblocked, framework risk is not.** The ADR-003 spike requirement still
   governs the *framework decision*. It no longer governs writing code that is framework-independent:
   domain logic, persistence ports, pure-Dart behavior, and their tests may be implemented, merged,
   and reviewed before the spike completes. Code that depends on an unproven platform boundary (the
   share extension adapter, durable transfer, notification delivery) ships behind a port with a fake
   and is marked `verification-debt` until its device rows clear.

## Consequences

- A solo founder with limited device access can implement an entire phase, then spend one focused
  session producing the manual evidence for that phase.
- `main` may contain device-unverified but automation-verified code. This is acceptable because
  nothing ships to a pilot participant without a cleared phase gate, and because the alternative —
  an unusable branch that drifts from `main` — is worse.
- The analysis surface grows: code must be structured so that classes A and B cover as much behavior
  as possible. A pure-Dart domain layer with no Flutter imports, and native code behind narrow
  ports, is now a delivery requirement rather than a preference.
- CI, not the founder's laptop, becomes the source of routine evidence. macOS runner minutes are
  limited on a private repository, so Apple-toolchain work is path-filtered to changes that can
  affect it.
- Physical-device and accessibility rows still cannot be automated. They remain the phase gate, and
  the pilot cannot start without them.
- An issue marked `verification-debt` is explicitly not done. If the pilot is scheduled before its
  rows are cleared, the pilot is the thing that slips.

## Alternatives considered

### Keep the per-task device gate

- Preserves the strongest possible evidentiary discipline.
- Rejected: it stalls implementation on hardware availability and produces exactly the outcome it
  was meant to prevent — tasks closing with untested device rows (see task #4) or sitting merged
  nowhere for weeks (see PR #74).

### Merge everything and verify at release

- Maximum implementation throughput.
- Rejected: it discards the traceability that the registry preserves, and lets a platform contract
  break silently across many tasks before anyone notices.

### Long-lived feature branch until the phase is device-verified

- Keeps `main` pure.
- Rejected: an unreviewed, undrifted branch of this size is unmaintainable for one developer, and
  it removes CI feedback from the default branch.

### Buy or borrow device access per task

- Makes the current gate achievable.
- Not adopted as the primary mechanism: an iPhone and an Android device are still required for
  classes D and E, and batching them into phase gates reduces the number of sessions from one per
  task to one per phase.

## References

- `docs/verification/DEFERRED_EVIDENCE.md` — the register of deferred rows and their gates.
- `docs/verification/DEVICE_SESSION.md` — the batched manual evidence session procedure.
- `docs/decisions/0003-provisional-flutter-architecture.md` — the spike this ADR amends.
- `docs/plan/V1_DEVELOPMENT_PLAN.md` — verification strategy and Definition of Done.
- `.github/workflows/ci.yml` — the automated evidence for classes A and B.
