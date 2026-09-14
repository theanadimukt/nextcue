# ADR-001: Use Instant Capture with Optional Delayed Triage

## Status

Accepted

## Date

2026-09-14

## Context

The original NextCue flow asked users to choose an intent, optionally write a note, and select a watch time during capture. That improves context but makes sharing to NextCue meaningfully slower than tapping Instagram Save.

The product succeeds only if people capture useful Reels in the moment and later convert some of them into timely application. Requiring organization during browsing risks failure before the product can deliver a reminder. Allowing unlimited passive saving, however, risks recreating Instagram's forgotten archive inside another app.

## Decision

Persist a valid Capture immediately. After the save succeeds, offer an optional Add cue flow with an optional Purpose and required reminder time.

Captures without a Cue enter the Unassigned inbox. A user-configurable daily triage cue asks the user to review one Reel. Each session starts with one Capture and may continue to a maximum of three. Skip hides a Capture from triage for seven days. Unassigned Captures become Stale after 30 days but are never silently deleted or archived.

## Alternatives considered

### Require purpose and reminder during capture

- Preserves context at its freshest point.
- Adds friction to the highest-frequency and most interruption-sensitive moment.
- Rejected because capture abandonment is the most dangerous early behavioral risk.

### Save without any triage mechanism

- Provides the fastest capture.
- Recreates a passive bookmark backlog and does not force a useful decision.
- Rejected because storage alone does not fulfill the product promise.

### Display the full backlog in a daily reminder

- Makes all pending work visible.
- Communicates guilt and workload rather than a manageable next decision.
- Rejected in favor of one-item progressive triage.

## Consequences

- Capture and cue creation must be separate durable operations.
- Unassigned is a first-class product state.
- The product needs triage eligibility, skip cooldown, and stale-view rules.
- Analytics must distinguish immediate assignment from delayed triage.
- Some Captures will lose their original mental context before triage; the pilot must measure whether delayed decisions still occur.
- Formal projects and mandatory organization remain outside Version 1.
