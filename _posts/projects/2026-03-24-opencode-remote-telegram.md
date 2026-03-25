---
title: "opencode-remote-telegram: Control OpenCode from Your Phone via Telegram"
date: 2026-03-25
categories:
  - projects
  - ai
tags:
  - opencode
  - telegram
  - bot
  - ai
  - vibe-coding
  - typescript
repo: https://github.com/weisser-dev/opencode-remote-telegram
read_time: true
---

[opencode-remote-telegram](https://github.com/weisser-dev/opencode-remote-telegram) is a Telegram bot that lets you control [OpenCode](https://opencode.ai) from your phone. Pick a project, pick a model, type what you want — the agent works, you get the formatted result.

## The origin story

The project was inspired by [RoundTable02/remote-opencode](https://github.com/RoundTable02/remote-opencode), a Discord bot for remote OpenCode access. The goal: take the concept, build a clean Telegram-native version with proper UX. It turned into a full rewrite — per-instance auth, SSE event handling, inline keyboards, persistent state, and a system prompt that teaches the model to format its output for Telegram.

## How it works

```
Your Phone (Telegram)
        │
        ▼
opencode-remote-telegram
        │  spawns per project, on demand
        │  per-instance random Basic Auth
        │  idle timeout: 10 min
        ▼
opencode serve  (HTTP API + SSE)
        │
        ▼
Your Codebase
```

The bot spawns `opencode serve` in your project directory when you start a coding session. Each instance gets a randomly generated password. Prompts are sent with a system prefix that instructs the model to format output for Telegram (no markdown tables, short paragraphs, code in fenced blocks). Responses are collected silently while witty loading messages rotate, then delivered as properly formatted HTML.

## Install

```bash
npm install -g opencode-remote-telegram
```

## Setup

```bash
opencode-remote-telegram setup
```

The wizard walks you through four steps:

**1. Telegram Bot Token**
- Open Telegram → search for **@BotFather** → `/newbot`
- Copy the token (looks like `1234567890:ABCdef…`)

**2. Access control**
- Message **@userinfobot** to find your Telegram user ID
- Enter your ID to restrict access

**3. Projects base directory**
- Point to your projects folder — subdirectories are auto-discovered
- Example: `~/Projects` → discovers `~/Projects/my-app`, `~/Projects/api`

**4. OpenCode config**
- Recommended: use a single global `opencode.json` for all projects
- Place it at `~/.config/opencode-remote-telegram/opencode.json`
- This prevents project-level configs from overriding credentials

## Verify the setup

```bash
opencode-remote-telegram test
```

This checks: config loaded, projects found, models loaded, server starts, test prompt gets a response.

## Start the bot

```bash
opencode-remote-telegram start
```

On first `/start` in Telegram, the bot shows an onboarding with inline buttons: pick a project, pick a model, start coding.

## Commands

**Projects**
- `/list_projects` — inline keyboard, tap to switch
- `/new_project` — clone a GitHub repo interactively
- `/switch_project <alias>` — switch by name

**Models**
- `/list_models` — inline keyboard, tap to switch
- `/switch_model <name>` — switch by name

**Coding**
- `/vibe_coding` — start passthrough session
- `/stop_coding` — stop session
- `/interrupt` — interrupt running task
- `/diff` — `git diff --stat HEAD`
- `/undo` — revert last commit (soft reset, with confirmation)

**Stats & History**
- `/show_stats` — token count, cost, duration after each response
- `/hide_stats` — hide stats
- `/history` — last 10 prompts with model and cost
- `/costs` — daily and weekly cost summary

**Queue**
- `/queue_list` — show queued prompts
- `/queue_clear` — clear queue
- `/queue_settings` — toggle continue-on-failure

**Info**
- `/status` — project, model, queue, settings
- `/clear` — reset everything
- `/help` — all commands

## The user experience

When you send a message while vibe coding is inactive (e.g. after a server restart), the bot offers three options:

- **Start & send this message** — activates vibe coding and immediately sends your text as the first prompt
- **Just start coding** — activates vibe coding, waits for the next message
- **No** — shows project/model/help buttons instead

While the agent is working (reading files, running tools), witty loading messages rotate every 4 seconds. The final response is delivered as a single formatted message — no partial streaming output, no thinking text.

## Configuration files

All config lives in `~/.config/opencode-remote-telegram/`:

- `config.json` — bot token, allowed users, project path
- `opencode.json` — global OpenCode config (providers, models)
- `state.json` — persisted state (project/model per chat, settings, history)
- `logs/` — daily log files

## Debug mode

```bash
opencode-remote-telegram --debug start
```

Logs every incoming message, command, callback and outgoing reply with timestamps.

## What this is a demo of

The entire project was built with OpenCode — including the architecture decisions, the SSE event mapping, and the Telegram formatting layer. It's a live example of AI-assisted development: describe what you want, iterate on the output, ship it.

---

Inspired by [RoundTable02/remote-opencode](https://github.com/RoundTable02/remote-opencode) — if you want OpenCode via Discord instead of Telegram, check it out.
