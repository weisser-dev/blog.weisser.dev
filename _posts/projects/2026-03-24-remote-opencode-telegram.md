---
title: "Bringing OpenCode to Telegram: Vibe Coding from Your Phone"
date: 2026-03-24
categories:
  - projects
  - ai
tags:
  - opencode
  - telegram
  - typescript
  - remote-opencode
  - ai-agent
  - open-source
repo: https://github.com/weisser-dev/remote-opencode-telegram
read_time: true
excerpt: "How I extended remote-opencode with full Telegram support — vibe coding mode, auto-project discovery, token usage stats, and a unified config system. Including the debugging journey through HTTP 401s and SSE auth issues."
---

`remote-opencode` already bridged OpenCode to Discord. Discord works fine on desktop, but on mobile it's clunky for actual coding sessions. Telegram is faster, lighter, and has a better mobile UX. So I added a full Telegram bot — and in the process had to solve a few interesting problems around HTTP Basic Auth, EventSource authentication, and broken JSON configs.

## What Changed

The feature branch `feature/telegram-bot` added about 2700 lines across 24 files. The core additions:

**`src/telegram/`** — A completely new module:
- `telegramBot.ts` — Bot bootstrap using [grammy](https://grammy.dev/), command registration, graceful shutdown
- `telegramHandlers.ts` — All command handlers with smart onboarding and vibe coding mode
- `telegramExecutionService.ts` — Prompt execution with SSE streaming and token/cost stats
- `telegramQueueManager.ts` — Sequential task queue
- `telegramFormatter.ts` — Telegram-specific formatting (4096 char limit vs Discord's 2000)

**Unified config system** — Previously config lived only in `~/.remote-opencode/config.json`. Now there are three tiers with clear priority:

1. `remote-opencode.config.json` (local project file, gitignored)
2. `.env` / environment variables
3. Legacy `~/.remote-opencode/config.json`

This means you can keep your token in a local file, never commit it, and the bot picks it up automatically.

**`remote-opencode configure`** — A single guided wizard that walks through everything: projects base path, default opencode.json, Telegram token, Discord credentials, OpenAI key.

**Auto-project discovery** — Instead of manually registering every project with `/setpath`, you set `projectsBasePaths: ["~/IdeaProjects"]` and every subdirectory becomes available automatically.

**Token usage & cost stats** — After each response, the bot sends a stats message:
```
Tokens: 15.0K in / 47 out
Cost: $0.00
Time: 3.8s
Project: remote-opencode | Branch: feature/telegram-bot | Model: default
/hide_stats to hide
```
Toggle with `/hide_stats` and `/show_stats`.

---

## The Debugging Journey

### Problem 1: Wrong Bot Token

First attempt to start the bot: `401 Unauthorized`. The token I had was `865764589:AAH...` but the correct one from BotFather was `8657645689:AAH...` — one missing digit. Classic copy-paste problem. Quick verification with curl:

```bash
curl -s "https://api.telegram.org/bot8657645689:AAH.../getMe"
```

That immediately tells you whether a token is valid. The response either gives you the bot info or `{"ok":false,"error_code":401}`.

### Problem 2: OpenCode Server HTTP 401

Once the bot was running and I sent a prompt, it hit a 30-second timeout:

```
OpenCode execution failed: Service at port 14097 failed to become ready within 30000ms.
```

The `waitForReady` function was checking `response.ok` (HTTP 200). But opencode v1.2.5 started requiring HTTP Basic Auth. Every request was returning 401, which is not "ok", so the function kept retrying until timeout.

I found the credentials by accident — `env | grep -i opencode` revealed something like:

```
OPENCODE_SERVER_USERNAME=opencode
OPENCODE_SERVER_PASSWORD=<generated-uuid>
```

The OpenCode desktop app injects these when it spawns the server. So I needed to:

1. Pass auth headers with every fetch call
2. Treat 401 as "server is running but auth failed" in `waitForReady`

The fix was a central `authHelper.ts`:

```typescript
export function getAuthHeaders(): Record<string, string> {
  const username = process.env.OPENCODE_SERVER_USERNAME;
  const password = process.env.OPENCODE_SERVER_PASSWORD;

  if (username && password) {
    const encoded = Buffer.from(`${username}:${password}`).toString('base64');
    return { 'Authorization': `Basic ${encoded}` };
  }
  return {};
}
```

And updating `waitForReady` to accept 401 as "ready":

```typescript
if (response.ok || response.status === 401 || response.status === 500) {
  return; // Server is up
}
```

### Problem 3: SSE Connection Fails with Auth

After fixing the regular HTTP calls, the SSE connection still failed with `SSE connection error`. The issue: `EventSource` doesn't support custom headers. You can't do `new EventSource(url, { headers: { Authorization: '...' } })`.

My first attempt was embedding credentials in the URL (`http://user:pass@127.0.0.1:port/event`). That didn't work with `eventsource` v4 either.

The solution was the `fetch` option in `eventsource` v4, which lets you provide a custom fetch function:

```typescript
this.eventSource = new EventSource(url, {
  fetch: (input: string | URL | Request, init?: RequestInit) => {
    const headers = new Headers(init?.headers);
    for (const [key, value] of Object.entries(authHeaders)) {
      headers.set(key, value);
    }
    return globalThis.fetch(input, { ...init, headers });
  },
} as any);
```

This wraps every SSE reconnect attempt with the auth headers injected. Verified with curl first:

```bash
curl -s -N -u "opencode:${OPENCODE_SERVER_PASSWORD}" http://127.0.0.1:14097/event
```

Once that returned `data: ...` events, I knew the endpoint was correct and just needed the auth wiring.

### Problem 4: Broken opencode.json

After fixing auth, the server responded with HTTP 500 and a `ConfigJsonError`. The error pointed to my `~/IdeaProjects/opencode.json` — the global config I wanted to symlink into all projects.

The file had a structural bug: the `mcp` block was never closed. Line 44 ended the last MCP server entry with `},` but then jumped directly to `"enabled_providers"` at the root level without the closing `}` for `"mcp"`:

```json
"mcp": {
  "MCP_PLAYWRIGHT": {
    ...
  },              <-- missing closing } for "mcp"
"enabled_providers": [
```

Fixed by adding the missing brace. Now the server starts clean and the config is valid.

### Problem 5: Telegram Breaks Commands at Hyphens

When I implemented `/list_projects`, each project appeared as a clickable `/sp_<alias>` command. But `open-webui` became `/sp_open` — Telegram stops parsing a command at the first hyphen.

The fix: encode hyphens as double underscores in the command, decode on receive:

```typescript
function encodeAlias(alias: string): string {
  return alias.replace(/-/g, '__');
}
function decodeAlias(encoded: string): string {
  return encoded.replace(/__/g, '-');
}
```

So `open-webui` shows as `/sp_open__webui` in the list (fully clickable), and the handler decodes it back to `open-webui` when processing.

---

## Vibe Coding Mode

The main UX concept: you shouldn't have to type a command prefix for every message. Enable it once, then just... write.

```
/sps   → tap a project
/lm    → tap a model
/vibe_coding
```

After that, every message goes directly to OpenCode. The bot responds with just the AI output — no headers, no "Prompt:", no "Branch:" clutter. All context (project, branch, model, tokens, cost) is in a separate stats message at the end.

### Problem 6: Long Model IDs Break Telegram Command Length Limit

The first approach for clickable model shortcuts was encoding the full model name into the command token: `/sm_AIC_S_Bedrock_SL_eu_P_anthropic_P_claude_H_3_H_5_H_sonnet_H_20240620_H_v1_C_0`. That's 81 characters. Telegram's limit is 64.

The fix: index-based shortcuts. `/sps` and `/lm` now build a numbered list and store a per-chat registry in memory. The command is always short (`/sp1`..`/sm99`), and the full name is shown right next to it so you always know what you're tapping:

```
/sps output:
/sp1 - remote-opencode << current
/sp2 - open-webui
/sp3 - blog.weisser.dev

/lm output:
/sm1 - AIC Bedrock/eu.anthropic.claude-sonnet-4-6
/sm2 - AIC Bedrock/eu.anthropic.claude-haiku-4-5-20251001-v1:0 << current
/sm3 - AIC Azure/gpt-5.2
```

Tap `/sm1` → bot looks up index 1 in the registry → switches to `AIC Bedrock/eu.anthropic.claude-sonnet-4-6`. No encoding, no length issues.

The stats footer also references the shortcuts so you can identify project and model at a glance:

```
Tokens: 15.0K in / 47 out
Cost: $0.00 | Time: 3.8s
sp1 - remote-opencode | Branch: main | sm1 - AIC Bedrock/claude-sonnet-4-6
/hide_stats to hide
```

---

## What This Enables

The practical benefit is coding from your phone without friction. The workflow I actually use now:

1. Think of something while away from desk
2. Open Telegram, tap the bot
3. `/status` to see where I am
4. Type what I need — fix this bug, add this feature, explain this code
5. Response streams in, stats appear, done

The bot runs on the dev machine and OpenCode does the actual work locally. Telegram is just the interface. This means you get the full local context — all your files, your git history, your tools, your MCP servers — without any of that leaving your machine.

The token usage stats are genuinely useful for understanding model costs, especially when switching between providers (Anthropic, Bedrock, Azure) that have very different pricing. Even when a provider returns `$0.00` because it's an internal proxy, the token counts tell you what you're working with.

---

## Installing Locally Without npm publish

The upstream package on npm is still on the old version without Telegram support. Until the maintainer merges and publishes, `npm link` is the way to use the fork globally.

```bash
git clone https://github.com/weisser-dev/remote-opencode-telegram.git
cd remote-opencode-telegram
npm install
npm run build
npm link
```

`npm link` creates a global symlink from your Node.js bin directory to the local `dist/src/cli.js`. After that, `remote-opencode` is available in any shell, in any directory — exactly like a globally installed npm package.

```bash
remote-opencode telegram start
```

The key advantage over `npm install -g` with the upstream version: since `npm link` points to your local `dist/` folder, any rebuild (`npm run build`) is immediately reflected in the global command. No re-linking needed after code changes.

To verify it's wired up correctly:

```bash
which remote-opencode
# -> /Users/you/.nvm/versions/node/v22.x.x/bin/remote-opencode

remote-opencode --version
# -> 1.5.1
```

To undo the link later (e.g. once the upstream npm package catches up):

```bash
npm unlink -g remote-opencode
npm install -g remote-opencode   # install the official version
```

---

## Release

The fork is tagged and released as [v1.5.1](https://github.com/weisser-dev/remote-opencode-telegram/releases/tag/v1.5.1) on GitHub.

## Pull Request

The changes are on [PR #43](https://github.com/RoundTable02/remote-opencode/pull/43) against the upstream `RoundTable02/remote-opencode` repo. No breaking changes — existing Discord functionality is untouched. Both bots share the same underlying services (`serveManager`, `sessionManager`, `dataStore`).
