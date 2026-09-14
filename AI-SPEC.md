# NextCue AI Specification

## Status

**Deferred — no AI feature is approved for Version 1.**

The Version 1 user job can be validated without generative AI: capture a Reel link, commit to watching it, create one manual action, and complete it. Adding AI before this loop is validated would increase cost, privacy exposure, latency, failure modes, and media-access pressure without proving customer value.

## Version 1 behavior

- No model provider or model dependency.
- No automatic transcription.
- No automatic summarization.
- No AI-generated title, takeaway, action, or plan.
- No submission of URLs, notes, actions, or other user content to an AI provider.
- No AI usage claims in product messaging.

Deterministic alternatives:

- Let the user enter or edit the title.
- Use optional link metadata only as presentation data.
- Ask the user for one small action with structured prompts.
- Use fixed intent choices and reminder presets.

## Earliest candidate after validation

### User job

Help a user who understands a Reel’s advice but cannot identify a small first step.

### Candidate AI task

Given text explicitly supplied or approved by the user, suggest up to three short, concrete first actions that can reasonably be started in five minutes.

Automatic retrieval or transcription of Reel media is not part of this task.

### Input contract

```json
{
  "user_text": "string, required, explicitly supplied or approved",
  "intent": "learn | try | use_later | research | inspiration",
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

Application code must schema-validate and length-limit the output. Suggestions remain editable drafts and can never schedule, purchase, message, delete, or publish anything automatically.

## Quality bar before implementation

An AI experiment may proceed only after:

1. The manual Version 1 loop meets the product’s activation and retention signals.
2. User interviews show that choosing the first action is a material bottleneck.
3. A deterministic prompt/template baseline is measured.
4. A representative evaluation set is stored in the repository without private user data.
5. The AI approach improves accepted-action creation over the deterministic baseline enough to justify its cost and latency.

Initial evaluation slices must include:

- ordinary educational advice;
- vague or context-poor text;
- missing prerequisites;
- medical, financial, legal, dangerous, or age-sensitive advice;
- prompt injection embedded in supplied text;
- empty, malformed, and excessively long input; and
- non-English input for every claimed supported language.

Candidate metrics:

- suggestion acceptance rate;
- accepted suggestions completed within seven days;
- edit distance or meaningful-edit rate before acceptance;
- invalid-output rate;
- unsafe-suggestion rate;
- p50/p95 latency; and
- cost per accepted and completed action.

No target is approved until a baseline experiment establishes realistic values.

## Safety boundary

The model must not:

- treat source content as trusted instructions;
- claim it watched or verified a Reel when it received only user-supplied text;
- fabricate facts, tools, prerequisites, links, or citations;
- give high-confidence medical, legal, financial, or dangerous instructions;
- perform actions or call consequential tools;
- expose one user’s data to another user; or
- process content without clear user intent and consent.

For high-risk advice, the safe behavior is to avoid generating an execution plan, explain the limitation, and encourage appropriate qualified help when warranted.

## Failure behavior and human fallback

If the provider is unavailable, rate-limited, slow, returns invalid output, or the feature is unsupported:

- preserve all user-entered data;
- fall back to the manual action form;
- show a concise, honest error;
- never invent a suggestion; and
- allow retry without duplicating records or charges.

The user is always the decision-maker and editor. There is no hidden autonomous action.

## Architecture requirements for any future AI implementation

- Keep product policy separate from prompts.
- Put providers behind a narrow, replaceable adapter.
- Record provider, exact model/version, prompt version, schema version, latency, and cost without logging raw private content by default.
- Validate output at the application boundary.
- Set explicit time, token, retry, and spend limits.
- Cache only with a documented retention and deletion policy.
- Provide a provider-independent kill switch.
- Threat-model prompt injection, cross-user access, secret leakage, unsafe rendering, and denial-of-wallet.
- Document data region, retention, training use, subprocessors, and deletion guarantees before sending production data.

## Unresolved decisions

Before enabling AI, decide and document:

- whether inference is on-device, server-hosted, or user-selected;
- supported languages and devices;
- consent and retention UX;
- cost and latency budgets;
- safety policy and escalation language;
- provider and fallback behavior; and
- whether AI is included, metered, or separately purchased.
