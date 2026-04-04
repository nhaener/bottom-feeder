# 🦞 Bottom Feeder

A depth-first knowledge crawler skill for OpenClaw that turns research prompts into durable knowledge artifacts (`knowledge/topics`, `knowledge/research`, `knowledge/procedures`) without blind budget burn.

---

## What it does

Bottom Feeder runs a practical pipeline:

1. **Execution planning** (single / batched / supervised)
2. **Topic selection** (seeds + gaps + refresh + optional external signals)
3. **Research collection** (Brave baseline + optional sources)
4. **Synthesis** (durable, self-contained markdown)
5. **Output writing + run logging** (audit trail in `knowledge/.runs/...`)
6. **Checkpoint monitoring** (for long runs)

It is provider-agnostic and works with Anthropic/OpenAI/Venice/etc.

---

## New in this release

- ✅ **Execution modes**: single, batched parallel, supervised
- ✅ **Provider fallback chains** with failure/cooldown triggers
- ✅ **Checkpoint monitoring pattern** for long runs
- ✅ **Recovery procedures** for subagent failures and run-log drift
- ✅ **External signal integration** (Asana/Jira/Linear/GitHub/Notion/generic)
- ✅ **Run-policy and signals templates**
- ✅ **Provider preflight script**: `scripts/check-provider-health.sh`

---

## Folder placement

```text
workspace/
├── skills/
│   └── bottom-feeder/
│       ├── SKILL.md
│       ├── config/
│       ├── references/
│       └── scripts/
└── knowledge/
    ├── topics/
    ├── research/
    └── .runs/
```

---

## Quick start

1. Install skill folder in `workspace/skills/bottom-feeder`
2. Check required files:
   - `SKILL.md`
   - `config/defaults.yaml`
   - `scripts/provider-usage.sh`
   - `scripts/check-balance.sh`
3. (Optional) Copy templates:
   - `config/run-policy.md.example` → `config/run-policy.md`
   - `config/signals.yaml.example` → `config/signals.yaml`
4. Run one routine topic first.

---

## Key docs

- `references/execution/execution-modes.md`
- `references/execution/provider-fallback.md`
- `references/execution/checkpoint-monitoring.md`
- `references/execution/recovery-patterns.md`
- `references/topic-selection/external-signals.md`
- `references/output/run-progress.md`
- `references/quality-gate/completion-checklist.md`

---

## Scripts

- `scripts/provider-usage.sh` — usage probe
- `scripts/check-balance.sh` — budget parser
- `scripts/estimate-cost.sh` — rough cost estimator
- `scripts/check-provider-health.sh` — provider reachability preflight

---

## Recommended defaults for broad teams

- Start with `execution_mode: single` in routine mode
- Use `execution_mode: batched`, `batch_size: 2-3` in burn mode
- Enable supervised mode + checkpoints for runs >2h
- Configure a fallback chain instead of strict provider lock
- Keep subagents short-lived (1 topic each)

---

Keep it useful, keep it auditable, keep it alive under failure.
