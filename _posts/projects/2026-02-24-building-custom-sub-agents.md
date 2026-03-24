---
title: "Building Custom Sub-Agents for AI-Assisted Workflows"
date: 2026-02-24
categories:
  - ai
tags:
  - shell
  - ai-agents
  - automation
  - opencode
read_time: true
---

As AI coding agents have become part of my daily workflow, I've started building specialized sub-agents — focused, single-purpose agents that can be invoked by a parent orchestrator to handle specific tasks. The own-subagents project is a collection of these: Shell-based sub-agents designed for specific automation tasks that I run repeatedly in my development workflow.

The design philosophy for sub-agents is narrow scope and explicit I/O. A sub-agent should do one thing well: analyze a codebase for a specific pattern, generate a changelog from git history, validate a configuration file, or transform data from one format to another. The input is well-defined (usually JSON or plain text via stdin), the output is well-defined (JSON or formatted text to stdout), and the sub-agent has no side effects beyond what's explicitly in its spec. This makes them composable — the orchestrator can chain sub-agents, pass outputs between them, and handle errors at the orchestration level.

Shell is a pragmatic choice for sub-agents that primarily orchestrate other command-line tools. A sub-agent that needs to run git commands, call the OpenCode CLI, manipulate files, and pass data between steps can do all of this in a shell script with no additional runtime dependencies. The Shell environment's pipe-and-filter model aligns well with the sub-agent pattern: each tool in the pipeline is itself a form of sub-agent.

The most valuable thing I've learned from building multi-agent pipelines is that reliability depends on the quality of the handoffs between agents. An orchestrator that gives a sub-agent ambiguous instructions or an imprecise schema will get unpredictable results regardless of how capable the sub-agent is. Investing in precise, typed interfaces between agents — with validation at each handoff point — is the engineering work that makes multi-agent systems actually reliable rather than just theoretically possible.
