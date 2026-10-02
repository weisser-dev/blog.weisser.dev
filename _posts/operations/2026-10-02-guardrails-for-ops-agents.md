---
title: "Letting an AI Agent Run My Homelab — and Why That's Nothing Special"
date: 2026-10-02
categories:
  - operations
  - ai
tags:
  - claude-code
  - agents
  - homelab
  - devops
  - security
lang: en
read_time: true
---

*[Deutsche Version](/blog/2026/10/02/guardrails-for-ops-agents-de/)*

My homelab now has agents. One reads logs and explains what went wrong. One runs every 15 minutes and checks whether everything is healthy — and if not, tries to fix it. One looks at CVE scan results and bumps vulnerable dependencies in my own projects. All of them are [Claude Code](https://claude.com/claude-code) running headless (`claude -p`), started from my self-built dashboard.

The obvious question: isn't it insane to let an LLM loose on a server? My answer: it would be — if you gave it a root shell and walked away. But that's not how you run *any* automation, and it's not how I run this one either.

## The setup in one paragraph

A tiny service (`agentd`, ~300 lines of Node, no dependencies) sits next to the Docker host. My dashboard talks to it over HTTP with a bearer token; the dashboard itself sits behind a login. `agentd` starts agent runs, keeps schedules, and stores every run on disk. Each agent is defined in a small JSON file: a name, a default task, whether it's read-only, and a shared set of rules. That's the whole architecture.

## Layer 1: A narrow job, written down

Every agent gets exactly one job. The log agent's prompt says: *fetch the logs for this container, group the errors by cause, rate them, suggest fixes — change nothing.* The repair agent's prompt says: *check containers, recent errors, disk space and public endpoints; if all is fine say so in three lines, otherwise find the cause and fix it.*

On top of that, every run gets the same appended system prompt with the house rules:

- Changes to apps, compose files, proxy config or workflows **only via Git**: clone, change, commit, push — the CI runner deploys. Never edit things directly on the server.
- Allowed without Git: reading logs and status, restarting a single container.
- Forbidden: deleting data, force-pushing, printing secrets, changing what's publicly reachable, rebooting hosts, installing packages.
- If a fix is risky or unclear: change nothing, report.
- End every run with the same three sections: *Findings*, *Actions* (with commit links), *Open points*.

Because the agent runs in a working directory below my home folder, it also automatically loads the same `AGENTS.md` that I keep for every other assistant. It knows how the infrastructure is laid out, where things live and *how changes are supposed to happen here* — the same onboarding a new colleague would get.

A prompt is not a security boundary, though. It's the job description. So there are more layers.

## Layer 2: Every action is reviewed before it runs

The agents run with Claude Code's **auto permission mode**. In this mode a separate safety classifier looks at each action *before* it executes and blocks the ones that are destructive, irreversible or outside what the task asked for. I didn't take that on faith: while building this setup, my own interactive session tried to flip a service from private to public through an API call — and got stopped, because changing public exposure is exactly the kind of thing that should stay a human decision. That's the behaviour I want for an unattended agent, too.

## Layer 3: A hard deny list

The classifier is smart; a deny list is dumb and therefore predictable. Every run starts with `--disallowedTools` for the commands that should never be needed: `rm -rf`, removing or pruning Docker volumes, `git push --force`, reboot and shutdown, destroying or stopping containers at the hypervisor level, `mkfs`, `dd`, package managers. Read-only agents additionally lose the ability to edit files, commit and push. The log agent can look at everything and touch nothing.

## Layer 4: Git is the only way in

This is the most important one, and it isn't AI-specific at all. My rule for *myself* is that nothing gets changed on the server by hand — every change is a commit, and a self-hosted runner deploys it. The agents follow the same rule.

That gives me everything I'd want from a change process for free:

- **An audit trail**: every change is a commit with a trailer that marks it as agent-made.
- **A diff** I can read afterwards.
- **A one-command rollback**: `git revert`, push, done.
- **The same deploy path** as human changes, so there's no "agent-only" way of changing production.

## Layer 5: Blast radius

At most two agents run at the same time, a scheduled agent never overlaps with itself, and every run can be cancelled from the dashboard. Secrets never get handed to the model as text. When the CVE scanner needs GitHub access to scan private repositories, the token is written to a temporary file for the duration of that one scan and deleted afterwards.

## The extra watchdog: the dashboard itself

Agents report what they did. I don't rely on that alone.

- **Every run is fully recorded.** `agentd` stores the complete event stream: every tool call, every command, every output. The dashboard shows it live while the agent works, and afterwards as a readable timeline. If an agent claims "restarted the container", I can see the exact command it ran.
- **The dashboard is independent of the agents.** Container health, restarts, crashes in the last 24 hours, disk usage, CVE counts and endpoint reachability come from Docker and the scanners directly, not from the agent's summary. If the repair agent says "all good" while a container is crash-looping, the dashboard shows the contradiction.
- **GitHub is the second record.** Anything the agent changed is a commit in a repository, visible in the normal history, on a different system than the one the agent works on.

## Why this is nothing special

Strip away the "AI" label and look at what's actually there:

- A **bot account with a narrow job** — like Dependabot or Renovate.
- A **runbook** it follows — like any on-call automation.
- **Least privilege** — a read-only role for analysis, a restricted role for fixes.
- **Changes through version control and CI** — like every deployment pipeline of the last decade.
- **Audit logs, a kill switch and a limited blast radius** — like any cron job you'd let near production.

None of these ideas are new. We've been letting scripts, CI pipelines and bots act on production systems for years, and the playbook for doing that safely is well known. An agent is a more capable script that also explains itself. It deserves the same treatment as any other automation: clear scope, limited permissions, every change reviewable and revertable. Not blind trust, not panic.

## What's not perfect (yet)

To be honest about the current state:

- The agents run on the hypervisor host because that's where Claude Code is logged in, and they inherit that user's rights. The layers above constrain what they *do*; they're not a sandbox. Next step: a dedicated system user with an explicit allow-list of commands.
- For anything non-trivial, the agents should push to a branch and open a pull request instead of pushing to `main`. Small, mechanical fixes (a dependency bump with a green build) are fine to land directly. A refactor isn't.
- There's no hard time or turn limit per run yet. A stuck run has to be cancelled by hand.

None of these are blockers for a homelab. They're the same backlog items you'd write down for any new piece of automation — which is exactly the point.
