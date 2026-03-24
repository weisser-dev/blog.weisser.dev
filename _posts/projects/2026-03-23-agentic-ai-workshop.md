---
title: "Building an Interactive AI Agent Workshop with Vite and Vanilla JS"
date: 2026-03-23
categories:
  - ai
  - javascript
tags:
  - ai
  - agents
  - opencode
  - workshop
  - javascript
  - vite
repo: https://github.com/weisser-dev/agentic-ai-workshop
read_time: true
---

A few weeks ago I set out to build a complete, interactive workshop about AI Agents, LLMs, and AI-assisted coding — something that could be used both as a live presentation and as a self-guided learning resource. The result is [agentic-ai.weisser.dev](https://agentic-ai.weisser.dev), a bilingual (German/English) web application built entirely with Vite and Vanilla JavaScript. The interesting twist: the entire project was developed using OpenCode, an AI coding agent — which made it a kind of meta-exercise in the topic itself.

The application ships in two distinct modes. **Presenter mode** is designed for live workshops: it includes a full slide deck with keyboard navigation, a confetti cannon for celebratory moments, and a session timer to keep things on schedule. Slides are authored in plain HTML/JS with a custom layout system — no external presentation framework. **Self-paced mode** lets participants work through the material independently, complete with embedded quizzes, collapsible hints, and progress tracking stored in localStorage. Both modes share the same underlying content model, so updates to the material propagate everywhere automatically.

The design system is entirely custom — a dark-first palette with carefully chosen contrast ratios, consistent spacing tokens, and a set of utility classes that kept the CSS manageable without reaching for Tailwind or a component framework. Bilingual support was implemented as a simple key-value JSON structure with a language toggle. No i18n library was pulled in; given the scope, a few dozen strings per language, the overhead wasn't justified.

What made this project technically interesting was the challenge of building a presentation tool without a framework. State management — tracking the current slide, quiz answers, timer state — had to be done intentionally rather than delegated to React or Vue conventions. It forced clarity about what actually needs to be stateful versus what can just be re-rendered from the DOM. The build pipeline with Vite made the development experience fast despite the lack of a framework, with instant HMR and a clean production bundle.

The meta-story here is just as interesting as the technical one. The project was built almost entirely through conversations with OpenCode, an AI coding agent running in the terminal. Features were described in natural language, the agent wrote the code, and I reviewed and iterated. This workflow is exactly what the workshop teaches, so the process of building it was itself a live demonstration of the concepts. The final codebase is clean, well-structured, and doesn't show obvious signs of "AI-written spaghetti" — which I consider a meaningful data point about the maturity of agent-assisted development in 2026.
