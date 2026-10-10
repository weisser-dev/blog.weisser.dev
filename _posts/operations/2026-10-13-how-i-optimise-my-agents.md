---
title: "How I Optimise My Agents: Logs, Reports, Vetoes and Small Steps"
date: 2026-10-13
categories:
  - operations
  - ai
tags:
  - agents
  - claude-code
  - automation
  - observability
lang: en
ref: how-i-optimise-my-agents
read_time: true
---

Getting an agent to do something once is easy. Getting ten scheduled agents to keep doing useful things for months, without me babysitting them, is a different job. Most of what makes that work is not clever prompting. It is boring operations: logs, budgets, permissions, reviews.

This post is the checklist I follow. To keep it concrete, everything below is shown on an **invented** example: a small recipe-sharing site called *Pantry Notes*. The app, the numbers and the log entries are made up for this post.

## The eight habits

1. **One run-log format for every agent.** Each scheduled run appends one line to the same kind of file. Without that, "what did the agents do last week?" is archaeology.
2. **A short morning report.** One page, generated from the logs, readable in a minute. If it is long, I stop reading it.
3. **A review agent that reads all logs.** Its only job is to tell me what *quietly stopped*: agents that did not run, runs that always end the same way, outputs that stopped changing.
4. **A veto window before anything is published.** Automatic publishing waits, for example, 24 hours as a draft. I can cancel; silence means go.
5. **Tight permissions per task.** The changelog agent can read the repo and write one file. It cannot touch CI or secrets.
6. **Hard budgets and timeouts.** Every run has a maximum number of turns, a spending cap and a wall-clock timeout. A stuck agent is stopped by the runner, not by me.
7. **The right model per task.** A big model for design and review, a mid-size one for implementation, a small one for tests and summaries.
8. **Small, verified steps, and failures written down.** Each run does one small thing and proves it worked. When something goes wrong, the lesson goes into the agent's instructions.

## The worked example: Pantry Notes

Pantry Notes is a fictional recipe-sharing site with four scheduled agents:

| Agent | Task | Model class | Permissions |
|---|---|---|---|
| `deps-bumper` | Bump patch/minor dependencies, open a PR | mid-size | read repo, write branch, run tests |
| `link-checker` | Find dead links in recipes, file a list | small | read repo, read-only HTTP |
| `changelog-writer` | Draft release notes from merged PRs | small | read git history, write `drafts/` |
| `reviewer` | Read all logs, report what stopped | big | read logs only |

### 1. One run-log format

Every run, whatever the agent, ends by appending a single JSON line to `runs/<agent>.jsonl`. The runner writes it, not the agent, so a crashed agent still leaves a record. Pretty-printed here for readability:

```json
{
  "ts": "2026-10-09T03:12:44Z",
  "agent": "deps-bumper",
  "run_id": "deps-bumper-20261009-0312",
  "model_class": "mid",
  "status": "partial",
  "duration_s": 412,
  "turns": 23,
  "cost_usd": 0.84,
  "budget_usd": 1.50,
  "timeout_s": 900,
  "task": "bump patch and minor dependencies",
  "result": "2 of 3 bumps merged-ready, 1 skipped: tests failed",
  "artifacts": ["pr:example/pantry-notes#212"],
  "verified": true,
  "next_action": "retry skipped bump with pinned lockfile",
  "error": null
}
```

The point is not these exact fields. The point is that **status, cost, duration, result and whether the result was verified** are always in the same place, so one small script (or one small agent) can read all of them.

### 2. The morning report

A summary job (small model, read-only) turns the last 24 hours of logs into a report. This is the whole thing, and it is meant to stay that short:

```text
Pantry Notes - agents - 2026-10-10

Ran 4 of 4 scheduled agents. Total cost: $2.10 (cap: $6.00).

OK       link-checker      38 dead links found, 5 new since Tuesday
PARTIAL  deps-bumper       2 bumps ready (PR #212), 1 skipped: tests failed
DRAFT    changelog-writer  release notes for v1.8.0 queued, publishes
                           Sat 09:00 unless vetoed
OK       reviewer          see below

Needs you today: look at PR #212, decide on the v1.8.0 draft.
```

I read this with coffee. If every line is OK, it takes ten seconds.

### 3. The review agent

The morning report only describes what *happened*. The failure mode I worry about is what *did not* happen. So a separate review agent (the big model, read-only access to the logs) reads all the run logs of the past two weeks and must answer one question: **what quietly stopped, or quietly stopped being useful?** It always returns exactly three items, ranked:

```text
1. link-checker: no new fix PRs for 11 days, although it reports dead
   links every run. The reports are being produced but nobody acts on
   them. Suggest: let it open one PR per run with at most 5 fixes.

2. changelog-writer: last 3 drafts were identical except the version
   number. Either the template is too rigid or it no longer reads the
   merged PRs. Check the artifacts of runs 0928, 0930, 1007.

3. deps-bumper: "partial" 4 runs in a row, always the same skipped
   package. A known failure is being retried forever at a cost of
   about $0.30 per run. Suggest: record it as a known issue in the
   agent's instructions and skip it explicitly.
```

Three items is deliberate. A list of fifteen "observations" gets ignored; three ranked ones get done. Note that none of these is a crash. They are the quiet failures: an agent that keeps running and stops mattering.

### 4. The veto window

The `changelog-writer` never publishes directly. It writes `drafts/release-1.8.0.md` and a timer publishes it after 24 hours, unless a `VETO` file next to it exists. The morning report tells me about the pending draft, so the veto window is actually seen. This costs one day of latency and removes the fear of automatic publishing. Anything that goes public, sends a message or spends money gets such a window, or a human approval.

### 5. Tight permissions per task

Each agent gets an explicit allow-list for exactly its task, nothing inherited. Claude Code supports this with permission rules and modes ([permissions docs](https://code.claude.com/docs/en/permissions)). For the `link-checker`, for instance, the allow-list is "read files, run the link-check script, write the report file", and nothing else. When an agent needs something new, I add that one thing, on purpose. The default is *deny*.

### 6. Hard budgets and timeouts

Three limits per run, enforced by the runner and not just requested in the prompt: a maximum number of turns, a maximum spend, and a wall-clock timeout. Claude Code's CLI has options for the first two (`--max-turns`, `--max-budget-usd`, see the [CLI reference](https://code.claude.com/docs/en/cli-reference)); the timeout I do with the scheduler. In the log above, `deps-bumper` used $0.84 of a $1.50 cap. If a run hits the cap, that is a finding in itself and shows up in the morning report.

### 7. Model choice per task

I do not use one model for everything:

- **Big model:** design decisions, the review agent, anything that has to judge other work.
- **Mid-size model:** implementation, like the dependency bumps.
- **Small model:** running tests, summaries, the morning report.

This is both cheaper and often better: the small model is fast enough for routine work, and the expensive one is spent where judgement matters. When unsure, I pick the more capable class for the first week and downgrade once the logs show it is not needed.

### 8. Small steps and lessons learned

Each run does one small thing and checks it, for example "bump one package, run the tests, record the result" rather than "update everything". The `verified` field in the log says whether the agent actually ran the check, not just whether it claimed success. A claim without verification counts as `unverified` in the report.

And when something fails, the lesson goes into the agent's own instructions. After the `deps-bumper` kept retrying the same broken bump, its instruction file got two new lines:

```text
Known issue: package "image-resizer" 4.x breaks the upload tests.
Do not bump it. Note it in the log as "skipped: known issue" and move on.
```

The failure happens once, the instruction file remembers it, and the review agent's next report is shorter. Treat the instructions as a living runbook, reviewed like code.

## Open standards for agent workflows

Once you run several agents, you end up describing the same things every time: who owns a workflow, which agent does which step, what it may use, what its budget is, what gets logged. Open standards for describing agent workflows now exist, for example the [Agentic Workflow Protocol (AWP)](https://agenticworkflowprotocol.org). Its site describes it as an open specification for portable, auditable and policy-controlled agentic workflows, defined in declarative YAML manifests that cover agents, tools, execution order, budgets, permissions and audit events. It is marked as a draft (`v1alpha1`), so fields may change. I am mentioning it as an example of the direction, not as something this post depends on; the habits above work with plain files and a scheduler.

## What I would do first

If you have agents running and none of this yet, start with the cheapest two: **one log format** and **hard limits**. Everything else (the report, the review agent, the vetoes) builds on having reliable logs. Then add the review agent, because silent failures are the ones that cost you the most.

## Sources

- Anthropic: [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
- Claude Code: [Run Claude Code programmatically (headless)](https://code.claude.com/docs/en/headless)
- Claude Code: [Permissions](https://code.claude.com/docs/en/permissions)
- Claude Code: [CLI reference](https://code.claude.com/docs/en/cli-reference) (`--max-turns`, `--max-budget-usd`, `--model`, `--permission-mode`)
- Claude Code: [Manage costs](https://code.claude.com/docs/en/costs)
- JSON Lines: [jsonlines.org](https://jsonlines.org/)
- Agentic Workflow Protocol: [agenticworkflowprotocol.org](https://agenticworkflowprotocol.org)

*Pantry Notes, its agents, numbers and log entries are invented for illustration.*
