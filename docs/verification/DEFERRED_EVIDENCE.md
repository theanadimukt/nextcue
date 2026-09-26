# Deferred verification evidence

Every manual verification step that a task could not complete is registered here. Registering a
deferral is not optional: an issue labeled `verification-debt` must have at least one row below, and
an issue with no row and no evidence attached is incomplete.

Policy and evidence classes: [`ADR-004`](../decisions/0004-code-first-with-batched-device-evidence.md).
Batched session procedure: [`DEVICE_SESSION.md`](DEVICE_SESSION.md).

## Row format

| Field | Meaning |
|---|---|
| ID | `VD-nnn`, never reused |
| Class | `C` simulator, `D` physical device, `E` accessibility |
| Owning issue | The issue that cannot close until this row clears |
| Evidence required | The exact matrix or procedure, by document and row |
| Gate | The phase gate that must clear this row before it can pass |
| Status | `Open`, `Cleared (date, evidence link)`, or `Refuted` |

## Register

| ID | Class | Owning issue | Evidence required | Gate | Status |
|---|---|---|---|---|---|
| VD-001 | D | [#5](https://github.com/theanadimukt/nextcue/issues/5) | `P0_T2_IOS_DURABLE_IMPORT.md` physical iPhone release matrix, rows 1–10 (terminated/background/foreground import, delayed launch, force-quit, duplicate share, duplicate import, optional failure, retry, unsigned+signed builds) | P0 exit | Open |
| VD-002 | C | [#5](https://github.com/theanadimukt/nextcue/issues/5) | Interactive share into Runner on the iOS Simulator; extension activation rule and App Group readback in a running process | P0 exit | Open |
| VD-003 | D | [#4](https://github.com/theanadimukt/nextcue/issues/4) | `P0_T1_IOS_EXTENSION_HARNESS.md` physical iPhone rows: real Instagram Reel with Runner terminated, backgrounded, and foregrounded, plus unsupported-text rejection | P0 exit | Open — issue closed on 2026-09-20 without attached sanitized evidence; confirm the rows were run or re-run them |
| VD-004 | D | [#27](https://github.com/theanadimukt/nextcue/issues/27) | Android share adapter: cold start, warm start, duplicate `ACTION_SEND` delivery, activity recreation, process death | P2 exit | Open |
| VD-005 | D | [#37](https://github.com/theanadimukt/nextcue/issues/37) | Local notification delivery, denial behavior, and reminder tap routing on both platforms | P3 exit | Open |
| VD-006 | E | [#40](https://github.com/theanadimukt/nextcue/issues/40) | VoiceOver and TalkBack labels, reading order, dynamic text maximum, and reduced-motion behavior for Today, View all, triage, outcome, and Settings flows | Pilot entry | Open |

Rows are added when an issue is marked `verification-debt` and removed only when their evidence is
attached to the owning issue. Clearing a row means attaching sanitized output: counts, status codes,
versions, and results. Never attach shared text, full URLs, paths, account names, device
identifiers, screenshots containing private content, or signing material.

## Gate definitions

| Gate | Meaning |
|---|---|
| P0 exit | The ADR-003 share-capture spike is proven on both platforms; the framework decision is recorded |
| P2 exit | Instant capture on iOS and Android is proven on real shares |
| P3 exit | Scheduling and local reminders are proven on both platforms |
| Pilot entry | All rows are cleared, analytics consent is in place, and a release build is installed on participant devices |

A gate passes only when every row assigned to it is `Cleared`.
