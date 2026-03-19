---
name: bottom-feeder
description: Depth-first knowledge crawling workflow that selects 1-2 high-value topics, researches with configured sources, synthesizes durable notes, and writes/updates files in knowledge/topics and knowledge/research. Use when asked to build or refresh knowledge files, run a scheduled knowledge-crawl, detect knowledge gaps, or run low-cost/Diem-aware research passes.
---

# Bottom Feeder

Run a modular 4-stage pipeline:
1) topic selection
2) research collection
3) synthesis
4) output writing

Prioritize depth over breadth. Default to 1 topic (max 2).

## Inputs to Load First

1. `config/defaults.yaml`
2. `config/topics.md`
3. If present, `config/next-topic.md` (force-priority override)

## Workflow

### 1) Select topic

Use these modules in order:
- `references/topic-selection/hardcoded-list.md`
- `references/topic-selection/conversation-mining.md`
- `references/topic-selection/knowledge-gaps.md`
- `references/topic-selection/knowledge-refresh.md`
- `references/topic-selection/trending.md`

Combine candidates, dedupe, score, and pick top 1-2.

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
- Why it matters for JPop/EdgeClaw ecosystem
- Key entities/projects
- Open questions + what to watch
- Sources with dates

For updates, include a short "What’s new since last update" section.

### 4) Write output

Use:
- `references/output/knowledge-writer.md`
- `references/output/lobsearch-index.md`

Write immediately after each topic (incremental write, never batch all topics first).

## Modes

### Routine mode (default)
- 1 topic
- low-cost sources
- concise synthesis
- quiet completion unless user asked for report

### Burn mode (explicit only)
Use when user explicitly asks to consume remaining Diem/credits.

Steps:
1. Run `scripts/provider-usage.sh` (uses optional standalone `tide-pool` package when present; supports legacy lobster path)
2. Run `scripts/check-balance.sh` if you already have Diem JSON input to parse
3. Keep reserve from config (`min_reserve_diem`)
4. Use heavier model + more sources
5. Save after every topic
6. Stop gracefully if balance or provider limit is hit

## Guardrails

- Never spend down to zero unless user explicitly says to.
- Avoid duplicate rewrites when no meaningful updates exist.
- Prefer free/local sources first.
- If source collection is weak, write a partial with clear uncertainty notes.
- Keep files readable; split oversized output into follow-up research files.

## Quick manual run recipe

1. Pick one topic from `config/topics.md`
2. Run brave search (3-6 results)
3. Synthesize into `knowledge/topics/<slug>.md`
4. Log run note in `memory/daily/YYYY-MM-DD.md`
5. Report: topic, files changed, estimated cost mode used
