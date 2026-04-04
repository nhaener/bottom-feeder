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

**Works with any provider** — Anthropic, OpenAI, Venice/Diem, or whatever you're running. No vendor lock-in.

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
3. Customize `config/topics.md` for your team's needs (see the file for guidance)
4. Run a low-burn test:
   - one topic
   - Brave-only source
   - output to `knowledge/topics/<slug>.md`

---

## Key docs

- `references/execution/execution-modes.md`
- `references/execution/provider-fallback.md`
- `references/execution/checkpoint-monitoring.md`
- `references/execution/recovery-patterns.md`
- `references/topic-selection/external-signals.md`
- `references/output/run-progress.md`
- `references/quality-gate/completion-checklist.md`
- **Routine mode**: low-cost and cautious (1 topic, default sources, concise synthesis)
- **Burn mode**: only when explicitly requested (all sources, deeper synthesis, heavier model)
- **Reserve guardrail**: configurable via `min_reserve_usd` (or legacy `min_reserve_diem`)
- **Multi-profile support**: if your provider has multiple auth profiles (team seats, API keys), the agent tracks rotation and flags when a profile is exhausted

Bottom Feeder can read usage from the optional Tide Pool plugin (`provider-usage.sh`) and parse balances via `check-balance.sh`.

---

## Scripts

- `scripts/provider-usage.sh` — usage probe
- `scripts/check-balance.sh` — budget parser
- `scripts/estimate-cost.sh` — rough cost estimator
- `scripts/check-provider-health.sh` — provider reachability preflight
- `scripts/provider-usage.sh` — provider usage snapshot (Tide Pool → legacy lobster → `openclaw status` fallback)
- `scripts/check-balance.sh` — parse budget from JSON (supports `remaining`, `balance`, `credits`, or `venice.data.diem`)
- `scripts/estimate-cost.sh` — rough relative cost estimate by mode/source count

---

## 🔧 Customization

### Topic seeds (`config/topics.md`)
Replace the default topics with what matters to your team. Organize by priority tiers — the agent will pick the highest-value topics first. The more specific your seeds, the better the output.

### Sources
Default: Brave search + local knowledge. Optional: Perplexity (deep synthesis), Twitter (sentiment), CoinGecko/CoinMarketCap (crypto data), browser (page extraction). Add your own source modules in `references/research-sources/`.

### Budget
Set `min_reserve_usd: 0` for no reserve, or a positive number to keep a safety buffer. For Venice-first setups, keep `min_reserve_diem` as a legacy fallback reserve when USD is not configured. Optional per-topic caps can use provider-agnostic `max_estimated_cost_units_per_topic_*` (legacy `max_estimated_diem_per_topic_*` remains supported).

---

## Recommended defaults for broad teams

- Start with `execution_mode: single` in routine mode
- Use `execution_mode: batched`, `batch_size: 2-3` in burn mode
- Enable supervised mode + checkpoints for runs >2h
- Configure a fallback chain instead of strict provider lock
- Keep subagents short-lived (1 topic each)
- Keep it crusty
- Keep it clean
- Don't zero the tank unless boss says so

---

Keep it useful, keep it auditable, keep it alive under failure.
