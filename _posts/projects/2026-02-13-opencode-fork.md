---
title: "Forking OpenCode: How Terminal-Based AI Coding Agents Work"
date: 2026-02-13
categories:
  - ai
  - typescript
tags:
  - opencode
  - ai-agent
  - typescript
  - open-source
repo: https://github.com/weisser-dev/opencode
read_time: true
---

OpenCode is an open-source AI coding agent that runs in your terminal. Unlike IDE plugins or browser-based tools, it operates directly on your filesystem, reads your code, and uses tool calls — file reads, writes, shell execution, grep — to complete tasks autonomously. When I discovered the project, I forked it to experiment with modifications and to better understand how it works from the inside.

The architecture of a terminal-based coding agent is worth understanding. At its core, it's a loop: receive a task, reason about the next step, call a tool, observe the result, repeat until done. The "tools" are just functions the model is allowed to invoke — read a file, write a file, run a shell command, search for a pattern. The model decides which tools to call and in what order. The TypeScript codebase is clean and well-structured, which makes it a good project to learn from if you're curious about agent implementation details.

What makes OpenCode interesting compared to similar tools is the focus on transparency and control. Every tool call is visible in the terminal, every file change is tracked, and the agent explains its reasoning as it works. This makes it much easier to catch mistakes and course-correct than tools that operate more opaquely. The conversation history also stays local — no data is sent to a third-party service beyond the API calls to the LLM provider you configure.

My fork is primarily a place to experiment — testing prompt modifications, adding tools, exploring how the agent handles edge cases. If you're interested in AI agent internals or want a coding assistant that runs entirely in your terminal without a GUI, OpenCode is worth looking at. The TypeScript codebase is approachable and the project is actively developed.
