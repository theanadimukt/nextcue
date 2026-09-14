# NextCue Product Definition

## One-line promise

**Turn useful saves into your next completed action.**

## Problem

People save useful Instagram Reels but rarely revisit them at the right time or convert the advice into a completed action. Instagram Saved is an archive; NextCue is a follow-through system.

## Version 1 audience

NextCue initially serves people who already save educational or practical Reels:

- professionals;
- creators and researchers;
- productivity and ADHD-oriented users; and
- students.

Measure each segment separately. The initial paid-market hypothesis is professionals, creators/researchers, and productivity-oriented users, but Version 1 does not include a paywall.

## Core value proposition

NextCue is a commitment-to-action product, not a bookmark manager, social feed, or AI knowledge base.

Primary outcome:

> A user completes one Reel-derived action within seven days of capture.

Supporting value includes remembering useful content, reducing backlog anxiety, and making the first step obvious.

## Version 1 platforms and source

- Flutter application for iOS and Android.
- Instagram Reels are the only committed source.
- Users capture a Reel through the operating system share sheet.
- Users can paste a Reel URL inside NextCue when sharing is unavailable or malformed.
- TikTok, YouTube Shorts, articles, podcasts, and screenshots are deferred until the Instagram loop is validated.

Keeping one source in Version 1 limits payload variants, QA combinations, messaging ambiguity, and scope. The domain model should not hard-code Instagram so another source can be added later without rewriting the action workflow.

## Core journey

1. The user shares an Instagram Reel to NextCue or pastes its URL.
2. NextCue validates the URL and detects duplicates.
3. NextCue immediately creates a draft from the URL; optional metadata must not block capture.
4. If available, NextCue displays a title, thumbnail/link preview, and source details. Missing metadata has a clear fallback.
5. The user chooses an intent: Learn, Try, Use later, Research, or Inspiration.
6. The user optionally adds a note and selects Today, Tomorrow, Weekend, or a custom `Watch by` time.
7. NextCue schedules a local notification after explaining the value and requesting permission at the first scheduling moment.
8. The Today queue presents no more than three due items.
9. The user opens the original Reel in Instagram or a browser.
10. On returning, the user chooses Not useful, Save takeaway, or Create action.
11. The user creates one small action and optionally chooses an `Act by` time.
12. Completing the action archives the Reel and contributes to the weekly review.

## Preview behavior

A preview means optional link metadata such as title and thumbnail. It does not mean downloading, embedding, copying, proxying, or re-hosting the Reel video.

If metadata cannot be retrieved because the Reel is private, deleted, blocked, or unavailable:

- keep the captured URL and user-authored fields;
- show a deterministic fallback card;
- allow opening, replacing, or archiving the link; and
- never make metadata availability a prerequisite for scheduling an action.

## Version 1 capabilities

- iOS Share Extension accepting URLs and shared text where supported.
- Android share target accepting `ACTION_SEND` text/URLs where supported.
- Paste-link fallback.
- Supported-URL validation and duplicate detection.
- Fast capture form with intent, note, and `Watch by` time.
- Optional title and link-preview metadata with resilient fallback.
- Local notifications with Open, Snooze, and Archive behavior where platform capabilities permit.
- Today queue capped at three, plus Upcoming and Unscheduled views.
- Open original Reel in Instagram or browser.
- Post-watch decision and one action per Reel.
- Completion, skipping, and archiving.
- Weekly counts and completion rate.
- Reminder time, quiet hours, and local data deletion settings.
- Local persistence and validation-funnel analytics that do not contain private notes or URLs.

## Product principles

- Optimize for completed actions, not saves or time in app.
- Ask for a decision rather than more organization.
- Keep queues intentionally small.
- Prefer a five-minute first action over a comprehensive plan.
- Degrade gracefully when platforms, metadata, or notifications fail.
- Do not hold user-created data hostage.

## Validation

### North-star event

`reel_action_completed_within_7_days`

### Initial targets

- At least 60% of new users schedule their first captured Reel.
- At least 40% create an action.
- At least 25% complete one Reel-derived action in week one.
- At least 25% of activated users complete another action in week four.

### Guardrails

- Captures must not grow materially faster than watched or archived items.
- Notification opt-out and repeated snoozes must be monitored.
- Analytics must not collect Reel URLs, captions, notes, takeaways, or action text.

## Key risks to validate first

1. Instagram may send inconsistent share payloads across iOS, Android, app versions, account types, and devices.
2. Opening Instagram to watch may distract users from returning to complete the workflow.
3. Optional public link metadata may be unavailable or unstable.
4. The commitment form may add enough friction that users choose Instagram Saved instead.
5. Users may respond to reminders without completing a meaningful action.
