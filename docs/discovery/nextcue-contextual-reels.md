# NextCue: Contextual Reels Concept

## Status

**Accepted discovery artifact.** This document preserves the reasoning that led to the current direction. It is not an implementation source of truth. See [`../product/PRODUCT.md`](../product/PRODUCT.md) for approved behavior.

## Problem Statement

How might we help people capture useful Instagram Reels without interrupting their browsing, then resurface each Reel when its information becomes relevant to real work, study, or creation?

## Recommended Direction

NextCue combines **instant capture**, **optional later triage**, and **contextual reminders**.

Users can share a Reel to NextCue without completing a form. If they already know why it matters, they can immediately add a purpose and reminder. Otherwise, it enters an Unassigned inbox. A gentle daily cue asks them to review one Reel rather than confront an ever-growing backlog.

The defining value is not storing or even watching the Reel. It is resurfacing the Reel with its original purpose immediately before the user can apply it.

## Audience hypotheses

- Professionals apply information to current work.
- Creators and researchers use information in an output or experiment.
- ADHD-oriented users turn interesting content into one manageable commitment.
- Students connect content to an assignment or study session.

The founder-user wedge is AI-curious professionals and technical creators. Other categories remain separate pilot hypotheses rather than a reason to make initial positioning generic.

## Core insight

The Reel is often useful only in a future context. Instagram remembers the source, but not the intended application or moment. NextCue therefore needs two capture speeds:

- **Intentional capture:** add purpose and timing immediately.
- **Fast capture:** save instantly and decide later through triage.

## Key assumptions

- Sharing to NextCue can feel nearly as effortless as Instagram Save.
- Users return to triage Unassigned Captures.
- Remembering why a Reel was saved improves the value of a reminder.
- Contextual resurfacing leads to real application rather than another watch.
- Daily triage can remain helpful without producing notification fatigue or backlog guilt.
- Manual purpose entry provides value without automatic media analysis.

## Risks surfaced during refinement

- Required organization during capture may cause abandonment.
- Optional delayed organization may merely relocate the Instagram backlog.
- Generic reminders are easy to reproduce in existing reminder products.
- Formal projects would pull NextCue into project-management scope.
- A growing unassigned count may communicate guilt rather than value.
- Opening Instagram may distract the user from returning to record an outcome.

## Direction chosen

Capture completes first. An optional cue preserves immediate intent. Unassigned Captures later enter a one-item triage flow. Scheduled Captures return at a useful time and receive an explicit Applied, Reschedule, or Archive outcome.

Detailed behavior was subsequently resolved through a multi-round grilling session and is recorded in the Product Definition, Domain Glossary, and ADR-001.

## Deliberate exclusions

- Mandatory organization during capture
- Formal project management
- Backlog-count-driven notifications
- AI summaries or generated plans
- Media transcription or downloading
- Additional content sources
- Accounts, synchronization, and payments during the pilot

## Related documents

- [`Product Definition`](../product/PRODUCT.md)
- [`Domain Glossary`](../domain/GLOSSARY.md)
- [`ADR-001`](../decisions/0001-instant-capture-and-delayed-triage.md)
