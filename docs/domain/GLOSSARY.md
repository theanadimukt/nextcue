# NextCue Domain Glossary

## Status

**Authoritative domain language for Version 1.** User-interface copy may use friendlier labels, but implementation, tests, analytics, and product documentation should preserve these meanings.

## Core concepts

### Capture

The durable local record created from a supported shared source.

A Capture conceptually contains:

- a stable local identifier;
- source type;
- original accepted URL;
- canonical URL used for duplicate matching;
- capture and update timestamps;
- optional public display metadata;
- optional Purpose;
- lifecycle status;
- optional active Cue;
- content-free transition history; and
- optional private application note.

The interface calls an Instagram-backed Capture a **Reel**. The internal term remains source-neutral without authorizing non-Instagram sources in Version 1.

### SharedCapture

The source-neutral transfer object produced by an operating-system share adapter before domain validation. It is untrusted input, not yet a Capture.

### Purpose

Optional user-authored text answering **Use this for…**. A Purpose provides future context but is not required to assign a Capture.

A Purpose is not a Project, task, tag, or analytics field.

### Cue

The single active reminder attached to a Capture. A Cue contains a scheduled time and notification scheduling information. Creating a Cue assigns the Capture. Rescheduling replaces the active Cue while retaining content-free history.

### Triage

The deliberate review of an Unassigned Capture. A triage decision is Use later, Not useful, or Skip for now.

### Outcome

An explicit user decision after a Capture becomes Due. Version 1 outcomes are Applied, Reschedule, and Archive. Opening Instagram is not an Outcome.

## Persisted statuses

### Unassigned

The Capture has no active Cue and has not reached a terminal outcome.

### Scheduled

The Capture has exactly one active Cue in the future or at the current time. A missed operating-system notification does not change this status.

### Applied

The user explicitly states that information from the Reel was applied. An optional private note may describe how. Applied is a successful terminal status and remains distinct from Archived.

### Archived

The user intentionally removes the Capture from active workflows without claiming application. Archive is reversible and is not deletion.

## Derived views

### Due

A Scheduled Capture whose Cue time is at or before the current time. Due is calculated from the active Cue; it is not stored as an independent status.

### Today

The focused presentation of up to three Due Captures. Additional Due Captures remain accessible through View all.

### Stale

An Unassigned Capture whose capture time is at least 30 days old. Stale is calculated from age; it is not stored as an independent status. Skipping does not reset the age.

### Eligible for triage

An Unassigned, non-Stale Capture that is not inside its seven-day skip cooldown.

## Actions

### Add cue

Optionally records a Purpose and creates the required reminder. The Capture must already exist before Add cue begins.

### Use later

The triage action that creates a Cue and optionally records a Purpose, moving Unassigned to Scheduled.

### Skip for now

Keeps the Capture Unassigned and excludes it from triage selection for seven days. Skip does not change capture age.

### Not useful

The user-facing triage action that moves an Unassigned Capture to Archived.

### Reschedule

Replaces the active Cue and returns the Capture to Scheduled. There is no hard reschedule limit; the content-free count may inform pilot analysis.

### Archive

Moves an active Capture to Archived and cancels its active Cue. Archive does not mean Applied.

### Restore

Moves an Archived Capture to Unassigned with no active Cue. Recapturing an Archived duplicate performs Restore.

### Delete

Permanently removes the Capture, Cue, history, metadata, Purpose, and optional note after confirmation. Delete is not a lifecycle status.

## Transition table

| From | Action or condition | To | Required effects |
|---|---|---|---|
| No record | Valid unique Reel captured | Unassigned | Persist before optional work. |
| No record | Invalid or unsupported input | No record | Explain failure; offer paste fallback. |
| Unassigned | Add cue / Use later | Scheduled | Create exactly one Cue; Purpose optional. |
| Unassigned | Skip for now | Unassigned | Set seven-day triage cooldown. |
| Unassigned | Not useful / Archive | Archived | No active Cue. |
| Scheduled | Cue time passes | Scheduled, derived Due | Do not create a second status. |
| Scheduled / Due | Reschedule | Scheduled | Replace Cue and record content-free event. |
| Scheduled / Due | Applied | Applied | Cancel active notification; optional note. |
| Scheduled / Due | Archive | Archived | Cancel active notification. |
| Applied | Delete | No record | Permanently remove local data. |
| Archived | Restore or duplicate recapture | Unassigned | Remove terminal status; no active Cue. |
| Archived | Delete | No record | Permanently remove local data. |

## Invariants

- Durable Capture precedes optional Purpose or Cue entry.
- One canonical Reel URL maps to at most one Capture.
- A Capture has at most one active Cue.
- Assigned means an active Cue exists; Purpose alone does not assign.
- Purpose is optional and private.
- Applied requires explicit user input.
- Opening a Reel does not imply Applied.
- Applied and Archived are mutually exclusive terminal statuses.
- Due and Stale are derived, not persisted statuses.
- Metadata failure cannot remove authoritative user data.
- Archive is reversible; Delete is permanent.
