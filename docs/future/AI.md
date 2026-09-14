# Deferred AI Direction

## Status

**Deferred. No AI feature is approved for Version 1.**

This document describes a possible future experiment and the gates required to authorize it. It is not part of the current product scope or implementation plan.

## Why AI is deferred

The Version 1 user job can be validated without generative AI: capture a Reel, optionally record its purpose, resurface it at a useful time, and explicitly record whether it was applied.

Adding AI before this loop is validated would increase cost, privacy exposure, latency, failure modes, and pressure to access Reel media. It would also obscure a core pilot assumption: whether users accept manual purpose entry and contextual reminders.

Version 1 therefore has:

- no model provider or model dependency;
- no automatic transcription or media retrieval;
- no automatic summary, title, takeaway, action, or plan;
- no submission of URLs, metadata, Purposes, or notes to an AI provider; and
- no AI claims in product messaging.

## Earliest candidate after validation

### User job

Help a user who understands a Reel's advice but cannot identify a small first step.

### Candidate task

Given text explicitly supplied or approved by the user, suggest up to three short, concrete first actions that can reasonably be started in five minutes.

Automatic retrieval or transcription of Reel media is not part of this candidate.

### Input contract

```json
{
  "user_text": "string, required, explicitly supplied or approved",
  "available_minutes": "integer from 5 to 120",
  "optional_goal": "string or null"
}
```

### Output contract

```json
{
  "suggestions": [
    {
      "title": "string, maximum 80 characters",
      "description": "string, maximum 240 characters",
      "estimated_minutes": "integer from 1 to 120",
      "assumptions": ["string"]
    }
  ],
  "uncertainty_note": "string or null"
}
```

Suggestions remain editable drafts and may never schedule, purchase, message, delete, or publish automatically.

## Gates before an experiment

An AI experiment requires all of the following:

1. The manual pilot reaches its continuation threshold.
2. Interviews show that identifying a first action is a material bottleneck.
3. A deterministic prompt/template baseline is measured.
4. A representative evaluation set exists without private user data.
5. The AI approach materially improves accepted and completed action creation enough to justify cost and latency.
6. A separate privacy, security, provider, retention, and failure design is approved.

## Safety boundary

A future model must not:

- treat source content as trusted instructions;
- claim it watched or verified a Reel it did not receive;
- fabricate facts, prerequisites, links, or citations;
- provide high-confidence medical, legal, financial, or dangerous instructions;
- perform consequential actions;
- expose one user's data to another; or
- process content without clear user intent and consent.

The application must schema-validate model output, preserve user data on failure, fall back to the manual flow, and keep the user as decision-maker and editor.

## Decisions deliberately unresolved

Before enabling AI, decide and document:

- whether inference is on-device or server-hosted;
- supported languages and devices;
- consent, retention, and deletion behavior;
- provider, model, fallback, and kill-switch behavior;
- latency, token, retry, and spend limits;
- safety policy and high-risk refusal behavior; and
- whether AI is included, metered, or separately purchased.
