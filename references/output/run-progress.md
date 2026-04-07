# run-progress

Maintain a per-run progress log separate from knowledge output.

## Location

`knowledge/.runs/<YYYY-MM-DD>-<mode>.md`

Example: `knowledge/.runs/2026-03-30-burn.md`

## Format

```markdown
# Bottom Feeder Run — YYYY-MM-DD (mode)

**Started:** <ISO timestamp>
**Execution mode:** single | batched | supervised
**Primary provider:** <provider>
**Fallback chain:** [<providers>] or none

## Topics

### 1. <Topic Name>
- **Status:** ✅ complete | 🔄 in-progress | ⚠️ partial | ❌ failed
- **Worker:** <coordinator|subagent-id>
- **Sources used:** brave, perplexity, ...
- **Output:** `knowledge/topics/<slug>.md`
- **Confidence:** high | medium | low
- **Time spent:** ~Xm
- **Notes:** <gaps / caveats>

## Provider Rotation Log
- 2026-04-04T15:12:00Z — anthropic -> openai (reason: 429 burst)

## Incident Log
- failed workers: <count>
- respawns: <count>
- drift reconciliations: <count>

## Summary
- Topics attempted: X
- Topics complete: X
- Topics partial: X
- Topics failed: X
- Ended: <ISO timestamp>
- End reason: all_topics_complete | duration_reached | providers_exhausted | user_stop
```

## Rules

- Update after each topic (not just at end).
- Disk state is source of truth for file existence.
- Reconcile run-log drift when checkpoints detect mismatch.
- Log all provider rotations and respawns.
- Keep this file append-oriented for auditability.
