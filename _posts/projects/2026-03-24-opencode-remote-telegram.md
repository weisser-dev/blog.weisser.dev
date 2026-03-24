---
title: "opencode-remote-telegram: Control OpenCode from Your Phone via Telegram"
date: 2026-03-24
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

[opencode-remote-telegram](https://github.com/weisser-dev/opencode-remote-telegram) is a Telegram bot that lets you control [OpenCode](https://opencode.ai) from your phone. Start a coding session, switch projects, stream AI responses in real time — all from a Telegram chat.

## The origin story

The project started as a fork of [RoundTable02/remote-opencode](https://github.com/RoundTable02/remote-opencode), a Discord bot for remote OpenCode access. The goal was straightforward: take the existing architecture, strip out the Discord layer, and replace it with a clean Telegram integration — ideally in under an hour.

It ended up taking a bit longer than that. The core SSE streaming, per-instance auth, and the new feature set turned it into a full rewrite rather than a fork. But the premise held: start from something that exists, describe what you want, let OpenCode do the heavy lifting.

## How it works

When you start a coding session, the bot spawns `opencode serve` in your project directory. Each instance gets a randomly generated Basic Auth password — no static credentials needed. Prompts go in via the OpenCode HTTP API, and responses stream back to Telegram in real time using the `message.part.delta` SSE events.

```
Your Phone (Telegram)
        │
        ▼
opencode-remote-telegram
        │  spawns per project on demand
        ▼
opencode serve  (HTTP API, per-instance Basic Auth)
        │
        ▼
Your Codebase
```

## Install

```bash
npm install -g opencode-remote-telegram
opencode-remote-telegram start
```

On first run the setup wizard launches automatically. It walks you through four steps:

1. **Telegram Bot Token** — create a bot via @BotFather, paste the token
2. **Access control** — restrict to specific Telegram user IDs (find yours via @userinfobot)
3. **Projects base directory** — every subdirectory is auto-discovered as a project
4. **OpenCode config** — recommended: use a single global `opencode.json` for all projects

Config is stored at `~/.config/opencode-remote-telegram/config.json`. No `.env` file needed.

### Global opencode.json

If your projects have their own `opencode.json` files, they often lack provider credentials (`baseURL`, `apiKey`) and will fail with `"undefined/chat/completions"`. The fix: place a shared config here and it always takes priority:

```
~/.config/opencode-remote-telegram/opencode.json
```

## Commands

The bot uses inline keyboards — tap to switch, no typing needed.

| Command | Description |
|---|---|
| `/list_projects` | Tap-to-switch project picker |
| `/list_models` | Tap-to-switch model picker |
| `/vibe_coding` | Start passthrough coding session |
| `/stop_coding` | Stop session |
| `/new_project` | Clone a GitHub repo interactively |
| `/diff` | `git diff --stat HEAD` for current project |
| `/show_stats` | Token count, cost and duration after responses |
| `/queue_settings` | Toggle continue-on-failure behavior |
| `/status` | Current project, model and queue |

## The workflow

```
/list_projects → pick project (inline button)
       ↓
/list_models → pick model (inline button)
       ↓
/vibe_coding → start session
       ↓
type anything → OpenCode works → response streams in
       ↓
🤔 Let me have a look… → HELLO WORLD
```

Stats appear after the response is complete (never during):
```
eu.anthropic.claude-sonnet-4-6
in 11,544 · out 6 · $0.0000 · 1.8s
```

## What this is a demo of

The project itself is a live example of AI-assisted development. The architecture decisions — per-instance auth, global config priority, SSE event mapping — were made through conversations with OpenCode. The code was written by the agent, reviewed and iterated by a human.

That loop is exactly what the [Agentic AI Workshop](https://agentic-ai.weisser.dev) teaches. Build something real, with AI, and use the process itself as the demo.

---

Inspired by [RoundTable02/remote-opencode](https://github.com/RoundTable02/remote-opencode) — if you want OpenCode via Discord instead of Telegram, check it out.
