---
name: bottom-feeder
description: Depth-first knowledge crawling workflow that selects 1-2 high-value topics, researches with configured sources, synthesizes durable notes, and writes/updates files in knowledge/topics and knowledge/research. Use when asked to build or refresh knowledge files, run a scheduled knowledge-crawl, detect knowledge gaps, or run budget-aware research passes (supports any provider — Anthropic, OpenAI, Venice/Diem, etc.).
---

# Bottom Feeder

Run a modular pipeline:

0) **execution planning** (single vs batched vs supervised — see `references/execution/execution-modes.md`)
1) topic selection
2) research collection
3) synthesis
4) output writing
5) monitoring (optional, for long runs — see `references/execution/checkpoint-monitoring.md`)

Prioritize depth over breadth. Default to 1 topic (max 2) in routine mode.

## Inputs to Load First

1. `config/defaults.yaml`
2. `config/topics.md`
3. If present, `config/next-topic.md` (force-priority override)
4. If present, `config/run-policy.md` (hard constraints for the current run — a fresh one can be derived from `config/run-policy.md.example`)
5. If present, `config/signals.yaml` (external signal sources like Asana/Jira/Linear/GitHub — see `references/topic-selection/external-signals.md`)

## Workflow

### 0) Plan execution

Before selecting topics, decide **how** the run will execute:

- **Single-agent (default):** one session writes all topics in sequence. Best for routine mode, ≤3 topics, stable providers.
- **Batched parallel:** N concurrent short-lived subagents (N=2–3 by default), 1 topic each, tight per-subagent timeout. Best for burn mode, >3 topics, when provider can sustain parallelism.
- **Supervised:** coordinator + workers + checkpoint crons. Best for long runs (>2h), unreliable providers, or when you want push-based progress reports.

See `references/execution/execution-modes.md` for the full decision guide.

If a run-policy is present and declares `execution_mode`, use it. Otherwise infer from `mode` (routine → single, burn → batched, explicit long run → supervised).

### 1) Select topic

Use these modules in order:
- `references/topic-selection/hardcoded-list.md`
- `references/topic-selection/conversation-mining.md`
- `references/topic-selection/knowledge-gaps.md`
- `references/topic-selection/knowledge-refresh.md`
- `references/topic-selection/trending.md`
- `references/topic-selection/external-signals.md` (optional — pulls live task/issue/ticket signal from Asana/Jira/Linear/GitHub/Notion/etc. to steer topics toward real operational pressure)

Combine candidates, dedupe, score, and pick top 1-2 (or as many as the run-policy declares).

Before finalizing topic, run a quick duplicate check:
- Search `knowledge/` for existing coverage.
- If coverage is already strong and recent, skip and pick next candidate.

### 2) Collect research

Pick sources by topic type using:
- `references/research-sources/brave.md` (baseline)
- `references/research-sources/perplexity.md` (optional deep synth)
- `references/research-sources/twitter.md` (optional sentiment/news pulse)
- `references/research-sources/coingecko.md` (optional crypto data)
- `references/research-sources/coinmarketcap.md` (optional crypto metadata)
- `references/research-sources/browser.md` (optional page extraction)

Low-cost default: brave only, plus local knowledge lookup.

### 3) Synthesize

Create one durable, standalone knowledge artifact per topic:
- What it is
- Current state
- Why it matters (for the user's ecosystem/team/work)
- Key entities/projects
- Open questions + what to watch
- Sources with dates

For updates, include a short "What's new since last update" section.

### 3.5) Quality gate

Before advancing to the next topic, run:
- `references/quality-gate/completion-checklist.md`

Every section must pass or be explicitly tagged `[INCOMPLETE: reason]`.
Do not start topic N+1 until topic N clears the gate.

### 4) Write output

Use:
- `references/output/knowledge-writer.md`
- `references/output/run-progress.md`
- `references/output/lobsearch-index.md`

Write immediately after each topic (incremental write, never batch all topics first).

After writing each topic, update the run progress log (`knowledge/.runs/<date>-<mode>.md`).
This is your audit trail — always current, even if the run is interrupted.

### 5) Monitoring (optional)

For **supervised** or long burn runs, schedule checkpoint jobs (cron or equivalent) to verify forward progress and surface stalls before they become expensive:
- `references/execution/checkpoint-monitoring.md`

Checkpoints read the run-progress file and new-file diffs, and announce status. They do **not** need to spawn new workers — they raise alerts that the coordinator can act on.

## Modes

### Routine mode (default)
- 1 topic
- low-cost sources
- single-agent execution
- concise synthesis
- quiet completion unless user asked for report

### Burn mode (explicit only)
Use when user explicitly asks to consume remaining credits/budget aggressively.

Steps:
1. Run `scripts/provider-usage.sh` to check current usage (supports Tide Pool, legacy lobster, or generic `openclaw status` fallback)
2. Run `scripts/check-balance.sh` if you have balance JSON input to parse (supports generic fields: `remaining`, `balance`, `credits`, or Venice-specific `venice.data.diem`)
3. Keep reserve from config: use `min_reserve_usd` when set (>0), otherwise fall back to legacy `min_reserve_diem`
4. Optional: run `scripts/check-provider-health.sh` to verify each provider in the fallback chain is reachable before launch
5. Use heavier model + more sources (all optional sources enabled)
6. **Execute in batched parallel or supervised mode** (see execution-modes.md). Do **not** spawn all topics at once — that is the #1 cause of rate-limit cascades.
7. Save after every topic (incremental write — never batch)
8. Stop gracefully if balance or provider limit is hit
9. If the run-policy declares a `provider_fallback` chain, honor it strictly: primary first, switch to next on qualified failure (see `references/execution/provider-fallback.md`).
10. If multiple auth profiles are available, monitor for exhaustion and note when rotation is needed

### Provider fallback (when configured)
If `config/run-policy.md` declares a fallback chain, enforce it per `references/execution/provider-fallback.md`:
- Track consecutive failures per provider.
- On qualified failure (rate_limit / cooldown / auth / transport), rotate to next provider.
- Log every rotation with reason, timestamp, and provider change in the run-progress file.
- If **all** providers in the chain are exhausted, stop and ask the user whether to wait, extend chain, or abort.

### Provider lock (strict mode)
If `config/run-policy.md` specifies `provider_lock: <provider>` and **no** fallback chain, enforce the lock strictly and stop on failure. Do not silently switch providers. This mode should be used only when provider compliance is a hard requirement (legal/billing/policy). Prefer fallback chains in normal operation.
3. Keep reserve from config (`min_reserve_usd`) if set
4. Use heavier model + more sources (all optional sources enabled)
5. Save after every topic (incremental write — never batch)
6. Stop gracefully if balance or provider limit is hit
7. If multiple auth profiles are available, monitor for exhaustion and note when rotation is needed

## Ad-hoc topic injection

Users can pass topics directly instead of using the seed list:
- "Run bottom feeder on [topic1, topic2, ...]"
- Ad-hoc topics skip the selection stage entirely — go straight to research.
- Still subject to quality gate and progress logging.

## Guardrails

- Never spend down to zero unless user explicitly says to.
- Avoid duplicate rewrites when no meaningful updates exist.
- Prefer free/local sources first.
- If source collection is weak, write a partial with clear uncertainty notes.
- Keep files readable; split oversized output into follow-up research files.
- In burn mode with multiple auth profiles, track which profile is active and flag when switching is needed.
- **Never spawn more than `batch_size` concurrent subagents** (default: 3). Larger parallel spawns trigger provider rate-limit cascades and kill throughput.
- **Keep subagents short-lived** (1 topic per subagent, tight timeout). Long-running subagents die silently under load.
- **Keep the run-log synced with disk state.** If a file exists but the run-log still shows "in-progress", the log is stale and must be reconciled (see `references/output/run-progress.md`).

## Quick manual run recipe

1. Pick one topic from `config/topics.md`
2. Run brave search (3-6 results)
3. Synthesize into `knowledge/topics/<slug>.md`
4. Log run note in `memory/daily/YYYY-MM-DD.md`
5. Report: topic, files changed, estimated cost mode used

## References — new in this version

- `references/execution/execution-modes.md` — single vs batched parallel vs supervised
- `references/execution/provider-fallback.md` — fallback chain semantics, triggers, rotation policy
- `references/execution/checkpoint-monitoring.md` — cron-based checkpoint pattern for long runs
- `references/execution/recovery-patterns.md` — what to do when subagents die
- `references/execution/lessons-learned.md` — retrospective from real burn runs
- `references/topic-selection/external-signals.md` — integrate live task/issue/ticket signal
- `config/run-policy.md.example` — opt-in run-policy template with fallback + batching
- `config/signals.yaml.example` — opt-in external signal sources template
- `scripts/check-provider-health.sh` — pre-flight provider reachability probe
