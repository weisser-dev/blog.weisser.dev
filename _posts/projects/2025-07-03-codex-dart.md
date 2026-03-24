---
title: "Codex Dart: Building a Game 100% with OpenAI Codex"
date: 2025-07-03
categories:
  - ai
  - javascript
tags:
  - ai
  - codex
  - javascript
  - experiment
repo: https://github.com/weisser-dev/codex-dart
read_time: true
---

Back in mid-2025, before AI coding agents became a routine part of my workflow, I ran an experiment: build a complete dart game from scratch using nothing but OpenAI Codex, without writing a single line of code myself. No edits, no manual fixes — pure output from the model. The result was illuminating, both for what worked and for what didn't.

The dart game itself is a browser-based implementation of 501 — two players, countdown scoring, checkout detection. Codex produced a working game in a surprisingly short number of iterations. The basic game loop, the scoring logic, and the UI structure came out coherently on the first few passes. Where things got complicated was in the details: the checkout detection logic had subtle bugs that Codex kept fixing in ways that introduced new edge cases, and getting the UI layout to feel right required more back-and-forth than I expected.

The biggest limitation I ran into was context. Codex in 2025 had a much smaller effective context window than modern agents, which meant that once the codebase grew past a certain size, later edits would sometimes break earlier functionality. Modern AI coding agents solve this with explicit file reads and a more structured tool-use approach — they don't just "know" the code, they actively re-read it before editing. That architectural difference turns out to matter enormously for larger tasks.

Looking at this experiment from the perspective of early 2026, it feels like a snapshot of an early era in AI-assisted development. The raw capability was already there in 2025 — Codex could clearly write functional JavaScript. But the workflow was clunky: copy-paste from a web UI, apply changes manually, hope the model hadn't forgotten what it wrote earlier. Compare that to OpenCode running natively in the terminal with full filesystem access, and the difference is night and day. The game still works, though. That part aged well.
