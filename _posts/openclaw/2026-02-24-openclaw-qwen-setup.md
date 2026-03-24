---
title: "OpenClaw with Qwen (Free Models)"
date: 2026-02-24
categories:
  - openclaw
tags:
  - openclaw
  - qwen
  - free-models
  - setup
  - rag
read_time: true
excerpt: "How to use OpenClaw with Qwen Portal's free AI models using the qwen-portal-auth skill – 128k context, vision support, zero cost."
---

This guide shows you how to configure OpenClaw to use **Qwen Portal's free AI models** – a cost-effective alternative to paid providers like OpenAI or Anthropic.

## Why Qwen?

- **Free to use** – No credit card required
- **Good code capabilities** – Qwen Coder model optimized for programming
- **Large context window** – 128k tokens
- **Vision support** – Qwen Vision model for image analysis
- **OAuth authentication** – Simple login flow

## Prerequisites

- OpenClaw installed (see [VPS Setup](/blog/2026/02/24/openclaw-vps-setup/))
- Qwen Portal account (free at [portal.qwen.ai](https://portal.qwen.ai))

## Step 1: Install Qwen Portal Auth Skill

```bash
npm install -g openclaw  # already installed
openclaw plugins install @openclaw/qwen-portal-auth
openclaw plugins list
```

## Step 2: Authenticate with Qwen Portal

```bash
openclaw configure --section qwen-portal
```

This opens a browser OAuth flow and stores the token in `~/.openclaw/agents/<agent>/auth-profiles.json`.

## Step 3: Configure Qwen Models

Edit `~/.openclaw/openclaw.json`:

```json
{
  "models": {
    "providers": {
      "qwen-portal": {
        "baseUrl": "https://portal.qwen.ai/v1",
        "apiKey": "qwen-oauth",
        "api": "openai-completions",
        "models": [
          {
            "id": "coder-model",
            "name": "Qwen Coder",
            "reasoning": false,
            "input": ["text"],
            "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0},
            "contextWindow": 128000,
            "maxTokens": 8192
          },
          {
            "id": "vision-model",
            "name": "Qwen Vision",
            "reasoning": false,
            "input": ["text", "image"],
            "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0},
            "contextWindow": 128000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "qwen-portal/coder-model",
        "fallbacks": []
      }
    }
  }
}
```

## Step 4: Test the Configuration

```bash
# Test text model
openclaw agent --model qwen --message "Write a Python function to calculate fibonacci"

# Test vision model
openclaw agent --model qwen-vision --message "What's in this image?" --image ./screenshot.png
```

## Model Comparison

| Model | Context | Max Tokens | Input Types | Best For |
|-------|---------|------------|-------------|----------|
| `coder-model` | 128k | 8k | Text | Code, general tasks |
| `vision-model` | 128k | 8k | Text + Image | Image analysis, OCR |

## Cost Comparison

| Provider | Model | Cost per 1M tokens |
|----------|-------|--------------------|
| Qwen Portal | Coder | **Free** |
| Qwen Portal | Vision | **Free** |
| OpenAI | GPT-4.1 | ~$10–20 |
| Anthropic | Claude Sonnet | ~$3–15 |

## Using Qwen with Subagents

```json
{
  "agents": {
    "list": [
      { "id": "main", "model": "qwen-portal/coder-model" },
      { "id": "code-reviewer", "model": "qwen-portal/coder-model" }
    ]
  }
}
```

## Troubleshooting

```bash
# OAuth token expired – re-authenticate
openclaw configure --section qwen-portal

# Model not found – verify config
openclaw models list
cat ~/.openclaw/openclaw.json | jq '.models.providers.qwen-portal'
```

## Next Steps

- [OpenClaw Subagents](/blog/2026/02/24/openclaw-subagents/)
- [OpenClaw Model Fallback](/blog/2026/02/24/openclaw-fallback-models/)
