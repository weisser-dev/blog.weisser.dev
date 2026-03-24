---
title: "OpenClaw Subagents Guide"
date: 2026-02-24
categories:
  - openclaw
tags:
  - openclaw
  - subagents
  - multi-agent
  - orchestration
  - ai-agents
read_time: true
excerpt: "Complete guide to using OpenClaw subagents for specialized tasks and multi-agent orchestration – architecture, routing, lifecycle and best practices."
---

Subagents allow you to spawn specialized AI agents for specific tasks, enabling better context management and task separation.

## What are Subagents?

Subagents are isolated agent sessions with their own:
- **Workspace** – Separate file context
- **Model** – Can use different models than the main agent
- **Memory** – Independent conversation history
- **Tools** – Same tool access as main agent

## When to Use Subagents

| Scenario | Use Subagent? | Why |
|----------|---------------|-----|
| Quick question | No | Main agent is faster |
| Complex coding task (>20 min) | Yes | Isolated context, parallel execution |
| Multi-file refactoring | Yes | Focused workspace |
| Background monitoring | Yes | Runs independently |
| Specialized domain (e.g., food tracking) | Yes | Domain-specific knowledge |

## Recommended Project Structure

```
own-subagents/
├── global/                    # Reusable subagent definitions
│   ├── frontend-builder.md
│   ├── backend-builder.md
│   ├── test-writer.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   └── meal-screenshot-intake.md
├── runtime-workspaces/        # Active agent workspaces (auto-generated)
└── workspace/
    └── AGENTS.md
```

## Creating Subagents

### Via CLI

```bash
openclaw agents add backend-builder \
  --workspace /root/.openclaw/workspace/own-subagents/runtime-workspaces/backend-builder
```

### Example Subagent Definition

```markdown
# backend-builder

## Purpose
Implements API, data model, and business logic changes.

## Inputs
- Endpoint/feature description
- Data model constraints
- Security requirements

## Outputs
- Implementation + validation
- Tests/smoke checks
- Migration/compatibility notes

## Boundaries
- No secret exposure
- No destructive DB operations without approval

## Definition of Done
- Relevant tests green
- Input validation present
- Error cases handled sensibly
```

## Routing Strategy

### Task Classification Matrix

| Task | Agent |
|------|-------|
| Fix login bug in health-tracker | `backend-builder` |
| Write E2E tests | `test-writer` |
| Food screenshot intake | `meal-screenshot-intake` |
| Security review | `security-reviewer` |

## Using Subagents in Practice

```bash
# Spawn a backend subagent
openclaw sessions spawn \
  --agent-id backend-builder \
  --task "Implement user registration endpoint with email verification" \
  --mode session \
  --label "user-auth-feature"

# One-shot task (auto-terminates after completion)
openclaw sessions spawn \
  --agent-id code-reviewer \
  --task "Review PR #42 for security issues" \
  --mode run \
  --label "pr-42-review"
```

## Managing Subagents

```bash
# List active subagents
openclaw sessions list --kinds subagent

# Send message to running subagent
openclaw sessions send --session-key <key> --message "Prioritize login endpoint"

# Kill subagent
openclaw subagents kill --target backend-builder

# View logs
openclaw logs --session <session-key> --follow
```

## Subagent Lifecycle

```
Main Agent
    │ spawn
    ▼
Subagent (isolated)
    │ complete
    ▼
Result pushed to Main
```

## Advanced: Orchestrator Pattern

```
User: "Build a complete user auth system"

Main Agent:
  1. spawn product-owner      → Define requirements
  2. spawn software-architect → Design architecture
  3. spawn backend-builder    → Implement API
  4. spawn test-writer        → Write tests
  5. spawn security-reviewer  → Security audit
  6. Synthesize → Present to user
```

## Model Assignment per Subagent

```json
{
  "agents": {
    "list": [
      {
        "id": "code-reviewer",
        "model": "openai-codex/gpt-5.3-codex"
      },
      {
        "id": "meal-screenshot-intake",
        "model": "qwen-portal/vision-model"
      }
    ]
  }
}
```

## Best Practices

1. **Clear task definitions** – Be explicit about inputs, outputs and scope
2. **Set explicit timeouts** – `--timeout-seconds 3600`
3. **Use labels for tracking** – `--label "feature-user-auth"`
4. **Clean up after completion** – `--cleanup delete`
5. **Match models to tasks** – Vision tasks need vision models, code reviews benefit from high-quality models

## Troubleshooting

```bash
# Subagent won't start – check if it exists
openclaw agents list

# Stuck subagent – kill and retry
openclaw subagents kill --target <agent-id>

# Results not returned – verify mode=run for one-shot tasks
```

## Next Steps

- [OpenClaw VPS Setup](/blog/2026/02/24/openclaw-vps-setup/)
- [OpenClaw Model Fallback](/blog/2026/02/24/openclaw-fallback-models/)
