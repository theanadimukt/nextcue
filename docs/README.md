# NextCue Documentation

This directory contains the approved product definition, binding delivery constraints, domain language, durable decisions, discovery history, and deferred concepts for NextCue.

## Document map

| Path | Responsibility | Authority |
|---|---|---|
| [`product/PRODUCT.md`](product/PRODUCT.md) | Defines the current user, product behavior, MVP scope, and validation criteria. | Authoritative for what the product does. |
| [`product/CONSTRAINTS.md`](product/CONSTRAINTS.md) | Defines binding platform, privacy, reliability, and delivery boundaries. | Authoritative for what implementations must not violate. |
| [`domain/GLOSSARY.md`](domain/GLOSSARY.md) | Defines shared terms, lifecycle states, derived views, and transition rules. | Authoritative for domain language and semantics. |
| [`decisions/`](decisions/) | Records why consequential product and architecture decisions were made. | Accepted ADRs govern the decisions they cover until superseded. |
| [`plan/`](plan/) | Breaks Version 1 delivery into dependency-ordered phases and GitHub issue-ready work. | Operational planning; it must remain consistent with authoritative product, constraint, domain, and ADR documents. |
| [`discovery/`](discovery/) | Preserves ideation and research that led to the approved direction. | Informative; never an implementation source of truth. |
| [`future/AI.md`](future/AI.md) | Describes deferred AI possibilities and the gates for reconsidering them. | Non-binding for Version 1. |

## Reading order

Before planning or implementing NextCue:

1. Read `product/PRODUCT.md`.
2. Read `product/CONSTRAINTS.md`.
3. Use `domain/GLOSSARY.md` for names and lifecycle behavior.
4. Read the relevant ADR before revisiting an accepted decision.
5. Use `plan/` for delivery sequencing and GitHub issue scope.
6. Treat `discovery/` and `future/` as context, not requirements.

## Conflict policy

The product definition, constraints, glossary, and accepted ADRs are intended to agree. A conflict between them is a documentation defect: stop and reconcile it rather than silently choosing one interpretation. New decisions that reverse an ADR require a new ADR that supersedes the old one.

## Current status

The product direction is approved for a private ten-person pilot. No application code has been created. Flutter is provisional until the cross-platform share-capture spike in ADR-003 passes.
