# NextCue Product Definition

## Status

**Approved direction for Version 1 and a private ten-person pilot.**

## One-line promise

**Save it now. Use it when it matters.**

## Problem

People encounter useful Instagram Reels while browsing, save them with good intentions, and rarely return when the information is relevant. Instagram remembers the content but not why it mattered or when it could be applied. The result is an accumulating archive rather than useful follow-through.

NextCue is not a bookmark manager. It captures a Reel without interrupting browsing, helps the user decide when it should return, and preserves the purpose that made it worth saving.

## How might we

How might we help people capture useful Instagram Reels without interrupting their browsing, then resurface each Reel when its information becomes relevant to real work, study, or creation?

## Initial audience

Initial positioning targets **AI-curious professionals and technical creators**. This is the founder-user wedge: people who regularly encounter fast-moving, practical information and want to use it in a project or output.

The pilot includes four separately measured categories:

- **Professionals** applying information to current work;
- **Creators and researchers** using information in an output or experiment;
- **ADHD-oriented users** turning interesting content into one manageable commitment; and
- **Students** connecting content to an assignment or study session.

The interface may serve all four categories, but launch messaging must not present NextCue as a product for everyone.

## Primary outcome

A user marks a captured Reel **Applied** after it returns in a useful context. Opening or watching the Reel is an engagement signal, not the primary value signal.

## Product principles

- Capture must complete before optional organization begins.
- Optimize for application, not saves, watch time, or time in NextCue.
- Ask for one decision at a time.
- Focus attention without hiding user commitments.
- Preserve user-authored context when external content fails.
- Remind without nagging or manufacturing guilt.
- Do not hold user-created data hostage.

## Core lifecycle

```text
Capture instantly
      ↓
Add cue now ───────────────┐
      or                   │
Unassigned → Later triage  │
                           ↓
                    Scheduled reminder
                           ↓
                         Due
                    ↙             ↘
                Applied         Archived
```

The precise meanings and transition rules live in [`../domain/GLOSSARY.md`](../domain/GLOSSARY.md).

## Core experience

### 1. Capture

1. The user shares an Instagram Reel to NextCue through the operating-system share flow.
2. NextCue extracts and validates a supported HTTP(S) Reel URL.
3. NextCue saves the Capture locally before showing optional controls.
4. The share surface confirms **Saved** and offers **Add cue**.
5. Add cue contains an optional **Use this for…** purpose and a required reminder time.
6. Closing the share surface without adding a cue leaves the Capture Unassigned.

When the share payload is invalid, NextCue explains that no supported Reel was found and offers an in-app paste-link fallback. Invalid arbitrary text does not enter the inbox.

### 2. Delayed triage

After the first Unassigned Capture, NextCue explains the value of daily triage, lets the user choose a time, and contextually requests notification permission.

The daily cue says **Review one Reel** rather than emphasizing backlog size. Opening it shows the oldest eligible Unassigned Capture. The user can:

- **Use later** — optionally add a purpose and select a reminder;
- **Not useful** — Archive the Capture; or
- **Skip for now** — hide it from triage for seven days.

After one decision, the user may review another, up to three Captures in one session. Unassigned Captures older than 30 days appear in the Stale view rather than the active inbox. They are never silently deleted or archived.

### 3. Reminder

Reminder choices are:

- Later today;
- Tomorrow;
- This weekend; or
- Pick a date and time.

Each Capture has at most one active Cue. Rescheduling replaces that Cue while retaining content-free event history. A Scheduled Capture remains valid even if operating-system notification permission is unavailable.

NextCue sends one notification per Cue. Ignoring it does not trigger automatic repeat notifications. The Capture remains visible as Due. When at least one scheduled Reel is due that day, NextCue suppresses the daily triage notification.

Notification content is private by default and does not show the user's purpose. A setting may explicitly enable purpose previews.

### 4. Apply or close

The user opens the original Reel in Instagram or a browser. When the user returns to NextCue, the app asks for one outcome:

- **Applied** — one tap, with an optional private note;
- **Reschedule** — choose a replacement reminder; or
- **Archive** — remove it from active workflows without claiming application.

NextCue cannot infer whether the Reel was watched or applied. Only an explicit user decision changes the outcome.

## Focused views

- **Today** highlights no more than three Due Captures.
- **View all** keeps every overdue Capture accessible.
- **Unassigned** contains eligible Captures with no active Cue.
- **Stale** contains Unassigned Captures at least 30 days old.
- **Applied** preserves successful outcomes.
- **Archived** contains reversible dismissals.

## Duplicate behavior

One canonical Reel URL maps to one Capture in Version 1.

- Capturing an active duplicate reopens the existing Capture so its purpose or Cue can be changed.
- Capturing an Archived duplicate restores it to Unassigned.
- Multiple simultaneous purposes or Cues for one Reel are deferred.

## Unavailable content

Title and thumbnail metadata are optional decoration. A private, deleted, blocked, or inaccessible Reel retains its URL, purpose, Cue, and note. The fallback card allows Open, replace URL, Archive, or Delete.

## Settings

Version 1 settings include:

- daily triage enabled/disabled and selected time;
- scheduled-reminder controls independent of triage;
- weekend reminder time;
- quiet hours;
- private notification previews;
- analytics consent;
- participant code for pilot builds;
- archived Captures;
- permanent local deletion; and
- Delete all local data.

## Version 1 capabilities

- Flutter application for iOS and Android, subject to the ADR-003 spike;
- iOS Share Extension and Android share target;
- in-app paste-link fallback;
- supported-URL validation and duplicate detection;
- durable zero-form capture;
- optional purpose and one active Cue;
- Unassigned, Today, Stale, Applied, and Archived views;
- daily triage and local scheduled reminders;
- open original Reel and collect an explicit outcome;
- optional, failure-tolerant public link metadata;
- local persistence;
- individual and complete local deletion; and
- consented, content-free pilot analytics.

## Pilot operation

Prospective testers register through an external form. The private pilot roster contains only:

- name;
- contact email;
- audience category;
- device and platform;
- participant code;
- pilot and analytics consent status; and
- interview notes.

Accepted testers receive a closed-store invitation and a participant code. The code is a research identifier, not authentication. It is entered during onboarding, validated for format locally, and mapped to personal information only in the private roster. Pilot participation and analytics consent are separate.

Uninstalling the app loses local data during the pilot. Onboarding and Settings must say so clearly.

## Validation

### North-star event

`capture_marked_applied`

### Supporting funnel

- valid Reel captured;
- Cue added immediately;
- Unassigned Capture triaged within seven days;
- scheduled Reel opened;
- Due Capture rescheduled;
- Capture marked Applied;
- Capture Archived;
- notification permission denied;
- daily triage disabled; and
- Unassigned backlog growth.

Analytics must never contain URLs, metadata, purposes, notes, or other user content.

### Four-week continuation threshold

A strong signal is at least **6 of 10** testers who:

- capture Reels repeatedly;
- triage Unassigned Captures;
- mark at least two Captures Applied;
- describe at least one concrete real-world application; and
- say they would be meaningfully disappointed if NextCue disappeared.

Weekly interviews explain why other participants did not reach the behavioral threshold. Ten positive opinions without repeated application are not sufficient evidence of a SaaS opportunity.

## Not doing in Version 1

- Mandatory purpose or scheduling during capture
- Formal projects, folders, tagging, or knowledge graphs
- Multiple active Cues for one Capture
- TikTok, YouTube Shorts, articles, podcasts, or screenshots
- Instagram Saved-library synchronization
- Embedded or offline Reel playback
- Media download, transcription, proxying, caching, or re-hosting
- AI summaries, generated actions, or plans
- Calendar or task-manager integrations
- Accounts, authentication, backend API, cloud backup, or synchronization
- Web, desktop, or browser-extension clients
- Social feeds, collaboration, accountability groups, streaks, points, or leaderboards
- Subscriptions or payments during the pilot

## Related decisions

- [`ADR-001`](../decisions/0001-instant-capture-and-delayed-triage.md): instant capture and delayed triage
- [`ADR-002`](../decisions/0002-local-first-pilot-without-backend.md): local-first pilot without a backend
- [`ADR-003`](../decisions/0003-provisional-flutter-architecture.md): provisional Flutter architecture
