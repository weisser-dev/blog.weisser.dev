---
title: "awesome-opencode: 108 Agents, 15 Skills, and a 2-Minute Setup for OpenCode"
date: 2026-03-27
categories:
  - ai
  - tools
tags:
  - opencode
  - ai-agent
  - ai-agents
  - cli
  - open-source
  - automation
  - mcp
repo: https://github.com/weisser-dev/awesome-opencode
read_time: true
---

Setting up [OpenCode](https://opencode.ai) properly -- agents, skills, model configuration, MCP servers, project rules -- takes about 30 minutes if you read the docs and do it by hand. Or 2 minutes with one command:

```bash
npx @weisser-dev/awesome-opencode
```

[awesome-opencode](https://github.com/weisser-dev/awesome-opencode) is an interactive CLI tool and template collection that analyzes your project, recommends the right configuration, and generates everything OpenCode needs to work well with your stack. 108 agents across 10 categories, 15 skills, 18 curated MCP servers, smart model detection, and an auto-generated AGENTS.md -- all from a single `npx` command.

## Why this exists

OpenCode is powerful, but the configuration surface is large. You need to decide which agents to install, how to write skill definitions, which MCP servers to connect, how to assign models to different agent tiers, and what project rules to define in AGENTS.md. Most of this requires reading multiple documentation pages, and the result is that many teams either skip configuration entirely or set up a minimal config that doesn't take advantage of what OpenCode can do.

The specific problems I wanted to solve:

- **Agent discovery.** With 108 available agents across 10 categories, knowing which ones are relevant to a Terraform-heavy infrastructure project versus a React frontend is not obvious. The tool scans your project files (`.tf` maps to Terraform, `.rs` to Rust, and so on for 28 language/technology mappings) and recommends agents with reason tags explaining why -- `(Terraform (IaC))`, `(Docker / Containers)`, `(default)`.
- **Model optimization.** Using the same frontier model for every agent is expensive and unnecessary. A code-writing agent needs Opus or GPT-5.2, but a context manager or documentation agent runs fine on Haiku or Flash. Configuring this per agent manually is tedious. The tool detects your existing models, benchmarks them, and assigns the right tier automatically.
- **MCP server fragmentation.** MCP servers are scattered across [mcp.so](https://mcp.so), GitHub repositories, and the [official registry](https://registry.modelcontextprotocol.io). The tool curates 18 servers filtered by your project languages, plus live search against the official MCP Registry API.
- **AGENTS.md.** Project rules are one of the most impactful things you can configure, but writing them from scratch for every project is the kind of task that gets deferred forever.

## How it works

The CLI follows a linear flow that takes about two minutes:

**1. Language detection.** Auto-detects languages by scanning file extensions in your project root. You can also select manually for fresh projects with no files yet.

**2. Agent selection.** Presents all 108 agents organized by category -- Core Development, Language Specialists, Infrastructure, Quality & Security, Data & AI, Developer Experience, Specialized Domains, Business & Product, Meta & Orchestration, Research & Analysis. Agents recommended for your detected languages appear first with reason tags.

**3. Skill selection.** 15 skills covering common workflows: `git-release`, `pr-review`, `migration`, `test-patterns`, `deploy`, `dependency-audit`, `incident-postmortem`, `docker-optimize`, `adr-write`, `api-contract`, `changelog-generate`, `ci-pipeline`, `env-setup`, `error-triage`, `performance-profile`.

**4. Model strategy.** Reads your existing `opencode.json`, fingerprints every configured model (even through custom Bedrock or Azure provider prefixes like `eu.anthropic.claude-opus-4-6-v1`), shows coding benchmarks on a 0--100 scale and cost tiers from `$` to `$$$$$`, then offers to auto-optimize: frontier models for code-writing agents, strong models for review agents, fast models for context and exploration.

**5. MCP servers.** Curated list filtered by your languages, plus an optional live search against `registry.modelcontextprotocol.io` to find and configure any registered server.

**6. Step limits.** Optional per-agent step limits for cost control -- code-writing agents get unlimited steps, review agents get 10--15, fast agents get 5--10.

**7. Generation.** Writes `.opencode/agents/*.md`, `.opencode/skills/*/SKILL.md`, updates `opencode.json`, creates `.opencode/advanced.json` (state for re-runs), and generates `AGENTS.md` with project-specific rules.

On re-run, the tool detects the existing configuration and offers to start OpenCode directly or reconfigure.

## Model fingerprinting

The part I find most technically interesting is the model detection. LLM provider IDs rarely follow a consistent naming convention. If you use Amazon Bedrock, your model ID might be `abcd/eu.anthropic.claude-opus-4-6-v1`. Azure has its own format. Self-hosted endpoints use whatever the operator decided. But the tool still needs to know that this is Claude Opus 4 so it can look up the benchmark score and assign the right agent tier.

The solution is 26 model fingerprints -- regex patterns that extract the canonical model identity from any provider-prefixed ID. The fingerprinting covers Anthropic (Claude), OpenAI (GPT, o-series), Google (Gemini), DeepSeek, Meta (Llama), and Mistral. Each fingerprint maps to a tier (frontier, strong, fast), a cost bracket, and a coding benchmark score sourced from [pricepertoken.com](https://pricepertoken.com/leaderboards/coding).

The auto-optimize strategy then maps agent types to tiers:

| Agent type | Model tier | Step limit | Example |
|---|---|---|---|
| Code-writing, language specialists | Frontier | Unlimited | Opus, GPT-5.2, o3 |
| Code review, architecture, security | Strong | 10--15 | Sonnet, GPT-5.1 |
| Exploration, docs, context management | Fast | 5--10 | Haiku, Flash, mini |

This means you can run 20+ agents without paying frontier prices for all of them, while the agents that actually write and review code still get the best models available.

## The 108 agents

Every agent is a markdown file with YAML frontmatter defining the description, mode, model tier, temperature, permissions, and step limit. The categories:

- **Core Development** (8) -- API design, backend, frontend, fullstack, GraphQL, microservices, mobile, WebSocket
- **Language Specialists** (22) -- Angular through Vue, covering the major languages and frameworks with specialist knowledge
- **Infrastructure** (13) -- cloud architecture, Kubernetes, Terraform, Docker, SRE, incident response
- **Quality & Security** (11) -- code review, penetration testing, compliance, accessibility, chaos engineering
- **Data & AI** (12) -- data engineering, ML, LLM architecture, prompt engineering, NLP
- **Developer Experience** (11) -- build systems, CLI tools, documentation, refactoring, testing
- **Specialized Domains** (8) -- blockchain, embedded systems, fintech, game development, IoT
- **Business & Product** (9) -- product management, technical writing, UX research, scrum
- **Meta & Orchestration** (7) -- multi-agent coordination, context management, workflow automation
- **Research & Analysis** (7) -- competitive analysis, market research, trend forecasting

The agent collection is adapted from [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents), reworked for OpenCode's markdown agent format with permissions, skill integration, and tier assignments.

## Technical details

The CLI is pure ESM Node.js -- no TypeScript compilation, no build step. The core logic lives in a single `setup.js` file of about 1,800 lines. Agent and skill templates are plain markdown files stored in the repo's `templates/` directory, not embedded strings, which means they're easy to review, edit, and contribute to.

Dependencies are minimal: `@inquirer/prompts` for interactive selection, `chalk` for terminal colors, `ora` for spinners. A `prepublishOnly` script syncs templates from the repo root into the npm package before publishing. CI validates that the agent count stays at 108+, the skill count at 15+, templates are in sync, and syntax is correct.

## Getting started

```bash
npx @weisser-dev/awesome-opencode
```

That's it. If you want to install globally instead:

```bash
npm install -g @weisser-dev/awesome-opencode
awesome-opencode
```

For manual setup without the CLI -- copying individual agent and skill templates -- see the [README](https://github.com/weisser-dev/awesome-opencode#manual-setup-without-cli).

## Contributing

The project is MIT-licensed and welcomes contributions. The most useful additions right now are new agent templates (add a markdown file to `templates/agents/` and register it in `AVAILABLE_AGENTS` in `setup.js`), new skill definitions (add a `SKILL.md` to `templates/skills/<name>/` and register in `AVAILABLE_SKILLS`), model fingerprints for new providers, and MCP server recommendations.

## Credits

- [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) -- the 127+ agent collection that served as the primary inspiration, adapted for OpenCode's format
- [darrenhinde/OpenAgentsControl](https://github.com/darrenhinde/OpenAgentsControl) -- agent configuration patterns
- [OpenCode Docs](https://opencode.ai/docs/) -- agents, skills, MCP, permissions, and configuration reference
- [pricepertoken.com](https://pricepertoken.com/leaderboards/coding) -- model benchmark rankings and pricing data
- [registry.modelcontextprotocol.io](https://registry.modelcontextprotocol.io) -- official MCP server registry API
- [mcp.so](https://mcp.so) -- community MCP server directory
