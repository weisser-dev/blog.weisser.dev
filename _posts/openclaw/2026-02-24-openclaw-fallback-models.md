---
title: "OpenClaw Model Fallback Configuration"
date: 2026-02-24
categories:
  - openclaw
tags:
  - openclaw
  - models
  - fallback
  - configuration
  - cost-optimization
read_time: true
excerpt: "How to configure automatic model fallback in OpenClaw – auth profile rotation, cooldown progression, multi-provider chains and cost optimization strategies."
---

OpenClaw supports **automatic model fallback** when your primary model provider runs into issues (token exhaustion, rate limits, billing errors).

## How Fallback Works

OpenClaw handles failures in two stages:

### Stage 1: Auth Profile Rotation
Within the same provider, OpenClaw tries alternative auth profiles. Cooldown is applied to failed profiles (1 min – 1 h).

### Stage 2: Model Fallback
When all profiles for a provider fail, OpenClaw switches to the next model in `agents.defaults.model.fallbacks`.

## Basic Fallback Setup

Edit `~/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai-codex/gpt-5.3-codex",
        "fallbacks": ["qwen-portal/coder-model"]
      }
    }
  }
}
```

### Multiple Fallback Chain

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "openai-codex/gpt-5.3-codex",
        "fallbacks": [
          "openai-codex/gpt-4.1",
          "qwen-portal/coder-model",
          "anthropic/claude-sonnet"
        ]
      }
    }
  }
}
```

## Fallback Triggers

| Error Type | Behavior | Backoff |
|------------|----------|---------|
| Billing/Credit Error | Profile disabled | 5 h – 24 h |
| Rate Limit (429) | Cooldown | 1 min – 1 h |
| Timeout | Cooldown | 1 min – 1 h |
| Auth Error (401) | Cooldown | 1 min – 1 h |

### Cooldown Progression

```
1st failure → 1 minute
2nd failure → 5 minutes
3rd failure → 25 minutes
4th+ failure → 1 hour (cap)
```

Billing errors are treated more seriously (5 h → 10 h → 24 h cap).

## Manual Model Switching

```bash
# Use specific model for this session
openclaw agent --model qwen-portal/coder-model --message "Hello"

# Change default permanently
openclaw config set agents.defaults.model.primary qwen-portal/coder-model

# Check current setup
openclaw config get agents.defaults.model.primary
openclaw config get agents.defaults.model.fallbacks
```

## Monitoring Fallback Events

```bash
# Check auth profile cooldown status
cat ~/.openclaw/agents/main/agent/auth-profiles.json | jq '.usageStats'

# Watch logs for fallback events
openclaw logs --follow | grep -i "fallback\|cooldown\|disabled"
```

## Example Scenarios

### Scenario 1: OpenAI Tokens Exhausted
1. OpenAI returns `402 Payment Required`
2. OpenClaw disables OpenAI profile (5 h)
3. Automatically switches to Qwen
4. Continues using Qwen until OpenAI cooldown expires

### Scenario 2: Temporary Rate Limit
1. OpenAI returns `429 Too Many Requests`
2. OpenClaw applies 1-minute cooldown
3. Retries after cooldown → still rate-limited → falls back to Qwen

### Scenario 3: Multi-Provider
1. OpenAI fails → try Anthropic
2. Anthropic fails → try Qwen
3. All fail → error returned to user

## Per-Agent Overrides

```json
{
  "agents": {
    "list": [
      {
        "id": "main",
        "model": {
          "primary": "openai-codex/gpt-5.3-codex",
          "fallbacks": ["qwen-portal/coder-model"]
        }
      },
      {
        "id": "code-reviewer",
        "model": {
          "primary": "openai-codex/gpt-5.3-codex",
          "fallbacks": []
        }
      },
      {
        "id": "meal-screenshot-intake",
        "model": {
          "primary": "qwen-portal/vision-model",
          "fallbacks": []
        }
      }
    ]
  }
}
```

## Cost Optimization

| Setup | Primary | Fallback | Est. Monthly |
|-------|---------|----------|-------------|
| OpenAI only | GPT-5.3 | None | ~$50–200 |
| OpenAI + Qwen | GPT-5.3 | Qwen (free) | ~$20–80 |
| Qwen only | Qwen | None | $0 |

Use expensive models for critical tasks (security reviews, production code), free fallback for bulk/routine work.

## Troubleshooting

```bash
# Fallback not working – verify config
openclaw config get agents.defaults.model.fallbacks

# Stuck on fallback – check cooldowns
cat ~/.openclaw/agents/main/agent/auth-profiles.json | jq '.usageStats'

# Force reset (restart gateway)
openclaw gateway restart
```

## Next Steps

- [OpenClaw VPS Setup](/blog/2026/02/24/openclaw-vps-setup/)
- [OpenClaw with Qwen](/blog/2026/02/24/openclaw-qwen-setup/)
- [OpenClaw Subagents](/blog/2026/02/24/openclaw-subagents/)
